import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
import 'package:penyaluran_app/app/data/models/petugas_desa_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/data/models/warga_model.dart';
import 'package:penyaluran_app/app/data/providers/auth_provider.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final AuthProvider _authProvider = AuthProvider();

  final Rx<UserData?> _userData = Rx<UserData?>(null);
  UserData? get userData => _userData.value;

  // Getter untuk BaseUserModel
  BaseUserModel? get baseUser => _userData.value?.baseUser;

  // Getter untuk role
  String get role => _userData.value?.baseUser.roleName.toLowerCase() ?? '';

  // Getter dinamis untuk data role-specific
  dynamic get roleData => _userData.value?.roleData;

  // Getter untuk memeriksa tipe roleData
  bool get isWarga =>
      _userData.value?.roleData is WargaModel && role == 'warga';
  bool get isDonatur =>
      _userData.value?.roleData is DonaturModel && role == 'donatur';
  bool get isPetugasDesa =>
      _userData.value?.roleData is PetugasDesaModel && role == 'petugas_desa';

  // Helper method untuk mendapatkan nama display
  String get displayName {
    if (roleData == null) return baseUser?.email ?? 'Pengguna';

    if (isWarga) {
      return (roleData as WargaModel).displayName;
    } else if (isDonatur) {
      return (roleData as DonaturModel).displayName;
    } else if (isPetugasDesa) {
      return (roleData as PetugasDesaModel).displayName;
    }

    return baseUser?.email ?? 'Pengguna';
  }

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
    // Dispose controller registrasi donatur
    confirmPasswordController.dispose();
    namaController.dispose();
    alamatController.dispose();
    noHpController.dispose();
    jenisController.dispose();
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
      if (_userData.value != null && _hasLoadedProfile.value) {
        print('Menggunakan data user yang sudah ada di memori');
        _handleAuthenticatedUser(_userData.value!);
        return;
      }

      // Jika belum ada data user, ambil dari provider
      final currentUserData = await _authProvider.getCurrentUser();

      if (currentUserData != null) {
        print(
            'User terautentikasi: ${currentUserData.baseUser.email}, role: ${currentUserData.baseUser.roleName}');
        _userData.value = currentUserData;
        _hasLoadedProfile.value = true;
        _handleAuthenticatedUser(currentUserData);
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
  void _handleAuthenticatedUser(UserData userData) {
    // Hindari navigasi jika sudah berada di halaman yang sesuai
    final currentRoute = Get.currentRoute;
    print('Rute saat ini: $currentRoute');

    // Dapatkan role dari BaseUserModel
    final role = userData.baseUser.roleName.toLowerCase();
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
      if (role == 'warga') {
        isWargaProfileComplete.value = roleData != null;
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

    switch (role.toLowerCase()) {
      case 'warga':
        Get.offAllNamed(Routes.wargaDashboard);
        break;
      case 'petugas_desa':
        Get.offAllNamed(Routes.petugasDesaDashboard);
        break;
      case 'donatur':
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
        snackPosition: SnackPosition.TOP,
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
      final userData = await _authProvider.signIn(
        email,
        password,
      );

      print('DEBUG: Hasil signIn: ${userData != null ? 'Berhasil' : 'Gagal'}');
      if (userData != null) {
        print('DEBUG: User ditemukan, role: ${userData.baseUser.roleName}');
        _userData.value = userData;
        _hasLoadedProfile.value = true; // Tandai bahwa profil sudah diambil
        clearControllers();

        // Arahkan ke dashboard sesuai peran
        print(
            'DEBUG: Navigasi berdasarkan peran: ${userData.baseUser.roleName}');
        navigateBasedOnRole(userData.baseUser.roleName.toLowerCase());
      } else {
        print('DEBUG: User null setelah login berhasil');
        handleLoginError(Exception('Data pengguna tidak ditemukan'));
      }
    } catch (e) {
      handleLoginError(e);
    } finally {
      print('DEBUG: Mengatur isLoading ke false');
      isLoading.value = false;
    }
  }

  // Menangani error saat login
  void handleLoginError(dynamic error) {
    print('DEBUG: Error login: $error');

    String errorMessage = 'Terjadi kesalahan saat login. Silakan coba lagi.';

    if (error.toString().contains('Invalid login credentials')) {
      errorMessage = 'Email atau password salah. Silakan coba lagi.';
    } else if (error.toString().contains('Too many requests')) {
      errorMessage = 'Terlalu banyak percobaan login. Silakan coba lagi nanti.';
    }

    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Metode untuk membersihkan controller
  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  // Metode untuk logout
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authProvider.signOut();
      _userData.value = null;
      _hasLoadedProfile.value = false;
      Get.offAllNamed(Routes.login);
    } catch (e) {
      print('Error saat logout: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat logout. Silakan coba lagi.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != passwordController.text) {
      return 'Password dan konfirmasi password tidak sama';
    }
    return null;
  }

  // Metode untuk refresh data user setelah update profil
  Future<void> refreshUserData() async {
    try {
      print('Memperbarui data pengguna...');
      isLoading.value = true;

      // Hapus cache profil yang sudah tidak valid
      _hasLoadedProfile.value = false;

      // Ambil data user terbaru dari provider dengan menskip cache
      final currentUserData =
          await _authProvider.getCurrentUser(skipCache: true);

      if (currentUserData != null) {
        print(
            'Data pengguna berhasil diperbarui: ${currentUserData.baseUser.name}');
        _userData.value = currentUserData;
        _hasLoadedProfile.value = true;
      } else {
        print('Gagal memperbarui data pengguna');
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mendapatkan rute target berdasarkan role
  String _getTargetRouteForRole(String role) {
    switch (role.toLowerCase()) {
      case 'warga':
        return Routes.wargaDashboard;
      case 'petugas_desa':
        return Routes.petugasDesaDashboard;
      case 'donatur':
        return Routes.donaturDashboard;
      default:
        return Routes.home;
    }
  }

  // Metode untuk validasi form registrasi donatur
  String? validateDonaturNama(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    return null;
  }

  String? validateDonaturNoHp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor HP tidak boleh kosong';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor HP hanya boleh berisi angka';
    }
    return null;
  }

  String? validateDonaturAlamat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat tidak boleh kosong';
    }
    return null;
  }

  // Form controller untuk registrasi donatur
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController jenisController = TextEditingController();

  // Form key untuk registrasi donatur
  final GlobalKey<FormState> registerDonaturFormKey = GlobalKey<FormState>();

  // Metode untuk registrasi donatur
  Future<void> registerDonatur() async {
    print('DEBUG: Memulai proses registrasi donatur');

    if (registerDonaturFormKey.currentState == null) {
      print('Error: registerDonaturFormKey.currentState adalah null');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan pada form registrasi. Silakan coba lagi.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!registerDonaturFormKey.currentState!.validate()) {
      print('DEBUG: Validasi form gagal');
      return;
    }

    isLoading.value = true;
    try {
      // Proses registrasi donatur dengan role_id 3
      await _authProvider.signUpDonatur(
        email: emailController.text,
        password: passwordController.text,
        namaLengkap: namaController.text,
        alamat: alamatController.text,
        noHp: noHpController.text,
        jenis: jenisController.text.isEmpty ? 'Individu' : jenisController.text,
      );

      Get.snackbar(
        'Sukses',
        'Registrasi donatur berhasil! Silakan login dengan akun Anda.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Bersihkan form
      clearDonaturRegistrationForm();

      // Arahkan ke halaman login
      Get.offAllNamed(Routes.login);
    } catch (e) {
      print('Error registrasi donatur: $e');

      String errorMessage = 'Gagal melakukan registrasi';

      // Tangani error sesuai jenisnya
      if (e.toString().contains('email konfirmasi')) {
        errorMessage =
            'Gagal mengirim email konfirmasi. Mohon periksa alamat email Anda dan coba lagi nanti.';
      } else if (e.toString().contains('Email sudah terdaftar')) {
        errorMessage =
            'Email sudah terdaftar. Silakan gunakan email lain atau login dengan email tersebut.';
      } else if (e.toString().contains('weak-password')) {
        errorMessage =
            'Password terlalu lemah. Gunakan kombinasi huruf, angka, dan simbol.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Format email tidak valid.';
      } else {
        errorMessage = 'Gagal melakukan registrasi: ${e.toString()}';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Metode untuk membersihkan form registrasi donatur
  void clearDonaturRegistrationForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    namaController.clear();
    alamatController.clear();
    noHpController.clear();
    jenisController.clear();
  }
}
