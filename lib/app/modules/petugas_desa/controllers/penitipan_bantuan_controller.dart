import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class PenitipanBantuanController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxBool isLoading = false.obs;

  // Indeks kategori yang dipilih untuk filter
  final RxInt selectedCategoryIndex = 0.obs;

  // Data untuk penitipan
  final RxList<PenitipanBantuanModel> daftarPenitipan =
      <PenitipanBantuanModel>[].obs;
  final RxInt jumlahMenunggu = 0.obs;
  final RxInt jumlahTerverifikasi = 0.obs;
  final RxInt jumlahDitolak = 0.obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();

  UserModel? get user => _authController.user;

  @override
  void onInit() {
    super.onInit();
    loadPenitipanData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadPenitipanData() async {
    isLoading.value = true;
    try {
      final penitipanData = await _supabaseService.getPenitipanBantuan();
      if (penitipanData != null) {
        daftarPenitipan.value = penitipanData
            .map((data) => PenitipanBantuanModel.fromJson(data))
            .toList();

        // Hitung jumlah berdasarkan status
        jumlahMenunggu.value =
            daftarPenitipan.where((item) => item.status == 'MENUNGGU').length;
        jumlahTerverifikasi.value = daftarPenitipan
            .where((item) => item.status == 'TERVERIFIKASI')
            .length;
        jumlahDitolak.value =
            daftarPenitipan.where((item) => item.status == 'DITOLAK').length;
      }
    } catch (e) {
      print('Error loading penitipan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifikasiPenitipan(String penitipanId) async {
    isLoading.value = true;
    try {
      await _supabaseService.verifikasiPenitipan(penitipanId);
      await loadPenitipanData();
      Get.snackbar(
        'Sukses',
        'Penitipan berhasil diverifikasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error verifying penitipan: $e');
      Get.snackbar(
        'Error',
        'Gagal memverifikasi penitipan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> tolakPenitipan(String penitipanId, String alasan) async {
    isLoading.value = true;
    try {
      await _supabaseService.tolakPenitipan(penitipanId, alasan);
      await loadPenitipanData();
      Get.snackbar(
        'Sukses',
        'Penitipan berhasil ditolak',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error rejecting penitipan: $e');
      Get.snackbar(
        'Error',
        'Gagal menolak penitipan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<DonaturModel?> getDonaturInfo(String donaturId) async {
    try {
      final donaturData = await _supabaseService.getDonaturById(donaturId);
      if (donaturData != null) {
        return DonaturModel.fromJson(donaturData);
      }
      return null;
    } catch (e) {
      print('Error getting donatur info: $e');
      return null;
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await loadPenitipanData();
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  List<PenitipanBantuanModel> getFilteredPenitipan() {
    switch (selectedCategoryIndex.value) {
      case 0:
        return daftarPenitipan;
      case 1:
        return daftarPenitipan
            .where((item) => item.status == 'MENUNGGU')
            .toList();
      case 2:
        return daftarPenitipan
            .where((item) => item.status == 'TERVERIFIKASI')
            .toList();
      case 3:
        return daftarPenitipan
            .where((item) => item.status == 'DITOLAK')
            .toList();
      default:
        return daftarPenitipan;
    }
  }
}
