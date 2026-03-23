import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/data/local/my_shared_pref.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/cloudinary_service.dart';
import 'app/data/services/database_service.dart';
import 'app/data/services/firebase_manager.dart';
import 'app/data/services/mpesa_service.dart';
import 'app/routes/app_pages.dart';
import 'config/cloudinary_config.dart';
import 'config/theme/my_theme.dart';
import 'config/translations/localization_service.dart';
import '../firebase_options.dart';

Future<void> main() async {
  // wait for bindings
  WidgetsFlutterBinding.ensureInitialized();

  // init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // init shared preference
  await MySharedPref.init();

  // Initialize Firebase manager first (required by AuthService)
  Get.put(FirebaseManager());

  // Initialize M-Pesa service
  Get.put(MpesaService());

  // Initialize services
  await Get.putAsync(() async => AuthService());
  await Get.putAsync(() async => CloudinaryService());
  CloudinaryService.to.configure(
    cloudName: CloudinaryConfig.cloudName,
    uploadPreset: CloudinaryConfig.uploadPreset,
  );

  Get.put(DatabaseService());

  runApp(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      rebuildFactor: (old, data) => true,
      builder: (context, widget) {
        return GetMaterialApp(
          title: "Biogas Technician App",
          useInheritedMediaQuery: true,
          debugShowCheckedModeBanner: false,
          builder: (context, widget) {
            bool themeIsLight = MySharedPref.getThemeIsLight();
            return Theme(
              data: MyTheme.getThemeData(isLight: themeIsLight),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: widget!,
              ),
            );
          },
          initialRoute:
              AppPages.INITIAL, // first screen to show when app is running
          getPages: AppPages.routes, // app screens
          locale: MySharedPref.getCurrentLocal(), // app language
          translations: LocalizationService
              .getInstance(), // localization services in app (controller app language)
        );
      },
    ),
  );
}
