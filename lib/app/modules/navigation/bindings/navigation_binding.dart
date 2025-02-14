import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../../dialpad/bindings/dialpad_binding.dart';
import '../../history/bindings/history_binding.dart';
import '../../contacts/bindings/contacts_binding.dart';
import '../../../services/block_service.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure BlockService is initialized
    if (!Get.isRegistered<BlockService>()) {
      Get.put(BlockService());
    }

    Get.lazyPut<NavigationController>(() => NavigationController());

    // Initialize all module bindings
    DialpadBinding().dependencies();
    HistoryBinding().dependencies();
    ContactsBinding().dependencies();
  }
}
