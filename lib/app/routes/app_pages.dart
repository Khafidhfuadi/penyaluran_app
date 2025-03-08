import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/auth/views/login_view.dart';
import 'package:penyaluran_app/app/modules/auth/views/register_view.dart';
import 'package:penyaluran_app/app/modules/auth/views/complete_profile_view.dart';
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

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.COMPLETE_PROFILE,
      page: () => const CompleteProfileView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.WARGA_DASHBOARD,
      page: () => const WargaDashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.PETUGAS_VERIFIKASI_DASHBOARD,
      page: () => const PetugasVerifikasiDashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.PETUGAS_DESA_DASHBOARD,
      page: () => const PetugasDesaDashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.DONATUR_DASHBOARD,
      page: () => const DonaturDashboardView(),
      binding: DashboardBinding(),
    ),
  ];
}
