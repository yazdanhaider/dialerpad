import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/call_service.dart';

class CallStateDisplay extends GetWidget<CallService> {
  const CallStateDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.callState.value;
      final number = controller.currentNumber.value;

      if (state == CallState.idle) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getBackgroundColor(state),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getStateText(state),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (number.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
            if (state == CallState.connected) ...[
              const SizedBox(height: 8),
              Obx(() => Text(
                    controller.formattedCallDuration,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  )),
            ],
          ],
        ),
      );
    });
  }

  Color _getBackgroundColor(CallState state) {
    switch (state) {
      case CallState.incoming:
        return Colors.blue;
      case CallState.dialing:
        return Colors.orange;
      case CallState.connected:
        return Colors.green;
      case CallState.disconnected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStateText(CallState state) {
    switch (state) {
      case CallState.incoming:
        return 'Incoming Call';
      case CallState.dialing:
        return 'Dialing...';
      case CallState.connected:
        return 'Call Connected';
      case CallState.disconnected:
        return 'Call Ended';
      default:
        return '';
    }
  }
}
