import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/directus_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/theme/app_theme.dart';
import 'package:app_finanzas_mobile/modules/workspaces/controllers/workspaces_controller.dart';

class EventsController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController =
      Get.find<WorkspacesController>();

  final events = <Event>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
    ever(_workspacesController.activeWorkspaceRx, (_) => loadEvents());
    ever(_directusService.dataVersion, (_) => loadEvents());
  }

  Future<void> loadEvents() async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) {
      events.clear();
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      final data = await _directusService.getEvents(workspaceId: workspaceId);
      events.assignAll(data);
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudieron cargar los eventos');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createEvent(
    String name,
    String description,
    DateTime start,
    DateTime end,
    double budget,
  ) async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) return;

    try {
      await _directusService.createEvent(
        name: name,
        description: description,
        startDate: start.toIso8601String().split('T')[0],
        endDate: end.toIso8601String().split('T')[0],
        budget: budget,
        workspaceId: workspaceId,
      );
      Get.back();
      _directusService.notifyDataChanged();
      loadEvents();
      SnackbarService.showSuccess('Éxito', 'Evento creado');
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo crear el evento: $e');
    }
  }

  Future<void> editEvent(Event event) async {
    final nameCtrl = TextEditingController(text: event.name);
    final descCtrl = TextEditingController(text: event.description);

    try {
      await Get.dialog(
        AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text('Editar Evento',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Get.back();
                try {
                  await _directusService.updateEvent(event.id, {
                    'name': name,
                    'description': descCtrl.text.trim(),
                  });
                  _directusService.notifyDataChanged();
                  loadEvents();
                  SnackbarService.showSuccess('Éxito', 'Evento actualizado');
                } catch (e) {
                  SnackbarService.showError(
                      'Error', 'No se pudo actualizar: $e');
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      );
    } finally {
      nameCtrl.dispose();
      descCtrl.dispose();
    }
  }

  Future<void> deleteEvent(Event event) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Eliminar Evento',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar "${event.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _directusService.deleteEvent(event.id);
      _directusService.notifyDataChanged();
      loadEvents();
      SnackbarService.showSuccess('Éxito', 'Evento eliminado');
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo eliminar: $e');
    }
  }
}
