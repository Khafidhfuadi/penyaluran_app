import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/pengajuan_kelayakan_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/data/models/warga_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:flutter/material.dart';

class WargaDashboardController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final Rx<BaseUserModel?> currentUser = Rx<BaseUserModel?>(null);

  // Variabel untuk foto profil
  final RxString fotoProfil = ''.obs;

  // Indeks tab yang aktif di bottom navigation bar
  final RxInt activeTabIndex = 0.obs;

  // Data untuk summary penerima penyaluran
  final RxList<PenerimaPenyaluranModel> penerimaPenyaluran =
      <PenerimaPenyaluranModel>[].obs;
  final RxInt totalPenyaluranDiterima = 0.obs;

  // Data untuk daftar pengajuan kelayakan bantuan
  final RxList<PengajuanKelayakanBantuanModel> pengajuanKelayakan =
      <PengajuanKelayakanBantuanModel>[].obs;
  final RxInt totalPengajuanMenunggu = 0.obs;
  final RxInt totalPengajuanTerverifikasi = 0.obs;
  final RxInt totalPengajuanDitolak = 0.obs;

  // Data untuk summary pengaduan
  final RxList<PengaduanModel> pengaduan = <PengaduanModel>[].obs;
  final RxInt totalPengaduan = 0.obs;
  final RxInt totalPengaduanProses = 0.obs;
  final RxInt totalPengaduanSelesai = 0.obs;

  // Indikator loading
  final RxBool isLoading = false.obs;

  // Jumlah notifikasi belum dibaca
  final RxInt jumlahNotifikasiBelumDibaca = 0.obs;

  // Variabel untuk mengontrol auto-refresh
  final RxBool _autoRefreshEnabled = true.obs;

  // Getter untuk status auto-refresh
  bool get isAutoRefreshEnabled => _autoRefreshEnabled.value;

  // Getter untuk data user
  BaseUserModel? get user => _authController.baseUser;
  String get role => user?.role ?? 'WARGA';
  String get nama {
    // Gunakan namaLengkap dari roleData jika tersedia
    if (_authController.isWarga && _authController.roleData != null) {
      return _authController.roleData.namaLengkap ??
          _authController.displayName;
    }
    // Gunakan displayName dari AuthController
    return _authController.displayName;
  }

  String? get desa => user?.desa?.nama;

  // Getter untuk alamat dan noHp
  String? get alamat {
    if (_authController.isWarga && _authController.roleData != null) {
      return (_authController.roleData as WargaModel).alamat;
    }
    return null;
  }

  String? get noHp {
    if (_authController.isWarga && _authController.roleData != null) {
      return (_authController.roleData as WargaModel).noHp;
    }
    return null;
  }

  // Getter untuk NIK
  String? get nik {
    if (_authController.isWarga && _authController.roleData != null) {
      return (_authController.roleData as WargaModel).nik;
    }
    return null;
  }

  // Getter untuk foto profil
  String? get profilePhotoUrl {
    // 1. Coba ambil dari fotoProfil yang sudah disimpan
    if (fotoProfil.isNotEmpty) {
      return fotoProfil.value;
    }

    // 2. Coba ambil dari roleData jika merupakan WargaModel
    if (_authController.isWarga && _authController.roleData != null) {
      final wargaData = _authController.roleData as WargaModel;
      if (wargaData.fotoProfil != null && wargaData.fotoProfil!.isNotEmpty) {
        return wargaData.fotoProfil;
      }
    }

    // 3. Coba ambil dari userData.roleData.fotoProfil
    final userData = _authController.userData;
    if (userData != null && userData.roleData is WargaModel) {
      final wargaData = userData.roleData as WargaModel;
      if (wargaData.fotoProfil != null && wargaData.fotoProfil!.isNotEmpty) {
        return wargaData.fotoProfil;
      }
    }

    return null;
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
    loadUserData();

    // Atau gunakan timer untuk refresh data secara periodik
    // Timer.periodic(Duration(seconds: 60), (_) => loadUserData());
  }

  @override
  void onReady() {
    super.onReady();
    // Perbarui data user dan foto profil saat halaman siap
    loadUserData();
  }

  void loadUserData() {
    currentUser.value = _authController.baseUser;

    // Kurangi log debugging
    if (_authController.userData != null) {
      if (_authController.isWarga) {
        var wargaData = _authController.roleData;

        // Ambil foto profil dari wargaData jika ada
        if (wargaData != null &&
            wargaData.fotoProfil != null &&
            wargaData.fotoProfil!.isNotEmpty) {
          fotoProfil.value = wargaData.fotoProfil!;
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

      final wargaData = await _supabaseService.client
          .from('warga')
          .select('foto_profil')
          .eq('id', user!.id) // Menggunakan id, bukan user_id
          .maybeSingle();

      if (wargaData != null && wargaData['foto_profil'] != null) {
        fotoProfil.value = wargaData['foto_profil'];
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

      // Ambil data penerima penyaluran dari server
      await fetchPenerimaPenyaluran();

      // Ambil data pengajuan kelayakan dari server
      await fetchPengajuanKelayakan();

      // Ambil data pengaduan dari server
      await fetchPengaduan();

      // Ambil data notifikasi
      await fetchNotifikasi();
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk mengambil data penerima penyaluran
  Future<List<PenerimaPenyaluranModel>> fetchPenerimaPenyaluran() async {
    try {
      // Reset data terlebih dahulu untuk memastikan tidak ada data lama yang tersimpan
      penerimaPenyaluran.clear();

      // Pastikan user sudah login dan memiliki ID
      if (user?.id == null) {
        return [];
      }

      // Gunakan langsung ID pengguna sebagai warga_id
      final wargaId = user!.id;

      // Ambil data penerima penyaluran dengan join ke warga, stok bantuan, dan penyaluran bantuan
      final response =
          await _supabaseService.client.from('penerima_penyaluran').select('''
            *,
            warga:warga_id(*),
            stok_bantuan:stok_bantuan_id(
              *,
              kategori_bantuan(*)
            ),
            penyaluran_bantuan:penyaluran_bantuan_id(
              *,
              lokasi_penyaluran(*),
              kategori_bantuan(*)
            )
          ''').eq('warga_id', wargaId).order('created_at', ascending: false);

      final List<PenerimaPenyaluranModel> penerima = [];

      // Loop melalui setiap data penerima
      for (var item in response) {
        try {
          // Pastikan data penerima sesuai dengan tipe data yang diharapkan
          Map<String, dynamic> sanitizedPenerimaData =
              Map<String, dynamic>.from(item);

          // Konversi jumlah_bantuan ke double jika bertipe String
          if (sanitizedPenerimaData['jumlah_bantuan'] is String) {
            sanitizedPenerimaData['jumlah_bantuan'] =
                double.tryParse(sanitizedPenerimaData['jumlah_bantuan']) ?? 0.0;
          }

          // Ambil data dari stok bantuan jika tersedia
          if (sanitizedPenerimaData['stok_bantuan'] != null) {
            // Cek apakah bantuan berupa uang atau barang
            final isUang =
                sanitizedPenerimaData['stok_bantuan']['is_uang'] ?? false;
            sanitizedPenerimaData['is_uang'] = isUang;

            // Ambil satuan bantuan
            final satuan =
                sanitizedPenerimaData['stok_bantuan']['satuan'] ?? '';
            sanitizedPenerimaData['satuan'] = satuan;

            // Ambil nama kategori bantuan
            if (sanitizedPenerimaData['stok_bantuan']['kategori_bantuan'] !=
                null) {
              final kategoriNama = sanitizedPenerimaData['stok_bantuan']
                      ['kategori_bantuan']['nama'] ??
                  '';
              sanitizedPenerimaData['kategori_nama'] = kategoriNama;
            }
          }

          // Ambil data dari penyaluran bantuan jika tersedia
          if (sanitizedPenerimaData['penyaluran_bantuan'] != null) {
            // Ambil nama penyaluran
            final namaPenyaluran =
                sanitizedPenerimaData['penyaluran_bantuan']['nama'] ?? '';
            sanitizedPenerimaData['nama_penyaluran'] = namaPenyaluran;

            // Ambil deskripsi penyaluran
            final deskripsiPenyaluran =
                sanitizedPenerimaData['penyaluran_bantuan']['deskripsi'] ?? '';
            sanitizedPenerimaData['deskripsi_penyaluran'] = deskripsiPenyaluran;

            // Ambil status penyaluran
            final statusPenyaluran =
                sanitizedPenerimaData['penyaluran_bantuan']['status'] ?? '';
            sanitizedPenerimaData['status_penyaluran'] = statusPenyaluran;

            // Ambil lokasi penyaluran jika tersedia
            if (sanitizedPenerimaData['penyaluran_bantuan']
                    ['lokasi_penyaluran'] !=
                null) {
              final lokasiNama = sanitizedPenerimaData['penyaluran_bantuan']
                      ['lokasi_penyaluran']['nama'] ??
                  '';
              sanitizedPenerimaData['lokasi_penyaluran_nama'] = lokasiNama;

              final lokasiAlamat = sanitizedPenerimaData['penyaluran_bantuan']
                      ['lokasi_penyaluran']['alamat_lengkap'] ??
                  '';
              sanitizedPenerimaData['lokasi_penyaluran_alamat'] = lokasiAlamat;
            }

            // Ambil kategori bantuan dari relasi langsung jika ada
            if (sanitizedPenerimaData['penyaluran_bantuan']
                    ['kategori_bantuan'] !=
                null) {
              final kategoriNama = sanitizedPenerimaData['penyaluran_bantuan']
                      ['kategori_bantuan']['nama'] ??
                  '';
              // Jika belum ada kategori_nama dari stok_bantuan, gunakan dari relasi langsung
              if (sanitizedPenerimaData['kategori_nama'] == null ||
                  sanitizedPenerimaData['kategori_nama'].isEmpty) {
                sanitizedPenerimaData['kategori_nama'] = kategoriNama;
              }
            }
          }

          var model = PenerimaPenyaluranModel.fromJson(sanitizedPenerimaData);
          penerima.add(model);
        } catch (parseError) {
          print('DEBUG PENERIMAAN: Error parsing item: $parseError');
          print('DEBUG PENERIMAAN: Data yang gagal di-parse: $item');
        }
      }

      // Pastikan list tidak kosong sebelum assign
      if (penerima.isNotEmpty) {
        // Update nilai observable
        penerimaPenyaluran.assignAll(penerima);

        var diterima =
            penerima.where((p) => p.statusPenerimaan == 'DITERIMA').length;
        totalPenyaluranDiterima.value = diterima;
      }

      return penerima;
    } catch (e) {
      print('Error fetchPenerimaPenyaluran: $e');
      // Pastikan list kosong jika terjadi error
      penerimaPenyaluran.clear();
      return [];
    }
  }

  // Fungsi untuk mengambil data pengajuan kelayakan
  Future<void> fetchPengajuanKelayakan() async {
    try {
      // Gunakan langsung ID pengguna sebagai warga_id
      final wargaId = user!.id;

      final response = await _supabaseService.client
          .from('xx02_pengajuan_kelayakan_bantuan')
          .select('*')
          .eq('warga_id', wargaId)
          .order('created_at', ascending: false);

      final List<PengajuanKelayakanBantuanModel> pengajuan = [];
      for (var item in response) {
        // Konversi status ke enum
        if (item['status'] != null) {
          final statusStr = item['status'].toString();
          item['status'] = statusStr; // Pastikan status dalam format string
        }

        pengajuan.add(PengajuanKelayakanBantuanModel.fromJson(item));
      }
      pengajuanKelayakan.assignAll(pengajuan);

      // Hitung jumlah berdasarkan status
      totalPengajuanMenunggu.value =
          pengajuan.where((p) => p.status == StatusKelayakan.MENUNGGU).length;
      totalPengajuanTerverifikasi.value = pengajuan
          .where((p) => p.status == StatusKelayakan.TERVERIFIKASI)
          .length;
      totalPengajuanDitolak.value =
          pengajuan.where((p) => p.status == StatusKelayakan.DITOLAK).length;
    } catch (e) {
      print('Error fetchPengajuanKelayakan: $e');
    }
  }

  // Fungsi untuk mengambil data pengaduan
  Future<void> fetchPengaduan() async {
    try {
      // Gunakan langsung ID user dari AuthController, bukan getWargaByUserId()
      String wargaId = user!.id;
      print('DEBUG WARGA: Mengambil pengaduan untuk warga ID: $wargaId');

      final response = await _supabaseService
          .getPengaduanWargaWithPenerimaPenyaluran(wargaId);

      if (response != null) {
        final List<PengaduanModel> pengaduanList = [];
        for (var item in response) {
          pengaduanList.add(PengaduanModel.fromJson(item));
        }
        pengaduan.assignAll(pengaduanList);

        // Hitung jumlah berdasarkan status
        totalPengaduan.value = pengaduanList.length;
        totalPengaduanProses.value = pengaduanList
            .where((p) => p.status == 'MENUNGGU' || p.status == 'TINDAKAN')
            .length;
        totalPengaduanSelesai.value =
            pengaduanList.where((p) => p.status == 'SELESAI').length;

        print(
            'DEBUG WARGA: Berhasil mendapatkan ${pengaduanList.length} pengaduan');
      } else {
        print('DEBUG WARGA: Tidak ada pengaduan yang ditemukan');
      }
    } catch (e) {
      print('DEBUG WARGA: Error fetching pengaduan: $e');
    }
  }

  // Fungsi untuk mengambil data notifikasi
  Future<void> fetchNotifikasi() async {
    try {
      // Notifikasi masih menggunakan user_id karena tabelnya terpisah
      final response = await _supabaseService.client
          .from('notifikasi')
          .select('*')
          .eq('user_id', user!.id)
          .eq('dibaca', false)
          .count();

      jumlahNotifikasiBelumDibaca.value = response.count;
    } catch (e) {
      jumlahNotifikasiBelumDibaca.value = 0;
    }
  }

  // Navigasi ke halaman detail
  void goToPenyaluranDetail() {
    changeTab(1);
  }

  void goToPengajuanDetail() {
    // Untuk saat ini, belum ada halaman detail pengajuan
  }

  void goToPengaduanDetail() {
    changeTab(2);
  }

  // Fungsi untuk mengubah tab
  void changeTab(int index) {
    activeTabIndex.value = index;

    // Tidak perlu navigasi ke halaman lain, cukup ubah indeks tab
    // yang akan mengubah konten body di WargaView
  }

  // Fungsi untuk logout
  void logout() {
    _authController.logout();
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
      return {
        'pengaduan': null,
        'tindakan': [],
      };
    }
  }

  // Metode untuk menambahkan feedback dan rating pengaduan
  Future<void> addPengaduanFeedback(
      String pengaduanId, String feedback, int rating) async {
    try {
      await _supabaseService.addPengaduanFeedback(
          pengaduanId, feedback, rating);
      fetchData(); // Refresh data
      Get.snackbar(
        'Berhasil',
        'Feedback berhasil dikirim',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengirim feedback: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Metode untuk memperbarui feedback dan rating pengaduan
  Future<void> updatePengaduanFeedback(
      String pengaduanId, String feedback, int rating) async {
    try {
      await _supabaseService.updatePengaduanFeedback(
          pengaduanId, feedback, rating);
      fetchData(); // Refresh data
      Get.snackbar(
        'Berhasil',
        'Feedback berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui feedback: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Metode untuk menambahkan pengaduan baru
  Future<bool> addPengaduan({
    required String judul,
    required String deskripsi,
    required String penerimaPenyaluranId,
    List<String> fotoPengaduanPaths = const [],
  }) async {
    try {
      isLoading.value = true;

      // Gunakan langsung ID pengguna sebagai warga_id
      final String wargaId = user!.id;

      // Upload foto pengaduan jika ada
      List<String> fotoPengaduanUrls = [];
      if (fotoPengaduanPaths.isNotEmpty) {
        fotoPengaduanUrls = await _supabaseService.uploadMultipleFiles(
                fotoPengaduanPaths, 'pengaduan', 'foto_pengaduan') ??
            [];
      }

      // Buat objek pengaduan
      final Map<String, dynamic> pengaduanData = {
        'judul': judul,
        'deskripsi': deskripsi,
        'status': 'MENUNGGU',
        'warga_id': wargaId,
        'penerima_penyaluran_id': penerimaPenyaluranId,
        'foto_pengaduan': fotoPengaduanUrls,
        'tanggal_pengaduan': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Simpan pengaduan ke Supabase
      await _supabaseService.client.from('pengaduan').insert(pengaduanData);

      // Refresh data pengaduan
      await fetchPengaduan();

      Get.snackbar(
        'Berhasil',
        'Pengaduan berhasil dibuat dan akan segera diproses',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      print('Error membuat pengaduan: $e');
      Get.snackbar(
        'Error',
        'Gagal membuat pengaduan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Metode untuk mengatur apakah auto-refresh diaktifkan atau tidak
  void setAutoRefreshEnabled(bool enabled) {
    _autoRefreshEnabled.value = enabled;
  }

  // Metode untuk refresh data setelah update profil atau kembali ke halaman
  Future<void> refreshData({bool silent = false}) async {
    // Cek apakah auto-refresh diaktifkan
    if (!_autoRefreshEnabled.value) {
      if (!silent) print('Auto-refresh dinonaktifkan, melewati refresh data');
      return;
    }

    if (!silent) print('Memulai refresh data...');
    await _authController.refreshUserData(); // Refresh data dari server
    loadUserData(); // Muat ulang data ke variabel lokal
    fetchData(); // Ambil data terkait lainnya
    if (!silent) print('Refresh data selesai');
  }
}
