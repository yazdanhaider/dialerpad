import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/blocked_numbers_controller.dart';

class BlockedNumbersView extends GetView<BlockedNumbersController> {
  const BlockedNumbersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Numbers'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                labelText: 'Search contacts or numbers',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: ObxValue<RxBool>(
                  (isSearching) => isSearching.value
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.searchContacts('');
                          },
                        )
                      : const SizedBox.shrink(),
                  controller.isSearching,
                ),
              ),
              onChanged: controller.searchContacts,
            ),
          ),

          Expanded(
            child: Obx(() {
              // Show search results if searching
              if (controller.isSearching.value) {
                if (controller.searchResults.isEmpty) {
                  return const Center(
                    child: Text('No contacts found'),
                  );
                }
                return ListView.builder(
                  itemCount: controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final contact = controller.searchResults[index];
                    final number = contact.phones?.first.value ?? '';
                    final isBlocked = controller.isNumberBlocked(number);

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (contact.displayName ?? '?')[0].toUpperCase(),
                        ),
                      ),
                      title: Text(contact.displayName ?? 'Unknown'),
                      subtitle: Text(number),
                      trailing: IconButton(
                        icon: Icon(
                          isBlocked ? Icons.block : Icons.block_outlined,
                          color: isBlocked ? Colors.red : null,
                        ),
                        onPressed: () => isBlocked
                            ? controller.unblockNumber(number)
                            : controller.blockContact(contact),
                      ),
                    );
                  },
                );
              }

              // Show blocked numbers list if not searching
              if (controller.blockedNumbers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.block, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No blocked numbers',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.blockedNumbers.length,
                itemBuilder: (context, index) {
                  final number = controller.blockedNumbers[index];
                  final contact = controller.getContactForNumber(number);

                  return ListTile(
                    leading: const Icon(Icons.block, color: Colors.red),
                    title: Text(contact?.displayName ?? number),
                    subtitle: contact != null ? Text(number) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => controller.unblockNumber(number),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
