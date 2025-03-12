import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/desa_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/counter_service.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class PetugasDesaController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;
  late final CounterService _counterService;

  // Indeks tab yang aktif di bottom navigation bar
  final RxInt activeTabIndex = 0.obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();

  // Data profil pengguna dari cache
  final RxMap<String, dynamic> userProfile = RxMap<String, dynamic>({});

  // Model desa dari cache
  final Rx<DesaModel?> desaModel = Rx<DesaModel?>(null);

  // Data jadwal hari ini
  final RxList<dynamic> jadwalHariIni = <dynamic>[].obs;

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

        print('Jumlah pengaduan diproses: $diproses');
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

  // Metode untuk mengubah tab aktif
  void changeTab(int index) {
    activeTabIndex.value = index;

    // Jika tab penitipan dipilih, muat ulang data penitipan
    if (index == 2) {
      loadPenitipanData();
    } else if (index == 3) {
      // Jika tab pengaduan dipilih, muat ulang data pengaduan
      loadPengaduanData();
    }
  }

  // Metode untuk logout
  Future<void> logout() async {
    await _authController.logout();
  }
}
