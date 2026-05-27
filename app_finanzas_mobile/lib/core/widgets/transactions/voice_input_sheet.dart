import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../data/services/directus_service.dart';
import '../../../data/services/voice_input_service.dart';
import '../../../modules/transactions/controllers/transactions_controller.dart';

/// Bottom sheet to dictate a transaction. Captures voice, transcribes,
/// asks Gemini to parse, and pre-fills [TransactionsController].
class VoiceInputSheet extends StatefulWidget {
  const VoiceInputSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => const VoiceInputSheet(),
    );
  }

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet> {
  final VoiceInputService _voice = Get.find<VoiceInputService>();
  bool _parsing = false;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final ok = await _voice.ensureInitialized();
    if (!ok && mounted) {
      SnackbarService.showError('Voz', _voice.lastError.value.isNotEmpty
          ? _voice.lastError.value
          : 'No se pudo activar el micrófono.');
    }
    _apiKey = await _fetchApiKey();
  }

  Future<String?> _fetchApiKey() async {
    try {
      final ds = Get.find<DirectusService>();
      final org = await ds.getOrganization();
      if (org == null) return null;
      final settings = await ds.getOrganizationSettings(org.id);
      return settings?['gemini_api_key'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _voice.stop();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_voice.isListening.value) {
      await _voice.stop();
      await _process();
    } else {
      await _voice.start();
    }
  }

  Future<void> _process() async {
    final text = _voice.transcript.value.trim();
    if (text.isEmpty) return;
    if (_apiKey == null || _apiKey!.isEmpty) {
      SnackbarService.showError(
          'Error', 'API key de Gemini no configurada.');
      return;
    }
    setState(() => _parsing = true);
    try {
      final parsed = await _voice.parseWithGemini(
        apiKey: _apiKey!,
        text: text,
      );
      if (!mounted) return;
      if (parsed == null) {
        SnackbarService.showWarning(
            'Voz', 'No pude entender un monto. Intenta otra vez.');
        return;
      }
      _applyToController(parsed);
      Get.back();
      SnackbarService.showSuccess(
        'Voz',
        'Transacción pre-llenada: ${parsed.type == 'income' ? 'Ingreso' : 'Gasto'} \$${parsed.amount.toStringAsFixed(2)}',
      );
    } finally {
      if (mounted) setState(() => _parsing = false);
    }
  }

  void _applyToController(ParsedVoiceTransaction p) {
    if (!Get.isRegistered<TransactionsController>()) return;
    final c = Get.find<TransactionsController>();
    c.amountString.value = p.amount.toString();
    c.selectedType.value = p.type;
    if (p.concept != null && p.concept!.isNotEmpty) {
      c.note.value = p.concept!;
    }
    if (p.dateIso != null) {
      final d = DateTime.tryParse(p.dateIso!);
      if (d != null) c.selectedDate.value = d;
    }
    if (p.categoryHint != null) {
      final match = c.categories.firstWhereOrNull(
        (cat) => cat.name.toLowerCase() == p.categoryHint!.toLowerCase(),
      );
      if (match != null) c.selectedCategoryId.value = match.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 40,
            height: 4,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Dictar transacción',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ejemplo: "Gasté 50 dólares en gasolina ayer"',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Obx(() => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(minHeight: 80),
                child: Text(
                  _voice.transcript.value.isEmpty
                      ? (_voice.isListening.value
                          ? 'Escuchando…'
                          : 'Toca el micrófono para empezar')
                      : _voice.transcript.value,
                  style: TextStyle(
                    color: _voice.transcript.value.isEmpty
                        ? Colors.white38
                        : Colors.white,
                    fontSize: 16,
                  ),
                ),
              )),
          const SizedBox(height: 24),
          Obx(() {
            final listening = _voice.isListening.value;
            return GestureDetector(
              onTap: _parsing ? null : _toggle,
              child: Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: listening
                      ? Colors.redAccent.withValues(alpha: 0.85)
                      : AppTheme.accentAI,
                  boxShadow: [
                    BoxShadow(
                      color: (listening ? Colors.redAccent : AppTheme.accentAI)
                          .withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: listening ? 6 : 0,
                    ),
                  ],
                ),
                child: _parsing
                    ? const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                      )
                    : Icon(
                        listening ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Obx(() => Text(
                _voice.isListening.value
                    ? 'Toca de nuevo para procesar'
                    : (_voice.transcript.value.isEmpty
                        ? 'Mantén micrófono cerca'
                        : 'Procesando con IA…'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
