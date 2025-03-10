import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penerima_controller.dart';

class PetugasDesaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PetugasDesaController>(
      () => PetugasDesaController(),
      fenix: true,
    );
    Get.lazyPut<PenerimaController>(
      () => PenerimaController(),
    );
  }
}
