import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/riwayat_pengaduan_controller.dart';

class RiwayatPengaduanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatPengaduanController>(
      () => RiwayatPengaduanController(),
    );
  }
}
