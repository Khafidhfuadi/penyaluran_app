import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/lokasi_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/kategori_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/data/models/skema_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class JadwalPenyaluranController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  SupabaseService get supabaseService => _supabaseService;

  final RxBool isLoading = false.obs;

  // Indeks kategori yang dipilih untuk filter
  final RxInt selectedCategoryIndex = 0.obs;

  // Data untuk jadwal
  final RxList<PenyaluranBantuanModel> jadwalAktif =
      <PenyaluranBantuanModel>[].obs;
  final RxList<PenyaluranBantuanModel> jadwalMendatang =
      <PenyaluranBantuanModel>[].obs;
  final RxList<PenyaluranBantuanModel> jadwalTerlaksana =
      <PenyaluranBantuanModel>[].obs;

  // Data untuk permintaan penjadwalan
  final RxList<PenyaluranBantuanModel> permintaanPenjadwalan =
      <PenyaluranBantuanModel>[].obs;
  final RxInt jumlahPermintaanPenjadwalan = 0.obs;

  // Cache untuk lokasi penyaluran dan kategori bantuan
  final RxMap<String, LokasiPenyaluranModel> lokasiPenyaluranCache =
      <String, LokasiPenyaluranModel>{}.obs;
  final RxMap<String, KategoriBantuanModel> kategoriBantuanCache =
      <String, KategoriBantuanModel>{}.obs;
  final RxMap<String, SkemaBantuanModel> skemaBantuanCache =
      <String, SkemaBantuanModel>{}.obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();

  BaseUserModel? get user => _authController.baseUser;

  @override
  void onInit() {
    super.onInit();
    loadJadwalData();
    loadPermintaanPenjadwalanData();
    loadLokasiPenyaluranData();
    loadKategoriBantuanData();
    loadSkemaBantuanData();

    // Jalankan timer untuk memeriksa jadwal secara berkala
    _startJadwalCheckTimer();
  }

  @override
  void onClose() {
    searchController.dispose();
    // Hentikan timer jika ada
    _stopJadwalCheckTimer();
    super.onClose();
  }

  // Timer untuk memeriksa jadwal secara berkala
  Timer? _jadwalCheckTimer;

  void _startJadwalCheckTimer() {
    // Periksa jadwal setiap 1 menit
    _jadwalCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      checkAndUpdateJadwalStatus();
    });

    // Periksa jadwal segera saat aplikasi dimulai
    checkAndUpdateJadwalStatus();
  }

  void _stopJadwalCheckTimer() {
    _jadwalCheckTimer?.cancel();
    _jadwalCheckTimer = null;
  }

  // Memeriksa dan memperbarui status jadwal
  Future<void> checkAndUpdateJadwalStatus() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      List<PenyaluranBantuanModel> jadwalToUpdate = [];
      List<PenyaluranBantuanModel> jadwalTerlewat = [];

      for (var jadwal in jadwalAktif) {
        if (jadwal.tanggalPenyaluran != null) {
          final jadwalDateTime =
              DateTimeHelper.toLocalDateTime(jadwal.tanggalPenyaluran!);
          final jadwalDate = DateTime(
            jadwalDateTime.year,
            jadwalDateTime.month,
            jadwalDateTime.day,
          );

          if (isSameDay(jadwalDate, today)) {
            if (now.isAfter(jadwalDateTime) ||
                now.isAtSameMomentAs(jadwalDateTime)) {
              if (jadwal.status == 'DIJADWALKAN') {
                if (now
                    .isBefore(jadwalDateTime.add(const Duration(hours: 2)))) {
                  await _supabaseService.updateJadwalStatus(
                      jadwal.id!, 'AKTIF');
                  jadwalToUpdate.add(jadwal);
                } else {
                  await _supabaseService.updateJadwalStatus(
                      jadwal.id!, 'BATALTERLAKSANA');
                  jadwalTerlewat.add(jadwal);
                }
              } else if (jadwal.status == 'AKTIF') {
                if (now.isAfter(jadwalDateTime.add(const Duration(hours: 2)))) {
                  await _supabaseService.updateJadwalStatus(
                      jadwal.id!, 'BATALTERLAKSANA');
                  jadwalTerlewat.add(jadwal);
                }
              }
            }
          }
        }
      }

      if (jadwalToUpdate.isNotEmpty || jadwalTerlewat.isNotEmpty) {
        await loadJadwalData();

        if (jadwalToUpdate.isNotEmpty) {
          Get.snackbar(
            'Jadwal Diperbarui',
            '${jadwalToUpdate.length} jadwal dipindahkan ke section Hari Ini',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }

        if (jadwalTerlewat.isNotEmpty) {
          Get.snackbar(
            'Jadwal Terlewat',
            '${jadwalTerlewat.length} jadwal diubah menjadi BATALTERLAKSANA',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error checking and updating jadwal status: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Helper method untuk memeriksa apakah dua tanggal adalah hari yang sama
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> loadJadwalData() async {
    isLoading.value = true;
    try {
      // Mengambil data jadwal hari ini
      final jadwalAktifData = await _supabaseService.getJadwalAktif();
      if (jadwalAktifData != null) {
        jadwalAktif.value = jadwalAktifData
            .map((data) => PenyaluranBantuanModel.fromJson(data))
            .toList();
      }

      // Mengambil data jadwal mendatang
      final jadwalMendatangData = await _supabaseService.getJadwalMendatang();
      if (jadwalMendatangData != null) {
        jadwalMendatang.value = jadwalMendatangData
            .map((data) => PenyaluranBantuanModel.fromJson(data))
            .toList();
      }

      // Mengambil data jadwal selesai
      final jadwalTerlaksanaData = await _supabaseService.getJadwalTerlaksana();
      if (jadwalTerlaksanaData != null) {
        jadwalTerlaksana.value = jadwalTerlaksanaData
            .map((data) => PenyaluranBantuanModel.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error loading jadwal data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPermintaanPenjadwalanData() async {
    try {
      final permintaanData = await _supabaseService.getPermintaanPenjadwalan();
      if (permintaanData != null) {
        permintaanPenjadwalan.value = permintaanData
            .map((data) => PenyaluranBantuanModel.fromJson(data))
            .toList();
        jumlahPermintaanPenjadwalan.value = permintaanPenjadwalan.length;
      }
    } catch (e) {
      print('Error loading permintaan penjadwalan data: $e');
    }
  }

  Future<void> loadLokasiPenyaluranData() async {
    try {
      final lokasiData = await _supabaseService.getAllLokasiPenyaluran();
      if (lokasiData != null) {
        for (var lokasi in lokasiData) {
          final lokasiModel = LokasiPenyaluranModel.fromJson(lokasi);
          lokasiPenyaluranCache[lokasiModel.id] = lokasiModel;
        }
      }
    } catch (e) {
      print('Error loading lokasi penyaluran data: $e');
    }
  }

  Future<void> loadKategoriBantuanData() async {
    try {
      final kategoriData = await _supabaseService.getAllKategoriBantuan();
      if (kategoriData != null) {
        for (var kategori in kategoriData) {
          final kategoriModel = KategoriBantuanModel.fromJson(kategori);
          if (kategoriModel.id != null) {
            kategoriBantuanCache[kategoriModel.id!] = kategoriModel;
          }
        }
      }
    } catch (e) {
      print('Error loading kategori bantuan data: $e');
    }
  }

  Future<void> loadSkemaBantuanData() async {
    try {
      final skemaData = await _supabaseService.getAllSkemaBantuan();
      if (skemaData != null) {
        for (var skema in skemaData) {
          final skemaModel = SkemaBantuanModel.fromJson(skema);
          if (skemaModel.id != null) {
            skemaBantuanCache[skemaModel.id!] = skemaModel;
          }
        }
      }
    } catch (e) {
      print('Error loading skema bantuan data: $e');
    }
  }

  // Mendapatkan nama lokasi penyaluran berdasarkan ID
  String getLokasiPenyaluranName(String? lokasiId) {
    if (lokasiId == null) return 'Lokasi tidak diketahui';
    final lokasi = lokasiPenyaluranCache[lokasiId];
    return lokasi?.nama ?? 'Lokasi tidak diketahui';
  }

  // Mendapatkan nama kategori bantuan berdasarkan ID
  String getKategoriBantuanName(String? kategoriId) {
    if (kategoriId == null) return 'Kategori tidak diketahui';
    final kategori = kategoriBantuanCache[kategoriId];
    return kategori?.nama ?? 'Kategori tidak diketahui';
  }

  Future<void> approveJadwal(String jadwalId) async {
    isLoading.value = true;
    try {
      await _supabaseService.approveJadwal(jadwalId);
      await loadPermintaanPenjadwalanData();
      await loadJadwalData();
      Get.snackbar(
        'Sukses',
        'Jadwal berhasil disetujui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error approving jadwal: $e');
      Get.snackbar(
        'Error',
        'Gagal menyetujui jadwal: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectJadwal(String jadwalId, String alasanPenolakan) async {
    isLoading.value = true;
    try {
      await _supabaseService.rejectJadwal(jadwalId, alasanPenolakan);
      await loadPermintaanPenjadwalanData();
      await loadJadwalData();
      Get.snackbar(
        'Sukses',
        'Jadwal berhasil ditolak',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error rejecting jadwal: $e');
      Get.snackbar(
        'Error',
        'Gagal menolak jadwal: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeJadwal(String jadwalId) async {
    isLoading.value = true;
    try {
      await _supabaseService.completeJadwal(jadwalId);
      await loadJadwalData();
      Get.snackbar(
        'Sukses',
        'Jadwal berhasil diselesaikan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error completing jadwal: $e');
      Get.snackbar(
        'Error',
        'Gagal menyelesaikan jadwal: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
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
      await loadJadwalData();
      await loadPermintaanPenjadwalanData();
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  // Fungsi untuk menambahkan penyaluran baru
  Future<void> tambahPenyaluran({
    required String nama,
    required String deskripsi,
    required String skemaId,
    required String kategoriBantuanId,
    required String lokasiPenyaluranId,
    required int jumlahPenerima,
    required DateTime? tanggalPenyaluran,
    required double jumlahDiterimaPerOrang,
    required String stokBantuanId,
    required double totalStokDibutuhkan,
  }) async {
    isLoading.value = true;
    try {
      // Pastikan user sudah login dan memiliki ID
      if (user?.id == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Buat objek penyaluran
      final penyaluran = {
        'nama': nama,
        'deskripsi': deskripsi,
        'skema_id': skemaId,
        'lokasi_penyaluran_id': lokasiPenyaluranId,
        'petugas_id': user!.id,
        'jumlah_penerima': jumlahPenerima,
        'tanggal_penyaluran': tanggalPenyaluran?.toUtc().toIso8601String(),
        'status': 'DIJADWALKAN', // Status awal adalah terjadwal
        'kategori_bantuan_id': kategoriBantuanId,
      };

      // Simpan ke database dan dapatkan ID penyaluran
      final response = await _supabaseService.tambahPenyaluran(penyaluran);
      final penyaluranId = response['id'];

      // Ambil data pengajuan kelayakan bantuan yang disetujui
      final pengajuanData = await _supabaseService.client
          .from('xx02_pengajuan_kelayakan_bantuan')
          .select('*')
          .eq('skema_bantuan_id', skemaId)
          .eq('status', 'TERVERIFIKASI');

      // Buat data penerima penyaluran untuk setiap pengajuan yang disetujui
      for (var pengajuan in pengajuanData) {
        // Generate QR code hash unik untuk setiap penerima
        final String qrCodeHash =
            generateQrCodeHash(penyaluranId, pengajuan['warga_id']);

        final penerimaPenyaluran = {
          'penyaluran_bantuan_id': penyaluranId,
          'warga_id': pengajuan['warga_id'],
          'stok_bantuan_id': skemaBantuanCache[skemaId]?.stokBantuanId,
          'status_penerimaan': 'BELUMMENERIMA',
          'qr_code_hash': qrCodeHash,
          'jumlah_bantuan': jumlahDiterimaPerOrang,
        };

        // Simpan data penerima ke database
        await _supabaseService.client
            .from('penerima_penyaluran')
            .insert(penerimaPenyaluran);
      }

      // Setelah berhasil menambahkan, refresh data
      await loadJadwalData();
      await loadPermintaanPenjadwalanData();

      // Tampilkan pesan sukses
      Get.snackbar(
        'Sukses',
        'Jadwal penyaluran bantuan telah dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error: $e');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat menambahkan jadwal penyaluran',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk generate hash QR code berdasarkan ID penyaluran dan ID warga
  String generateQrCodeHash(String penyaluranId, String wargaId) {
    // Kombinasikan ID penyaluran dan ID warga dengan timestamp untuk keunikan
    final String combinedData =
        '$penyaluranId-$wargaId-${DateTime.now().millisecondsSinceEpoch}';
    // Gunakan SHA-256 untuk menghasilkan hash yang aman
    final bytes = utf8.encode(combinedData);
    final hash = sha256.convert(bytes);
    // Kembalikan representasi string dari hash
    return hash.toString();
  }
}
