import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/tindakan_pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class PengaduanController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxBool isLoading = false.obs;

  // Indeks kategori yang dipilih untuk filter
  final RxInt selectedCategoryIndex = 0.obs;

  // Data untuk pengaduan
  final RxList<PengaduanModel> daftarPengaduan = <PengaduanModel>[].obs;
  final RxInt jumlahDiproses = 0.obs;
  final RxInt jumlahTindakan = 0.obs;
  final RxInt jumlahSelesai = 0.obs;

  // Controller untuk pencarian dan form
  final TextEditingController searchController = TextEditingController();
  final TextEditingController tindakanController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  // Form key
  final GlobalKey<FormState> tindakanFormKey = GlobalKey<FormState>();

  UserModel? get user => _authController.user;

  @override
  void onInit() {
    super.onInit();
    loadPengaduanData();
  }

  @override
  void onClose() {
    searchController.dispose();
    tindakanController.dispose();
    catatanController.dispose();
    super.onClose();
  }

  Future<void> loadPengaduanData() async {
    isLoading.value = true;
    try {
      final pengaduanData = await _supabaseService.getPengaduan();
      if (pengaduanData != null) {
        daftarPengaduan.value =
            pengaduanData.map((data) => PengaduanModel.fromJson(data)).toList();

        // Hitung jumlah berdasarkan status
        jumlahDiproses.value =
            daftarPengaduan.where((item) => item.status == 'DIPROSES').length;
        jumlahTindakan.value =
            daftarPengaduan.where((item) => item.status == 'TINDAKAN').length;
        jumlahSelesai.value =
            daftarPengaduan.where((item) => item.status == 'SELESAI').length;
      }
    } catch (e) {
      print('Error loading pengaduan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> prosesPengaduan(String pengaduanId) async {
    isLoading.value = true;
    try {
      await _supabaseService.prosesPengaduan(pengaduanId);
      await loadPengaduanData();
      Get.snackbar(
        'Sukses',
        'Pengaduan berhasil diproses',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error processing pengaduan: $e');
      Get.snackbar(
        'Error',
        'Gagal memproses pengaduan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> tambahTindakan(String pengaduanId) async {
    if (!tindakanFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final tindakan = TindakanPengaduanModel(
        pengaduanId: pengaduanId,
        tindakan: tindakanController.text,
        catatan: catatanController.text,
        tanggalTindakan: DateTime.now(),
        petugasId: user?.id,
      );

      await _supabaseService.tambahTindakanPengaduan(tindakan.toJson());
      await _supabaseService.updateStatusPengaduan(pengaduanId, 'TINDAKAN');

      // Clear form
      tindakanController.clear();
      catatanController.clear();

      await loadPengaduanData();
      Get.back(); // Close dialog

      Get.snackbar(
        'Sukses',
        'Tindakan berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error adding tindakan: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan tindakan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selesaikanPengaduan(String pengaduanId) async {
    isLoading.value = true;
    try {
      await _supabaseService.updateStatusPengaduan(pengaduanId, 'SELESAI');
      await loadPengaduanData();
      Get.snackbar(
        'Sukses',
        'Pengaduan berhasil diselesaikan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error completing pengaduan: $e');
      Get.snackbar(
        'Error',
        'Gagal menyelesaikan pengaduan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<TindakanPengaduanModel>> getTindakanPengaduan(
      String pengaduanId) async {
    try {
      final tindakanData =
          await _supabaseService.getTindakanPengaduan(pengaduanId);
      if (tindakanData != null) {
        return tindakanData
            .map((data) => TindakanPengaduanModel.fromJson(data))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting tindakan pengaduan: $e');
      return [];
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await loadPengaduanData();
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  List<PengaduanModel> getFilteredPengaduan() {
    switch (selectedCategoryIndex.value) {
      case 0:
        return daftarPengaduan;
      case 1:
        return daftarPengaduan
            .where((item) => item.status == 'DIPROSES')
            .toList();
      case 2:
        return daftarPengaduan
            .where((item) => item.status == 'TINDAKAN')
            .toList();
      case 3:
        return daftarPengaduan
            .where((item) => item.status == 'SELESAI')
            .toList();
      default:
        return daftarPengaduan;
    }
  }

  // Validasi form
  String? validateTindakan(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tindakan tidak boleh kosong';
    }
    return null;
  }
}
