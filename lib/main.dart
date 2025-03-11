import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';
import 'package:penyaluran_app/app/services/auth_service.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data locale untuk format tanggal
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Supabase
  await initServices();

  runApp(const MyApp());
}

// Inisialisasi service
Future<void> initServices() async {
  await Get.putAsync(() => SupabaseService().init());
  await Get.putAsync(() => AuthService().init());

  // Inisialisasi AuthController secara global
  Get.put(AuthController(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Penyaluran App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default ke tema terang
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
