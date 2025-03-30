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
import 'package:penyaluran_app/app/services/jadwal_update_service.dart';
import 'package:penyaluran_app/app/services/notification_service.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/counter_service.dart';

class JadwalPenyaluranController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;
  late final JadwalUpdateService _jadwalUpdateService;
  late final StreamSubscription _jadwalUpdateSubscription;

  SupabaseService get supabaseService => _supabaseService;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingStatusUpdate = false.obs;
  final RxBool isLokasiLoading = false.obs;

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

    // Inisialisasi JadwalUpdateService
    if (Get.isRegistered<JadwalUpdateService>()) {
      _jadwalUpdateService = Get.find<JadwalUpdateService>();
    } else {
      _jadwalUpdateService = Get.put(JadwalUpdateService());
    }

    // Daftarkan controller ini untuk menerima pembaruan
    _jadwalUpdateService.registerForUpdates('JadwalPenyaluranController');

    // Berlangganan ke pembaruan jadwal
    _jadwalUpdateSubscription =
        _jadwalUpdateService.jadwalUpdateStream.listen(_handleJadwalUpdate);

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
    // Berhenti berlangganan pembaruan jadwal
    _jadwalUpdateSubscription.cancel();
    // Batalkan pendaftaran controller
    _jadwalUpdateService.unregisterFromUpdates('JadwalPenyaluranController');
    super.onClose();
  }

  // Timer untuk memeriksa jadwal secara berkala
  Timer? _jadwalCheckTimer;
  Timer?
      _intensiveCheckTimer; // Timer untuk pengecekan intensif mendekati waktu penyaluran
  final RxBool _intensiveCheckActive = false.obs; // Status pengecekan intensif

  void _startJadwalCheckTimer() {
    // Dengan fitur realtime yang sudah aktif, kita bisa mengurangi frekuensi polling
    // Cek setiap 30 detik sebagai fallback untuk realtime
    _jadwalCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isLoadingStatusUpdate.value) {
        checkAndUpdateJadwalStatus();
      }
    });

    // Periksa jadwal segera saat aplikasi dimulai
    checkAndUpdateJadwalStatus();

    // Log info untuk debugging
    print('Jadwal check timer started with 30 seconds interval');

    // Mulai juga pengecekan jadwal yang akan datang
    _startUpcomingJadwalCheck();
  }

  void _stopJadwalCheckTimer() {
    _jadwalCheckTimer?.cancel();
    _jadwalCheckTimer = null;
    _intensiveCheckTimer?.cancel();
    _intensiveCheckTimer = null;
  }

  // Metode baru untuk memeriksa jadwal mendatang dan memulai pemeriksaan intensif jika perlu
  void _startUpcomingJadwalCheck() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      // Jika sudah ada timer intensif yang berjalan, tidak perlu melakukan pengecekan lagi
      if (_intensiveCheckActive.value) return;

      final now = DateTime.now();
      bool foundUpcomingJadwal = false;

      // Periksa apakah ada jadwal yang akan aktif dalam 10 menit ke depan
      for (var jadwal in jadwalMendatang) {
        if (jadwal.tanggalPenyaluran != null &&
            jadwal.status == 'DIJADWALKAN') {
          final jadwalTime = jadwal.tanggalPenyaluran!;
          final diff = jadwalTime.difference(now).inMinutes;

          // Jika ada jadwal dalam 10 menit ke depan, mulai pemeriksaan intensif
          if (diff >= 0 && diff <= 10) {
            print(
                'Found upcoming jadwal in $diff minutes: ${jadwal.id} - ${jadwal.nama}');
            foundUpcomingJadwal = true;
            break;
          }
        }
      }

      // Jika ditemukan jadwal yang akan datang, mulai pemeriksaan intensif
      if (foundUpcomingJadwal && !_intensiveCheckActive.value) {
        _startIntensiveCheck();
      }
    });
  }

  // Metode untuk memulai pemeriksaan intensif untuk jadwal yang mendekati waktu
  void _startIntensiveCheck() {
    if (_intensiveCheckActive.value) return;

    _intensiveCheckActive.value = true;
    print('Starting intensive jadwal check every 5 seconds');

    // Periksa setiap 5 detik
    _intensiveCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isLoadingStatusUpdate.value) {
        checkAndUpdateJadwalStatus();
      }

      // Periksa apakah masih perlu melakukan pemeriksaan intensif
      final now = DateTime.now();
      bool needIntensiveCheck = false;

      for (var jadwal in jadwalMendatang) {
        if (jadwal.tanggalPenyaluran != null &&
            jadwal.status == 'DIJADWALKAN') {
          final jadwalTime = jadwal.tanggalPenyaluran!;
          final diff = jadwalTime.difference(now).inMinutes;

          // Jika masih ada jadwal dalam 10 menit ke depan, lanjutkan pemeriksaan
          if (diff >= -5 && diff <= 10) {
            needIntensiveCheck = true;
            break;
          }
        }
      }

      // Jika tidak ada lagi jadwal yang mendekati waktu, hentikan pemeriksaan intensif
      if (!needIntensiveCheck) {
        _stopIntensiveCheck();
      }
    });
  }

  // Metode untuk menghentikan pemeriksaan intensif
  void _stopIntensiveCheck() {
    _intensiveCheckTimer?.cancel();
    _intensiveCheckTimer = null;
    _intensiveCheckActive.value = false;
    print('Stopping intensive jadwal check');
  }

  // Handler untuk menerima pembaruan jadwal dari service
  void _handleJadwalUpdate(Map<String, dynamic> updateData) {
    if (updateData['type'] == 'status_update') {
      // Update lokal jika jadwal yang diperbarui ada di salah satu list
      final jadwalId = updateData['jadwal_id'];
      final newStatus = updateData['new_status'];

      // Periksa dan update jadwal di berbagai daftar
      _updateJadwalStatusLocally(jadwalId, newStatus);
    } else if (updateData['type'] == 'reload_required') {
      // Muat ulang data jika diminta
      loadJadwalData();
      loadPermintaanPenjadwalanData();
    } else if (updateData['type'] == 'check_required') {
      // Segera periksa status jadwal
      if (!isLoadingStatusUpdate.value) {
        print(
            'Received check_required signal, checking jadwal status immediately');
        checkAndUpdateJadwalStatus();
      } else {
        print('Already checking jadwal status, ignoring check_required signal');
      }
    }
  }

  // Perbarui status jadwal secara lokal tanpa perlu memanggil API lagi
  void _updateJadwalStatusLocally(String jadwalId, String newStatus) {
    bool updated = false;
    print(
        'Updating jadwal status locally - ID: $jadwalId, New Status: $newStatus');

    // Periksa jadwal aktif
    final jadwalAktifIndex =
        jadwalAktif.indexWhere((jadwal) => jadwal.id == jadwalId);
    if (jadwalAktifIndex >= 0) {
      print('Found in jadwalAktif at index $jadwalAktifIndex');
      jadwalAktif[jadwalAktifIndex] =
          jadwalAktif[jadwalAktifIndex].copyWith(status: newStatus);
      updated = true;
    }

    // Periksa jadwal mendatang
    final jadwalMendatangIndex =
        jadwalMendatang.indexWhere((jadwal) => jadwal.id == jadwalId);
    if (jadwalMendatangIndex >= 0) {
      print('Found in jadwalMendatang at index $jadwalMendatangIndex');
      jadwalMendatang[jadwalMendatangIndex] =
          jadwalMendatang[jadwalMendatangIndex].copyWith(status: newStatus);
      updated = true;
    }

    // Periksa jadwal terlaksana
    final jadwalTerlaksanaIndex =
        jadwalTerlaksana.indexWhere((jadwal) => jadwal.id == jadwalId);
    if (jadwalTerlaksanaIndex >= 0) {
      print('Found in jadwalTerlaksana at index $jadwalTerlaksanaIndex');
      jadwalTerlaksana[jadwalTerlaksanaIndex] =
          jadwalTerlaksana[jadwalTerlaksanaIndex].copyWith(status: newStatus);
      updated = true;
    }

    // Jika perlu, reorganisasi daftar berdasarkan status baru
    if (updated) {
      print('Status updated locally, reorganizing lists');
      _reorganizeJadwalLists();

      // Perbarui counter penyaluran setelah reorganisasi daftar
      _updatePenyaluranCounters();
    } else {
      print(
          'Jadwal with ID $jadwalId not found in any list, refreshing data from server');
      // Jika jadwal tidak ditemukan di daftar lokal, muat ulang data
      loadJadwalData();
    }
  }

  // Reorganisasi daftar jadwal berdasarkan status mereka
  void _reorganizeJadwalLists() {
    // Filter jadwal yang seharusnya pindah dari satu list ke list lain

    // Jadwal yang seharusnya pindah dari aktif ke terlaksana
    final completedJadwal = jadwalAktif
        .where((j) => j.status == 'TERLAKSANA' || j.status == 'BATALTERLAKSANA')
        .toList();
    if (completedJadwal.isNotEmpty) {
      jadwalAktif.removeWhere(
          (j) => j.status == 'TERLAKSANA' || j.status == 'BATALTERLAKSANA');
      jadwalTerlaksana.addAll(completedJadwal);
    }

    // Jadwal yang seharusnya pindah dari mendatang ke aktif
    final activeJadwal =
        jadwalMendatang.where((j) => j.status == 'AKTIF').toList();
    if (activeJadwal.isNotEmpty) {
      jadwalMendatang.removeWhere((j) => j.status == 'AKTIF');
      jadwalAktif.addAll(activeJadwal);
    }

    // Jadwal yang seharusnya pindah dari mendatang ke terlaksana
    final expiredJadwal = jadwalMendatang
        .where((j) => j.status == 'TERLAKSANA' || j.status == 'BATALTERLAKSANA')
        .toList();
    if (expiredJadwal.isNotEmpty) {
      jadwalMendatang.removeWhere(
          (j) => j.status == 'TERLAKSANA' || j.status == 'BATALTERLAKSANA');
      jadwalTerlaksana.addAll(expiredJadwal);
    }

    // Memicu pembaruan UI
    jadwalAktif.refresh();
    jadwalMendatang.refresh();
    jadwalTerlaksana.refresh();
  }

  // Metode baru untuk memperbarui counter penyaluran
  void _updatePenyaluranCounters() {
    try {
      // Dapatkan jumlah jadwal untuk setiap status
      int dijadwalkan =
          jadwalMendatang.where((j) => j.status == 'DIJADWALKAN').length;
      int aktif = jadwalAktif.where((j) => j.status == 'AKTIF').length;
      int batal =
          jadwalTerlaksana.where((j) => j.status == 'BATALTERLAKSANA').length;
      int terlaksana =
          jadwalTerlaksana.where((j) => j.status == 'TERLAKSANA').length;

      // Hitung total jadwal aktif untuk tab hari ini
      int jadwalHariIni = jadwalAktif.length;

      // Perbarui counter jadwal
      if (Get.isRegistered<CounterService>()) {
        final counterService = Get.find<CounterService>();
        counterService.updateJadwalCounter(jadwalHariIni);
      }

      print(
          'Jadwal counters updated - Aktif: $aktif, Dijadwalkan: $dijadwalkan, Terlaksana: $terlaksana, Batal: $batal');
    } catch (e) {
      print('Error updating jadwal counters: $e');
    }
  }

  // Memeriksa dan memperbarui status jadwal
  Future<void> checkAndUpdateJadwalStatus() async {
    if (isLoadingStatusUpdate.value) return;

    isLoadingStatusUpdate.value = true;
    print('Starting jadwal status check at ${DateTime.now()}');

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Kelompokkan jadwal yang perlu diperbarui untuk mengurangi jumlah operasi database
      final Map<String, String> jadwalUpdates = {};
      final List<PenyaluranBantuanModel> jadwalToUpdate = [];
      final List<PenyaluranBantuanModel> jadwalTerlewat = [];

      print('Checking ${jadwalMendatang.length} upcoming schedules');

      // Proses semua jadwal yang perlu diperbarui
      for (var jadwal in jadwalMendatang) {
        if (jadwal.tanggalPenyaluran != null && jadwal.id != null) {
          final jadwalDate = jadwal.tanggalPenyaluran!;

          // Log untuk debugging waktu pemeriksaan
          print(
              'Checking jadwal: ${jadwal.id} - ${jadwal.nama} scheduled for ${jadwal.tanggalPenyaluran}');
          print('Current time: $now, Jadwal time: $jadwalDate');

          // Periksa apakah jadwal sudah melewati waktunya
          // Kita gunakan isAtSameMomentAs atau isAfter untuk menangkap dengan tepat
          if (now.isAfter(jadwalDate) || now.isAtSameMomentAs(jadwalDate)) {
            print('Jadwal time has passed/reached for ${jadwal.id}');

            // Batasan 2 jam untuk status aktif
            final batasAktif = jadwalDate.add(const Duration(hours: 2));

            if (jadwal.status == 'DIJADWALKAN' && now.isBefore(batasAktif)) {
              print(
                  'Updating to AKTIF: ${jadwal.id} - Time difference: ${now.difference(jadwalDate).inSeconds} seconds');
              jadwalUpdates[jadwal.id!] = 'AKTIF';
              jadwalToUpdate.add(jadwal);
            } else if ((jadwal.status == 'DIJADWALKAN' ||
                    jadwal.status == 'AKTIF') &&
                now.isAfter(batasAktif)) {
              print('Updating to BATALTERLAKSANA (time expired): ${jadwal.id}');
              jadwalUpdates[jadwal.id!] = 'BATALTERLAKSANA';
              jadwalTerlewat.add(jadwal);
            }
          } else {
            // Periksa apakah jadwal hampir memasuki waktunya (dalam 5 menit ke depan)
            final diff = jadwalDate.difference(now).inMinutes;
            if (diff >= 0 && diff <= 5 && jadwal.status == 'DIJADWALKAN') {
              print('Jadwal will be active in $diff minutes: ${jadwal.id}');

              // Tambahkan jadwal ke daftar pengawasan intensif
              _jadwalUpdateService.addJadwalToWatch(jadwal.id!, jadwalDate);

              // Jika tinggal 1 menit atau kurang, cek setiap 15 detik
              if (diff <= 1) {
                Future.delayed(const Duration(seconds: 15), () {
                  if (!isLoadingStatusUpdate.value) {
                    checkAndUpdateJadwalStatus();
                  }
                });
              }
            }
          }
        }
      }

      // Update database hanya jika ada perubahan
      if (jadwalUpdates.isNotEmpty) {
        print('Batch updating ${jadwalUpdates.length} schedules');

        try {
          // Gunakan batch update untuk meningkatkan efisiensi
          await _supabaseService.batchUpdateJadwalStatus(jadwalUpdates);

          // Perbarui data lokal
          await loadJadwalData();

          // Beritahu seluruh aplikasi tentang pembaruan
          await _jadwalUpdateService.notifyJadwalUpdate();

          // Kirim notifikasi untuk perubahan status jadwal
          bool notificationsSuccessful = true;
          final notificationService = Get.find<NotificationService>();

          try {
            // Kirim notifikasi untuk jadwal yang diperbarui menjadi Aktif
            for (var jadwal in jadwalToUpdate) {
              if (jadwal.id != null && jadwal.nama != null) {
                await notificationService.sendJadwalStatusNotification(
                  jadwalId: jadwal.id!,
                  newStatus: 'AKTIF',
                  jadwalNama: jadwal.nama!,
                );
              }
            }
          } catch (notificationError) {
            print(
                'Warning: Error sending AKTIF notifications: $notificationError');
            notificationsSuccessful = false;
          }

          try {
            // Kirim notifikasi untuk jadwal yang terlewat
            for (var jadwal in jadwalTerlewat) {
              if (jadwal.id != null && jadwal.nama != null) {
                await notificationService.sendJadwalStatusNotification(
                  jadwalId: jadwal.id!,
                  newStatus: 'BATALTERLAKSANA',
                  jadwalNama: jadwal.nama!,
                );
              }
            }
          } catch (notificationError) {
            print(
                'Warning: Error sending BATALTERLAKSANA notifications: $notificationError');
            notificationsSuccessful = false;
          }

          // Tampilkan notifikasi hanya jika ada perubahan
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

          // Log status keseluruhan
          if (notificationsSuccessful) {
            print(
                'Jadwal status update and notifications completed successfully');
          } else {
            print('Jadwal status update completed with notification errors');
          }
        } catch (updateError) {
          print('Error during batch update process: $updateError');
          // Jika batch update gagal, coba update satu-per-satu secara manual
          print('Trying individual updates for critical jadwal...');

          // Prioritaskan jadwal yang akan diaktifkan
          for (var jadwal in jadwalToUpdate) {
            if (jadwal.id != null) {
              try {
                await _supabaseService.updateJadwalStatus(jadwal.id!, 'AKTIF');
                print('Manual update successful for jadwal ${jadwal.id}');
              } catch (e) {
                print('Manual update failed for jadwal ${jadwal.id}: $e');
              }
            }
          }
        }
      } else {
        print('No schedule updates needed');
      }
    } catch (e, stackTrace) {
      print('Error checking and updating jadwal status: $e');
      print('Stack trace: $stackTrace');
    } finally {
      isLoadingStatusUpdate.value = false;
      print('Jadwal status check completed at ${DateTime.now()}');
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

      // Perbarui counter penyaluran setelah data dimuat
      _updatePenyaluranCounters();
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
    isLokasiLoading.value = true;
    try {
      final data = await _supabaseService.getLokasiPenyaluran(
        petugasId: user?.id,
      );

      // Bersihkan cache dan tambahkan data baru
      lokasiPenyaluranCache.clear();
      for (final lokasi in data) {
        lokasiPenyaluranCache[lokasi.id] = lokasi;
      }
    } catch (e) {
      print('Error loading lokasi penyaluran: $e');
    } finally {
      isLokasiLoading.value = false;
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
      // Dapatkan detail jadwal
      final jadwalIndex = jadwalAktif.indexWhere((j) => j.id == jadwalId);
      PenyaluranBantuanModel? jadwal;

      if (jadwalIndex >= 0) {
        jadwal = jadwalAktif[jadwalIndex];
      }

      // Update status di database
      await _supabaseService.completeJadwal(jadwalId);

      // Kirim notifikasi
      if (jadwal != null && jadwal.nama != null) {
        final notificationService = Get.find<NotificationService>();
        await notificationService.sendJadwalStatusNotification(
          jadwalId: jadwalId,
          newStatus: 'TERLAKSANA',
          jadwalNama: jadwal.nama!,
        );
      }

      // Reload data
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
    await Future.wait([
      loadJadwalData(),
      loadPermintaanPenjadwalanData(),
      loadLokasiPenyaluranData(),
      loadKategoriBantuanData(),
      loadSkemaBantuanData(),
    ]);
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
          'created_at': DateTime.now().toIso8601String(),
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

  // Mengedit lokasi penyaluran
  void editLokasiPenyaluran(String lokasiId) {
    if (lokasiPenyaluranCache.containsKey(lokasiId)) {
      // Ambil data lokasi yang akan diedit
      final lokasi = lokasiPenyaluranCache[lokasiId];

      // Navigasi ke halaman edit dengan membawa data lokasi
      Get.toNamed('/petugas-desa/edit-lokasi-penyaluran', arguments: {
        'lokasi_id': lokasiId,
        'lokasi': lokasi,
      });
    } else {
      Get.snackbar(
        'Gagal',
        'Data lokasi tidak ditemukan',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Menghapus lokasi penyaluran
  void hapusLokasiPenyaluran(String lokasiId) {
    // Tampilkan dialog konfirmasi penghapusan
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus lokasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Tutup dialog

              // Tampilkan loading
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              try {
                // Lakukan penghapusan di database
                await _supabaseService.deleteLokasiPenyaluran(lokasiId);

                // Hapus data dari cache lokal
                lokasiPenyaluranCache.remove(lokasiId);

                // Tutup dialog loading
                Get.back();

                // Tampilkan notifikasi berhasil
                Get.snackbar(
                  'Berhasil',
                  'Lokasi penyaluran berhasil dihapus',
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade800,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                // Tutup dialog loading
                Get.back();

                // Tampilkan pesan error
                Get.snackbar(
                  'Gagal',
                  'Terjadi kesalahan: ${e.toString()}',
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade800,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );
  }
}
