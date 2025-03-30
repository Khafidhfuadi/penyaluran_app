import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';
import 'package:penyaluran_app/app/services/auth_service.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:penyaluran_app/app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi GetStorage
  await GetStorage.init();

  // Inisialisasi data locale untuk format tanggal
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Supabase
  await initServices();

  runApp(const MyApp());
}

// Inisialisasi service
Future<void> initServices() async {
  print('Initializing services...');
  // Inisialisasi SupabaseService dengan pendekatan async
  final supabaseService =
      await Get.putAsync(() => SupabaseService().init(), permanent: true);
  print('SupabaseService initialized: ${supabaseService != null}');

  // Inisialisasi AuthService
  final authService =
      await Get.putAsync(() => AuthService().init(), permanent: true);
  print('AuthService initialized: ${authService != null}');

  // Inisialisasi AuthController secara global
  final authController = Get.put(AuthController(), permanent: true);
  print('AuthController initialized: ${authController != null}');

  // Register NotificationService
  final notificationService = Get.put(NotificationService(), permanent: true);
  print('NotificationService initialized: ${notificationService != null}');

  print('All services initialized');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DisalurKita',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default ke tema terang
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      // Konfigurasi locale
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Indonesia
        Locale('en', 'US'), // English
      ],
      // initialBinding tidak diperlukan lagi karena service sudah diinisialisasi di initServices()
    );
  }
}
