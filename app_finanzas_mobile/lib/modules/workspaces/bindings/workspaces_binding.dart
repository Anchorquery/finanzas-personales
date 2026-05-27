import 'package:get/get.dart';
import '../controllers/workspaces_controller.dart';

class WorkspacesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkspacesController>(() => WorkspacesController());
  }
}
