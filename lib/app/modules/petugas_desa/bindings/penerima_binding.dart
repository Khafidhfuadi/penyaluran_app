import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penerima_controller.dart';

class PenerimaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PenerimaController>(
      () => PenerimaController(),
      fenix: true,
    );
  }
}
