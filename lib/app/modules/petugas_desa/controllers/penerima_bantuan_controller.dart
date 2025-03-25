import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/warga_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class PenerimaBantuanController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxBool isLoading = false.obs;

  // Indeks kategori yang dipilih untuk filter
  final RxInt selectedCategoryIndex = 0.obs;

  // Data untuk penerima bantuan
  final RxList<WargaModel> daftarPenerima = <WargaModel>[].obs;
  final RxInt totalPenerima = 0.obs;
  final RxInt totalPenerimaAktif = 0.obs;
  final RxInt totalPenerimaNonaktif = 0.obs;

  // Controller untuk pencarian dan form
  final TextEditingController searchController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  // Form key
  final GlobalKey<FormState> penerimaFormKey = GlobalKey<FormState>();

  BaseUserModel? get user => _authController.baseUser;

  @override
  void onInit() {
    super.onInit();
    loadPenerimaData();
  }

  @override
  void onClose() {
    searchController.dispose();
    namaController.dispose();
    nikController.dispose();
    alamatController.dispose();
    teleponController.dispose();
    emailController.dispose();
    catatanController.dispose();
    super.onClose();
  }

  Future<void> loadPenerimaData() async {
    isLoading.value = true;
    try {
      final penerimaData = await _supabaseService.getPenerimaBantuan();
      if (penerimaData != null) {
        daftarPenerima.value =
            penerimaData.map((data) => WargaModel.fromJson(data)).toList();

        // Hitung total
        totalPenerima.value = daftarPenerima.length;
        totalPenerimaAktif.value =
            daftarPenerima.where((item) => item.status == 'AKTIF').length;
        totalPenerimaNonaktif.value =
            daftarPenerima.where((item) => item.status == 'NONAKTIF').length;
      }
    } catch (e) {
      print('Error loading penerima data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> tambahPenerima() async {
    if (!penerimaFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // Biarkan Supabase yang akan menghasilkan ID saat insert
      // Kita hanya perlu menyediakan data lainnya
      final penerima = {
        'nama_lengkap': namaController.text,
        'nik': nikController.text,
        'alamat': alamatController.text,
        'no_hp': teleponController.text,
        'email': emailController.text,
        'catatan': catatanController.text,
        'status': 'AKTIF',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.tambahPenerima(penerima);

      // Clear form
      clearForm();

      await loadPenerimaData();
      Get.back(); // Close dialog

      Get.snackbar(
        'Sukses',
        'Penerima bantuan berhasil ditambahkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error adding penerima: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan penerima bantuan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePenerima(String penerimaId) async {
    if (!penerimaFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final penerima = {
        'nama_lengkap': namaController.text,
        'nik': nikController.text,
        'alamat': alamatController.text,
        'no_hp': teleponController.text,
        'email': emailController.text,
        'catatan': catatanController.text,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.updatePenerima(penerimaId, penerima);

      // Clear form
      clearForm();

      await loadPenerimaData();
      Get.back(); // Close dialog

      Get.snackbar(
        'Sukses',
        'Penerima bantuan berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error updating penerima: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui penerima bantuan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> nonaktifkanPenerima(String penerimaId) async {
    isLoading.value = true;
    try {
      await _supabaseService.updateStatusPenerima(penerimaId, 'NONAKTIF');
      await loadPenerimaData();
      Get.snackbar(
        'Sukses',
        'Penerima bantuan berhasil dinonaktifkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error deactivating penerima: $e');
      Get.snackbar(
        'Error',
        'Gagal menonaktifkan penerima bantuan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> aktifkanPenerima(String penerimaId) async {
    isLoading.value = true;
    try {
      await _supabaseService.updateStatusPenerima(penerimaId, 'AKTIF');
      await loadPenerimaData();
      Get.snackbar(
        'Sukses',
        'Penerima bantuan berhasil diaktifkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error activating penerima: $e');
      Get.snackbar(
        'Error',
        'Gagal mengaktifkan penerima bantuan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setFormData(WargaModel penerima) {
    namaController.text = penerima.namaLengkap ?? '';
    nikController.text = penerima.nik ?? '';
    alamatController.text = penerima.alamat ?? '';
    teleponController.text = penerima.noHp ?? '';
    emailController.text = penerima.email ?? '';
    catatanController.text = penerima.catatan ?? '';
  }

  void clearForm() {
    namaController.clear();
    nikController.clear();
    alamatController.clear();
    teleponController.clear();
    emailController.clear();
    catatanController.clear();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await loadPenerimaData();
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  List<WargaModel> getFilteredPenerima() {
    switch (selectedCategoryIndex.value) {
      case 0:
        return daftarPenerima;
      case 1:
        return daftarPenerima.where((item) => item.status == 'AKTIF').toList();
      case 2:
        return daftarPenerima
            .where((item) => item.status == 'NONAKTIF')
            .toList();
      default:
        return daftarPenerima;
    }
  }

  // Validasi form
  String? validateNama(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    return null;
  }

  String? validateNIK(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK tidak boleh kosong';
    }
    if (value.length != 16) {
      return 'NIK harus 16 digit';
    }
    return null;
  }

  String? validateAlamat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat tidak boleh kosong';
    }
    return null;
  }

  String? validateTelepon(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email boleh kosong
    }
    if (!GetUtils.isEmail(value)) {
      return 'Email tidak valid';
    }
    return null;
  }
}
