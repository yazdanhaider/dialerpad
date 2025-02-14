import 'package:get/get.dart';
import '../../../services/call_service.dart';
import '../../../services/country_service.dart';
import 'package:country_picker/country_picker.dart' as picker;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:contacts_service/contacts_service.dart';
import '../../../routes/app_routes.dart';

class DialpadController extends GetxController {
  final CallService _callService = Get.find();
  final CountryService _countryService = Get.find();
  var inputNumber = ''.obs;
  var callState = ''.obs;
  final scrollController = ScrollController();

  String get displayNumber =>
      _countryService.getDisplayNumber(inputNumber.value);
  picker.Country? get selectedCountry => _countryService.selectedCountry.value;

  @override
  void onInit() {
    super.onInit();
    ever(_callService.callStateStream, (state) {
      callState.value = state.toString();
    });
  }

  void addNumber(String number) {
    inputNumber.value += number;
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 50), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void removeNumber() {
    if (inputNumber.value.isNotEmpty) {
      inputNumber.value =
          inputNumber.value.substring(0, inputNumber.value.length - 1);
    }
  }

  void clearNumber() {
    if (inputNumber.isNotEmpty) {
      inputNumber.value =
          inputNumber.value.substring(0, inputNumber.value.length - 1);
      HapticFeedback.lightImpact();
    }
  }

  void showCountryPicker(BuildContext context) {
    picker.showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (picker.Country country) {
        _countryService.updateCountry(country);
      },
    );
  }

  Future<void> makeCall() async {
    if (inputNumber.value.isEmpty) {
      Get.snackbar('Error', 'Please enter a number');
      return;
    }
    final formattedNumber = _countryService.formatNumber(inputNumber.value);
    try {
      await _callService.makeCall(formattedNumber);
      inputNumber.value = ''; // Clear number after successful call
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to make call: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addNumberToContacts() async {
    if (inputNumber.value.isEmpty) return;

    final formattedNumber = _countryService.formatNumber(inputNumber.value);

    try {
      // Show contact form with pre-filled number
      final result = await Get.dialog(
        AlertDialog(
          title: const Text('Add to Contacts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Create New Contact'),
                onTap: () {
                  Get.back(result: 'new');
                },
              ),
              if (await _callService.contacts.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Add to Existing Contact'),
                  onTap: () {
                    Get.back(result: 'existing');
                  },
                ),
            ],
          ),
        ),
      );

      if (result == 'new') {
        // Pass phone number as a map instead of Contact object
        Get.toNamed(Routes.CONTACT_FORM, arguments: {'phone': formattedNumber});
      } else if (result == 'existing') {
        // TODO: Implement add to existing contact
        Get.snackbar(
          'Coming Soon',
          'Add to existing contact will be available soon',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error in addNumberToContacts: $e');
      Get.snackbar(
        'Error',
        'Failed to proceed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Long press on 0 to add +
  void onZeroLongPress() {
    if (!inputNumber.value.startsWith('+')) {
      inputNumber.value = '+${inputNumber.value}';
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
