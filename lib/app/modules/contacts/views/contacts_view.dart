import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/contacts_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../modules/contacts/views/contact_detail_view.dart';

class ContactsView extends GetView<ContactsController> {
  const ContactsView({Key? key}) : super(key: key);

  String _formatContactName(Contact contact) {
    // Try different name fields in order of preference
    if (contact.givenName?.isNotEmpty == true ||
        contact.familyName?.isNotEmpty == true) {
      return [contact.givenName ?? '', contact.familyName ?? '']
          .where((s) => s.isNotEmpty)
          .join(' ');
    }

    if (contact.displayName?.isNotEmpty == true) {
      return contact.displayName!;
    }

    if (contact.company?.isNotEmpty == true) {
      return contact.company!;
    }

    // If no name is found, format the phone number nicely
    final phone = contact.phones?.firstOrNull?.value ?? '';
    if (phone.isNotEmpty) {
      // Format Indian numbers differently
      if (phone.startsWith('+91')) {
        return phone.replaceFirst('+91', ''); // Remove +91 prefix
      }
      return phone;
    }

    return 'Unknown Contact';
  }

  String _getAvatarText(Contact contact) {
    // Try to get initials from name
    if (contact.givenName?.isNotEmpty == true) {
      return contact.givenName![0].toUpperCase();
    }
    if (contact.familyName?.isNotEmpty == true) {
      return contact.familyName![0].toUpperCase();
    }
    if (contact.displayName?.isNotEmpty == true) {
      return contact.displayName![0].toUpperCase();
    }

    // If no name, use first digit of phone
    final phone = contact.phones?.firstOrNull?.value ?? '';
    if (phone.isNotEmpty) {
      // For Indian numbers, use first digit after +91
      if (phone.startsWith('+91')) {
        return phone[3];
      }
      return phone[0];
    }

    return '?';
  }

  Widget _buildShimmerLoading() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Shimmer.fromColors(
              baseColor: Theme.of(Get.context!).brightness == Brightness.dark
                  ? Colors.grey[800]!
                  : Colors.grey[300]!,
              highlightColor:
                  Theme.of(Get.context!).brightness == Brightness.dark
                      ? Colors.grey[700]!
                      : Colors.grey[100]!,
              period: const Duration(milliseconds: 1000), // Slower animation
              child: Row(
                children: [
                  // Avatar shimmer
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Contact details shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          margin: const EdgeInsets.only(right: 64),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Call icon shimmer
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Google Contacts Sync Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 16),
                const Text('Sign in to sync with Google Contacts'),
                const Spacer(),
                TextButton(
                  onPressed: () => controller.signInToGoogle(),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: ValueBuilder<bool?>(
                  initialValue: false,
                  builder: (isSearching, updater) => isSearching == true
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.searchContacts('');
                            updater(false);
                          },
                        )
                      : const SizedBox.shrink(),
                  onUpdate: (isSearching) =>
                      controller.isSearching.value = isSearching ?? false,
                ),
              ),
              onChanged: controller.searchContacts,
            ),
          ),

          // Contacts List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmerLoading();
              }

              final contacts = controller.filteredContacts.toList();

              if (controller.isSearching.value && contacts.isEmpty) {
                return const Center(child: Text('No contacts found'));
              }

              return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  if (index >= contacts.length) return const SizedBox.shrink();
                  final contact = contacts[index];
                  return _buildContactTile(contact);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.CONTACT_FORM),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildContactTile(Contact contact) {
    final phoneNumber = contact.phones?.first.value ?? '';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(Get.context!).primaryColor,
          child: Text(
            (contact.displayName?.isNotEmpty == true)
                ? contact.displayName![0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact.displayName?.isNotEmpty == true
              ? contact.displayName!
              : phoneNumber,
          style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(phoneNumber),
        trailing: IconButton(
          icon: const Icon(Icons.phone, color: Colors.green),
          onPressed: () => controller.callContact(phoneNumber),
        ),
        onTap: () => Get.to(() => ContactDetailView(contact: contact)),
      ),
    );
  }
}
