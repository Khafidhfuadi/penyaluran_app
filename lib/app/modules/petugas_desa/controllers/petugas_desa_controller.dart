import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/desa_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/counter_service.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penitipan_bantuan_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/stok_bantuan_controller.dart';

class PetugasDesaController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;
  late final CounterService _counterService;

  // Indeks tab yang aktif di bottom navigation bar
  final RxInt activeTabIndex = 0.obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();

  // Controller untuk pencarian penerima
  final TextEditingController searchPenerimaController =
      TextEditingController();

  // Data profil pengguna dari cache
  final RxMap<String, dynamic> userProfile = RxMap<String, dynamic>({});

  // Model desa dari cache
  final Rx<DesaModel?> desaModel = Rx<DesaModel?>(null);

  // Data jadwal hari ini
  final RxList<dynamic> jadwalHariIni = <dynamic>[].obs;

  // Data penerima penyaluran
  final RxList<Map<String, dynamic>> penerimaPenyaluran =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredPenerima =
      <Map<String, dynamic>>[].obs;
  final RxInt jumlahPenerima = 0.obs;
  final RxString filterStatus = 'SEMUA'.obs;

  // Tambahkan variabel isLoading
  final isLoading = false.obs;

  // Tambahkan instance supabaseService yang sudah diinisialisasi
  final supabaseService = SupabaseService.to;

  // Variabel untuk pencarian dan filter
  final searchQuery = ''.obs;

  UserModel? get user => _authController.user;
  String get role => user?.role ?? 'PETUGASDESA';
  String get nama => user?.name ?? 'Petugas Desa';

  // Getter untuk counter dari CounterService
  RxInt get jumlahNotifikasiBelumDibaca =>
      _counterService.jumlahNotifikasiBelumDibaca;
  RxInt get jumlahMenunggu => _counterService.jumlahMenunggu;
  RxInt get jumlahDiproses => _counterService.jumlahDiproses;

  // Getter untuk nama lengkap dari profil pengguna
  String get namaLengkap => userProfile['name'] ?? user?.name ?? 'Petugas Desa';

  // Getter untuk nama desa dari profil pengguna
  String get desa {
    // Prioritaskan model desa dari user
    if (user?.desa != null) {
      print('DEBUG: Menggunakan desa dari user model: ${user!.desa!.nama}');
      return user!.desa!.nama;
    }

    // Kemudian coba dari userProfile
    if (userProfile['desa'] != null && userProfile['desa'] is Map) {
      final desaNama = userProfile['desa']['nama'] ?? 'Desa';
      print('DEBUG: Menggunakan desa dari userProfile: $desaNama');
      return desaNama;
    }

    // Fallback ke nilai default
    print('DEBUG: Menggunakan nilai default untuk desa');
    return userProfile['desa_id'] != null ? 'Desa' : 'Desa';
  }

  @override
  void onInit() {
    super.onInit();

    // Inisialisasi CounterService jika belum ada
    if (!Get.isRegistered<CounterService>()) {
      Get.put(CounterService(), permanent: true);
    }
    _counterService = Get.find<CounterService>();

    loadUserProfile();
    loadNotifikasiData();
    loadJadwalData();
    loadPenitipanData();
    loadPengaduanData();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchPenerimaController.dispose();
    super.onClose();
  }

  // Metode untuk memuat data profil pengguna dari cache
  Future<void> loadUserProfile() async {
    try {
      // Jika user sudah ada di AuthController, tidak perlu mengambil data lagi
      if (user != null) {
        print('DEBUG: User ditemukan di AuthController: ${user!.email}');
        print('DEBUG: User desa: ${user!.desa?.nama}');

        // Ambil data tambahan jika diperlukan, tapi gunakan cache
        final profileData = await _supabaseService.getUserProfile();
        if (profileData != null) {
          print('DEBUG: Profile data ditemukan: ${profileData['name']}');
          userProfile.value = profileData;

          // Parse data desa jika ada
          if (profileData['desa'] != null &&
              profileData['desa'] is Map<String, dynamic>) {
            try {
              final desaData = profileData['desa'] as Map<String, dynamic>;
              print('DEBUG: Desa data ditemukan: $desaData');
            } catch (e) {
              print('Error parsing desa data: $e');
            }
          } else {
            print('DEBUG: Desa data tidak ditemukan atau bukan Map');
          }
        } else {
          print('DEBUG: Profile data tidak ditemukan');
        }
      } else {
        print('DEBUG: User tidak ditemukan di AuthController');
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Metode untuk memuat data notifikasi
  Future<void> loadNotifikasiData() async {
    try {
      if (user != null) {
        final notifikasiData =
            await _supabaseService.getNotifikasiBelumDibaca(user!.id);
        if (notifikasiData != null) {
          _counterService.updateNotifikasiCounter(notifikasiData.length);
        }
      }
    } catch (e) {
      print('Error loading notifikasi data: $e');
    }
  }

  // Metode untuk memuat data jadwal
  Future<void> loadJadwalData() async {
    try {
      final jadwalHariIniData = await _supabaseService.getJadwalHariIni();
      if (jadwalHariIniData != null) {
        jadwalHariIni.value = jadwalHariIniData;
        _counterService.updateJadwalCounter(jadwalHariIniData.length);
      }
    } catch (e) {
      print('Error loading jadwal data: $e');
    }
  }

  // Metode untuk memuat data penitipan
  Future<void> loadPenitipanData() async {
    try {
      // Simulasi data untuk contoh
      // Dalam implementasi nyata, Anda akan mengambil data dari API
      final penitipanData = await _supabaseService.getPenitipanBantuan();
      if (penitipanData != null) {
        int menunggu = 0;

        // Hitung jumlah penitipan dengan status MENUNGGU
        for (var item in penitipanData) {
          if (item['status'] == 'MENUNGGU') {
            menunggu++;
          }
        }

        // Update counter
        _counterService.updatePenitipanCounters(
          menunggu: menunggu,
          terverifikasi: 0, // Tidak digunakan di UI utama
          ditolak: 0, // Tidak digunakan di UI utama
        );

        print('Jumlah penitipan menunggu: $menunggu');
      }
    } catch (e) {
      print('Error loading penitipan data: $e');
    }
  }

  // Metode untuk memuat data pengaduan
  Future<void> loadPengaduanData() async {
    try {
      // Simulasi data untuk contoh
      // Dalam implementasi nyata, Anda akan mengambil data dari API
      final pengaduanData = await _supabaseService.getPengaduan();
      if (pengaduanData != null) {
        int diproses = 0;

        // Hitung jumlah pengaduan dengan status DIPROSES
        for (var item in pengaduanData) {
          if (item['status'] == 'DIPROSES') {
            diproses++;
          }
        }

        // Update counter
        _counterService.updatePengaduanCounter(diproses);
      } else {
        _counterService.updatePengaduanCounter(0);
      }
    } catch (e) {
      print('Error loading pengaduan data: $e');
    }
  }

  // Metode untuk memperbarui counter pengaduan
  Future<void> updatePengaduanCounter() async {
    try {
      await loadPengaduanData();
    } catch (e) {
      print('Error updating pengaduan counter: $e');
    }
  }

  // Metode untuk memastikan format UUID yang benar
  String ensureValidUUID(String id) {
    // Jika ID sudah dalam format UUID yang benar, kembalikan apa adanya
    if (id.contains('-') && id.length == 36) {
      return id;
    }

    // Jika ID adalah string UUID tanpa tanda hubung, tambahkan tanda hubung
    if (id.length == 32) {
      return '${id.substring(0, 8)}-${id.substring(8, 12)}-${id.substring(12, 16)}-${id.substring(16, 20)}-${id.substring(20)}';
    }

    // Jika format tidak dikenali, kembalikan apa adanya
    return id;
  }

  // Metode untuk memuat ulang data penerima
  Future<void> reloadPenerimaPenyaluran() async {
    isLoading.value = true;
    try {
      // Gunakan data dummy sementara
      final dummyData = _createDummyPenerimaPenyaluran();
      penerimaPenyaluran.value = dummyData;
      jumlahPenerima.value = dummyData.length;
      print(
          'Data dummy penerima berhasil dimuat: ${penerimaPenyaluran.length} data');
    } catch (e) {
      print('Error saat memuat data dummy penerima: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Membuat data dummy penerima penyaluran
  List<Map<String, dynamic>> _createDummyPenerimaPenyaluran() {
    return [
      {
        'id': 1,
        'penyaluran_bantuan_id': 'a2dabc5a-761f-4f11-9fbe-a376768880c3',
        'warga_id': 'warga-001',
        'status_penerimaan': 'SUDAHMENERIMA',
        'jumlah_bantuan': 1,
        'created_at': '2023-01-01',
        'warga': {
          'id': 'warga-001',
          'nama_lengkap': 'Budi Santoso',
          'nik': '3201234567890001',
          'alamat': 'Jl. Merdeka No. 123, RT 01/RW 02',
          'jenis_kelamin': 'L',
          'tanggal_lahir': '1980-01-01',
        }
      },
      {
        'id': 2,
        'penyaluran_bantuan_id': 'a2dabc5a-761f-4f11-9fbe-a376768880c3',
        'warga_id': 'warga-002',
        'status_penerimaan': 'BELUMMENERIMA',
        'jumlah_bantuan': 1,
        'created_at': '2023-01-01',
        'warga': {
          'id': 'warga-002',
          'nama_lengkap': 'Siti Aminah',
          'nik': '3201234567890002',
          'alamat': 'Jl. Pahlawan No. 45, RT 03/RW 04',
          'jenis_kelamin': 'P',
          'tanggal_lahir': '1985-05-15',
        }
      },
      {
        'id': 3,
        'penyaluran_bantuan_id': 'a2dabc5a-761f-4f11-9fbe-a376768880c3',
        'warga_id': 'warga-003',
        'status_penerimaan': 'SUDAHMENERIMA',
        'jumlah_bantuan': 1,
        'created_at': '2023-01-01',
        'warga': {
          'id': 'warga-003',
          'nama_lengkap': 'Ahmad Hidayat',
          'nik': '3201234567890003',
          'alamat': 'Jl. Cendrawasih No. 78, RT 05/RW 06',
          'jenis_kelamin': 'L',
          'tanggal_lahir': '1975-12-10',
        }
      },
      {
        'id': 4,
        'penyaluran_bantuan_id': 'a2dabc5a-761f-4f11-9fbe-a376768880c3',
        'warga_id': 'warga-004',
        'status_penerimaan': 'BELUMMENERIMA',
        'jumlah_bantuan': 1,
        'created_at': '2023-01-01',
        'warga': {
          'id': 'warga-004',
          'nama_lengkap': 'Dewi Lestari',
          'nik': '3201234567890004',
          'alamat': 'Jl. Mawar No. 12, RT 07/RW 08',
          'jenis_kelamin': 'P',
          'tanggal_lahir': '1990-08-22',
        }
      },
      {
        'id': 5,
        'penyaluran_bantuan_id': 'a2dabc5a-761f-4f11-9fbe-a376768880c3',
        'warga_id': 'warga-005',
        'status_penerimaan': 'SUDAHMENERIMA',
        'jumlah_bantuan': 1,
        'created_at': '2023-01-01',
        'warga': {
          'id': 'warga-005',
          'nama_lengkap': 'Joko Widodo',
          'nik': '3201234567890005',
          'alamat': 'Jl. Kenanga No. 56, RT 09/RW 10',
          'jenis_kelamin': 'L',
          'tanggal_lahir': '1965-06-30',
        }
      }
    ];
  }

  // Metode untuk menginisialisasi data penerima penyaluran
  void initPenerimaPenyaluran(List<Map<String, dynamic>> data) {
    print(
        'DEBUG CONTROLLER: Inisialisasi penerima penyaluran dengan ${data.length} item');

    // Periksa struktur data
    if (data.isNotEmpty) {
      final firstItem = data.first;
      print(
          'DEBUG CONTROLLER: Struktur data penerima: ${firstItem.keys.join(', ')}');

      if (firstItem.containsKey('warga')) {
        final warga = firstItem['warga'];
        print(
            'DEBUG CONTROLLER: Struktur data warga: ${warga != null ? (warga is Map ? warga.keys.join(', ') : 'bukan Map') : 'null'}');
      } else {
        print(
            'DEBUG CONTROLLER: Data warga tidak ditemukan dalam item penerima');
      }
    }

    penerimaPenyaluran.value = data;
    filteredPenerima.value = data;
    jumlahPenerima.value = data.length;

    print(
        'DEBUG CONTROLLER: Selesai inisialisasi, jumlah penerima: ${jumlahPenerima.value}');
  }

  // Metode untuk memfilter penerima berdasarkan kata kunci
  void filterPenerima(String keyword) {
    print('DEBUG CONTROLLER: Memfilter penerima dengan keyword: "$keyword"');

    if (keyword.isEmpty) {
      print('DEBUG CONTROLLER: Keyword kosong, menerapkan filter status saja');
      applyFilters();
      return;
    }

    final lowercaseKeyword = keyword.toLowerCase();
    final filtered = penerimaPenyaluran.where((penerima) {
      final warga = penerima['warga'] as Map<String, dynamic>?;
      if (warga == null) {
        print(
            'DEBUG CONTROLLER: Data warga null untuk penerima: ${penerima['id']}');
        return false;
      }

      final namaLengkap =
          (warga['nama_lengkap'] ?? '').toString().toLowerCase();
      final nik = (warga['nik'] ?? '').toString().toLowerCase();
      final alamat = (warga['alamat'] ?? '').toString().toLowerCase();

      final matches = namaLengkap.contains(lowercaseKeyword) ||
          nik.contains(lowercaseKeyword) ||
          alamat.contains(lowercaseKeyword);

      return matches;
    }).toList();

    print(
        'DEBUG CONTROLLER: Hasil filter: ${filtered.length} dari ${penerimaPenyaluran.length} item');
    filteredPenerima.value = filtered;
  }

  // Metode untuk menerapkan filter status
  void applyFilters() {
    final keyword = searchPenerimaController.text.toLowerCase();
    print(
        'DEBUG CONTROLLER: Menerapkan filter dengan status: ${filterStatus.value}, keyword: "$keyword"');

    if (filterStatus.value == 'SEMUA' && keyword.isEmpty) {
      print('DEBUG CONTROLLER: Tidak ada filter, menampilkan semua data');
      filteredPenerima.value = penerimaPenyaluran;
      return;
    }

    final filtered = penerimaPenyaluran.where((penerima) {
      bool statusMatch = true;
      if (filterStatus.value != 'SEMUA') {
        statusMatch = penerima['status_penerimaan'] == filterStatus.value;
      }

      if (keyword.isEmpty) return statusMatch;

      final warga = penerima['warga'] as Map<String, dynamic>?;
      if (warga == null) return false;

      final namaLengkap =
          (warga['nama_lengkap'] ?? '').toString().toLowerCase();
      final nik = (warga['nik'] ?? '').toString().toLowerCase();
      final alamat = (warga['alamat'] ?? '').toString().toLowerCase();

      final keywordMatch = namaLengkap.contains(keyword) ||
          nik.contains(keyword) ||
          alamat.contains(keyword);

      return statusMatch && keywordMatch;
    }).toList();

    print(
        'DEBUG CONTROLLER: Hasil filter gabungan: ${filtered.length} dari ${penerimaPenyaluran.length} item');
    filteredPenerima.value = filtered;
  }

  // Metode untuk memperbarui status penerimaan bantuan
  Future<bool> updateStatusPenerimaan(int penerimaId, String status,
      {DateTime? tanggalPenerimaan,
      String? buktiPenerimaan,
      String? keterangan}) async {
    try {
      final result = await _supabaseService.updateStatusPenerimaan(
          penerimaId, status,
          tanggalPenerimaan: tanggalPenerimaan,
          buktiPenerimaan: buktiPenerimaan,
          keterangan: keterangan);
      return result;
    } catch (e) {
      print('Error updating status penerimaan: $e');
      return false;
    }
  }

  // Metode untuk menyelesaikan jadwal penyaluran
  Future<void> completeJadwal(String jadwalId) async {
    try {
      await _supabaseService.completeJadwal(jadwalId);
    } catch (e) {
      print('Error completing jadwal: $e');
      throw e.toString();
    }
  }

  // Metode untuk mengubah tab aktif
  void changeTab(int index) {
    activeTabIndex.value = index;

    // Jika tab penitipan dipilih, muat ulang data penitipan
    if (index == 2) {
      // Dapatkan instance PenitipanBantuanController dan panggil onTabReactivated
      try {
        final penitipanController = Get.find<PenitipanBantuanController>();
        penitipanController.onTabReactivated();
        print('Memanggil onTabReactivated pada PenitipanBantuanController');
      } catch (e) {
        print('Error saat memanggil onTabReactivated: $e');
        // Fallback ke metode lama jika controller tidak ditemukan
        loadPenitipanData();
      }
    } else if (index == 3) {
      // Jika tab pengaduan dipilih, muat ulang data pengaduan
      loadPengaduanData();
    } else if (index == 4) {
      // Jika tab stok bantuan dipilih, muat ulang data stok bantuan
      try {
        final stokBantuanController = Get.find<StokBantuanController>();
        stokBantuanController.onTabReactivated();
        print('Memanggil onTabReactivated pada StokBantuanController');
      } catch (e) {
        print('Error saat memanggil onTabReactivated: $e');
      }
    }
  }

  // Metode untuk logout
  Future<void> logout() async {
    await _authController.logout();
  }

  // Metode untuk debugging struktur data jadwal
  void debugJadwalData(Map<String, dynamic> jadwal) {
    print('DEBUG CONTROLLER: ===== DEBUGGING JADWAL DATA =====');
    print('DEBUG CONTROLLER: Keys dalam jadwal: ${jadwal.keys.join(', ')}');

    // Periksa ID
    final id = jadwal['id'];
    print('DEBUG CONTROLLER: ID jadwal: $id (${id.runtimeType})');

    // Periksa data lain yang penting
    print('DEBUG CONTROLLER: Nama: ${jadwal['nama']}');
    print('DEBUG CONTROLLER: Status: ${jadwal['status']}');
    print('DEBUG CONTROLLER: Jumlah penerima: ${jadwal['jumlah_penerima']}');

    // Periksa apakah ada data yang null
    jadwal.forEach((key, value) {
      if (value == null) {
        print('DEBUG CONTROLLER: Field "$key" bernilai null');
      }
    });

    print('DEBUG CONTROLLER: ===== END DEBUGGING JADWAL DATA =====');
  }

  // Metode untuk mendapatkan daftar penerima penyaluran
  Future<List<Map<String, dynamic>>?> getPenerimaPenyaluran(
      String penyaluranId) async {
    print(
        'DEBUG CONTROLLER: Mengambil data penerima untuk penyaluran ID: $penyaluranId');
    // Gunakan data dummy sementara
    final dummyData = _createDummyPenerimaPenyaluran();
    print(
        'DEBUG CONTROLLER: Mengembalikan ${dummyData.length} data dummy penerima');
    return dummyData;
  }

  // Metode untuk memfilter data penerima berdasarkan status dan pencarian
  List<Map<String, dynamic>> get filteredPenerimaPenyaluran {
    if (penerimaPenyaluran.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> filtered =
        List<Map<String, dynamic>>.from(penerimaPenyaluran);

    // Filter berdasarkan status
    if (filterStatus.value != 'SEMUA') {
      filtered = filtered.where((penerima) {
        return penerima['status_penerimaan'] == filterStatus.value;
      }).toList();
    }

    // Filter berdasarkan pencarian
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((penerima) {
        final warga = penerima['warga'] as Map<String, dynamic>?;
        if (warga == null) return false;

        final nama = (warga['nama_lengkap'] ?? '').toString().toLowerCase();
        final nik = (warga['nik'] ?? '').toString().toLowerCase();
        final alamat = (warga['alamat'] ?? '').toString().toLowerCase();

        return nama.contains(query) ||
            nik.contains(query) ||
            alamat.contains(query);
      }).toList();
    }

    return filtered;
  }
}
