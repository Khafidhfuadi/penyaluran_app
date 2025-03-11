import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_dashboard_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/stok_bantuan_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penitipan_bantuan_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/pengaduan_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penerima_bantuan_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/laporan_controller.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';

class PetugasDesaBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan AuthController tersedia
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }

    // Main controller
    Get.lazyPut<PetugasDesaController>(
      () => PetugasDesaController(),
      fenix: true,
    );

    // Dashboard controller
    Get.lazyPut<PetugasDesaDashboardController>(
      () => PetugasDesaDashboardController(),
    );

    // Jadwal penyaluran controller
    Get.lazyPut<JadwalPenyaluranController>(
      () => JadwalPenyaluranController(),
    );

    // Stok bantuan controller
    Get.lazyPut<StokBantuanController>(
      () => StokBantuanController(),
    );

    // Penitipan bantuan controller
    Get.lazyPut<PenitipanBantuanController>(
      () => PenitipanBantuanController(),
    );

    // Pengaduan controller
    Get.lazyPut<PengaduanController>(
      () => PengaduanController(),
    );

    // Penerima bantuan controller
    Get.lazyPut<PenerimaBantuanController>(
      () => PenerimaBantuanController(),
    );

    // Laporan controller
    Get.lazyPut<LaporanController>(
      () => LaporanController(),
    );
  }
}
