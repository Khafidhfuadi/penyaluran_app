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

  // Data untuk permintaan penjadwalan
  final RxList<Map<String, dynamic>> permintaanPenjadwalan =
      <Map<String, dynamic>>[].obs;
  final RxInt jumlahPermintaanPenjadwalan = 0.obs;

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

  // Data untuk penitipan
  final RxList<Map<String, dynamic>> daftarPenitipan =
      <Map<String, dynamic>>[].obs;
  final RxInt jumlahMenunggu = 0.obs;
  final RxInt jumlahTerverifikasi = 0.obs;
  final RxInt jumlahDitolak = 0.obs;

  // Data untuk pengaduan
  final RxList<Map<String, dynamic>> daftarPengaduan =
      <Map<String, dynamic>>[].obs;
  final RxInt jumlahDiproses = 0.obs;
  final RxInt jumlahTindakan = 0.obs;
  final RxInt jumlahSelesai = 0.obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();

  UserModel? get user => _authController.user;
  String get role => user?.role ?? 'PETUGASDESA';
  String get nama => user?.name ?? 'Petugas Desa';

  @override
  void onInit() {
    super.onInit();

    // Inisialisasi manual untuk pengaduan (untuk debugging)
    jumlahDiproses.value = 3;
    print('onInit - Jumlah pengaduan diproses: ${jumlahDiproses.value}');

    loadRoleData();
    loadDashboardData();
    loadJadwalData();
    loadPermintaanPenjadwalanData();
    loadNotifikasiData();
    loadInventarisData();
    loadPenitipanData();
    loadPengaduanData();
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

  Future<void> loadPermintaanPenjadwalanData() async {
    try {
      // Simulasi data untuk permintaan penjadwalan
      await Future.delayed(const Duration(milliseconds: 600));

      permintaanPenjadwalan.value = [
        {
          'id': '1',
          'nama': 'Ahmad Sulaiman',
          'nik': '3201234567890001',
          'jenis_bantuan': 'Beras',
          'tanggal_permintaan': '14 April 2023',
          'alamat': 'Dusun Sukamaju RT 02/03',
          'status': 'menunggu',
        },
        {
          'id': '2',
          'nama': 'Siti Aminah',
          'nik': '3201234567890002',
          'jenis_bantuan': 'Sembako',
          'tanggal_permintaan': '13 April 2023',
          'alamat': 'Dusun Sukamaju RT 01/03',
          'status': 'menunggu',
        },
      ];

      jumlahPermintaanPenjadwalan.value = permintaanPenjadwalan.length;

      // Di implementasi nyata, data akan diambil dari Supabase
      // final result = await _supabaseService.getPermintaanPenjadwalanData();
      // permintaanPenjadwalan.value = result ?? [];
      // jumlahPermintaanPenjadwalan.value = permintaanPenjadwalan.length;
    } catch (e) {
      print('Error loading permintaan penjadwalan data: $e');
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

  Future<void> loadPenitipanData() async {
    try {
      // Simulasi data untuk penitipan
      await Future.delayed(const Duration(milliseconds: 600));

      daftarPenitipan.value = [
        {
          'id': '1',
          'donatur': 'PT Sejahtera Abadi',
          'jenis_bantuan': 'Sembako',
          'jumlah': '500 kg',
          'tanggal_pengajuan': '15 April 2023',
          'status': 'Menunggu',
        },
        {
          'id': '2',
          'donatur': 'Yayasan Peduli Sesama',
          'jenis_bantuan': 'Pakaian',
          'jumlah': '200 pcs',
          'tanggal_pengajuan': '14 April 2023',
          'status': 'Terverifikasi',
        },
        {
          'id': '3',
          'donatur': 'Bank BRI',
          'jenis_bantuan': 'Beras',
          'jumlah': '300 kg',
          'tanggal_pengajuan': '13 April 2023',
          'status': 'Terverifikasi',
        },
        {
          'id': '4',
          'donatur': 'Komunitas Peduli',
          'jenis_bantuan': 'Alat Tulis',
          'jumlah': '100 set',
          'tanggal_pengajuan': '12 April 2023',
          'status': 'Ditolak',
        },
      ];

      // Hitung jumlah penitipan berdasarkan status
      jumlahMenunggu.value =
          daftarPenitipan.where((p) => p['status'] == 'Menunggu').length;
      jumlahTerverifikasi.value =
          daftarPenitipan.where((p) => p['status'] == 'Terverifikasi').length;
      jumlahDitolak.value =
          daftarPenitipan.where((p) => p['status'] == 'Ditolak').length;

      // Di implementasi nyata, data akan diambil dari Supabase
      // final result = await _supabaseService.getPenitipanData();
      // daftarPenitipan.value = result ?? [];
      // jumlahMenunggu.value = daftarPenitipan.where((p) => p['status'] == 'Menunggu').length;
      // jumlahTerverifikasi.value = daftarPenitipan.where((p) => p['status'] == 'Terverifikasi').length;
      // jumlahDitolak.value = daftarPenitipan.where((p) => p['status'] == 'Ditolak').length;
    } catch (e) {
      print('Error loading penitipan data: $e');
    }
  }

  Future<void> loadPengaduanData() async {
    try {
      // Simulasi data untuk pengaduan
      await Future.delayed(const Duration(milliseconds: 650));

      // Pastikan data pengaduan tidak kosong
      daftarPengaduan.value = [
        {
          'id': '1',
          'nama': 'Budi Santoso',
          'nik': '3201020107030011',
          'jenis_pengaduan': 'Bantuan Tidak Diterima',
          'deskripsi':
              'Saya belum menerima bantuan beras yang dijadwalkan minggu lalu',
          'tanggal': '15 April 2023',
          'status': 'Diproses',
        },
        {
          'id': '2',
          'nama': 'Siti Rahayu',
          'nik': '3201020107030010',
          'jenis_pengaduan': 'Kualitas Bantuan',
          'deskripsi':
              'Beras yang diterima berkualitas buruk dan tidak layak konsumsi',
          'tanggal': '14 April 2023',
          'status': 'Tindakan',
          'tindakan':
              'Pengecekan kualitas beras di gudang dan pengambilan sampel',
        },
        {
          'id': '3',
          'nama': 'Ahmad Fauzi',
          'nik': '3201020107030013',
          'jenis_pengaduan': 'Jumlah Bantuan',
          'deskripsi':
              'Jumlah bantuan yang diterima tidak sesuai dengan yang dijanjikan',
          'tanggal': '13 April 2023',
          'status': 'Tindakan',
          'tindakan':
              'Verifikasi data penerima dan jumlah bantuan yang seharusnya diterima',
        },
        {
          'id': '4',
          'nama': 'Dewi Lestari',
          'nik': '3201020107030012',
          'jenis_pengaduan': 'Jadwal Penyaluran',
          'deskripsi':
              'Jadwal penyaluran bantuan sering berubah tanpa pemberitahuan',
          'tanggal': '10 April 2023',
          'status': 'Selesai',
          'tindakan':
              'Koordinasi dengan tim penyaluran untuk perbaikan sistem pemberitahuan',
          'hasil':
              'Implementasi sistem notifikasi perubahan jadwal melalui SMS dan pengumuman di balai desa',
        },
        // Tambahkan data pengaduan dengan status 'Diproses' untuk memastikan counter muncul
        {
          'id': '5',
          'nama': 'Joko Widodo',
          'nik': '3201020107030014',
          'jenis_pengaduan': 'Bantuan Tidak Sesuai',
          'deskripsi':
              'Bantuan yang diterima tidak sesuai dengan yang dijanjikan',
          'tanggal': '16 April 2023',
          'status': 'Diproses',
        },
        {
          'id': '6',
          'nama': 'Anita Sari',
          'nik': '3201020107030015',
          'jenis_pengaduan': 'Bantuan Tidak Tepat Sasaran',
          'deskripsi':
              'Bantuan diberikan kepada warga yang tidak berhak menerima',
          'tanggal': '17 April 2023',
          'status': 'Diproses',
        },
      ];

      // Hitung jumlah pengaduan berdasarkan status
      int jumlahDiprosesTemp =
          daftarPengaduan.where((p) => p['status'] == 'Diproses').length;
      int jumlahTindakanTemp =
          daftarPengaduan.where((p) => p['status'] == 'Tindakan').length;
      int jumlahSelesaiTemp =
          daftarPengaduan.where((p) => p['status'] == 'Selesai').length;

      // Update nilai Rx
      jumlahDiproses.value = jumlahDiprosesTemp;
      jumlahTindakan.value = jumlahTindakanTemp;
      jumlahSelesai.value = jumlahSelesaiTemp;

      // Print untuk debugging
      print('Data pengaduan dimuat:');
      print('Jumlah pengaduan diproses: ${jumlahDiproses.value}');
      print('Jumlah pengaduan tindakan: ${jumlahTindakan.value}');
      print('Jumlah pengaduan selesai: ${jumlahSelesai.value}');
      print('Total pengaduan: ${daftarPengaduan.length}');

      // Perbarui UI secara manual
      update();

      // Di implementasi nyata, data akan diambil dari Supabase
      // final result = await _supabaseService.getPengaduanData();
      // daftarPengaduan.value = result ?? [];
      // jumlahDiproses.value = daftarPengaduan.where((p) => p['status'] == 'Diproses').length;
      // jumlahTindakan.value = daftarPengaduan.where((p) => p['status'] == 'Tindakan').length;
      // jumlahSelesai.value = daftarPengaduan.where((p) => p['status'] == 'Selesai').length;
    } catch (e) {
      print('Error loading pengaduan data: $e');
    }
  }

  // Method untuk memperbarui jumlah pengaduan secara manual (untuk debugging)
  void updatePengaduanCounter() {
    jumlahDiproses.value = 5; // Set nilai secara manual
    update(); // Perbarui UI
    print(
        'Counter pengaduan diperbarui secara manual: ${jumlahDiproses.value}');
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

  void terimaPermohonanPenitipan(String id) {
    // Implementasi untuk menerima permohonan penitipan
    // Di implementasi nyata, akan memanggil Supabase untuk memperbarui status penitipan
    // await _supabaseService.acceptDeposit(id);

    // Perbarui data lokal
    loadPenitipanData();
    loadInventarisData(); // Perbarui inventaris karena ada penambahan stok
  }

  void tolakPermohonanPenitipan(String id) {
    // Implementasi untuk menolak permohonan penitipan
    // Di implementasi nyata, akan memanggil Supabase untuk memperbarui status penitipan
    // await _supabaseService.rejectDeposit(id);

    // Perbarui data lokal
    loadPenitipanData();
  }

  void prosesPengaduan(String id, String tindakan) {
    // Implementasi untuk memproses pengaduan
    // Di implementasi nyata, akan memanggil Supabase untuk memperbarui status pengaduan
    // await _supabaseService.processPengaduan(id, tindakan);

    // Perbarui data lokal
    loadPengaduanData();
  }

  void selesaikanPengaduan(String id, String hasil) {
    // Implementasi untuk menyelesaikan pengaduan
    // Di implementasi nyata, akan memanggil Supabase untuk memperbarui status pengaduan
    // await _supabaseService.completePengaduan(id, hasil);

    // Perbarui data lokal
    loadPengaduanData();
  }

  void logout() {
    _authController.logout();
  }

  void changeTab(int index) {
    activeTabIndex.value = index;
  }

  // Metode untuk konfirmasi permintaan penjadwalan
  Future<void> konfirmasiPermintaanPenjadwalan(
      String id, String jadwalId) async {
    try {
      if (id.isEmpty || jadwalId.isEmpty) {
        Get.snackbar(
          'Error',
          'ID permintaan atau jadwal tidak valid',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      // Simulasi proses konfirmasi
      await Future.delayed(const Duration(milliseconds: 800));

      // Hapus permintaan dari daftar
      permintaanPenjadwalan.removeWhere((item) => item['id'] == id);
      jumlahPermintaanPenjadwalan.value = permintaanPenjadwalan.length;

      // Di implementasi nyata, data akan diupdate ke Supabase
      // await _supabaseService.konfirmasiPermintaanPenjadwalan(id, jadwalId);
      // await loadPermintaanPenjadwalanData();
      // await loadJadwalData();
    } catch (e) {
      print('Error konfirmasi permintaan penjadwalan: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat mengkonfirmasi permintaan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Metode untuk menolak permintaan penjadwalan
  Future<void> tolakPermintaanPenjadwalan(String id, String alasan) async {
    try {
      if (id.isEmpty) {
        Get.snackbar(
          'Error',
          'ID permintaan tidak valid',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      // Simulasi proses penolakan
      await Future.delayed(const Duration(milliseconds: 800));

      // Hapus permintaan dari daftar
      permintaanPenjadwalan.removeWhere((item) => item['id'] == id);
      jumlahPermintaanPenjadwalan.value = permintaanPenjadwalan.length;

      // Di implementasi nyata, data akan diupdate ke Supabase
      // await _supabaseService.tolakPermintaanPenjadwalan(id, alasan);
      // await loadPermintaanPenjadwalanData();
    } catch (e) {
      print('Error tolak permintaan penjadwalan: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menolak permintaan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
