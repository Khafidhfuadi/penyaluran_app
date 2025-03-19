import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/controllers/laporan_penyaluran_controller.dart';

class LaporanPenyaluranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LaporanPenyaluranController>(
      () => LaporanPenyaluranController(),
    );
  }
}
