import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/logger_service.dart';
import 'core/services/network_service.dart';
import 'core/services/prefs_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/api/api_client.dart';
import 'localization/app_translations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);
  
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  await initServices();

  runApp(const CoreSphereApp());
}

Future<void> initServices() async {
  Get.put(AppLogger());
  await Get.find<AppLogger>().init();
  
  Get.put(StorageService());
  await Get.find<StorageService>().init();
  
  Get.put(PrefsService());
  await Get.find<PrefsService>().init();
  
  Get.put(NetworkService());
  await Get.find<NetworkService>().init();
  
  Get.put(ApiClient());
  
  Get.put(PushNotificationService());
  await Get.find<PushNotificationService>().init();
}

class CoreSphereApp extends StatelessWidget {
  const CoreSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Get.find<PrefsService>();
    final languageCode = prefs.getLanguage();
    final locale = languageCode == 'ar' ? const Locale('ar', 'SA') : const Locale('en', 'US');

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard mobile design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: locale,
          fallbackLocale: const Locale('en', 'US'),
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
