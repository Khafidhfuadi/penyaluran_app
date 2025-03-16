import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/pengajuan_kelayakan_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class WargaDashboardController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

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

  // Getter untuk data user
  UserModel? get user => _authController.user;
  String get role => user?.role ?? 'WARGA';
  String get nama => user?.name ?? 'Warga';
  String? get desa => user?.desa?.nama;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    loadUserData();
  }

  void loadUserData() {
    currentUser.value = _authController.user;
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
  Future<void> fetchPenerimaPenyaluran() async {
    try {
      print('Memulai fetchPenerimaPenyaluran()');
      print('User ID: ${user?.id}');

      // Pertama, cari warga_id berdasarkan user_id
      final wargaResponse = await _supabaseService.client
          .from('warga')
          .select('id')
          .eq('user_id', user!.id)
          .single();

      print('Warga response: $wargaResponse');

      if (wargaResponse == null) {
        print('Tidak ditemukan data warga untuk user_id: ${user!.id}');
        return;
      }

      final wargaId = wargaResponse['id'];
      print('Warga ID: $wargaId');

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
              lokasi_penyaluran(*)
            )
          ''').eq('warga_id', wargaId).order('created_at', ascending: false);

      print('Response dari API: $response');

      if (response != null) {
        final List<PenerimaPenyaluranModel> penerima = [];
        for (var item in response) {
          print('Memproses item: $item');

          Map<String, dynamic> sanitizedPenerimaData =
              Map<String, dynamic>.from(item);

          print('Data yang disanitasi: $sanitizedPenerimaData');

          if (sanitizedPenerimaData['jumlah_bantuan'] is String) {
            var jumlahBantuan = double.tryParse(
                sanitizedPenerimaData['jumlah_bantuan'] as String);
            print(
                'Konversi jumlah_bantuan dari String ke double: $jumlahBantuan');
            sanitizedPenerimaData['jumlah_bantuan'] = jumlahBantuan;
          }

          // Tambahkan informasi apakah bantuan uang atau bukan dan satuan
          if (sanitizedPenerimaData['stok_bantuan'] != null) {
            print('Stok bantuan: ${sanitizedPenerimaData['stok_bantuan']}');

            // Cek apakah bantuan uang
            final isUang =
                sanitizedPenerimaData['stok_bantuan']['is_uang'] ?? false;
            sanitizedPenerimaData['is_uang'] = isUang;

            // Ambil satuan
            final satuan =
                sanitizedPenerimaData['stok_bantuan']['satuan'] ?? '';
            sanitizedPenerimaData['satuan'] = satuan;

            // Ambil nama kategori bantuan jika tersedia
            if (sanitizedPenerimaData['stok_bantuan']['kategori_bantuan'] !=
                null) {
              final kategoriNama = sanitizedPenerimaData['stok_bantuan']
                      ['kategori_bantuan']['nama'] ??
                  '';
              sanitizedPenerimaData['kategori_nama'] = kategoriNama;
            }

            print('Is Uang: $isUang, Satuan: $satuan');
          }

          // Tambahkan informasi dari penyaluran bantuan
          if (sanitizedPenerimaData['penyaluran_bantuan'] != null) {
            print(
                'Penyaluran bantuan: ${sanitizedPenerimaData['penyaluran_bantuan']}');

            // Ambil nama penyaluran
            final namaPenyaluran =
                sanitizedPenerimaData['penyaluran_bantuan']['nama'] ?? '';
            sanitizedPenerimaData['nama_penyaluran'] = namaPenyaluran;

            // Ambil deskripsi penyaluran
            final deskripsiPenyaluran =
                sanitizedPenerimaData['penyaluran_bantuan']['deskripsi'] ?? '';
            sanitizedPenerimaData['deskripsi_penyaluran'] = deskripsiPenyaluran;

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

            print('Nama Penyaluran: $namaPenyaluran');
          }

          var model = PenerimaPenyaluranModel.fromJson(sanitizedPenerimaData);
          print('Model yang dibuat: $model');
          penerima.add(model);
        }

        print('Total data yang diproses: ${penerima.length}');
        penerimaPenyaluran.assignAll(penerima);

        var diterima =
            penerima.where((p) => p.statusPenerimaan == 'DITERIMA').length;
        print('Total penyaluran diterima: $diterima');
        totalPenyaluranDiterima.value = diterima;
      }
    } catch (e, stackTrace) {
      print('Error fetchPenerimaPenyaluran: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Fungsi untuk mengambil data pengajuan kelayakan
  Future<void> fetchPengajuanKelayakan() async {
    try {
      // Pertama, cari warga_id berdasarkan user_id
      final wargaResponse = await _supabaseService.client
          .from('warga')
          .select('id')
          .eq('user_id', user!.id)
          .single();

      if (wargaResponse == null) {
        print('Tidak ditemukan data warga untuk user_id: ${user!.id}');
        return;
      }

      final wargaId = wargaResponse['id'];
      print('Warga ID untuk pengajuan kelayakan: $wargaId');

      final response = await _supabaseService.client
          .from('xx02_pengajuan_kelayakan_bantuan')
          .select('*')
          .eq('warga_id', wargaId)
          .order('created_at', ascending: false);

      if (response != null) {
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
      }
    } catch (e) {
      print('Error fetching pengajuan kelayakan: $e');
    }
  }

  // Fungsi untuk mengambil data pengaduan
  Future<void> fetchPengaduan() async {
    try {
      final response = await _supabaseService.client
          .from('pengaduan')
          .select('*')
          .eq('pelapor', user!.id)
          .order('created_at', ascending: false);

      if (response != null) {
        final List<PengaduanModel> pengaduanList = [];
        for (var item in response) {
          pengaduanList.add(PengaduanModel.fromJson(item));
        }
        pengaduan.assignAll(pengaduanList);

        // Hitung jumlah berdasarkan status
        totalPengaduan.value = pengaduanList.length;
        totalPengaduanProses.value = pengaduanList
            .where((p) => p.status == 'PROSES' || p.status == 'DIPROSES')
            .length;
        totalPengaduanSelesai.value =
            pengaduanList.where((p) => p.status == 'SELESAI').length;
      }
    } catch (e) {
      print('Error fetching pengaduan: $e');
    }
  }

  // Fungsi untuk mengambil data notifikasi
  Future<void> fetchNotifikasi() async {
    try {
      final response = await _supabaseService.client
          .from('notifikasi')
          .select('*')
          .eq('user_id', user!.id)
          .eq('dibaca', false)
          .count();

      jumlahNotifikasiBelumDibaca.value = response.count;
    } catch (e) {
      print('Error fetching notifikasi: $e');
      jumlahNotifikasiBelumDibaca.value = 0;
    }
  }

  // Navigasi ke halaman detail
  void goToPenyaluranDetail() {
    changeTab(1);
  }

  void goToPengajuanDetail() {
    // TODO: Implementasi navigasi ke halaman detail pengajuan
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
}
