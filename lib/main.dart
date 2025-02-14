import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/utils/permission_handler.dart';
import 'app/services/call_service.dart';
import 'app/services/platform_service.dart';
import 'app/services/theme_service.dart';
import 'app/services/country_service.dart';
import 'app/services/block_service.dart';
import 'app/services/google_contacts_service.dart';
import 'dart:io' show Platform;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize GetStorage
    await GetStorage.init();

    // Initialize core services
    await Get.putAsync(() => ThemeService().onInit());
    await Get.putAsync(() => CountryService().onInit());
    await Get.putAsync(() => BlockService().onInit());
    await Get.putAsync(() => CallService().onInit());

    // Initialize Google services last
    await Get.putAsync(() => GoogleContactsService().onInit());

    // Request permissions based on platform
    if (Platform.isAndroid || Platform.isIOS) {
      await PermissionHandlerUtil.handlePermissions();
    }

    runApp(const MyApp());
  } catch (e) {
    print('Error during initialization: $e');
    // Still try to run the app even if there are initialization errors
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return GetMaterialApp(
      title: 'Dialpad App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: themeService.themeMode,
      initialRoute: Routes.NAVIGATION,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
      debugShowCheckedModeBanner: false,
    );
  }
}
