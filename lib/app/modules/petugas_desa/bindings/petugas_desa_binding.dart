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
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/counter_service.dart';

class PetugasDesaBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan AuthController tersedia
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }

    // Daftarkan CounterService terlebih dahulu
    if (!Get.isRegistered<CounterService>()) {
      Get.put(CounterService(), permanent: true);
    }

    // Main controller - gunakan put dengan permanent untuk controller utama
    if (!Get.isRegistered<PetugasDesaController>()) {
      Get.put(PetugasDesaController(), permanent: true);
    } else {
      // Jika sudah terdaftar, gunakan find untuk mendapatkan instance yang ada
      Get.find<PetugasDesaController>();
    }

    // Dashboard controller
    Get.lazyPut<PetugasDesaDashboardController>(
      () => PetugasDesaDashboardController(),
      fenix: true,
    );

    // Jadwal penyaluran controller
    Get.lazyPut<JadwalPenyaluranController>(
      () => JadwalPenyaluranController(),
      fenix: true,
    );

    // Stok bantuan controller
    Get.lazyPut<StokBantuanController>(
      () => StokBantuanController(),
      fenix: true,
    );

    // Penitipan bantuan controller
    Get.lazyPut<PenitipanBantuanController>(
      () => PenitipanBantuanController(),
      fenix: true,
    );

    // Pengaduan controller
    Get.lazyPut<PengaduanController>(
      () => PengaduanController(),
      fenix: true,
    );

    // Penerima bantuan controller
    Get.lazyPut<PenerimaBantuanController>(
      () => PenerimaBantuanController(),
      fenix: true,
    );

    // Laporan controller
    Get.lazyPut<LaporanController>(
      () => LaporanController(),
      fenix: true,
    );
  }
}
