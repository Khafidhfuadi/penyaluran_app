import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class DashboardController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxBool isLoading = false.obs;
  final Rx<Map<String, dynamic>?> roleData = Rx<Map<String, dynamic>?>(null);

  // Indeks kategori yang dipilih untuk filter
  final RxInt selectedCategoryIndex = 0.obs;

  UserModel? get user => _authController.user;
  String get role => user?.role ?? 'WARGA';

  @override
  void onInit() {
    super.onInit();
    loadRoleData();
  }

  Future<void> loadRoleData() async {
    isLoading.value = true;
    try {
      if (user != null) {
        final data = await _supabaseService.getRoleSpecificData(role);
        roleData.value = data;
      }
    } catch (e) {
      print('Error loading role data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _authController.logout();
  }
}
