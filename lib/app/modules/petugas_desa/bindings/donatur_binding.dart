import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/donatur_controller.dart';

class DonaturBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DonaturController>(
      () => DonaturController(),
    );
  }
}
