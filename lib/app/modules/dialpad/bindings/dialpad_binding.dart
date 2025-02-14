import 'package:get/get.dart';
import '../controllers/dialpad_controller.dart';
import '../../../services/call_service.dart';
import '../../../services/country_service.dart';

class DialpadBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure required services are initialized
    if (!Get.isRegistered<CallService>()) {
      Get.put(CallService());
    }
    if (!Get.isRegistered<CountryService>()) {
      Get.put(CountryService());
    }

    Get.lazyPut<DialpadController>(() => DialpadController());
  }
}
