import 'package:get/get.dart';
import '../controllers/ai_coach_controller.dart';

class AICoachBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AICoachController>(() => AICoachController());
  }
}
