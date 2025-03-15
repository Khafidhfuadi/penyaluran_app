import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/pelaksanaan_penyaluran_controller.dart';

class PelaksanaanPenyaluranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PelaksanaanPenyaluranController>(
      () => PelaksanaanPenyaluranController(),
    );
  }
}
