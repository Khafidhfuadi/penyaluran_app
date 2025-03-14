import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/laporan_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class LaporanController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxBool isLoading = false.obs;

  // Indeks kategori yang dipilih untuk filter
  final RxInt selectedCategoryIndex = 0.obs;

  // Data untuk laporan
  final RxList<LaporanModel> daftarLaporan = <LaporanModel>[].obs;

  // Filter tanggal
  final Rx<DateTime?> tanggalMulai = Rx<DateTime?>(null);
  final Rx<DateTime?> tanggalSelesai = Rx<DateTime?>(null);

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();

  UserModel? get user => _authController.user;

  @override
  void onInit() {
    super.onInit();
    // Set default tanggal filter (1 bulan terakhir)
    tanggalSelesai.value = DateTime.now();
    tanggalMulai.value = DateTime.now().subtract(const Duration(days: 30));
    loadLaporanData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadLaporanData() async {
    isLoading.value = true;
    try {
      final laporanData = await _supabaseService.getLaporan(
        tanggalMulai.value,
        tanggalSelesai.value,
      );
      if (laporanData != null) {
        daftarLaporan.value =
            laporanData.map((data) => LaporanModel.fromJson(data)).toList();
      }
    } catch (e) {
      print('Error loading laporan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateLaporan(String jenis) async {
    isLoading.value = true;
    try {
      final laporan = LaporanModel(
        jenis: jenis,
        tanggalMulai: tanggalMulai.value,
        tanggalSelesai: tanggalSelesai.value,
        petugasId: user?.id,
        createdAt: DateTime.now(),
      );

      final laporanId =
          await _supabaseService.generateLaporan(laporan.toJson());

      if (laporanId != null) {
        await loadLaporanData();
        Get.snackbar(
          'Sukses',
          'Laporan berhasil dibuat',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error generating laporan: $e');
      Get.snackbar(
        'Error',
        'Gagal membuat laporan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadLaporan(String laporanId) async {
    isLoading.value = true;
    try {
      final url = await _supabaseService.downloadLaporan(laporanId);
      if (url != null) {
        // Implementasi download file
        Get.snackbar(
          'Sukses',
          'Laporan berhasil diunduh',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error downloading laporan: $e');
      Get.snackbar(
        'Error',
        'Gagal mengunduh laporan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteLaporan(String laporanId) async {
    isLoading.value = true;
    try {
      await _supabaseService.deleteLaporan(laporanId);
      await loadLaporanData();
      Get.snackbar(
        'Sukses',
        'Laporan berhasil dihapus',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error deleting laporan: $e');
      Get.snackbar(
        'Error',
        'Gagal menghapus laporan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setTanggalMulai(DateTime tanggal) {
    tanggalMulai.value = tanggal;
  }

  void setTanggalSelesai(DateTime tanggal) {
    tanggalSelesai.value = tanggal;
  }

  Future<void> applyFilter() async {
    await loadLaporanData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await loadLaporanData();
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  List<LaporanModel> getFilteredLaporan() {
    switch (selectedCategoryIndex.value) {
      case 0:
        return daftarLaporan;
      case 1:
        return daftarLaporan
            .where((item) => item.jenis == 'PENYALURAN')
            .toList();
      case 2:
        return daftarLaporan
            .where((item) => item.jenis == 'STOK_BANTUAN')
            .toList();
      case 3:
        return daftarLaporan.where((item) => item.jenis == 'PENERIMA').toList();
      default:
        return daftarLaporan;
    }
  }
}
