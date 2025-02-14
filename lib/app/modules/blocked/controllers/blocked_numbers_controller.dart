import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/block_service.dart';
import '../../../services/call_service.dart';
import 'package:contacts_service/contacts_service.dart';

class BlockedNumbersController extends GetxController {
  final BlockService _blockService = Get.find();
  final CallService _callService = Get.find();
  final numberController = TextEditingController();
  final searchController = TextEditingController();
  final searchResults = <Contact>[].obs;
  final isSearching = false.obs;

  List<String> get blockedNumbers => _blockService.blockedNumbers;

  Contact? getContactForNumber(String number) {
    return _callService.contacts.firstWhereOrNull((contact) =>
        contact.phones?.any((phone) =>
            phone.value?.replaceAll(RegExp(r'[^\d+]'), '') ==
            number.replaceAll(RegExp(r'[^\d+]'), '')) ??
        false);
  }

  void addBlockedNumber() {
    final number = numberController.text.trim();
    if (number.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _blockService.blockNumber(number);
    numberController.clear();
  }

  void unblockNumber(String number) {
    _blockService.unblockNumber(number);
  }

  void searchContacts(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    final cleanQuery = query.toLowerCase().replaceAll(RegExp(r'[^\d\w]'), '');

    searchResults.value = _callService.contacts.where((contact) {
      // Search by name
      final name = contact.displayName?.toLowerCase() ?? '';
      if (name.contains(cleanQuery)) return true;

      // Search by number
      return contact.phones?.any((phone) {
            final cleanNumber =
                phone.value?.replaceAll(RegExp(r'[^\d+]'), '') ?? '';
            return cleanNumber.contains(cleanQuery);
          }) ??
          false;
    }).toList();
  }

  void blockContact(Contact contact) {
    final number = contact.phones?.first.value;
    if (number != null) {
      _blockService.blockNumber(number);
      searchController.clear();
      searchResults.clear();
      isSearching.value = false;
    }
  }

  bool isNumberBlocked(String number) {
    return _blockService.isBlocked(number);
  }

  @override
  void onClose() {
    numberController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
