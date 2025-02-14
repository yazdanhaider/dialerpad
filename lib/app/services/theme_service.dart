import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  final isDarkMode = false.obs;

  @override
  Future<ThemeService> onInit() async {
    super.onInit();
    isDarkMode.value = _loadThemeFromBox();
    return this;
  }

  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  _saveThemeToBox(bool isDark) => _box.write(_key, isDark);

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _saveThemeToBox(isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}
