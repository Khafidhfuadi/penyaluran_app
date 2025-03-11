import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/data/providers/auth_provider.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final AuthProvider _authProvider = AuthProvider();

  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  UserModel? get user => _user.value;

  final RxBool isLoading = false.obs;
  final RxBool isWargaProfileComplete = false.obs;

  // Flag untuk menandai apakah sudah melakukan pengambilan data profil
  final RxBool _hasLoadedProfile = false.obs;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> wargaProfileFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();

    // Tambahkan penundaan kecil untuk menghindari loop navigasi
    Future.delayed(const Duration(milliseconds: 100), () {
      checkAuthStatus();
    });
  }

  @override
  void onClose() {
    // Pastikan semua controller dibersihkan sebelum dilepaskan
    clearAndDisposeControllers();
    super.onClose();
  }

  // Metode untuk membersihkan dan melepaskan controller
  void clearAndDisposeControllers() {
    try {
      if (emailController.text.isNotEmpty) emailController.clear();
      if (passwordController.text.isNotEmpty) passwordController.clear();
      if (confirmPasswordController.text.isNotEmpty) {
        confirmPasswordController.clear();
      }

      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
    } catch (e) {
      print('Error disposing controllers: $e');
    }
  }

  // Memeriksa status autentikasi
  Future<void> checkAuthStatus() async {
    if (isLoading.value) {
      return; // Hindari pemanggilan berulang jika sedang loading
    }

    isLoading.value = true;
    try {
      print('Memeriksa status autentikasi...');

      // Jika user sudah ada di memori dan profil sudah diambil, gunakan data yang ada
      if (_user.value != null && _hasLoadedProfile.value) {
        print('Menggunakan data user yang sudah ada di memori');
        _handleAuthenticatedUser(_user.value!);
        return;
      }

      // Jika belum ada data user, ambil dari provider
      final currentUser = await _authProvider.getCurrentUser();

      if (currentUser != null) {
        print(
            'User terautentikasi: ${currentUser.email}, role: ${currentUser.role}');
        _user.value = currentUser;
        _hasLoadedProfile.value = true;
        _handleAuthenticatedUser(currentUser);
      } else {
        print('Tidak ada user yang terautentikasi');
        _handleUnauthenticatedUser();
      }
    } catch (e) {
      print('Error checking auth status: $e');
      print('Stack trace: ${StackTrace.current}');
      _handleUnauthenticatedUser();
    } finally {
      isLoading.value = false;
      print('Pemeriksaan status autentikasi selesai');
    }
  }

  // Metode untuk menangani user yang terautentikasi
  void _handleAuthenticatedUser(UserModel user) {
    // Hindari navigasi jika sudah berada di halaman yang sesuai
    final currentRoute = Get.currentRoute;
    print('Rute saat ini: $currentRoute');

    // Pastikan role tidak null, gunakan default jika null
    final role = user.role.isNotEmpty ? user.role : 'WARGA';
    print('Role yang digunakan: $role');

    // Untuk semua role, arahkan ke dashboard masing-masing
    final targetRoute = _getTargetRouteForRole(role);
    print('Target rute: $targetRoute');

    // Jika berada di splash atau login, navigasi ke dashboard
    if (currentRoute == Routes.splash || currentRoute == Routes.login) {
      print('Navigasi ke rute target berdasarkan role');
      navigateBasedOnRole(role);
    } else if (currentRoute != targetRoute) {
      // Jika berada di rute lain yang tidak sesuai dengan role, navigasi ke dashboard
      print('Berada di rute yang tidak sesuai, navigasi ke rute target');
      navigateBasedOnRole(role);
    } else {
      print('Sudah berada di rute yang sesuai, tidak perlu navigasi');
    }
  }

  // Metode untuk menangani user yang tidak terautentikasi
  void _handleUnauthenticatedUser() {
    // Jika tidak ada user yang login, arahkan ke halaman login
    if (Get.currentRoute != Routes.login) {
      print('Navigasi ke halaman login');
      // Bersihkan dependensi form sebelum navigasi
      clearFormDependencies();
      Get.offAllNamed(Routes.login);
    } else {
      print('Sudah berada di halaman login');
    }
  }

  // Memeriksa status profil warga
  Future<void> checkWargaProfileStatus() async {
    try {
      if (_user.value?.role == 'WARGA') {
        final wargaData = await _authProvider.getWargaData();
        isWargaProfileComplete.value = wargaData != null;
      } else {
        isWargaProfileComplete.value = true;
      }
    } catch (e) {
      print('Error checking warga profile: $e');
      isWargaProfileComplete.value = false;
    }
  }

  // Metode untuk membersihkan dependensi form
  void clearFormDependencies() {
    try {
      // Hapus fokus dari semua field
      FocusManager.instance.primaryFocus?.unfocus();

      // Reset form state jika ada
      loginFormKey.currentState?.reset();
      wargaProfileFormKey.currentState?.reset();
    } catch (e) {
      print('Error clearing form dependencies: $e');
    }
  }

  // Metode untuk navigasi berdasarkan peran
  void navigateBasedOnRole(String role) {
    // Bersihkan dependensi form sebelum navigasi
    clearFormDependencies();

    switch (role) {
      case 'WARGA':
        Get.offAllNamed(Routes.wargaDashboard);
        break;
      case 'PETUGASVERIFIKASI':
        Get.offAllNamed(Routes.petugasVerifikasiDashboard);
        break;
      case 'PETUGASDESA':
        Get.offAllNamed(Routes.petugasDesaDashboard);
        break;
      case 'DONATUR':
        Get.offAllNamed(Routes.donaturDashboard);
        break;
      default:
        Get.offAllNamed(Routes.home);
        break;
    }
  }

  // Metode untuk login
  Future<void> login() async {
    print('DEBUG: Memulai proses login');

    if (loginFormKey.currentState == null) {
      print('Error: loginFormKey.currentState adalah null');
      print('DEBUG: Form key: $loginFormKey');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan pada form login. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('DEBUG: Form state ditemukan, melakukan validasi');
    if (!loginFormKey.currentState!.validate()) {
      print('DEBUG: Validasi form gagal');
      return;
    }

    // Simpan nilai dari controller sebelum melakukan operasi asinkron
    final email = emailController.text.trim();
    final password = passwordController.text;
    print('DEBUG: Email: $email, Password length: ${password.length}');

    try {
      print('DEBUG: Mengatur isLoading ke true');
      isLoading.value = true;

      print('DEBUG: Memanggil _authProvider.signIn');
      final user = await _authProvider.signIn(
        email,
        password,
      );

      print('DEBUG: Hasil signIn: ${user != null ? 'Berhasil' : 'Gagal'}');
      if (user != null) {
        print('DEBUG: User ditemukan, role: ${user.role}');
        _user.value = user;
        _hasLoadedProfile.value = true; // Tandai bahwa profil sudah diambil
        clearControllers();

        // Arahkan ke dashboard sesuai peran
        print('DEBUG: Navigasi berdasarkan peran: ${user.role}');
        navigateBasedOnRole(user.role);
      } else {
        print('DEBUG: User null setelah login berhasil');
      }
    } catch (e) {
      print('DEBUG: Error detail pada login: $e');
      print('DEBUG: Stack trace: ${StackTrace.current}');
      Get.snackbar(
        'Error',
        'Login gagal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      print('DEBUG: Mengatur isLoading ke false');
      isLoading.value = false;
    }
  }

  // Metode untuk logout
  Future<void> logout() async {
    try {
      await _authProvider.signOut();
      _user.value = null;
      _hasLoadedProfile.value = false; // Reset flag saat logout
      isWargaProfileComplete.value = false;

      // Bersihkan dependensi form sebelum navigasi
      clearFormDependencies();

      Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout gagal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Metode untuk membersihkan controller
  void clearControllers() {
    try {
      if (emailController.text.isNotEmpty) emailController.clear();
      if (passwordController.text.isNotEmpty) passwordController.clear();
      if (confirmPasswordController.text.isNotEmpty) {
        confirmPasswordController.clear();
      }
    } catch (e) {
      print('Error clearing controllers: $e');
    }
  }

  // Validasi email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

  // Validasi password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // Validasi konfirmasi password
  String? validateConfirmPassword(String? value) {
    try {
      if (value == null || value.isEmpty) {
        return 'Konfirmasi password tidak boleh kosong';
      }

      // Ambil nilai password dari controller jika tersedia
      final password = passwordController.text;
      if (value != password) {
        return 'Password dan konfirmasi password tidak sama';
      }
      return null;
    } catch (e) {
      print('Error validating confirm password: $e');
      return 'Terjadi kesalahan saat validasi';
    }
  }

  // Mendapatkan rute target berdasarkan role
  String _getTargetRouteForRole(String role) {
    switch (role) {
      case 'WARGA':
        return Routes.wargaDashboard;
      case 'PETUGASVERIFIKASI':
        return Routes.petugasVerifikasiDashboard;
      case 'PETUGASDESA':
        return Routes.petugasDesaDashboard;
      case 'DONATUR':
        return Routes.donaturDashboard;
      default:
        return Routes.home;
    }
  }
}
