import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/models/finance/transaction_template.dart';
import '../../../data/services/directus_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';

/// Persists per-workspace transaction templates in GetStorage (local).
class TemplatesController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspaces = Get.find();
  final GetStorage _store = GetStorage();

  final templates = <TransactionTemplate>[].obs;

  static const _storageKey = 'tx_templates_v1';

  String? get _wsId => _workspaces.activeWorkspace?.id;

  @override
  void onInit() {
    super.onInit();
    _load();
    ever(_workspaces.activeWorkspaceRx, (_) => _load());
  }

  void _load() {
    final wsId = _wsId;
    if (wsId == null) {
      templates.clear();
      return;
    }
    final raw = _store.read<List>(_storageKey) ?? const [];
    final all = raw
        .map((e) => TransactionTemplate.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final filtered = all.where((t) => t.workspaceId == wsId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    templates.assignAll(filtered);
  }

  void _persist() {
    // Merge templates of other workspaces + current → write all back.
    final raw = _store.read<List>(_storageKey) ?? const [];
    final others = raw
        .map((e) => TransactionTemplate.fromJson(Map<String, dynamic>.from(e)))
        .where((t) => t.workspaceId != _wsId)
        .toList();
    final all = [...others, ...templates];
    _store.write(_storageKey, all.map((t) => t.toJson()).toList());
  }

  Future<void> add(TransactionTemplate t) async {
    templates.add(t);
    _persist();
  }

  Future<void> remove(String id) async {
    templates.removeWhere((t) => t.id == id);
    _persist();
  }

  Future<void> updateTemplate(TransactionTemplate updated) async {
    final i = templates.indexWhere((t) => t.id == updated.id);
    if (i == -1) return;
    templates[i] = updated;
    _persist();
  }

  /// Generates a unique id derived from the timestamp and a short random tail.
  static String newId() {
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final rand = (ts.hashCode & 0xffff).toRadixString(36);
    return 't_${ts}_$rand';
  }

  /// Records the template as a new transaction immediately.
  /// Returns true on success.
  Future<bool> quickRegister(TransactionTemplate t) async {
    final wsId = _wsId;
    if (wsId == null) return false;
    try {
      String? categoryId = t.categoryId;
      // Fallback: look up by name if id missing or stale
      if (categoryId == null && t.categoryName != null) {
        final cats =
            await _directusService.getCategories(workspaceId: wsId);
        categoryId = cats
            .firstWhereOrNull(
              (c) =>
                  c.name.toLowerCase() == t.categoryName!.toLowerCase(),
            )
            ?.id;
      }
      if (categoryId == null || categoryId.isEmpty) {
        SnackbarService.showError(
            'Error', 'Plantilla sin categoría válida.');
        return false;
      }

      await _directusService.createTransaction(
        amount: t.amount,
        concept: t.concept ?? t.label,
        date: DateTime.now().toIso8601String().substring(0, 10),
        type: t.type,
        categoryId: categoryId,
        workspaceId: wsId,
      );
      _directusService.notifyDataChanged();
      SnackbarService.showSuccess(
        'Registrado',
        '${t.type == 'income' ? 'Ingreso' : 'Gasto'} \$${t.amount.toStringAsFixed(2)} — ${t.label}',
      );
      return true;
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo registrar: $e');
      return false;
    }
  }

  /// Helper for tests / external callers — serialize storage as JSON.
  String exportRaw() => jsonEncode(templates.map((t) => t.toJson()).toList());
}
