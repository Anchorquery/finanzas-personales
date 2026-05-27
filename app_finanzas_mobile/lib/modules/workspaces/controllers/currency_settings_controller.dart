import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/exchange_rate.dart';
import '../../../data/models/workspace.dart';
import '../../workspaces/controllers/workspace_settings_controller.dart';
import '../../../data/services/exchange_rate_service.dart';
import '../../../core/utils/snackbar_service.dart';

class CurrencySettingsController extends GetxController {
  final ExchangeRateService _exchangeRateService =
      Get.find<ExchangeRateService>();

  final selectedProvider = ExchangeRateProvider.manual.obs;
  final manualRateController = TextEditingController();
  final currentRates = <ExchangeRateProvider, ExchangeRate>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRates();
    _loadWorkspaceSettings();
  }

  void _loadWorkspaceSettings() {
    final Workspace? ws = Get.arguments as Workspace?;
    if (ws != null) {
      final mode = ExchangeRateProvider.values.firstWhere(
        (e) => e.name == ws.exchangeRateMode,
        orElse: () => ExchangeRateProvider.manual,
      );
      setProvider(mode);

      if (mode == ExchangeRateProvider.manual) {
        manualRateController.text = ws.manualExchangeRate.toString();
      }
    }
  }

  Future<void> _loadRates() async {
    isLoading.value = true;
    await _exchangeRateService.fetchAllRates();
    currentRates.assignAll(_exchangeRateService.currentRates);
    isLoading.value = false;
  }

  void setProvider(ExchangeRateProvider provider) {
    selectedProvider.value = provider;
  }

  double get effectiveRate {
    if (selectedProvider.value == ExchangeRateProvider.manual) {
      return double.tryParse(manualRateController.text.replaceAll(',', '.')) ??
          0.0;
    }
    return currentRates[selectedProvider.value]?.rate ?? 0.0;
  }

  @override
  void onClose() {
    manualRateController.dispose();
    super.onClose();
  }

  Future<void> saveSettings() async {
    if (effectiveRate <= 0) {
      SnackbarService.showError(
        'Error',
        'La tasa de cambio debe ser mayor a 0',
      );
      return;
    }

    final Workspace? ws = Get.arguments as Workspace?;
    if (ws == null) return;

    try {
      final settingsController = Get.find<WorkspaceSettingsController>();

      await settingsController.updateWorkspace({
        'exchange_rate_mode': selectedProvider.value.name,
        'manual_exchange_rate':
            double.tryParse(manualRateController.text.replaceAll(',', '.')) ??
            0.0,
      });

      Get.back();
      SnackbarService.showSuccess(
        'Guardado',
        'Configuración de moneda actualizada',
      );
    } catch (e) {
      SnackbarService.showError(
        'Error',
        'No se pudo guardar la configuración: $e',
      );
    }
  }
}
