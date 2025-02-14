import 'package:get/get.dart';
import 'package:contacts_service/contacts_service.dart';
import '../../../services/call_service.dart';
import '../../../services/google_contacts_service.dart';
import 'package:flutter/material.dart';

class ContactsController extends GetxController {
  final CallService _callService = Get.find();
  final GoogleContactsService _googleContactsService = Get.find();
  final searchQuery = ''.obs;
  final isSearching = false.obs;
  final isSyncing = false.obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final _filteredContacts = <Contact>[].obs;

  // Getter for filtered contacts
  List<Contact> get contacts {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) {
      return _callService.contacts;
    }

    return _callService.contacts.where((contact) {
      // Clean the search query (remove spaces, hyphens, etc.)
      final cleanQuery = query.replaceAll(RegExp(r'[\s\-()]'), '');

      // Search in phone numbers
      bool matchesPhone = false;
      if (contact.phones != null && contact.phones!.isNotEmpty) {
        for (var phone in contact.phones!) {
          if (phone.value == null) continue;

          // Clean the phone number
          String cleanNumber = phone.value!.replaceAll(RegExp(r'[\s\-()]'), '');

          // Remove +91 prefix if exists
          if (cleanNumber.startsWith('+91')) {
            cleanNumber = cleanNumber.substring(3);
          }

          // Check if query matches any part of the number
          if (cleanNumber.contains(cleanQuery)) {
            matchesPhone = true;
            break;
          }
        }
      }

      // If query is numeric, only search in phone numbers
      if (RegExp(r'^\d+$').hasMatch(cleanQuery)) {
        return matchesPhone;
      }

      // Search in all name fields
      final givenName = (contact.givenName ?? '').toLowerCase();
      final familyName = (contact.familyName ?? '').toLowerCase();
      final displayName = (contact.displayName ?? '').toLowerCase();
      final company = (contact.company ?? '').toLowerCase();

      // Check if query matches any name field
      final matchesName = givenName.contains(query) ||
          familyName.contains(query) ||
          displayName.contains(query) ||
          company.contains(query);

      return matchesName || matchesPhone;
    }).toList();
  }

  bool get isSignedInToGoogle => _googleContactsService.isSignedIn.value;

  Future<void> signInToGoogle() async {
    final success = await _googleContactsService.signIn();
    if (success) {
      Get.snackbar(
        'Success',
        'Signed in to Google',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> syncGoogleContacts() async {
    if (!isSignedInToGoogle) {
      final success = await _googleContactsService.signIn();
      if (!success) return;
    }

    isSyncing.value = true;
    try {
      await _googleContactsService.syncContacts();
      await _callService.initialize(); // Refresh local contacts
    } finally {
      isSyncing.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;
    // Debug print to see what's being searched
    print('Searching for: $query');
    // Force refresh before search
    _callService.contacts.refresh();
    final results = contacts;
    print('Found ${results.length} matches');
    for (var contact in results) {
      print(
          'Match: ${contact.displayName}, ${contact.phones?.map((p) => p.value).join(', ')}');
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    isSearching.value = false;
    // Force refresh the contacts list
    _callService.contacts.refresh();
  }

  Future<void> refreshContacts() async {
    isLoading.value = true;
    await _callService.initialize();
    _filteredContacts.value = _callService.contacts;
    isLoading.value = false;
  }

  Future<void> callContact(String? number) async {
    if (number != null && number.isNotEmpty) {
      await _callService.makeCall(number);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _filteredContacts.value = _callService.contacts;
    refreshContacts();
  }

  List<Contact> get filteredContacts => _filteredContacts;

  void searchContacts(String query) {
    if (query.isEmpty) {
      isSearching.value = false;
      _filteredContacts.value = _callService.contacts;
      return;
    }

    isSearching.value = true;
    final searchQuery = query.toLowerCase();
    _filteredContacts.value = _callService.contacts
        .where((contact) =>
            contact.displayName?.toLowerCase().contains(searchQuery) == true ||
            contact.phones?.any((phone) =>
                    phone.value?.toLowerCase().contains(searchQuery) == true) ==
                true)
        .toList();
  }
}
