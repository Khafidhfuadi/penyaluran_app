import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/skema_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/laporan_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/data/models/stok_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class DonaturDashboardController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final Rx<BaseUserModel?> currentUser = Rx<BaseUserModel?>(null);

  // Variabel untuk foto profil
  final RxString fotoProfil = ''.obs;

  // Indeks tab yang aktif di bottom navigation bar
  final RxInt activeTabIndex = 0.obs;

  // Data untuk skema bantuan tersedia
  final RxList<SkemaBantuanModel> skemaBantuan = <SkemaBantuanModel>[].obs;

  // Data untuk jadwal penyaluran
  final RxList<PenyaluranBantuanModel> jadwalPenyaluran =
      <PenyaluranBantuanModel>[].obs;

  // Data untuk riwayat penitipan bantuan
  final RxList<PenitipanBantuanModel> penitipanBantuan =
      <PenitipanBantuanModel>[].obs;

  // Data untuk laporan penyaluran
  final RxList<LaporanPenyaluranModel> laporanPenyaluran =
      <LaporanPenyaluranModel>[].obs;

  // Data untuk stok bantuan yang tersedia
  final RxList<StokBantuanModel> stokBantuan = <StokBantuanModel>[].obs;

  // Indikator loading
  final RxBool isLoading = false.obs;

  // Jumlah notifikasi belum dibaca
  final RxInt jumlahNotifikasiBelumDibaca = 0.obs;

  // Data untuk foto bantuan pada form penitipan
  final RxList<String> fotoBantuanPaths = <String>[].obs;
  final ImagePicker _imagePicker = ImagePicker();

  // Getter untuk data user
  BaseUserModel? get user => _authController.baseUser;
  String get role => user?.role ?? 'DONATUR';
  String get nama {
    // Gunakan namaLengkap dari roleData jika tersedia
    if (_authController.isDonatur && _authController.roleData != null) {
      return _authController.roleData.namaLengkap ??
          _authController.displayName;
    }
    // Gunakan displayName dari AuthController
    return _authController.displayName;
  }

  String? get desa => user?.desa?.nama;

  // Getter untuk alamat dan noHp
  String? get alamat {
    if (_authController.isDonatur && _authController.roleData != null) {
      return (_authController.roleData as DonaturModel).alamat;
    }
    return null;
  }

  String? get noHp {
    if (_authController.isDonatur && _authController.roleData != null) {
      return (_authController.roleData as DonaturModel).noHp;
    }
    return null;
  }

  // Getter untuk jenis donatur
  String? get jenis {
    if (_authController.isDonatur && _authController.roleData != null) {
      return (_authController.roleData as DonaturModel).jenis;
    }
    return null;
  }

  // Getter untuk foto profil
  String? get profilePhotoUrl {
    // 1. Coba ambil dari fotoProfil yang sudah disimpan
    if (fotoProfil.isNotEmpty) {
      return fotoProfil.value;
    }

    // 2. Coba ambil dari roleData jika merupakan DonaturModel
    if (_authController.isDonatur && _authController.roleData != null) {
      final donaturData = _authController.roleData as DonaturModel;
      if (donaturData.fotoProfil != null &&
          donaturData.fotoProfil!.isNotEmpty) {
        return donaturData.fotoProfil;
      }
    }

    // 3. Coba ambil dari userData.roleData.fotoProfil
    final userData = _authController.userData;
    if (userData != null && userData.roleData is DonaturModel) {
      final donaturData = userData.roleData as DonaturModel;
      if (donaturData.fotoProfil != null &&
          donaturData.fotoProfil!.isNotEmpty) {
        return donaturData.fotoProfil;
      }
    }

    return null;
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
    loadUserData();
  }

  @override
  void onReady() {
    super.onReady();
    // Perbarui data user dan foto profil saat halaman siap
    loadUserData();
  }

  void loadUserData() {
    currentUser.value = _authController.baseUser;

    if (_authController.userData != null) {
      if (_authController.isDonatur) {
        var donaturData = _authController.roleData;

        // Ambil foto profil dari donaturData jika ada
        if (donaturData != null &&
            donaturData.fotoProfil != null &&
            donaturData.fotoProfil!.isNotEmpty) {
          fotoProfil.value = donaturData.fotoProfil!;
        }
      }
    }

    // Ambil foto profil dari database
    _fetchProfilePhoto();
  }

  // Metode untuk mengambil foto profil
  Future<void> _fetchProfilePhoto() async {
    try {
      if (user?.id == null) return;

      final donaturData = await _supabaseService.client
          .from('donatur')
          .select('foto_profil')
          .eq('id', user!.id)
          .maybeSingle();

      if (donaturData != null && donaturData['foto_profil'] != null) {
        fotoProfil.value = donaturData['foto_profil'];
      }
    } catch (e) {
      print('Error fetching profile photo: $e');
    }
  }

  void fetchData() async {
    isLoading.value = true;

    try {
      // Pastikan user sudah login dan memiliki ID
      if (user?.id == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Ambil data skema bantuan
      await fetchSkemaBantuan();

      // Ambil data jadwal penyaluran
      await fetchJadwalPenyaluran();

      // Ambil data penitipan bantuan
      await fetchPenitipanBantuan();

      // Ambil data laporan penyaluran
      await fetchLaporanPenyaluran();

      // Ambil data stok bantuan
      await fetchStokBantuan();

      // Ambil data notifikasi
      await fetchNotifikasi();
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Ambil data skema bantuan
  Future<void> fetchSkemaBantuan() async {
    try {
      final response = await _supabaseService.client
          .from('xx02_skema_bantuan')
          .select()
          .order('created_at', ascending: false);

      skemaBantuan.value = response
          .map((data) => SkemaBantuanModel.fromJson(data))
          .toList()
          .cast<SkemaBantuanModel>();
    } catch (e) {
      print('Error fetching skema bantuan: $e');
    }
  }

  // Ambil data jadwal penyaluran
  Future<void> fetchJadwalPenyaluran() async {
    try {
      final now = DateTime.now();
      final response = await _supabaseService.client
          .from('penyaluran_bantuan')
          .select()
          .order('tanggal_penyaluran', ascending: true);

      // Konversi ke model lalu filter di sisi client
      final allJadwal = response
          .map((data) => PenyaluranBantuanModel.fromJson(data))
          .toList()
          .cast<PenyaluranBantuanModel>();

      // Filter jadwal yang tanggalnya lebih besar dari hari ini
      jadwalPenyaluran.value = allJadwal
          .where((jadwal) =>
              jadwal.tanggalPenyaluran != null &&
              jadwal.tanggalPenyaluran!.isAfter(now))
          .toList();
    } catch (e) {
      print('Error fetching jadwal penyaluran: $e');
    }
  }

  // Ambil data penitipan bantuan
  Future<void> fetchPenitipanBantuan() async {
    try {
      if (user?.id == null) return;

      final response = await _supabaseService.client
          .from('penitipan_bantuan')
          .select('*, donatur(*), stok_bantuan:stok_bantuan_id(*)')
          .eq('donatur_id', user!.id)
          .order('created_at', ascending: false);

      penitipanBantuan.value = response
          .map((data) => PenitipanBantuanModel.fromJson(data))
          .toList()
          .cast<PenitipanBantuanModel>();
    } catch (e) {
      print('Error fetching penitipan bantuan: $e');
    }
  }

  // Ambil data laporan penyaluran
  Future<void> fetchLaporanPenyaluran() async {
    try {
      final response = await _supabaseService.client
          .from('laporan_penyaluran')
          .select()
          .order('created_at', ascending: false);

      laporanPenyaluran.value = response
          .map((data) => LaporanPenyaluranModel.fromJson(data))
          .toList()
          .cast<LaporanPenyaluranModel>();
    } catch (e) {
      print('Error fetching laporan penyaluran: $e');
    }
  }

  // Ambil data stok bantuan
  Future<void> fetchStokBantuan() async {
    try {
      final response = await _supabaseService.client
          .from('stok_bantuan')
          .select('*, kategori_bantuan:kategori_bantuan_id(*)')
          .order('nama', ascending: true);

      stokBantuan.value = response
          .map((data) => StokBantuanModel.fromJson(data))
          .toList()
          .cast<StokBantuanModel>();
    } catch (e) {
      print('Error fetching stok bantuan: $e');
    }
  }

  // Ambil data notifikasi
  Future<void> fetchNotifikasi() async {
    try {
      if (user?.id == null) return;

      final response = await _supabaseService.client
          .from('notifikasi')
          .select('*')
          .eq('user_id', user!.id)
          .eq('is_read', false)
          .count();

      jumlahNotifikasiBelumDibaca.value = response.count ?? 0;
    } catch (e) {
      print('Error fetching notifikasi: $e');
    }
  }

  // Fungsi untuk logout
  void logout() async {
    try {
      await _authController.logout();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      print('Error during logout: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Mendapatkan daftar stok bantuan yang tersedia
  List<StokBantuanModel> getAvailableStokBantuan() {
    // Filter stok bantuan yang jumlahnya lebih dari 0
    return stokBantuan.where((stok) => (stok.totalStok ?? 0) > 0).toList();
  }

  // Ambil gambar dari kamera atau galeri
  Future<void> pickImage({required bool isCamera}) async {
    try {
      final source = isCamera ? ImageSource.camera : ImageSource.gallery;
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70, // Kurangi kualitas untuk menghemat ukuran
      );

      if (pickedFile != null) {
        fotoBantuanPaths.add(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat mengambil gambar',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Hapus foto bantuan dari daftar
  void removeFotoBantuan(int index) {
    if (index >= 0 && index < fotoBantuanPaths.length) {
      fotoBantuanPaths.removeAt(index);
    }
  }

  // Reset foto bantuan paths
  void resetFotoBantuan() {
    fotoBantuanPaths.clear();
  }

  // Membuat penitipan bantuan baru
  Future<void> createPenitipanBantuan(
    String? stokBantuanId,
    double jumlah,
    String deskripsi,
    String? skemaBantuanId,
  ) async {
    try {
      isLoading.value = true;

      if (user?.id == null) {
        throw Exception('User tidak terautentikasi');
      }

      if (stokBantuanId == null) {
        throw Exception('Stok bantuan harus dipilih');
      }

      if (fotoBantuanPaths.isEmpty) {
        throw Exception('Foto bantuan harus diunggah');
      }

      // Unggah foto bantuan ke storage menggunakan metode dari SupabaseService
      final fotoBantuanUrls = await _supabaseService.uploadMultipleFiles(
          fotoBantuanPaths, 'penitipan', 'foto_bantuan');

      // Data yang akan disimpan
      final Map<String, dynamic> data = {
        'donatur_id': user!.id,
        'stok_bantuan_id': stokBantuanId,
        'jumlah': jumlah,
        'deskripsi': deskripsi,
        'status': 'MENUNGGU',
        'tanggal_penitipan': DateTime.now().toIso8601String(),
        'foto_bantuan': fotoBantuanUrls,
      };

      // Tambahkan skema bantuan jika ada
      if (skemaBantuanId != null && skemaBantuanId.isNotEmpty) {
        data['skema_bantuan_id'] = skemaBantuanId;
      }

      // Simpan ke database
      await _supabaseService.client.from('penitipan_bantuan').insert(data);

      // Reset foto bantuan setelah berhasil disimpan
      resetFotoBantuan();

      // Ambil data penitipan bantuan yang baru
      await fetchPenitipanBantuan();

      // Tampilkan pesan sukses
      Get.snackbar(
        'Berhasil',
        'Penitipan bantuan berhasil dikirim dan akan diproses oleh petugas desa',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Pindah ke tab riwayat penitipan
      DefaultTabController.of(Get.context!)?.animateTo(0);
    } catch (e) {
      print('Error creating penitipan bantuan: $e');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat mengirim penitipan bantuan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
