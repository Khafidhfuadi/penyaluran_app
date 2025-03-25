import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/tindakan_pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';

class PengaduanController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  // Indeks kategori yang dipilih untuk filter
  final RxInt selectedCategoryIndex = 4.obs;

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

  // List untuk menyimpan path file bukti tindakan
  final RxList<String> buktiTindakanPaths = <String>[].obs;

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  BaseUserModel? get user => _authController.baseUser;

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
      final pengaduanData =
          await _supabaseService.getPengaduanWithPenerimaPenyaluran();
      if (pengaduanData != null) {
        daftarPengaduan.value =
            pengaduanData.map((data) => PengaduanModel.fromJson(data)).toList();

        // Hitung jumlah berdasarkan status
        jumlahDiproses.value =
            daftarPengaduan.where((item) => item.status == 'MENUNGGU').length;
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
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error processing pengaduan: $e');
      Get.snackbar(
        'Error',
        'Gagal memproses pengaduan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> tambahTindakanPengaduan({
    required String pengaduanId,
    required String tindakan,
    required String kategoriTindakan,
    required String statusTindakan,
    String? catatan,
    String? hasilTindakan,
    required List<String> buktiTindakanPaths,
  }) async {
    try {
      isLoading.value = true;

      // Upload bukti tindakan jika ada
      List<String> buktiTindakanUrls = [];
      if (buktiTindakanPaths.isNotEmpty) {
        for (var path in buktiTindakanPaths) {
          final String? fileUrl = await SupabaseService.to
              .uploadFile(path, 'tindakan_pengaduan', 'bukti_tindakan');
          if (fileUrl != null) {
            buktiTindakanUrls.add(fileUrl);
          }
        }
      }

      // Buat objek tindakan
      final Map<String, dynamic> tindakanData = {
        'pengaduan_id': pengaduanId,
        'tindakan': tindakan,
        'catatan': catatan,
        'status_tindakan': statusTindakan,
        'kategori_tindakan': kategoriTindakan,
        'hasil_tindakan': hasilTindakan,
        'tanggal_tindakan': DateTime.now().toIso8601String(),
        'petugas_id': user?.id,
        'bukti_tindakan': buktiTindakanUrls,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Simpan tindakan ke Supabase
      await SupabaseService.to.tambahTindakanPengaduan(tindakanData);

      // Update status pengaduan jika perlu
      if (statusTindakan == 'SELESAI') {
        await SupabaseService.to.updateStatusPengaduan(pengaduanId, 'SELESAI');
      } else {
        await SupabaseService.to.updateStatusPengaduan(pengaduanId, 'TINDAKAN');
      }

      // Reset paths setelah berhasil
      buktiTindakanPaths.clear();

      //refresh page
      Get.forceAppUpdate();
      Get.back(); // Tutup dialog

      Get.snackbar(
        'Berhasil',
        'Tindakan berhasil ditambahkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error adding tindakan: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan tindakan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTindakanPengaduan({
    required String tindakanId,
    required String pengaduanId,
    required String tindakan,
    required String kategoriTindakan,
    required String statusTindakan,
    String? catatan,
    String? hasilTindakan,
    required List<String> buktiTindakanPaths,
  }) async {
    try {
      isLoading.value = true;

      // Upload bukti tindakan jika ada file baru (yang belum diupload)
      List<String> buktiTindakanUrls = [];
      for (var path in buktiTindakanPaths) {
        // Jika path sudah berupa URL, tambahkan langsung
        if (path.startsWith('http')) {
          buktiTindakanUrls.add(path);
        } else {
          // Jika path adalah file lokal, upload dulu
          final String? fileUrl = await SupabaseService.to
              .uploadFile(path, 'tindakan_pengaduan', 'bukti_tindakan');
          if (fileUrl != null) {
            buktiTindakanUrls.add(fileUrl);
          }
        }
      }

      // Buat objek tindakan
      final Map<String, dynamic> tindakanData = {
        'tindakan': tindakan,
        'catatan': catatan,
        'status_tindakan': statusTindakan,
        'kategori_tindakan': kategoriTindakan,
        'hasil_tindakan': hasilTindakan,
        'bukti_tindakan': buktiTindakanUrls,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Update tindakan di Supabase
      await SupabaseService.to
          .updateTindakanPengaduan(tindakanId, tindakanData);

      // Reset paths setelah berhasil
      buktiTindakanPaths.clear();

      //refresh page
      Get.forceAppUpdate();
      Get.back(); // Tutup dialog
      Get.snackbar(
        'Berhasil',
        'Tindakan berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error updating tindakan: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui tindakan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
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
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error completing pengaduan: $e');
      Get.snackbar(
        'Error',
        'Gagal menyelesaikan pengaduan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatusPengaduan(String pengaduanId, String status) async {
    isLoading.value = true;
    try {
      await _supabaseService.updateStatusPengaduan(pengaduanId, status);
      await loadPengaduanData();
    } catch (e) {
      print('Error updating pengaduan status: $e');
      Get.snackbar(
        'Error',
        'Gagal mengubah status pengaduan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
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
            .where((item) => item.status == 'MENUNGGU')
            .toList();
      case 2:
        return daftarPengaduan
            .where((item) => item.status == 'TINDAKAN')
            .toList();
      case 3:
        return daftarPengaduan
            .where((item) => item.status == 'SELESAI')
            .toList();
      case 4:
        return daftarPengaduan
            .where((item) => item.status != 'SELESAI')
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

  Future<Map<String, dynamic>> getDetailPengaduan(String pengaduanId) async {
    try {
      // Ambil data pengaduan
      final pengaduanData =
          await _supabaseService.client.from('pengaduan').select('''
            *,
            penerima_penyaluran:penerima_penyaluran_id(
              *,
              penyaluran_bantuan:penyaluran_bantuan_id(*),
              stok_bantuan:stok_bantuan_id(*),
              warga:warga_id(*)
            ),
            warga:warga_id(*)
          ''').eq('id', pengaduanId).single();

      // Ambil data tindakan pengaduan
      final tindakanData =
          await _supabaseService.getTindakanPengaduan(pengaduanId);
      print(tindakanData);

      // Gabungkan data
      final result = {
        'pengaduan': pengaduanData,
        'tindakan': tindakanData ?? [],
      };

      return result;
    } catch (e) {
      print('Error getting detail pengaduan: $e');
      return {
        'pengaduan': null,
        'tindakan': [],
      };
    }
  }

  // Fungsi untuk memilih bukti tindakan
  Future<void> pickBuktiTindakan({bool fromCamera = true}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedFile != null) {
        buktiTindakanPaths.add(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil gambar: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fungsi untuk menghapus bukti tindakan
  void removeBuktiTindakan(int index) {
    if (index >= 0 && index < buktiTindakanPaths.length) {
      buktiTindakanPaths.removeAt(index);
    }
  }
}
