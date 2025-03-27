import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/riwayat_stok_model.dart';
import 'package:penyaluran_app/app/data/models/stok_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RiwayatStokController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;
  final ImagePicker _imagePicker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxList<RiwayatStokModel> daftarRiwayatStok = <RiwayatStokModel>[].obs;
  final RxList<StokBantuanModel> daftarStokBantuan = <StokBantuanModel>[].obs;

  // Filter untuk riwayat stok
  final RxString filterJenisPerubahan = 'semua'.obs;
  final RxString filterStokBantuanId = 'semua'.obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Data untuk form penambahan/pengurangan manual
  final Rx<StokBantuanModel?> selectedStokBantuan = Rx<StokBantuanModel?>(null);
  final RxDouble jumlah = 0.0.obs;
  final RxString alasan = ''.obs;
  final Rx<File?> fotoBukti = Rx<File?>(null);
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRiwayatStok();
    loadStokBantuan();

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
    refreshData();
  }

  Future<void> loadRiwayatStok() async {
    isLoading.value = true;
    try {
      final String? stokBantuanId = filterStokBantuanId.value != 'semua'
          ? filterStokBantuanId.value
          : null;

      final String? jenisPerubahan = filterJenisPerubahan.value != 'semua'
          ? filterJenisPerubahan.value
          : null;

      final riwayatStokData = await _supabaseService.getRiwayatStok(
        stokBantuanId: stokBantuanId,
        jenisPerubahan: jenisPerubahan,
      );

      if (riwayatStokData != null) {
        daftarRiwayatStok.value = riwayatStokData
            .map((data) => RiwayatStokModel.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error loading riwayat stok data: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data riwayat stok: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStokBantuan() async {
    try {
      final stokBantuanData = await _supabaseService.getStokBantuan();
      if (stokBantuanData != null) {
        daftarStokBantuan.value = stokBantuanData
            .map((data) => StokBantuanModel.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error loading stok bantuan data: $e');
    }
  }

  Future<void> refreshData() async {
    await loadRiwayatStok();
    await loadStokBantuan();
  }

  void filterByJenisPerubahan(String value) {
    filterJenisPerubahan.value = value;
    loadRiwayatStok();
  }

  void filterByStokBantuan(String value) {
    filterStokBantuanId.value = value;
    loadRiwayatStok();
  }

  List<RiwayatStokModel> getFilteredRiwayatStok() {
    if (searchQuery.isEmpty) {
      return daftarRiwayatStok;
    }

    return daftarRiwayatStok.where((item) {
      // Cari berdasarkan nama stok bantuan
      final stokBantuanMatch = item.stokBantuan != null &&
          item.stokBantuan!['nama'] != null &&
          item.stokBantuan!['nama']
              .toString()
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());

      // Cari berdasarkan alasan
      final alasanMatch = item.alasan != null &&
          item.alasan!.toLowerCase().contains(searchQuery.value.toLowerCase());

      // Cari berdasarkan sumber
      final sumberMatch = item.sumber != null &&
          item.sumber!.toLowerCase().contains(searchQuery.value.toLowerCase());

      return stokBantuanMatch || alasanMatch || sumberMatch;
    }).toList();
  }

  Future<void> tambahStokManual() async {
    isSubmitting.value = true;
    try {
      if (selectedStokBantuan.value == null) {
        throw Exception('Pilih bantuan terlebih dahulu');
      }

      if (jumlah.value <= 0) {
        throw Exception('Jumlah harus lebih dari 0');
      }

      if (alasan.value.isEmpty) {
        throw Exception('Alasan harus diisi');
      }

      if (fotoBukti.value == null) {
        throw Exception('Foto bukti harus diupload');
      }

      final petugasId = _authController.baseUser?.id;
      if (petugasId == null) {
        throw Exception('ID petugas tidak ditemukan');
      }

      await _supabaseService.tambahStokManual(
        stokBantuanId: selectedStokBantuan.value!.id!,
        jumlah: jumlah.value,
        alasan: alasan.value,
        fotoBuktiPath: fotoBukti.value!.path,
        petugasId: petugasId,
      );

      // Reset form
      resetForm();

      // Refresh data
      await refreshData();

      Get.back(); // Tutup dialog

      Get.snackbar(
        'Sukses',
        'Stok bantuan berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error menambahkan stok manual: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan stok: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> kurangiStokManual() async {
    isSubmitting.value = true;
    try {
      if (selectedStokBantuan.value == null) {
        throw Exception('Pilih bantuan terlebih dahulu');
      }

      if (jumlah.value <= 0) {
        throw Exception('Jumlah harus lebih dari 0');
      }

      if (alasan.value.isEmpty) {
        throw Exception('Alasan harus diisi');
      }

      if (fotoBukti.value == null) {
        throw Exception('Foto bukti harus diupload');
      }

      final petugasId = _authController.baseUser?.id;
      if (petugasId == null) {
        throw Exception('ID petugas tidak ditemukan');
      }

      await _supabaseService.kurangiStokManual(
        stokBantuanId: selectedStokBantuan.value!.id!,
        jumlah: jumlah.value,
        alasan: alasan.value,
        fotoBuktiPath: fotoBukti.value!.path,
        petugasId: petugasId,
      );

      // Reset form
      resetForm();

      // Refresh data
      await refreshData();

      Get.back(); // Tutup dialog

      Get.snackbar(
        'Sukses',
        'Stok bantuan berhasil dikurangi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error mengurangi stok manual: $e');
      Get.snackbar(
        'Error',
        'Gagal mengurangi stok: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void setSelectedStokBantuan(StokBantuanModel? stokBantuan) {
    selectedStokBantuan.value = stokBantuan;
  }

  void setJumlah(double value) {
    jumlah.value = value;
  }

  void setAlasan(String value) {
    alasan.value = value;
  }

  Future<void> pickImage() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        fotoBukti.value = File(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void resetForm() {
    selectedStokBantuan.value = null;
    jumlah.value = 0.0;
    alasan.value = '';
    fotoBukti.value = null;
  }

  // Metode untuk mendapatkan detail referensi berdasarkan id dan sumber
  Future<Map<String, dynamic>?> getReferensiDetail({
    required String idReferensi,
    required String sumber,
  }) async {
    try {
      Map<String, dynamic>? data;

      // Berdasarkan sumber, ambil data dari tabel yang sesuai
      if (sumber == 'penitipan') {
        data = await _supabaseService.getPenitipanById(idReferensi);
      } else if (sumber == 'penerimaan') {
        data = await _supabaseService.getPenerimaanById(idReferensi);
      }

      return data;
    } catch (e) {
      print('Error getting referensi detail: $e');
      throw Exception('Gagal mendapatkan data: $e');
    }
  }
}
