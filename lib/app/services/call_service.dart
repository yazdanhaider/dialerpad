import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/permission_handler.dart';
import '../services/block_service.dart';
import 'dart:async';
import 'dart:io' show Platform;

enum CallState {
  idle,
  incoming,
  dialing,
  connected,
  disconnected,
}

class CallService extends GetxService {
  BlockService get _blockService => Get.find<BlockService>();
  StreamSubscription? _phoneStateSubscription;
  final contactsUpdated = RxBool(false);
  final callState = CallState.idle.obs;
  final currentNumber = ''.obs;
  final callDuration = 0.obs;
  final callStateStream = ''.obs;
  final callLogs = <CallLogEntry>[].obs;
  final contacts = <Contact>[].obs;
  Timer? _callTimer;

  @override
  Future<CallService> onInit() async {
    try {
      // Initialize basic features for both platforms
      await _loadContacts();

      // Initialize Android-specific features
      if (Platform.isAndroid) {
        await _initializeCallDetection();
        await _loadCallLogs();
      }
    } catch (e) {
      print('Error initializing CallService: $e');
    }
    return this;
  }

  Future<void> initialize() async {
    try {
      // Refresh data
      await _loadContacts();
      if (Platform.isAndroid) {
        await _loadCallLogs();
      }
    } catch (e) {
      print('Error in initialize: $e');
    }
  }

  Future<void> _initializeCallDetection() async {
    try {
      final status = await Permission.phone.request();
      if (status.isGranted) {
        _phoneStateSubscription = (await PhoneState.stream).listen(
          (PhoneState? state) {
            if (state?.status != null) {
              _handlePhoneStateChange(state!.status);
            }
          },
        );
      } else {
        Get.snackbar(
          'Permission Required',
          'Phone state permission is required for call detection',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error initializing call detection: $e');
    }
  }

  void _handlePhoneStateChange(PhoneStateStatus status) {
    switch (status) {
      case PhoneStateStatus.CALL_INCOMING:
        _handleIncomingCall();
        break;
      case PhoneStateStatus.CALL_STARTED:
        _handleCallConnected();
        break;
      case PhoneStateStatus.CALL_ENDED:
        _handleCallDisconnected();
        break;
      default:
        callState.value = CallState.idle;
    }
  }

  void _handleIncomingCall() {
    callState.value = CallState.incoming;
    // Reset call duration
    callDuration.value = 0;
  }

  void _handleCallConnected() {
    callState.value = CallState.connected;
    // Start call duration timer
    _startCallTimer();
  }

  void _handleCallDisconnected() {
    callState.value = CallState.disconnected;
    // Stop call duration timer
    _stopCallTimer();
    // Reset after a brief delay
    Future.delayed(const Duration(seconds: 2), () {
      if (callState.value == CallState.disconnected) {
        callState.value = CallState.idle;
      }
    });
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    callDuration.value = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDuration.value++;
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  Future<void> makeCall(String number) async {
    try {
      currentNumber.value = number;
      callState.value = CallState.dialing;

      if (number.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter a valid number',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check if number is blocked
      if (_blockService.isBlocked(number)) {
        Get.snackbar(
          'Blocked Number',
          'This number is blocked. Unblock it to make calls.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final result = await FlutterPhoneDirectCaller.callNumber(number);
      if (result == true) {
        // Wait a moment for the call to be registered in logs
        await Future.delayed(const Duration(seconds: 2));
        // Refresh call logs
        await _loadCallLogs();
      } else {
        throw Exception('Failed to make call');
      }
    } catch (e) {
      print('Error making call: $e');
      callState.value = CallState.idle;
      Get.snackbar(
        'Error',
        'Failed to make call: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadCallLogs() async {
    try {
      // Check platform
      if (!Platform.isAndroid) {
        print('Call logs are only available on Android');
        return;
      }

      // Check permission specifically for call logs
      if (!await PermissionHandlerUtil.checkSpecificPermission(
          Permission.phone)) {
        print('Call log permission not granted');
        return;
      }

      // Get call logs with more details and sorting
      final entries = await CallLog.query();

      print('Successfully fetched ${entries.length} call logs');
      // Sort by timestamp (most recent first)
      final sortedEntries = entries.toList()
        ..sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));

      callLogs.value = sortedEntries;

      // Update contact information for non-saved numbers
      for (var log in callLogs) {
        if (log.name == null || log.name!.isEmpty) {
          final number = log.number;
          if (number != null) {
            final contact = contacts.firstWhereOrNull((c) =>
                c.phones?.any((phone) =>
                    phone.value?.replaceAll(RegExp(r'[^\d+]'), '') ==
                    number.replaceAll(RegExp(r'[^\d+]'), '')) ??
                false);
            if (contact != null) {
              log.name = contact.displayName;
            }
          }
        }
      }
    } catch (e) {
      print('Error in _loadCallLogs: $e');
      if (Get.isRegistered<GetMaterialController>()) {
        Get.snackbar(
          'Notice',
          'Failed to load call logs: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> _loadContacts() async {
    try {
      if (!await PermissionHandlerUtil.checkSpecificPermission(
          Permission.contacts)) {
        print('Contacts permission not granted');
        return;
      }

      // Request with full contact details
      final deviceContacts = await ContactsService.getContacts(
        withThumbnails: false, // Set to false for faster loading
        orderByGivenName: true, // Sort by given name
        photoHighResolution: false,
      );

      // Debug print
      for (var contact in deviceContacts) {
        print(
            'Contact: ${contact.displayName}, ${contact.givenName}, ${contact.familyName}');
      }

      // Filter out contacts without names or numbers
      final validContacts = deviceContacts.where((contact) {
        return contact.phones != null && contact.phones!.isNotEmpty;
      }).toList();

      contacts.value = validContacts;
      notifyContactsUpdated();
    } catch (e) {
      print('Error loading contacts: $e');
      if (Get.isRegistered<GetMaterialController>()) {
        Get.snackbar(
          'Error',
          'Failed to load contacts: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void onClose() {
    _phoneStateSubscription?.cancel();
    _callTimer?.cancel();
    super.onClose();
  }

  // Helper method to format call duration
  String get formattedCallDuration {
    final duration = Duration(seconds: callDuration.value);
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  // Method to notify contact updates
  void notifyContactsUpdated() {
    contactsUpdated.toggle();
  }
}
