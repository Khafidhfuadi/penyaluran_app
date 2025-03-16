import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/pengaduan_controller.dart';

class PengaduanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengaduanController>(
      () => PengaduanController(),
    );
  }
}
