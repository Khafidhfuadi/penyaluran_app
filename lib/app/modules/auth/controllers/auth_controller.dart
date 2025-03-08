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

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
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
    isLoading.value = true;
    try {
      final currentUser = await _authProvider.getCurrentUser();
      if (currentUser != null) {
        _user.value = currentUser;

        // Periksa apakah profil warga sudah lengkap
        await checkWargaProfileStatus();

        // Hindari navigasi jika sudah berada di halaman yang sesuai
        final currentRoute = Get.currentRoute;

        // Untuk semua role, arahkan ke dashboard masing-masing
        final targetRoute = _getTargetRouteForRole(currentUser.role);
        if (currentRoute != targetRoute) {
          navigateBasedOnRole(currentUser.role);
        }
      } else {
        // Jika tidak ada user yang login, arahkan ke halaman login
        if (Get.currentRoute != Routes.login) {
          // Bersihkan dependensi form sebelum navigasi
          clearFormDependencies();
          Get.offAllNamed(Routes.login);
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
      // Jika terjadi error, arahkan ke halaman login
      if (Get.currentRoute != Routes.login) {
        // Bersihkan dependensi form sebelum navigasi
        clearFormDependencies();
        Get.offAllNamed(Routes.login);
      }
    } finally {
      isLoading.value = false;
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
      registerFormKey.currentState?.reset();
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
    if (!loginFormKey.currentState!.validate()) return;

    // Simpan nilai dari controller sebelum melakukan operasi asinkron
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      isLoading.value = true;
      final user = await _authProvider.signIn(
        email,
        password,
      );

      if (user != null) {
        _user.value = user;
        clearControllers();

        // Periksa apakah profil warga sudah lengkap
        await checkWargaProfileStatus();

        // Arahkan ke dashboard sesuai peran
        navigateBasedOnRole(user.role);

        // Tampilkan notifikasi jika profil belum lengkap untuk warga
        if (user.role == 'WARGA' && !isWargaProfileComplete.value) {
          Get.snackbar(
            'Informasi',
            'Profil Anda belum lengkap. Silakan lengkapi profil Anda melalui menu Profil',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        } else {
          Get.snackbar(
            'Berhasil',
            'Login berhasil',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error login: $e');
      Get.snackbar(
        'Error',
        'Login gagal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Metode untuk register
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    // Simpan nilai dari controller sebelum melakukan operasi asinkron
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      Get.snackbar(
        'Error',
        'Password dan konfirmasi password tidak sama',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final user = await _authProvider.signUp(
        email,
        password,
      );

      if (user != null) {
        _user.value = user;
        clearControllers();

        // Periksa status profil
        await checkWargaProfileStatus();

        // Arahkan ke dashboard sesuai peran
        navigateBasedOnRole(user.role);

        // Tampilkan notifikasi untuk melengkapi profil
        Get.snackbar(
          'Berhasil',
          'Registrasi berhasil. Silakan lengkapi profil Anda melalui menu Profil',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registrasi gagal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Metode untuk logout
  Future<void> logout() async {
    try {
      await _authProvider.signOut();
      _user.value = null;
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

  // Validasi NIK
  String? validateNIK(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK tidak boleh kosong';
    }
    if (value.length != 16) {
      return 'NIK harus 16 digit';
    }
    if (!GetUtils.isNumericOnly(value)) {
      return 'NIK harus berupa angka';
    }
    return null;
  }

  // Validasi nama lengkap
  String? validateNamaLengkap(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    return null;
  }

  // Validasi jenis kelamin
  String? validateJenisKelamin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jenis kelamin tidak boleh kosong';
    }
    return null;
  }

  // Mendapatkan rute target berdasarkan peran
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
