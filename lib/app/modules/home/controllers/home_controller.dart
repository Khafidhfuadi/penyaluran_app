import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Getter untuk mendapatkan user dari auth controller
  get user => _authController.user;

  // Metode untuk logout
  void logout() {
    _authController.logout();
  }
}
