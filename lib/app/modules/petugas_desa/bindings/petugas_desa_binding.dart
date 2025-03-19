import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/controllers/laporan_penyaluran_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_dashboard_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/stok_bantuan_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penitipan_bantuan_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/pengaduan_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penerima_bantuan_controller.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/counter_service.dart';

class PetugasDesaBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan AuthController sudah terdaftar
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }

    // Daftarkan CounterService jika belum terdaftar
    if (!Get.isRegistered<CounterService>()) {
      Get.put(CounterService(), permanent: true);
    }

    // Daftarkan controller utama
    Get.lazyPut<PetugasDesaController>(
      () => PetugasDesaController(),
    );

    // Daftarkan controller dashboard
    Get.lazyPut<PetugasDesaDashboardController>(
      () => PetugasDesaDashboardController(),
    );

    // Daftarkan controller jadwal penyaluran
    Get.lazyPut<JadwalPenyaluranController>(
      () => JadwalPenyaluranController(),
    );

    // Daftarkan controller stok bantuan
    Get.lazyPut<StokBantuanController>(
      () => StokBantuanController(),
    );

    // Daftarkan controller penitipan bantuan
    Get.lazyPut<PenitipanBantuanController>(
      () => PenitipanBantuanController(),
      fenix: true, // Agar controller tetap hidup saat berpindah halaman
    );

    // Daftarkan controller pengaduan
    Get.lazyPut<PengaduanController>(
      () => PengaduanController(),
    );

    // Daftarkan controller penerima bantuan
    Get.lazyPut<PenerimaBantuanController>(
      () => PenerimaBantuanController(),
    );

    // Daftarkan controller laporan
    Get.lazyPut<LaporanPenyaluranController>(
      () => LaporanPenyaluranController(),
    );
  }
}
