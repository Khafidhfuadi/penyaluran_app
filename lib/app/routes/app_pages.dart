import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/auth/views/login_view.dart';
import 'package:penyaluran_app/app/modules/home/views/home_view.dart';
import 'package:penyaluran_app/app/modules/dashboard/views/warga_dashboard_view.dart';
import 'package:penyaluran_app/app/modules/dashboard/views/petugas_verifikasi_dashboard_view.dart';
import 'package:penyaluran_app/app/modules/dashboard/views/petugas_desa_dashboard_view.dart';
import 'package:penyaluran_app/app/modules/dashboard/views/donatur_dashboard_view.dart';
import 'package:penyaluran_app/app/modules/auth/bindings/auth_binding.dart';
import 'package:penyaluran_app/app/modules/home/bindings/home_binding.dart';
import 'package:penyaluran_app/app/modules/dashboard/bindings/dashboard_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.wargaDashboard,
      page: () => const WargaDashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.petugasVerifikasiDashboard,
      page: () => const PetugasVerifikasiDashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.petugasDesaDashboard,
      page: () => const PetugasDesaDashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.donaturDashboard,
      page: () => const DonaturDashboardView(),
      binding: DashboardBinding(),
    ),
  ];
}
