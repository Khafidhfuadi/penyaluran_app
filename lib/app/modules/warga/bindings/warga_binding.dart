import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';

class WargaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WargaDashboardController>(
      () => WargaDashboardController(),
    );
  }
}
