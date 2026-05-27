import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/settings_controller.dart';

class AISettingsView extends StatefulWidget {
  const AISettingsView({super.key});

  @override
  State<AISettingsView> createState() => _AISettingsViewState();
}

class _AISettingsViewState extends State<AISettingsView> {
  late final SettingsController controller;
  late final TextEditingController _keyCtrl;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SettingsController>();
    _keyCtrl = TextEditingController(text: controller.apiKey.value);
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header consistente con el resto de la app
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      AppL10n.of(context).aiSettingsTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner informativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAI.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.accentAI.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome, color: AppTheme.accentAI, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Conecta tu propia API Key de Google Gemini para habilitar el Coach Financiero y el escaneo de recibos con IA.',
                              style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Toggle habilitar AI
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF111422),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Obx(() => SwitchListTile(
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.smart_toy_rounded, color: AppTheme.accentAI, size: 20),
                            ),
                            title: const Text(
                              'Habilitar funciones AI',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            subtitle: const Text(
                              'Coach financiero y escaneo de recibos',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            value: controller.aiEnabled.value,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.accentAI,
                            inactiveTrackColor: const Color(0xFF1E293B),
                            onChanged: (val) => controller.aiEnabled.value = val,
                          )),
                    ),
                    const SizedBox(height: 24),

                    // Campo API Key
                    const Text(
                      'GEMINI API KEY',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _keyCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'AIza...',
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: const Color(0xFF111422),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.accentAI),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: Colors.white38,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.link_rounded, size: 13, color: Colors.white24),
                        const SizedBox(width: 6),
                        Text(
                          'Obtén tu key en aistudio.google.com',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Botón guardar
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => controller.saveAISettings(
                          _keyCtrl.text,
                          controller.aiEnabled.value,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Guardar configuración',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
