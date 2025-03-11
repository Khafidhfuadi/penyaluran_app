import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/data/models/notifikasi_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class PetugasDesaDashboardController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxBool isLoading = false.obs;

  // Data profil pengguna dari cache
  final RxMap<String, dynamic> userProfile = RxMap<String, dynamic>({});

  // Data untuk dashboard
  final RxInt totalPenerima = 0.obs;
  final RxInt totalBantuan = 0.obs;
  final RxInt totalPenyaluran = 0.obs;
  final RxDouble progressPenyaluran = 0.0.obs;

  // Data untuk notifikasi
  final RxList<NotifikasiModel> notifikasiBelumDibaca = <NotifikasiModel>[].obs;
  final RxInt jumlahNotifikasiBelumDibaca = 0.obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();

  UserModel? get user => _authController.user;
  String get role => user?.role ?? 'PETUGASDESA';
  String get nama => user?.name ?? 'Petugas Desa';

  // Getter untuk nama lengkap dari profil pengguna
  String get namaLengkap => userProfile['name'] ?? user?.name ?? 'Petugas Desa';

  // Getter untuk nama desa dari profil pengguna
  String get desa =>
      userProfile['desa']?['nama'] ??
      (userProfile['desa_id'] != null ? 'Desa' : 'Desa');

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadDashboardData();
    loadNotifikasiData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Metode untuk memuat data profil pengguna dari cache
  Future<void> loadUserProfile() async {
    try {
      // Jika user sudah ada di AuthController, tidak perlu mengambil data lagi
      if (user != null) {
        // Ambil data tambahan jika diperlukan, tapi gunakan cache
        final profileData = await _supabaseService.getUserProfile();
        if (profileData != null) {
          userProfile.value = profileData;
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      // Mengambil data total penerima
      final penerimaData = await _supabaseService.getTotalPenerima();
      totalPenerima.value = penerimaData ?? 0;

      // Mengambil data total bantuan
      final bantuanData = await _supabaseService.getTotalBantuan();
      totalBantuan.value = bantuanData ?? 0;

      // Mengambil data total penyaluran
      final penyaluranData = await _supabaseService.getTotalPenyaluran();
      totalPenyaluran.value = penyaluranData ?? 0;

      // Menghitung progress penyaluran
      if (totalBantuan.value > 0) {
        progressPenyaluran.value =
            (totalPenyaluran.value / totalBantuan.value) * 100;
      } else {
        progressPenyaluran.value = 0.0;
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNotifikasiData() async {
    try {
      final notifikasiData =
          await _supabaseService.getNotifikasiBelumDibaca(user?.id ?? '');

      if (notifikasiData != null) {
        notifikasiBelumDibaca.value = notifikasiData
            .map((data) => NotifikasiModel.fromJson(data))
            .toList();
        jumlahNotifikasiBelumDibaca.value = notifikasiBelumDibaca.length;
      }
    } catch (e) {
      print('Error loading notifikasi data: $e');
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await loadDashboardData();
      await loadNotifikasiData();
    } finally {
      isLoading.value = false;
    }
  }
}
