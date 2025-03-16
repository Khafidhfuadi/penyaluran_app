import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/skema_bantuan_model.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class PelaksanaanPenyaluranController extends GetxController {
  // Instance Supabase Service
  final SupabaseService supabaseService = SupabaseService.to;

  // Controller untuk pencarian penerima
  final TextEditingController searchPenerimaController =
      TextEditingController();

  // Data penerima penyaluran
  final RxList<PenerimaPenyaluranModel> penerimaPenyaluran =
      <PenerimaPenyaluranModel>[].obs;
  final RxList<PenerimaPenyaluranModel> filteredPenerima =
      <PenerimaPenyaluranModel>[].obs;
  final RxInt jumlahPenerima = 0.obs;
  final RxString filterStatus = 'SEMUA'.obs;

  // Status loading
  final isLoading = false.obs;

  // Variabel untuk pencarian
  final searchQuery = ''.obs;

  // ID penyaluran yang sedang aktif
  final RxString activePenyaluranId = ''.obs;

  // Variabel untuk data skema bantuan
  final Rx<SkemaBantuanModel?> skemaBantuan = Rx<SkemaBantuanModel?>(null);
  final isLoadingSkema = false.obs;

  // Variabel untuk data jadwal penyaluran
  final Rx<PenyaluranBantuanModel?> jadwalPenyaluran =
      Rx<PenyaluranBantuanModel?>(null);
  final Rx<Map<String, dynamic>> jadwalPenyaluranFormatted =
      Rx<Map<String, dynamic>>({});
  final isLoadingJadwal = false.obs;

  // Variabel untuk konfirmasi penerima
  final RxBool isKonfirmasiChecked = false.obs;
  final RxBool isIdentitasChecked = false.obs;
  final RxBool isDataValidChecked = false.obs;
  final RxString fotoBuktiPath = ''.obs;
  final RxString tandaTanganPath = ''.obs;
  final TextEditingController catatanController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi listener untuk filter status
    ever(filterStatus, (_) => applyFilters());
  }

  @override
  void onClose() {
    // Bersihkan controller
    searchPenerimaController.dispose();
    catatanController.dispose();
    super.onClose();
  }

  // Metode untuk memuat data jadwal penyaluran
  Future<void> loadJadwalPenyaluran(String penyaluranId) async {
    isLoadingJadwal.value = true;
    jadwalPenyaluran.value = null;
    jadwalPenyaluranFormatted.value = {};

    try {
      final response = await supabaseService.client
          .from('penyaluran_bantuan')
          .select('*, lokasi_penyaluran(*), kategori_bantuan(*)')
          .eq('id', penyaluranId)
          .single();

      // Konversi ke model
      final PenyaluranBantuanModel penyaluranModel =
          PenyaluranBantuanModel.fromJson(response);
      jadwalPenyaluran.value = penyaluranModel;

      // Format data jadwal untuk tampilan
      final Map<String, dynamic> formattedJadwal = {
        'id': penyaluranModel.id,
        'nama': penyaluranModel.nama,
        'deskripsi': penyaluranModel.deskripsi,
        'lokasi': response['lokasi_penyaluran'] != null
            ? response['lokasi_penyaluran']['nama']
            : 'Tidak tersedia',
        'kategori_bantuan': response['kategori_bantuan'] != null
            ? response['kategori_bantuan']['nama']
            : 'Tidak tersedia',
        'tanggal': penyaluranModel.tanggalPenyaluran != null
            ? DateTimeHelper.formatDate(penyaluranModel.tanggalPenyaluran!)
            : 'Tidak tersedia',
        'waktu': penyaluranModel.tanggalPenyaluran != null
            ? DateTimeHelper.formatTime(penyaluranModel.tanggalPenyaluran!)
            : 'Tidak tersedia',
        'jumlah_penerima': penyaluranModel.jumlahPenerima?.toString() ?? '0',
        'status': penyaluranModel.status,
        'skema_bantuan_id': penyaluranModel.skemaId,
        'lokasi_penyaluran_id': penyaluranModel.lokasiPenyaluranId,
        'kategori_bantuan_id': penyaluranModel.kategoriBantuanId,
        'raw_data': response, // Simpan data mentah untuk keperluan lain
      };

      jadwalPenyaluranFormatted.value = formattedJadwal;

      // Jika ada ID skema, muat data skema bantuan
      if (penyaluranModel.skemaId != null) {
        loadSkemaBantuan(penyaluranModel.skemaId!);
      }

      print(
          'DEBUG: Jadwal penyaluran berhasil dimuat: ${jadwalPenyaluran.value?.nama}');
    } catch (e) {
      print('DEBUG: Error saat memuat jadwal penyaluran: $e');
    } finally {
      isLoadingJadwal.value = false;
    }
  }

  // Metode untuk memuat data skema bantuan
  Future<void> loadSkemaBantuan(String skemaId) async {
    isLoadingSkema.value = true;

    try {
      final response = await supabaseService.client
          .from('xx02_skema_bantuan')
          .select('*')
          .eq('id', skemaId)
          .single();

      skemaBantuan.value = SkemaBantuanModel.fromJson(response);
      print(
          'DEBUG: Skema bantuan berhasil dimuat: ${skemaBantuan.value?.nama}');
    } catch (e) {
      print('DEBUG: Error saat memuat skema bantuan: $e');
    } finally {
      isLoadingSkema.value = false;
    }
  }

  // Metode untuk memuat data penerima penyaluran
  Future<void> loadPenerimaPenyaluran(String penyaluranId) async {
    isLoading.value = true;
    activePenyaluranId.value = penyaluranId;

    try {
      // Coba ambil data dari Supabase
      final data = await _fetchPenerimaPenyaluranFromSupabase(penyaluranId);

      if (data != null && data.isNotEmpty) {
        // Konversi ke model
        penerimaPenyaluran.value =
            data.map((item) => PenerimaPenyaluranModel.fromJson(item)).toList();
        jumlahPenerima.value = data.length;
        print(
            'Data penerima berhasil dimuat: ${penerimaPenyaluran.length} data');
      }

      // Terapkan filter
      applyFilters();
    } catch (e) {
      print('Error saat memuat data penerima: $e');
      applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  // Metode untuk mengambil data penerima dari Supabase
  Future<List<Map<String, dynamic>>?> _fetchPenerimaPenyaluranFromSupabase(
      String penyaluranId) async {
    try {
      final response = await supabaseService.client
          .from('penerima_penyaluran')
          .select('*, warga(*)')
          .eq('penyaluran_bantuan_id', penyaluranId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error saat mengambil data dari Supabase: $e');
      return null;
    }
  }

  // Metode untuk memfilter penerima berdasarkan kata kunci
  void filterPenerima(String keyword) {
    if (keyword.isEmpty) {
      applyFilters();
      return;
    }

    final lowercaseKeyword = keyword.toLowerCase();
    final filtered = penerimaPenyaluran.where((penerima) {
      final wargaData = penerima.warga ?? {};
      final nama = ((wargaData['nama_lengkap'] ?? wargaData['nama']) ?? '')
          .toString()
          .toLowerCase();
      final nik = (wargaData['nik'] ?? '').toString().toLowerCase();
      final alamat = (wargaData['alamat'] ?? '').toString().toLowerCase();

      final matches = nama.contains(lowercaseKeyword) ||
          nik.contains(lowercaseKeyword) ||
          alamat.contains(lowercaseKeyword);

      return matches;
    }).toList();

    filteredPenerima.value = filtered;
  }

  // Metode untuk menerapkan filter status
  void applyFilters() {
    final keyword = searchPenerimaController.text.toLowerCase();

    if (filterStatus.value == 'SEMUA' && keyword.isEmpty) {
      filteredPenerima.value = penerimaPenyaluran;
      return;
    }

    final filtered = penerimaPenyaluran.where((penerima) {
      bool statusMatch = true;
      if (filterStatus.value != 'SEMUA') {
        statusMatch = penerima.statusPenerimaan == filterStatus.value;
      }

      if (keyword.isEmpty) return statusMatch;

      final wargaData = penerima.warga ?? {};
      final nama = ((wargaData['nama_lengkap'] ?? wargaData['nama']) ?? '')
          .toString()
          .toLowerCase();
      final nik = (wargaData['nik'] ?? '').toString().toLowerCase();
      final alamat = (wargaData['alamat'] ?? '').toString().toLowerCase();

      final keywordMatch = nama.contains(keyword) ||
          nik.contains(keyword) ||
          alamat.contains(keyword);

      return statusMatch && keywordMatch;
    }).toList();

    filteredPenerima.value = filtered;
  }

  // Metode untuk memperbarui status penerimaan bantuan
  Future<bool> updateStatusPenerimaan(int penerimaId, String status,
      {DateTime? tanggalPenerimaan,
      String? buktiPenerimaan,
      String? keterangan}) async {
    try {
      final result = await supabaseService.updateStatusPenerimaan(
          penerimaId, status,
          tanggalPenerimaan: tanggalPenerimaan,
          buktiPenerimaan: buktiPenerimaan,
          keterangan: keterangan);

      // Jika berhasil, perbarui data lokal
      if (result) {
        await loadPenerimaPenyaluran(activePenyaluranId.value);
      }

      return result;
    } catch (e) {
      print('Error updating status penerimaan: $e');
      return false;
    }
  }

  // Metode untuk menyelesaikan jadwal penyaluran
  Future<void> completeJadwal(String jadwalId) async {
    try {
      await supabaseService.completeJadwal(jadwalId);
    } catch (e) {
      print('Error completing jadwal: $e');
      throw e.toString();
    }
  }

  // Metode untuk mendapatkan warna status penerimaan
  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUDAHMENERIMA':
        return AppTheme.successColor;
      case 'BELUMMENERIMA':
        return AppTheme.warningColor;
      default:
        return Colors.grey;
    }
  }

  // Metode untuk mendapatkan ikon status penerimaan
  IconData getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'SUDAHMENERIMA':
        return Icons.check_circle;
      case 'BELUMMENERIMA':
        return Icons.event_available;
      default:
        return Icons.info_outline;
    }
  }

  // Metode untuk mendapatkan teks status penerimaan
  String getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'SUDAHMENERIMA':
        return 'Sudah Menerima';
      case 'BELUMMENERIMA':
        return 'Belum Menerima';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  // Metode untuk memilih foto bukti
  void pilihFotoBukti() async {
    // Implementasi untuk memilih foto dari galeri atau kamera
    // Untuk sementara, gunakan URL dummy
    fotoBuktiPath.value =
        'https://via.placeholder.com/400x300?text=Bukti+Penyaluran';
  }

  // Metode untuk menghapus foto bukti
  void hapusFotoBukti() {
    fotoBuktiPath.value = '';
  }

  // Metode untuk membuka signature pad
  void bukaSignaturePad(BuildContext context) {
    // Implementasi untuk membuka signature pad
    // Untuk sementara, gunakan URL dummy
    tandaTanganPath.value =
        'https://via.placeholder.com/400x200?text=Tanda+Tangan';
  }

  // Metode untuk menghapus tanda tangan
  void hapusTandaTangan() {
    tandaTanganPath.value = '';
  }

  // Metode untuk konfirmasi penyaluran
  Future<void> konfirmasiPenyaluran(int penerimaId, String penyaluranId) async {
    try {
      isLoading.value = true;

      // Simulasi proses konfirmasi
      await Future.delayed(const Duration(seconds: 2));

      // Reset form
      isKonfirmasiChecked.value = false;
      isIdentitasChecked.value = false;
      isDataValidChecked.value = false;
      fotoBuktiPath.value = '';
      tandaTanganPath.value = '';
      catatanController.clear();

      // Perbarui status penerima di daftar
      final index = penerimaPenyaluran
          .indexWhere((penerima) => penerima.id == penerimaId);

      if (index != -1) {
        // Buat salinan model dengan status yang diperbarui
        final updatedPenerima = PenerimaPenyaluranModel(
          id: penerimaPenyaluran[index].id,
          createdAt: penerimaPenyaluran[index].createdAt,
          penyaluranBantuanId: penerimaPenyaluran[index].penyaluranBantuanId,
          wargaId: penerimaPenyaluran[index].wargaId,
          statusPenerimaan: 'SUDAHMENERIMA',
          tanggalPenerimaan: penerimaPenyaluran[index].tanggalPenerimaan,
          buktiPenerimaan: penerimaPenyaluran[index].buktiPenerimaan,
          keterangan: penerimaPenyaluran[index].keterangan,
          jumlahBantuan: penerimaPenyaluran[index].jumlahBantuan,
          stokBantuanId: penerimaPenyaluran[index].stokBantuanId,
          warga: penerimaPenyaluran[index].warga,
        );

        // Perbarui daftar
        final List<PenerimaPenyaluranModel> updatedList =
            List.from(penerimaPenyaluran);
        updatedList[index] = updatedPenerima;
        penerimaPenyaluran.value = updatedList;

        // Terapkan filter
        applyFilters();
      }

      // Tampilkan pesan sukses
      Get.back();
      Get.snackbar(
        'Sukses',
        'Konfirmasi penyaluran berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat menyimpan konfirmasi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
