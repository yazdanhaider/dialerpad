import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../dialpad/views/dialpad_view.dart';
import '../../history/views/history_view.dart';
import '../../contacts/views/contacts_view.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;

  final pages = [
    const DialpadView(),
    const HistoryView(),
    const ContactsView(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}
