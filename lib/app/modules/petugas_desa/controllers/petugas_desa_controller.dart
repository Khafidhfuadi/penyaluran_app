import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class PetugasDesaController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxBool isLoading = false.obs;
  final Rx<Map<String, dynamic>?> roleData = Rx<Map<String, dynamic>?>(null);

  // Indeks kategori yang dipilih untuk filter
  final RxInt selectedCategoryIndex = 0.obs;

  // Indeks tab yang aktif di bottom navigation bar
  final RxInt activeTabIndex = 0.obs;

  // Data untuk dashboard
  final RxInt totalPenerima = 0.obs;
  final RxInt totalBantuan = 0.obs;
  final RxInt totalPenyaluran = 0.obs;
  final RxDouble progressPenyaluran = 0.0.obs;

  // Data untuk jadwal
  final RxList<Map<String, dynamic>> jadwalHariIni =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> jadwalMendatang =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> jadwalSelesai =
      <Map<String, dynamic>>[].obs;

  // Data untuk notifikasi
  final RxList<Map<String, dynamic>> notifikasiBelumDibaca =
      <Map<String, dynamic>>[].obs;
  final RxInt jumlahNotifikasiBelumDibaca = 0.obs;

  // Data untuk inventaris
  final RxList<Map<String, dynamic>> daftarInventaris =
      <Map<String, dynamic>>[].obs;
  final RxDouble totalStok = 0.0.obs;
  final RxDouble stokMasuk = 0.0.obs;
  final RxDouble stokKeluar = 0.0.obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();

  UserModel? get user => _authController.user;
  String get role => user?.role ?? 'PETUGASDESA';
  String get nama => user?.name ?? 'Petugas Desa';

  @override
  void onInit() {
    super.onInit();
    loadRoleData();
    loadDashboardData();
    loadJadwalData();
    loadNotifikasiData();
    loadInventarisData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadRoleData() async {
    isLoading.value = true;
    try {
      if (user != null) {
        final data = await _supabaseService.getRoleSpecificData(role);
        roleData.value = data;
      }
    } catch (e) {
      print('Error loading role data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDashboardData() async {
    try {
      // Simulasi data untuk dashboard
      await Future.delayed(const Duration(milliseconds: 800));

      totalPenerima.value = 120;
      totalBantuan.value = 5;
      totalPenyaluran.value = 8;
      progressPenyaluran.value = 0.75;

      // Di implementasi nyata, data akan diambil dari Supabase
      // final result = await _supabaseService.getDashboardData();
      // totalPenerima.value = result['total_penerima'] ?? 0;
      // totalBantuan.value = result['total_bantuan'] ?? 0;
      // totalPenyaluran.value = result['total_penyaluran'] ?? 0;
      // progressPenyaluran.value = result['progress_penyaluran'] ?? 0.0;
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  Future<void> loadJadwalData() async {
    try {
      // Simulasi data untuk jadwal
      await Future.delayed(const Duration(milliseconds: 600));

      jadwalHariIni.value = [
        {
          'id': '1',
          'lokasi': 'Balai Desa Sukamaju',
          'jenis_bantuan': 'Beras',
          'tanggal': '15 April 2023',
          'waktu': '09:00 - 12:00',
          'status': 'aktif',
          'jumlah_penerima': 45,
        },
        {
          'id': '2',
          'lokasi': 'Pos RW 03',
          'jenis_bantuan': 'Paket Sembako',
          'tanggal': '15 April 2023',
          'waktu': '13:00 - 15:00',
          'status': 'aktif',
          'jumlah_penerima': 30,
        },
      ];

      jadwalMendatang.value = [
        {
          'id': '3',
          'lokasi': 'Balai Desa Sukamaju',
          'jenis_bantuan': 'Beras',
          'tanggal': '22 April 2023',
          'waktu': '09:00 - 12:00',
          'status': 'terjadwal',
          'jumlah_penerima': 50,
        },
        {
          'id': '4',
          'lokasi': 'Pos RW 05',
          'jenis_bantuan': 'Paket Sembako',
          'tanggal': '23 April 2023',
          'waktu': '13:00 - 15:00',
          'status': 'terjadwal',
          'jumlah_penerima': 35,
        },
      ];

      jadwalSelesai.value = [
        {
          'id': '5',
          'lokasi': 'Balai Desa Sukamaju',
          'jenis_bantuan': 'Beras',
          'tanggal': '8 April 2023',
          'waktu': '09:00 - 12:00',
          'status': 'selesai',
          'jumlah_penerima': 48,
        },
        {
          'id': '6',
          'lokasi': 'Pos RW 02',
          'jenis_bantuan': 'Paket Sembako',
          'tanggal': '9 April 2023',
          'waktu': '13:00 - 15:00',
          'status': 'selesai',
          'jumlah_penerima': 32,
        },
      ];

      // Di implementasi nyata, data akan diambil dari Supabase
      // final result = await _supabaseService.getJadwalData();
      // jadwalHariIni.value = result['hari_ini'] ?? [];
      // jadwalMendatang.value = result['mendatang'] ?? [];
      // jadwalSelesai.value = result['selesai'] ?? [];
    } catch (e) {
      print('Error loading jadwal data: $e');
    }
  }

  Future<void> loadNotifikasiData() async {
    try {
      // Simulasi data untuk notifikasi
      await Future.delayed(const Duration(milliseconds: 500));

      // Hitung jumlah notifikasi yang belum dibaca
      final List<Map<String, dynamic>> notifikasi = [
        {
          'id': '1',
          'judul': 'Jadwal Penyaluran Baru',
          'pesan': 'Jadwal penyaluran beras telah ditambahkan untuk hari ini',
          'waktu': '08:30',
          'dibaca': false,
          'tanggal': 'hari_ini',
        },
        {
          'id': '2',
          'judul': 'Pengajuan Bantuan Baru',
          'pesan': 'Ada 3 pengajuan bantuan baru yang perlu diverifikasi',
          'waktu': '10:15',
          'dibaca': false,
          'tanggal': 'hari_ini',
        },
        {
          'id': '3',
          'judul': 'Laporan Penyaluran',
          'pesan':
              'Laporan penyaluran bantuan tanggal 14 April 2023 telah selesai',
          'waktu': '16:45',
          'dibaca': true,
          'tanggal': 'kemarin',
        },
      ];

      notifikasiBelumDibaca.value =
          notifikasi.where((n) => n['dibaca'] == false).toList();
      jumlahNotifikasiBelumDibaca.value = notifikasiBelumDibaca.length;

      // Di implementasi nyata, data akan diambil dari Supabase
      // final result = await _supabaseService.getNotifikasiData();
      // notifikasiBelumDibaca.value = result.where((n) => n['dibaca'] == false).toList();
      // jumlahNotifikasiBelumDibaca.value = notifikasiBelumDibaca.length;
    } catch (e) {
      print('Error loading notifikasi data: $e');
    }
  }

  Future<void> loadInventarisData() async {
    try {
      // Simulasi data untuk inventaris
      await Future.delayed(const Duration(milliseconds: 700));

      daftarInventaris.value = [
        {
          'id': '1',
          'nama': 'Beras',
          'jenis': 'Sembako',
          'stok': '750 kg',
          'stok_angka': 750.0,
          'lokasi': 'Gudang Utama',
          'tanggal_masuk': '10 April 2023',
          'kadaluarsa': '10 April 2024',
        },
        {
          'id': '2',
          'nama': 'Minyak Goreng',
          'jenis': 'Sembako',
          'stok': '250 liter',
          'stok_angka': 250.0,
          'lokasi': 'Gudang Utama',
          'tanggal_masuk': '12 April 2023',
          'kadaluarsa': '12 Oktober 2023',
        },
        {
          'id': '3',
          'nama': 'Paket Sembako',
          'jenis': 'Paket Bantuan',
          'stok': '100 paket',
          'stok_angka': 100.0,
          'lokasi': 'Gudang Cabang',
          'tanggal_masuk': '15 April 2023',
          'kadaluarsa': '15 Juli 2023',
        },
      ];

      // Hitung total stok, stok masuk, dan stok keluar
      totalStok.value = daftarInventaris.fold(
          0, (sum, item) => sum + (item['stok_angka'] as double));
      stokMasuk.value = 500.0; // Contoh data
      stokKeluar.value = 350.0; // Contoh data

      // Di implementasi nyata, data akan diambil dari Supabase
      // final result = await _supabaseService.getInventarisData();
      // daftarInventaris.value = result['daftar'] ?? [];
      // totalStok.value = result['total_stok'] ?? 0.0;
      // stokMasuk.value = result['stok_masuk'] ?? 0.0;
      // stokKeluar.value = result['stok_keluar'] ?? 0.0;
    } catch (e) {
      print('Error loading inventaris data: $e');
    }
  }

  void tandaiNotifikasiDibaca(String id) {
    // Implementasi untuk menandai notifikasi sebagai dibaca
    // Di implementasi nyata, akan memanggil Supabase untuk memperbarui status notifikasi
    // await _supabaseService.markNotificationAsRead(id);

    // Perbarui data lokal
    loadNotifikasiData();
  }

  void tambahInventaris(Map<String, dynamic> data) {
    // Implementasi untuk menambah inventaris
    // Di implementasi nyata, akan memanggil Supabase untuk menambah data inventaris
    // await _supabaseService.addInventory(data);

    // Perbarui data lokal
    loadInventarisData();
  }

  void hapusInventaris(String id) {
    // Implementasi untuk menghapus inventaris
    // Di implementasi nyata, akan memanggil Supabase untuk menghapus data inventaris
    // await _supabaseService.deleteInventory(id);

    // Perbarui data lokal
    loadInventarisData();
  }

  void logout() {
    _authController.logout();
  }

  void changeTab(int index) {
    activeTabIndex.value = index;
  }
}
