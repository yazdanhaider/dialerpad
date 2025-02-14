import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/navigation/bindings/navigation_binding.dart';
import '../modules/navigation/views/main_navigation_view.dart';
import '../modules/dialpad/bindings/dialpad_binding.dart';
import '../modules/dialpad/views/dialpad_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/contacts/bindings/contacts_binding.dart';
import '../modules/contacts/bindings/contact_form_binding.dart';
import '../modules/contacts/views/contacts_view.dart';
import '../modules/contacts/views/contact_form_view.dart';
import '../modules/blocked/bindings/blocked_numbers_binding.dart';
import '../modules/blocked/views/blocked_numbers_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.NAVIGATION,
      page: () => const MainNavigationView(),
      binding: NavigationBinding(),
    ),
    GetPage(
      name: Routes.DIALPAD,
      page: () => const DialpadView(),
      binding: DialpadBinding(),
    ),
    GetPage(
      name: Routes.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: Routes.CONTACTS,
      page: () => const ContactsView(),
      binding: ContactsBinding(),
    ),
    GetPage(
      name: Routes.BLOCKED,
      page: () => const BlockedNumbersView(),
      binding: BlockedNumbersBinding(),
    ),
    GetPage(
      name: Routes.CONTACT_FORM,
      page: () => const ContactFormView(),
      binding: ContactFormBinding(),
    ),
  ];
}
