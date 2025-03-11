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

  // Data untuk stok bantuan
  final RxList<StokBantuanModel> daftarStokBantuan = <StokBantuanModel>[].obs;
  final RxDouble totalStok = 0.0.obs;
  final RxDouble stokMasuk = 0.0.obs;
  final RxDouble stokKeluar = 0.0.obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  UserModel? get user => _authController.user;

  @override
  void onInit() {
    super.onInit();
    loadStokBantuanData();

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

  Future<void> loadStokBantuanData() async {
    isLoading.value = true;
    try {
      final stokBantuanData = await _supabaseService.getStokBantuan();
      if (stokBantuanData != null) {
        daftarStokBantuan.value = stokBantuanData
            .map((data) => StokBantuanModel.fromJson(data))
            .toList();

        // Hitung total stok
        totalStok.value = 0;
        for (var item in daftarStokBantuan) {
          totalStok.value += item.jumlah ?? 0;
        }

        // Ambil data stok masuk dan keluar
        final stokData = await _supabaseService.getStokStatistics();
        if (stokData != null) {
          stokMasuk.value = stokData['masuk'] ?? 0;
          stokKeluar.value = stokData['keluar'] ?? 0;
        }
      }
    } catch (e) {
      print('Error loading stok bantuan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addStok(StokBantuanModel stok) async {
    isLoading.value = true;
    try {
      await _supabaseService.addStok(stok.toJson());
      await loadStokBantuanData();
      Get.snackbar(
        'Sukses',
        'Stok berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error adding stok: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan stok: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStok(StokBantuanModel stok) async {
    isLoading.value = true;
    try {
      await _supabaseService.updateStok(stok.id ?? '', stok.toJson());
      await loadStokBantuanData();
      Get.snackbar(
        'Sukses',
        'Stok berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error updating stok: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui stok: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStok(String stokId) async {
    isLoading.value = true;
    try {
      await _supabaseService.deleteStok(stokId);
      await loadStokBantuanData();
      Get.snackbar(
        'Sukses',
        'Stok berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error deleting stok: $e');
      Get.snackbar(
        'Error',
        'Gagal menghapus stok: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await loadStokBantuanData();
    } finally {
      isLoading.value = false;
    }
  }

  List<StokBantuanModel> getFilteredStokBantuan() {
    if (searchQuery.isEmpty) {
      return daftarStokBantuan;
    } else {
      return daftarStokBantuan
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
  }
}
