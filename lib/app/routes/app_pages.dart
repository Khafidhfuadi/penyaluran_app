import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/auth/views/login_view.dart';
import 'package:penyaluran_app/app/modules/auth/bindings/auth_binding.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/petugas_desa_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/bindings/petugas_desa_binding.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/permintaan_penjadwalan_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/daftar_penerima_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/detail_penerima_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/konfirmasi_penerima_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/pelaksanaan_penyaluran_view.dart';

import 'package:penyaluran_app/app/modules/petugas_desa/bindings/penerima_binding.dart';
import 'package:penyaluran_app/app/modules/profile/bindings/profile_binding.dart';
import 'package:penyaluran_app/app/modules/profile/views/profile_view.dart';
import 'package:penyaluran_app/app/modules/splash/bindings/splash_binding.dart';
import 'package:penyaluran_app/app/modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: _Paths.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.petugasDesaDashboard,
      page: () => const PetugasDesaView(),
      binding: PetugasDesaBinding(),
    ),
    GetPage(
      name: _Paths.permintaanPenjadwalan,
      page: () => const PermintaanPenjadwalanView(),
      binding: PetugasDesaBinding(),
    ),
    GetPage(
      name: _Paths.daftarPenerima,
      page: () => const DaftarPenerimaView(),
      binding: PenerimaBinding(),
    ),
    GetPage(
      name: _Paths.detailPenerima,
      page: () => const DetailPenerimaView(),
      binding: PenerimaBinding(),
    ),
    GetPage(
      name: _Paths.konfirmasiPenerima,
      page: () => const KonfirmasiPenerimaView(),
      binding: PenerimaBinding(),
    ),
    GetPage(
      name: _Paths.pelaksanaanPenyaluran,
      page: () => const PelaksanaanPenyaluranView(),
      binding: PetugasDesaBinding(),
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
