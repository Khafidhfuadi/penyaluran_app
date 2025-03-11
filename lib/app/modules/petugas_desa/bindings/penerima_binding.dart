import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penerima_controller.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';

class PenerimaBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan AuthController tersedia
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }

    Get.lazyPut<PenerimaController>(
      () => PenerimaController(),
      fenix: true,
    );
  }
}
