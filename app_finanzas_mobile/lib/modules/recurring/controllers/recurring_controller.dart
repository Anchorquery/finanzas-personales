import 'package:get/get.dart';
import '../../../data/services/directus_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';

class RecurringController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController = Get.find<WorkspacesController>();
  final recurringItems = <Subscription>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecurring();
    ever(_workspacesController.activeWorkspaceRx, (_) => loadRecurring());
    ever(_directusService.dataVersion, (_) => loadRecurring());
  }

  Future<void> loadRecurring() async {
    try {
      isLoading.value = true;
      final list = await _directusService.getSubscriptions(
        workspaceId: _workspacesController.activeWorkspace?.id,
      );
      recurringItems.assignAll(list);
    } catch (e) {
      SnackbarService.showError("Error", "Error cargando recurrentes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> payItem(String name, double amount) async {
    try {
      await _directusService.payRecurring(name, amount);
      _directusService.notifyDataChanged();
      loadRecurring();
      SnackbarService.showSuccess(
        "Pago Registrado",
        "Se creó el gasto de $name por \$$amount",
      );
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo registrar el pago: $e");
    }
  }
}
