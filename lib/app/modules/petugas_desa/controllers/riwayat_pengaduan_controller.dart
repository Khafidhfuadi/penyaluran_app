import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class RiwayatPengaduanController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxBool isLoading = false.obs;

  // Data untuk pengaduan
  final RxList<PengaduanModel> daftarRiwayatPengaduan = <PengaduanModel>[].obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();

  UserModel? get user => _authController.user;

  @override
  void onInit() {
    super.onInit();
    loadRiwayatPengaduanData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadRiwayatPengaduanData() async {
    isLoading.value = true;
    try {
      final pengaduanData =
          await _supabaseService.getPengaduanWithPenerimaPenyaluran();
      if (pengaduanData != null) {
        // Filter hanya pengaduan dengan status SELESAI
        final List<PengaduanModel> selesaiPengaduan = pengaduanData
            .map((data) => PengaduanModel.fromJson(data))
            .where((item) => item.status == 'SELESAI')
            .toList();

        daftarRiwayatPengaduan.value = selesaiPengaduan;
      }
    } catch (e) {
      print('Error loading riwayat pengaduan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await loadRiwayatPengaduanData();
    } finally {
      isLoading.value = false;
    }
  }

  List<PengaduanModel> getFilteredRiwayatPengaduan() {
    if (searchController.text.isEmpty) {
      return daftarRiwayatPengaduan;
    }

    final searchQuery = searchController.text.toLowerCase();
    return daftarRiwayatPengaduan.where((item) {
      final namaWarga = item.warga?['nama']?.toString().toLowerCase() ?? '';
      final nik = item.warga?['nik']?.toString().toLowerCase() ?? '';
      final deskripsi = item.deskripsi?.toLowerCase() ?? '';

      return namaWarga.contains(searchQuery) ||
          nik.contains(searchQuery) ||
          deskripsi.contains(searchQuery);
    }).toList();
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
}
