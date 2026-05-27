import 'package:get/get.dart';
import '../controllers/expenses_controller.dart';
import '../controllers/transaction_items_controller.dart';

class ExpensesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpensesController>(() => ExpensesController());
    Get.lazyPut<TransactionItemsController>(() => TransactionItemsController());
  }
}
