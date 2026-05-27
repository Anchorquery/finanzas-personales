import 'package:get/get.dart';
import '../controllers/scan_receipt_controller.dart';

class ScanReceiptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanReceiptController>(() => ScanReceiptController());
  }
}
