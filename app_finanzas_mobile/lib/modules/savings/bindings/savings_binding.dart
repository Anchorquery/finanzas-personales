import 'package:get/get.dart';
import '../controllers/savings_controller.dart';

class SavingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SavingsController>(() => SavingsController());
  }
}
