import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/history_controller.dart';
import 'dart:io' show Platform;
import 'call_log_detail_view.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({Key? key}) : super(key: key);

  String _formatDuration(int? duration) {
    if (duration == null) return '';
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes > 0 ? '${minutes}m ' : ''}${seconds}s';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return 'Today ${DateFormat('h:mm a').format(dateTime)}';
    } else if (date == yesterday) {
      return 'Yesterday ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  Widget _buildCallTypeIcon(CallType? callType) {
    IconData iconData;
    Color iconColor;

    switch (callType) {
      case CallType.incoming:
        iconData = Icons.call_received;
        iconColor = Colors.green;
        break;
      case CallType.outgoing:
        iconData = Icons.call_made;
        iconColor = Colors.blue;
        break;
      case CallType.missed:
        iconData = Icons.call_missed;
        iconColor = Colors.red;
        break;
      case CallType.rejected:
        iconData = Icons.call_end;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.call;
        iconColor = Colors.grey;
    }

    return Icon(iconData, color: iconColor);
  }

  Widget _buildShimmerLoading() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          // Add date header shimmer every 5 items
          if (index % 5 == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Shimmer.fromColors(
                    baseColor:
                        Theme.of(Get.context!).brightness == Brightness.dark
                            ? Colors.grey[800]!
                            : Colors.grey[300]!,
                    highlightColor:
                        Theme.of(Get.context!).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[100]!,
                    period:
                        const Duration(milliseconds: 1500), // Slower animation
                    child: Container(
                      height: 24,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                _buildShimmerCallLogTile(),
              ],
            );
          }
          return _buildShimmerCallLogTile();
        },
      ),
    );
  }

  Widget _buildShimmerCallLogTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Theme.of(Get.context!).brightness == Brightness.dark
            ? Colors.grey[800]!
            : Colors.grey[300]!,
        highlightColor: Theme.of(Get.context!).brightness == Brightness.dark
            ? Colors.grey[700]!
            : Colors.grey[100]!,
        period: const Duration(milliseconds: 1500), // Slower animation
        child: Row(
          children: [
            // Call type icon shimmer
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            // Call details shimmer
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
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Call button shimmer
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
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone_iphone,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Call History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Call history is only available on Android devices',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Date filter indicator with animation
        Obx(() {
          if (controller.selectedDate.value != null) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing calls from ${DateFormat('MMM d, y').format(controller.selectedDate.value!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.clearDateFilter,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Call logs list with animations and shimmer
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return _buildShimmerLoading();
            }

            final groupedLogs = controller.groupedCallLogs;

            if (groupedLogs.isEmpty) {
              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.call_end,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No call history available',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: groupedLogs.length,
              itemBuilder: (context, index) {
                final date = groupedLogs.keys.elementAt(index);
                final logs = groupedLogs[date]!;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          date,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      ...logs
                          .map((log) => _buildCallLogTile(context, log))
                          .toList(),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCallLogTile(BuildContext context, CallLogEntry log) {
    // Get contact information if available
    final contact = controller.contacts.firstWhereOrNull((c) =>
        c.phones?.any((phone) =>
            phone.value?.replaceAll(RegExp(r'[^\d+]'), '') ==
            log.number?.replaceAll(RegExp(r'[^\d+]'), '')) ??
        false);

    return Hero(
      tag: 'call_log_${log.timestamp}',
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: _buildCallTypeIcon(log.callType),
          title: Text(
            log.name ?? log.number ?? 'Unknown',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(log.number ?? 'No number'),
              Text(
                '${_formatDateTime(DateTime.fromMillisecondsSinceEpoch(log.timestamp ?? 0))} • ${_formatDuration(log.duration)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.phone, color: Colors.green),
            onPressed: () => controller.callNumber(log.number ?? ''),
          ),
          onLongPress: () => _showCallDetails(context, log),
          onTap: () => Get.to(() => CallLogDetailView(
                callLog: log,
              )),
        ),
      ),
    );
  }

  void _showCallDetails(BuildContext context, CallLogEntry log) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Call Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildDetailRow('Name', log.name ?? 'Unknown'),
            _buildDetailRow('Number', log.number ?? 'No number'),
            _buildDetailRow(
              'Date & Time',
              _formatDateTime(
                DateTime.fromMillisecondsSinceEpoch(log.timestamp ?? 0),
              ),
            ),
            _buildDetailRow('Duration', _formatDuration(log.duration)),
            _buildDetailRow(
              'Call Type',
              log.callType?.toString().split('.').last ?? 'Unknown',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.callNumber(log.number ?? ''),
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                ),
                if (log.number != null)
                  ElevatedButton.icon(
                    onPressed: () => controller.addToContacts(log.number!),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add to Contacts'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
