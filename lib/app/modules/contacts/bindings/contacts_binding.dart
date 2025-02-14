import 'package:get/get.dart';
import '../controllers/contacts_controller.dart';
import '../../../services/google_contacts_service.dart';

class ContactsBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize GoogleContactsService
    if (!Get.isRegistered<GoogleContactsService>()) {
      Get.put(GoogleContactsService());
    }

    Get.lazyPut<ContactsController>(() => ContactsController());
  }
}
