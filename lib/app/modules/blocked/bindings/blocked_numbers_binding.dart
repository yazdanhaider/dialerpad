import 'package:get/get.dart';
import '../controllers/blocked_numbers_controller.dart';

class BlockedNumbersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlockedNumbersController>(() => BlockedNumbersController());
  }
}
