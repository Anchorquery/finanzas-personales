import 'package:get/get.dart';
import '../controllers/incomes_controller.dart';
import '../controllers/add_income_controller.dart';

class IncomesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomesController>(() => IncomesController());
    Get.lazyPut<AddIncomeController>(() => AddIncomeController());
  }
}
