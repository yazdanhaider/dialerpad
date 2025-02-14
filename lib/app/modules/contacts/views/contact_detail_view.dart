import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:contacts_service/contacts_service.dart';
import '../../../services/block_service.dart';
import '../../../services/call_service.dart';

class ContactDetailView extends StatelessWidget {
  final Contact contact;
  final BlockService _blockService = Get.find();
  final CallService _callService = Get.find();

  ContactDetailView({Key? key, required this.contact}) : super(key: key);

  String get primaryNumber => contact.phones?.first.value ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.displayName ?? 'Contact Details'),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  _blockService.isBlocked(primaryNumber)
                      ? Icons.block
                      : Icons.block_outlined,
                  color: _blockService.isBlocked(primaryNumber)
                      ? Colors.red
                      : null,
                ),
                onPressed: _toggleBlock,
                tooltip: _blockService.isBlocked(primaryNumber)
                    ? 'Unblock Contact'
                    : 'Block Contact',
              )),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Avatar/Icon
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(
                (contact.displayName ?? '?')[0].toUpperCase(),
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Phone Numbers
          if (contact.phones != null && contact.phones!.isNotEmpty) ...[
            const Text(
              'Phone Numbers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...contact.phones!.map((phone) => ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(phone.value ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call),
                        onPressed: () =>
                            _callService.makeCall(phone.value ?? ''),
                        color: Colors.green,
                      ),
                      Obx(() => IconButton(
                            icon: Icon(
                              _blockService.isBlocked(phone.value ?? '')
                                  ? Icons.block
                                  : Icons.block_outlined,
                            ),
                            onPressed: () => _toggleBlock(phone.value ?? ''),
                            color: _blockService.isBlocked(phone.value ?? '')
                                ? Colors.red
                                : null,
                          )),
                    ],
                  ),
                )),
          ],

          // Email
          if (contact.emails != null && contact.emails!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Email Addresses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...contact.emails!
                .map((email) => ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(email.value ?? ''),
                    ))
                .toList(),
          ],
        ],
      ),
    );
  }

  void _toggleBlock([String? specificNumber]) {
    final numberToBlock = specificNumber ?? primaryNumber;
    if (numberToBlock.isEmpty) return;

    if (_blockService.isBlocked(numberToBlock)) {
      _blockService.unblockNumber(numberToBlock);
    } else {
      _blockService.blockNumber(numberToBlock);
    }
  }
}
