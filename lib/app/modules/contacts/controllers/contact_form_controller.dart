import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:contacts_service/contacts_service.dart';
import '../../../services/call_service.dart';
import '../controllers/contacts_controller.dart';

class ContactFormController extends GetxController {
  final CallService _callService = Get.find();
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final phoneControllers = <TextEditingController>[TextEditingController()].obs;

  final isEditing = false.obs;
  Contact? contactToEdit;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is Contact) {
        // Editing existing contact
        contactToEdit = Get.arguments as Contact;
        isEditing.value = true;
        _loadContactData();
      } else if (Get.arguments is Map<String, dynamic>) {
        // New contact with pre-filled phone number
        final args = Get.arguments as Map<String, dynamic>;
        if (args.containsKey('phone')) {
          phoneControllers.first.text = args['phone'] as String;
        }
      }
    }
  }

  void _loadContactData() {
    if (contactToEdit == null) return;

    firstNameController.text = contactToEdit!.givenName ?? '';
    lastNameController.text = contactToEdit!.familyName ?? '';
    emailController.text = contactToEdit!.emails?.firstOrNull?.value ?? '';
    companyController.text = contactToEdit!.company ?? '';

    // Load phone numbers
    phoneControllers.clear();
    if (contactToEdit!.phones != null && contactToEdit!.phones!.isNotEmpty) {
      for (var phone in contactToEdit!.phones!) {
        phoneControllers.add(TextEditingController(text: phone.value));
      }
    } else {
      phoneControllers.add(TextEditingController());
    }
  }

  void addPhoneField() {
    phoneControllers.add(TextEditingController());
  }

  void removePhoneField(int index) {
    if (index < phoneControllers.length) {
      phoneControllers[index].dispose();
      phoneControllers.removeAt(index);
    }
  }

  Future<void> pickImage() async {
    // TODO: Implement image picking functionality
    Get.snackbar(
      'Coming Soon',
      'Profile picture functionality will be added soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> saveContact() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      final phones = phoneControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => Item(value: controller.text))
          .toList();

      final emails = emailController.text.isNotEmpty
          ? [Item(value: emailController.text)]
          : null;

      if (isEditing.value && contactToEdit != null) {
        // Update existing contact
        contactToEdit!.givenName = firstNameController.text;
        contactToEdit!.familyName = lastNameController.text;
        contactToEdit!.emails = emails;
        contactToEdit!.company = companyController.text;
        contactToEdit!.phones = phones;

        await ContactsService.updateContact(contactToEdit!);
      } else {
        // Create new contact
        final newContact = Contact(
          givenName: firstNameController.text,
          familyName: lastNameController.text,
          emails: emails,
          company: companyController.text,
          phones: phones,
        );
        await ContactsService.addContact(newContact);
      }

      // Give more time for the system to process the change
      await Future.delayed(const Duration(seconds: 1));

      // Force refresh contacts
      await _callService.initialize();
      final contactsController = Get.find<ContactsController>();
      await contactsController.refreshContacts();
      contactsController.clearSearch();

      Get.back(result: true);
      Get.snackbar(
        'Success',
        isEditing.value
            ? 'Contact updated successfully'
            : 'Contact added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error saving contact: $e');
      Get.snackbar(
        'Error',
        'Failed to ${isEditing.value ? 'update' : 'add'} contact: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    companyController.dispose();
    for (var controller in phoneControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
