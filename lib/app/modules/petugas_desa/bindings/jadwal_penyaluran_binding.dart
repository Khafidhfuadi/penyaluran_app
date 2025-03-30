import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/services/jadwal_update_service.dart';

class JadwalPenyaluranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JadwalPenyaluranController>(
      () => JadwalPenyaluranController(),
    );

    // Register service untuk komunikasi pembaruan jadwal
    if (!Get.isRegistered<JadwalUpdateService>()) {
      Get.lazyPut<JadwalUpdateService>(
        () => JadwalUpdateService(),
        fenix: true, // Pastikan service tetap aktif selama aplikasi berjalan
      );
    }
  }
}
