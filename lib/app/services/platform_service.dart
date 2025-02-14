import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

class PlatformService extends GetxService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static bool? _isSimulator; // Cache the result

  @override
  Future<PlatformService> onInit() async {
    super.onInit();
    await initialize();
    return this;
  }

  static Future<void> initialize() async {
    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      _isSimulator = !iosInfo.isPhysicalDevice;
    } else {
      _isSimulator = false;
    }
  }

  static bool get canMakePhoneCalls {
    if (Platform.isIOS) {
      return !(_isSimulator ?? true);
    }
    return true;
  }

  static bool get canAccessCallLog => Platform.isAndroid;

  static bool get canAccessContacts {
    if (Platform.isIOS) {
      return !(_isSimulator ?? true);
    }
    return true;
  }
}
