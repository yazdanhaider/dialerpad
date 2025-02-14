import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../../../services/theme_service.dart';
import '../../../routes/app_routes.dart';
import '../../history/controllers/history_controller.dart';
import '../../contacts/controllers/contacts_controller.dart';

class MainNavigationView extends GetView<NavigationController> {
  const MainNavigationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          switch (controller.currentIndex.value) {
            case 0:
              return const Text('Dialpad');
            case 1:
              return const Text('Call History');
            case 2:
              return const Text('Contacts');
            default:
              return const Text('Dialpad');
          }
        }),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.currentIndex.value == 1) {
              // History tab - show calendar and filter
              final historyController = Get.find<HistoryController>();
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: historyController.selectDate,
                    tooltip: 'Select Date',
                  ),
                  PopupMenuButton<String>(
                    onSelected: historyController.filterCallLogs,
                    tooltip: 'Filter Calls',
                    icon: const Icon(Icons.filter_list),
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'all',
                        child: Text('All Calls'),
                      ),
                      const PopupMenuItem(
                        value: 'missed',
                        child: Text('Missed Calls'),
                      ),
                      const PopupMenuItem(
                        value: 'incoming',
                        child: Text('Incoming Calls'),
                      ),
                      const PopupMenuItem(
                        value: 'outgoing',
                        child: Text('Outgoing Calls'),
                      ),
                    ],
                  ),
                ],
              );
            } else if (controller.currentIndex.value == 2) {
              // Contacts tab - show only sync button
              final contactsController = Get.find<ContactsController>();
              return Obx(() => contactsController.isSyncing.value
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.sync),
                      onPressed: contactsController.syncGoogleContacts,
                      tooltip: 'Sync Google Contacts',
                    ));
            } else {
              // Dialpad tab - show block and theme buttons
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.block),
                    onPressed: () => Get.toNamed(Routes.BLOCKED),
                  ),
                  IconButton(
                    icon: Icon(
                      themeService.isDarkMode.value
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    onPressed: themeService.toggleTheme,
                  ),
                ],
              );
            }
          }),
        ],
      ),
      body: Obx(() => controller.pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dialpad),
              label: 'Dialpad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts),
              label: 'Contacts',
            ),
          ],
        ),
      ),
    );
  }
}
