import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';
import '../../../services/call_service.dart';
import '../../../services/block_service.dart';
import 'package:contacts_service/contacts_service.dart';

class CallLogDetailView extends StatelessWidget {
  final CallLogEntry callLog;
  final CallService _callService = Get.find();
  final BlockService _blockService = Get.find();
  final _contact = Rxn<Contact>();
  final _name = RxString('');

  CallLogDetailView({
    Key? key,
    required this.callLog,
  }) : super(key: key) {
    _updateContactInfo();
    // Listen for contact updates
    ever(_callService.contactsUpdated, (_) => _updateContactInfo());
  }

  void _updateContactInfo() {
    // Get contact information if available
    _contact.value = _callService.contacts.firstWhereOrNull((c) =>
        c.phones?.any((phone) =>
            phone.value?.replaceAll(RegExp(r'[^\d+]'), '') ==
            callLog.number?.replaceAll(RegExp(r'[^\d+]'), '')) ??
        false);
    _name.value = _contact.value?.displayName ?? callLog.name ?? '';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  String _formatDuration(int? duration) {
    if (duration == null) return '';
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes > 0 ? '$minutes min ' : ''}${seconds > 0 ? '$seconds sec' : ''}';
  }

  String _getCallType(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return 'Incoming Call';
      case CallType.outgoing:
        return 'Outgoing Call';
      case CallType.missed:
        return 'Missed Call';
      case CallType.rejected:
        return 'Rejected Call';
      case CallType.blocked:
        return 'Blocked Call';
      default:
        return 'Unknown';
    }
  }

  Color _getCallTypeColor(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
      case CallType.rejected:
        return Colors.red;
      case CallType.blocked:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final number = callLog.number ?? '';
    final isBlocked = _blockService.isBlocked(number);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Details'),
        actions: [
          IconButton(
            icon: Icon(
              isBlocked ? Icons.block : Icons.block_outlined,
              color: isBlocked ? Colors.red : null,
            ),
            onPressed: () {
              if (isBlocked) {
                _blockService.unblockNumber(number);
              } else {
                _blockService.blockNumber(number);
              }
            },
            tooltip: isBlocked ? 'Unblock number' : 'Block number',
          ),
        ],
      ),
      body: Column(
        children: [
          // Contact/Number Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: Obx(() => Text(
                          _name.value.isNotEmpty
                              ? _name.value[0].toUpperCase()
                              : '+',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.blue.shade700,
                          ),
                        )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                              _name.value.isNotEmpty ? _name.value : number,
                              style: Theme.of(context).textTheme.titleLarge,
                            )),
                        if (_name.value.isNotEmpty)
                          Text(
                            number,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Call Details Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Call Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Type',
                    _getCallType(callLog.callType),
                    color: _getCallTypeColor(callLog.callType),
                  ),
                  _buildDetailRow(
                    context,
                    'Time',
                    _formatDateTime(
                      DateTime.fromMillisecondsSinceEpoch(
                          callLog.timestamp ?? 0),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Bottom Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Obx(() => _name.isEmpty
                    ? ElevatedButton.icon(
                        onPressed: () async {
                          await Get.toNamed('/contact-form',
                              arguments: {'phone': number});
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add to Contacts'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      )
                    : const SizedBox.shrink()),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _callService.makeCall(number),
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
