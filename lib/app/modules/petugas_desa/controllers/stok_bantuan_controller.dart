import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/stok_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class StokBantuanController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxBool isLoading = false.obs;
  final RxBool showInfoBanner = true.obs;

  // Data untuk stok bantuan
  final RxList<StokBantuanModel> daftarStokBantuan = <StokBantuanModel>[].obs;

  // Data untuk penitipan bantuan terverifikasi
  final RxList<Map<String, dynamic>> daftarPenitipanTerverifikasi =
      <Map<String, dynamic>>[].obs;

  // Data untuk kategori bantuan
  final RxList<Map<String, dynamic>> daftarKategoriBantuan =
      <Map<String, dynamic>>[].obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Filter untuk stok bantuan
  final RxString filterValue = 'semua'.obs;

  // Tambahkan properti untuk total dana bantuan
  RxDouble totalDanaBantuan = 0.0.obs;

  // Tambahkan properti untuk waktu terakhir update
  Rx<DateTime> lastUpdateTime = DateTime.now().obs;

  UserModel? get user => _authController.user;

  @override
  void onInit() {
    super.onInit();
    loadStokBantuanData();
    loadKategoriBantuanData();
    loadPenitipanTerverifikasi();

    // Listener untuk pencarian
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Metode untuk memperbarui data saat tab diaktifkan kembali
  void onTabReactivated() {
    print('Stok Bantuan tab reactivated - refreshing data');
    refreshData();
  }

  Future<void> loadStokBantuanData() async {
    isLoading.value = true;
    try {
      final stokBantuanData = await _supabaseService.getStokBantuan();
      if (stokBantuanData != null) {
        daftarStokBantuan.value = stokBantuanData
            .map((data) => StokBantuanModel.fromJson(data))
            .toList();

        // Hitung total dana bantuan
        _hitungTotalDanaBantuan();

        // Update waktu terakhir refresh
        lastUpdateTime.value = DateTime.now();
      }
    } catch (e) {
      print('Error loading stok bantuan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPenitipanTerverifikasi() async {
    try {
      final penitipanData =
          await _supabaseService.getPenitipanBantuanTerverifikasi();
      if (penitipanData != null) {
        daftarPenitipanTerverifikasi.value = penitipanData;
        // Tidak perlu lagi menghitung total stok dari penitipan
        // karena total_stok sudah dikelola oleh trigger database
      }
    } catch (e) {
      print('Error loading penitipan terverifikasi: $e');
    }
  }

  Future<void> loadKategoriBantuanData() async {
    try {
      final kategoriBantuanData = await _supabaseService.getKategoriBantuan();
      if (kategoriBantuanData != null) {
        daftarKategoriBantuan.value = kategoriBantuanData;
      }
    } catch (e) {
      print('Error loading kategori bantuan data: $e');
    }
  }

  Future<void> addStok(StokBantuanModel stok) async {
    try {
      // Buat data stok baru
      final stokData = stok.toJson();

      // Tambahkan total_stok = 0 untuk stok baru
      stokData['total_stok'] = 0.0;

      await _supabaseService.addStok(stokData);
      await loadStokBantuanData();
      Get.snackbar(
        'Sukses',
        'Stok bantuan berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error adding stok: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan stok bantuan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateStok(StokBantuanModel stok) async {
    try {
      // Buat data stok untuk update
      final stokData = stok.toJson();

      // Hapus field total_stok dari data yang akan dikirim ke database
      // karena total_stok dikelola oleh trigger database
      if (stokData.containsKey('total_stok')) {
        stokData.remove('total_stok');
      }

      await _supabaseService.updateStok(stok.id ?? '', stokData);
      await loadStokBantuanData();
      Get.snackbar(
        'Sukses',
        'Stok bantuan berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error updating stok: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui stok bantuan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteStok(String id) async {
    try {
      await _supabaseService.deleteStok(id);
      await loadStokBantuanData(); // Ini akan memanggil _hitungTotalDanaBantuan()
      Get.snackbar(
        'Sukses',
        'Stok bantuan berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error deleting stok: $e');
      Get.snackbar(
        'Error',
        'Gagal menghapus stok bantuan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await loadStokBantuanData();
    await loadPenitipanTerverifikasi();

    // Update waktu terakhir refresh
    lastUpdateTime.value = DateTime.now();

    isLoading.value = false;
  }

  List<StokBantuanModel> getFilteredStokBantuan() {
    var filteredList = <StokBantuanModel>[];

    // Filter berdasarkan jenis (uang/barang/hampir habis)
    switch (filterValue.value) {
      case 'uang':
        filteredList =
            daftarStokBantuan.where((item) => item.isUang == true).toList();
        break;
      case 'barang':
        filteredList =
            daftarStokBantuan.where((item) => item.isUang != true).toList();
        break;
      case 'hampir_habis':
        filteredList = daftarStokBantuan
            .where((item) => (item.totalStok ?? 0) <= 10)
            .toList();
        break;
      default: // 'semua'
        filteredList = daftarStokBantuan.toList();
    }

    // Filter berdasarkan pencarian jika ada
    if (searchQuery.isNotEmpty) {
      return filteredList
          .where((item) =>
              (item.nama
                      ?.toLowerCase()
                      .contains(searchQuery.value.toLowerCase()) ??
                  false) ||
              (item.satuan
                      ?.toLowerCase()
                      .contains(searchQuery.value.toLowerCase()) ??
                  false) ||
              (item.deskripsi
                      ?.toLowerCase()
                      .contains(searchQuery.value.toLowerCase()) ??
                  false))
          .toList();
    }

    return filteredList;
  }

  // Metode untuk mendapatkan jumlah stok yang hampir habis (stok <= 10)
  int getStokHampirHabis() {
    return daftarStokBantuan
        .where((stok) => (stok.totalStok ?? 0) <= 10)
        .length;
  }

  // Metode untuk menghitung total dana bantuan
  void _hitungTotalDanaBantuan() {
    double total = 0.0;
    for (var stok in daftarStokBantuan) {
      if (stok.isUang == true) {
        total += stok.totalStok ?? 0.0;
      }
    }
    totalDanaBantuan.value = total;
  }

  // Metode untuk mengatur filter
  void setFilter(String value) {
    filterValue.value = value;
  }
}
