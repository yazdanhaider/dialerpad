import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;

class PermissionHandlerUtil {
  static Future<bool> handlePermissions() async {
    // Skip permission check on iOS simulator
    if (Platform.isIOS) {
      // For iOS simulator, we'll return true and handle permissions when needed
      return true;
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.contacts,
      if (Platform.isAndroid) Permission.phone, // For call logs on Android
    ].request();

    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
      }
    });

    if (!allGranted) {
      Get.snackbar(
        'Permissions Required',
        'Please grant all required permissions to use this app',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  static Future<bool> checkSpecificPermission(Permission permission) async {
    // Skip permission check on iOS simulator
    if (Platform.isIOS) {
      return true;
    }

    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    final result = await permission.request();
    return result.isGranted;
  }
}
