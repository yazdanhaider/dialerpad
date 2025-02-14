import 'package:get/get.dart';
import 'package:call_log/call_log.dart';
import '../../../services/call_service.dart';
import 'package:contacts_service/contacts_service.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class HistoryController extends GetxController {
  final CallService _callService = Get.find();
  final isLoading = false.obs;
  final currentFilter = 'all'.obs;
  final selectedDate = Rx<DateTime?>(null);

  // Add public getter for contacts
  List<Contact> get contacts => _callService.contacts;

  // Getter for filtered and grouped call logs
  Map<String, List<CallLogEntry>> get groupedCallLogs {
    final logs = _getFilteredLogs();
    final grouped = <String, List<CallLogEntry>>{};

    for (var log in logs) {
      final date = DateTime.fromMillisecondsSinceEpoch(log.timestamp ?? 0);
      final key = _getGroupKey(date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(log);
    }

    return grouped;
  }

  List<CallLogEntry> _getFilteredLogs() {
    final logs = _callService.callLogs.toList();

    // Apply date filter if selected
    var filteredLogs = logs;
    if (selectedDate.value != null) {
      filteredLogs = logs.where((log) {
        final logDate = DateTime.fromMillisecondsSinceEpoch(log.timestamp ?? 0);
        return _isSameDay(logDate, selectedDate.value!);
      }).toList();
    }

    // Apply call type filter
    switch (currentFilter.value) {
      case 'missed':
        return filteredLogs
            .where((log) => log.callType == CallType.missed)
            .toList();
      case 'incoming':
        return filteredLogs
            .where((log) => log.callType == CallType.incoming)
            .toList();
      case 'outgoing':
        return filteredLogs
            .where((log) => log.callType == CallType.outgoing)
            .toList();
      default:
        return filteredLogs;
    }
  }

  String _getGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(date.year, date.month, date.day);

    if (logDate == today) {
      return 'Today';
    } else if (logDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void filterCallLogs(String filter) {
    currentFilter.value = filter;
  }

  void selectDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  void clearDateFilter() {
    selectedDate.value = null;
  }

  Future<void> callNumber(String number) async {
    await _callService.makeCall(number);
  }

  Future<void> addToContacts(String number) async {
    try {
      final newContact = Contact();
      newContact.phones = [Item(label: 'mobile', value: number)];
      await ContactsService.addContact(newContact);
      await _callService.initialize();
      Get.snackbar(
        'Success',
        'Contact added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _callService.notifyContactsUpdated();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add contact: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (Platform.isAndroid) {
      refreshCallLogs();
    } else {
      isLoading.value = false;
      Get.snackbar(
        'Notice',
        'Call history is only available on Android devices',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshCallLogs() async {
    isLoading.value = true;
    await _callService.initialize();
    isLoading.value = false;
  }
}
