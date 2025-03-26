import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';

class DonaturBinding extends Bindings {
  @override
  void dependencies() {
    // Hapus controller lama jika sudah ada
    if (Get.isRegistered<DonaturDashboardController>(
        tag: 'donatur_dashboard')) {
      Get.delete<DonaturDashboardController>(tag: 'donatur_dashboard');
    }

    // Pasang controller baru
    Get.put<DonaturDashboardController>(
      DonaturDashboardController(),
      permanent: true,
      tag: 'donatur_dashboard',
    );
  }
}
