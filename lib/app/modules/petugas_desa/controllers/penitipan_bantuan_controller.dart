import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
import 'package:penyaluran_app/app/data/models/stok_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/counter_service.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class PenitipanBantuanController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;
  final ImagePicker _imagePicker = ImagePicker();
  late final CounterService _counterService;

  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  // Path untuk bukti serah terima
  final Rx<String?> fotoBuktiSerahTerimaPath = Rx<String?>(null);

  // Path untuk foto bantuan
  final RxList<String> fotoBantuanPaths = <String>[].obs;

  // Untuk pencarian donatur
  final RxList<DonaturModel> hasilPencarianDonatur = <DonaturModel>[].obs;
  final RxBool isSearchingDonatur = false.obs;
  final TextEditingController donaturSearchController = TextEditingController();

  // Indeks kategori yang dipilih untuk filter
  final RxInt selectedCategoryIndex = 0.obs;

  // Data untuk penitipan
  final RxList<PenitipanBantuanModel> daftarPenitipan =
      <PenitipanBantuanModel>[].obs;

  // Data untuk kategori bantuan
  final RxMap<String, StokBantuanModel> stokBantuanMap =
      <String, StokBantuanModel>{}.obs;

  // Cache untuk donatur
  final RxMap<String, DonaturModel> donaturCache = <String, DonaturModel>{}.obs;

  // Cache untuk petugas desa
  final RxMap<String, Map<String, dynamic>> petugasDesaCache =
      <String, Map<String, dynamic>>{}.obs;

  // Controller untuk pencarian
  final TextEditingController searchController = TextEditingController();

  // Tambahkan properti untuk waktu terakhir update
  final Rx<DateTime> lastUpdateTime = DateTime.now().obs;

  BaseUserModel? get user => _authController.baseUser;

  // Getter untuk counter dari CounterService
  RxInt get jumlahMenunggu => _counterService.jumlahMenunggu;
  RxInt get jumlahTerverifikasi => _counterService.jumlahTerverifikasi;
  RxInt get jumlahDitolak => _counterService.jumlahDitolak;

  @override
  void onInit() {
    super.onInit();

    // Inisialisasi CounterService jika belum ada
    if (!Get.isRegistered<CounterService>()) {
      Get.put(CounterService(), permanent: true);
    }
    _counterService = Get.find<CounterService>();

    loadPenitipanData();
    loadKategoriBantuanData();

    // Hapus delay dan muat data petugas desa langsung
    loadAllPetugasDesaData();

    // Listener untuk pencarian donatur
    donaturSearchController.addListener(() {
      if (donaturSearchController.text.length >= 3) {
        searchDonatur(donaturSearchController.text);
      } else {
        hasilPencarianDonatur.clear();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Pastikan counter diperbarui saat tab diakses kembali
    updateCounters();
  }

  @override
  void onClose() {
    searchController.dispose();
    donaturSearchController.dispose();
    super.onClose();
  }

  // Metode untuk memperbarui data saat tab diakses kembali
  void onTabReactivated() {
    print('Penitipan tab reactivated - refreshing data');
    // Selalu muat ulang data dari server saat tab diaktifkan kembali
    refreshData();
  }

  Future<void> loadPenitipanData() async {
    isLoading.value = true;
    try {
      final penitipanData = await _supabaseService.getPenitipanBantuan();
      if (penitipanData != null) {
        daftarPenitipan.value = penitipanData
            .map((data) => PenitipanBantuanModel.fromJson(data))
            .toList();

        // Hitung jumlah berdasarkan status
        updateCounters();

        // Muat informasi petugas desa untuk item yang terverifikasi
        print(
            'Memuat informasi petugas desa untuk ${daftarPenitipan.length} penitipan');

        List<Future> petugasLoaders = [];

        for (var item in daftarPenitipan) {
          if (item.status == 'TERVERIFIKASI' && item.petugasDesaId != null) {
            print(
                'Memuat informasi petugas desa untuk penitipan ID: ${item.id}, petugasDesaId: ${item.petugasDesaId}');
            petugasLoaders.add(getPetugasDesaInfo(item.petugasDesaId));
          }
        }

        // Tunggu semua data petugas desa selesai dimuat
        await Future.wait(petugasLoaders);

        // Debug: print semua data petugas desa yang sudah dimuat
        print('Data petugas desa yang sudah dimuat:');
        petugasDesaCache.forEach((key, value) {
          print('ID: $key, Nama: ${value['nama_lengkap']}');
        });

        // Update waktu terakhir refresh
        lastUpdateTime.value = DateTime.now();
      }
    } catch (e) {
      print('Error loading penitipan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStokBantuanData() async {
    try {
      print('Loading stok bantuan data...');
      final stokBantuanData = await _supabaseService.getStokBantuan();
      if (stokBantuanData != null) {
        print(
            'Received ${stokBantuanData.length} stok bantuan items from service');
        stokBantuanMap.clear(); // Clear existing data

        for (var data in stokBantuanData) {
          final stokBantuan = StokBantuanModel.fromJson(data);
          if (stokBantuan.id != null) {
            stokBantuanMap[stokBantuan.id!] = stokBantuan;
            print(
                'Added stok bantuan: ID=${stokBantuan.id}, Nama=${stokBantuan.nama}, Satuan=${stokBantuan.satuan}');
          } else {
            print('Skipped stok bantuan with null ID: $data');
          }
        }
        print('Loaded ${stokBantuanMap.length} stok bantuan items');
      } else {
        print('No stok bantuan data received from service');
      }
    } catch (e) {
      print('Error loading stok bantuan data: $e');
    }
  }

  Future<void> loadKategoriBantuanData() async {
    try {
      await loadStokBantuanData();
      print(
          'Loaded kategori bantuan data. stokBantuanMap size: ${stokBantuanMap.length}');

      // Debug: print all stok bantuan items
      stokBantuanMap.forEach((key, value) {
        print(
            'Stok Bantuan - ID: $key, Nama: ${value.nama}, Satuan: ${value.satuan}');
      });
    } catch (e) {
      print('Error loading kategori bantuan data: $e');
    }
  }

  Future<void> pickfotoBuktiSerahTerima() async {
    try {
      // Tampilkan bottom sheet untuk memilih sumber foto
      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Get.back();
                  _pickfotoBuktiSerahTerimaFrom(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Get.back();
                  _pickfotoBuktiSerahTerimaFrom(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error showing bottom sheet: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fungsi helper untuk mengambil foto dari sumber yang dipilih
  Future<void> _pickfotoBuktiSerahTerimaFrom(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedFile != null) {
        fotoBuktiSerahTerimaPath.value = pickedFile.path;
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil gambar: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickFotoBantuan({bool fromCamera = true}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedFile != null) {
        fotoBantuanPaths.add(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil gambar: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeFotoBantuan(int index) {
    if (index >= 0 && index < fotoBantuanPaths.length) {
      fotoBantuanPaths.removeAt(index);
    }
  }

  Future<void> tambahPenitipanBantuan({
    required String stokBantuanId,
    required double jumlah,
    required String deskripsi,
    String? donaturId,
    bool isUang = false,
  }) async {
    if (fotoBantuanPaths.isEmpty) {
      Get.snackbar(
        'Error',
        'Foto bantuan harus diupload',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    isUploading.value = true;
    try {
      await _supabaseService.tambahPenitipanBantuan(
        stokBantuanId: stokBantuanId,
        jumlah: jumlah,
        deskripsi: deskripsi,
        fotoBantuanPaths: fotoBantuanPaths,
        donaturId: donaturId,
        isUang: isUang,
      );

      // Reset paths setelah berhasil
      fotoBantuanPaths.clear();

      await loadPenitipanData();
      // Pastikan counter diperbarui setelah penambahan
      updateCounters();

      Get.back(); // Tutup dialog
      Get.snackbar(
        'Sukses',
        'Penitipan bantuan berhasil ditambahkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error adding penitipan: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan penitipan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isUploading.value = false;
    }
  }

  Future<void> verifikasiPenitipan(String penitipanId) async {
    if (fotoBuktiSerahTerimaPath.value == null) {
      Get.snackbar(
        'Error',
        'Bukti serah terima harus diupload',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    isUploading.value = true;
    try {
      await _supabaseService.verifikasiPenitipan(
          penitipanId, fotoBuktiSerahTerimaPath.value!);

      // Reset path setelah berhasil
      fotoBuktiSerahTerimaPath.value = null;

      await loadPenitipanData();
      // Pastikan counter diperbarui setelah verifikasi
      updateCounters();

      Get.back(); // Tutup dialog
      Get.snackbar(
        'Sukses',
        'Penitipan berhasil diverifikasi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error verifying penitipan: $e');
      Get.snackbar(
        'Error',
        'Gagal memverifikasi penitipan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isUploading.value = false;
    }
  }

  Future<void> tolakPenitipan(String penitipanId, String alasan) async {
    isLoading.value = true;
    try {
      await _supabaseService.tolakPenitipan(penitipanId, alasan);
      await loadPenitipanData();
      // Pastikan counter diperbarui setelah penolakan
      updateCounters();

      Get.snackbar(
        'Sukses',
        'Penitipan berhasil ditolak',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error rejecting penitipan: $e');
      Get.snackbar(
        'Error',
        'Gagal menolak penitipan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<DonaturModel?> getDonaturInfo(String donaturId) async {
    try {
      // Cek cache terlebih dahulu
      if (donaturCache.containsKey(donaturId)) {
        return donaturCache[donaturId];
      }

      final donaturData = await _supabaseService.getDonaturById(donaturId);
      if (donaturData != null) {
        final donatur = DonaturModel.fromJson(donaturData);
        // Simpan ke cache
        donaturCache[donaturId] = donatur;
        return donatur;
      }
      return null;
    } catch (e) {
      print('Error getting donatur info: $e');
      return null;
    }
  }

  String getKategoriNama(String? stokBantuanId) {
    if (stokBantuanId == null) {
      print('Stok bantuan ID is null');
      return 'Tidak ada kategori';
    }

    if (!stokBantuanMap.containsKey(stokBantuanId)) {
      print('Stok bantuan not found for ID: $stokBantuanId');
      print('Available keys: ${stokBantuanMap.keys.join(', ')}');
      return 'Tidak ada kategori';
    }

    final nama = stokBantuanMap[stokBantuanId]?.nama ?? 'Tidak ada nama';
    print('Found stok bantuan name: $nama for ID: $stokBantuanId');
    return nama;
  }

  String getKategoriSatuan(String? stokBantuanId) {
    if (stokBantuanId == null) {
      return '';
    }

    if (!stokBantuanMap.containsKey(stokBantuanId)) {
      return '';
    }

    return stokBantuanMap[stokBantuanId]?.satuan ?? '';
  }

  Future<void> refreshData() async {
    await loadPenitipanData();
    await loadStokBantuanData();

    // Update waktu terakhir refresh
    lastUpdateTime.value = DateTime.now();
  }

  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  List<PenitipanBantuanModel> getFilteredPenitipan() {
    final searchText = searchController.text.toLowerCase();
    var filteredList = <PenitipanBantuanModel>[];

    // Filter berdasarkan status
    switch (selectedCategoryIndex.value) {
      case 0:
        filteredList = daftarPenitipan.toList();
        break;
      case 1:
        filteredList =
            daftarPenitipan.where((item) => item.status == 'MENUNGGU').toList();
        break;
      case 2:
        filteredList = daftarPenitipan
            .where((item) => item.status == 'TERVERIFIKASI')
            .toList();
        break;
      case 3:
        filteredList =
            daftarPenitipan.where((item) => item.status == 'DITOLAK').toList();
        break;
      default:
        filteredList = daftarPenitipan.toList();
    }

    // Filter berdasarkan pencarian jika ada teks pencarian
    if (searchText.isNotEmpty) {
      filteredList = filteredList.where((item) {
        // Cari berdasarkan deskripsi
        final deskripsiMatch =
            item.deskripsi?.toLowerCase().contains(searchText) ?? false;

        // Cari berdasarkan kategori
        final stokBantuan = getKategoriNama(item.stokBantuanId).toLowerCase();
        final stokBantuanMatch = stokBantuan.contains(searchText);

        // Cari berdasarkan nama donatur
        final donaturId = item.donaturId;
        String donaturNama = '';
        if (donaturId != null && donaturCache.containsKey(donaturId)) {
          donaturNama =
              donaturCache[donaturId]?.namaLengkap?.toLowerCase() ?? '';
        }
        final donaturMatch = donaturNama.contains(searchText);

        // Cari berdasarkan tanggal penitipan
        final tanggalMatch = item.tanggalPenitipan != null &&
            item.tanggalPenitipan.toString().toLowerCase().contains(searchText);

        return deskripsiMatch ||
            stokBantuanMatch ||
            donaturMatch ||
            tanggalMatch;
      }).toList();
    }

    // Urutkan berdasarkan tanggal terbaru
    filteredList.sort((a, b) {
      if (a.tanggalPenitipan == null) return 1;
      if (b.tanggalPenitipan == null) return -1;
      return b.tanggalPenitipan!.compareTo(a.tanggalPenitipan!);
    });

    return filteredList;
  }

  Future<Map<String, dynamic>?> getPetugasDesaInfo(
      String? petugasDesaId) async {
    try {
      if (petugasDesaId == null) {
        return null;
      }

      // Cek cache terlebih dahulu
      if (petugasDesaCache.containsKey(petugasDesaId)) {
        return petugasDesaCache[petugasDesaId];
      }

      final petugasDesaData =
          await _supabaseService.getPetugasDesaById(petugasDesaId);
      if (petugasDesaData != null) {
        // Simpan ke cache
        petugasDesaCache[petugasDesaId] = petugasDesaData;
        return petugasDesaData;
      }
      return null;
    } catch (e) {
      print('Error getting petugas desa info: $e');
      return null;
    }
  }

  String getPetugasDesaNama(String? petugasDesaId) {
    print('Petugas Desa ID: $petugasDesaId');
    if (petugasDesaId == null) {
      return 'Tidak diketahui';
    }

    // Cek apakah data ada di cache
    if (!petugasDesaCache.containsKey(petugasDesaId)) {
      print(
          'Data petugas desa tidak ditemukan di cache untuk ID: $petugasDesaId');
      // Muat data petugas dan perbarui UI
      loadPetugasDesaData(petugasDesaId);

      // Coba cek lagi setelah pemuatan
      if (petugasDesaCache.containsKey(petugasDesaId)) {
        // Akses nama dari struktur data petugas_desa
        final nama = petugasDesaCache[petugasDesaId]?['nama_lengkap'];
        return nama ?? 'Tidak diketahui';
      }

      return 'Memuat data...';
    }

    // Sekarang data seharusnya ada di cache
    // Akses nama dari struktur data petugas_desa
    final nama = petugasDesaCache[petugasDesaId]?['nama_lengkap'];
    print('Nama petugas desa: $nama untuk ID: $petugasDesaId');
    return nama ?? 'Tidak diketahui';
  }

  // Fungsi untuk memuat data petugas desa dan memperbarui UI
  Future<void> loadPetugasDesaData(String petugasDesaId) async {
    try {
      print('Memuat data petugas desa untuk ID: $petugasDesaId');
      final petugasData = await getPetugasDesaInfo(petugasDesaId);
      if (petugasData != null) {
        // Data sudah dimasukkan ke cache oleh getPetugasDesaInfo
        print('Berhasil memuat data petugas: ${petugasData['nama_lengkap']}');

        // Refresh UI segera
        update(['petugas_data']);
      } else {
        print(
            'Gagal mengambil data petugas desa dari server untuk ID: $petugasDesaId');
      }
    } catch (e) {
      print('Error saat memuat data petugas desa: $e');
    }
  }

  // Fungsi untuk memuat semua data petugas desa yang terkait dengan penitipan
  void loadAllPetugasDesaData() async {
    try {
      print('Memuat ulang semua data petugas desa...');
      for (var item in daftarPenitipan) {
        if (item.status == 'TERVERIFIKASI' && item.petugasDesaId != null) {
          if (!petugasDesaCache.containsKey(item.petugasDesaId)) {
            print('Memuat data petugas desa untuk ID: ${item.petugasDesaId}');
            await getPetugasDesaInfo(item.petugasDesaId);
          }
        }
      }
      // Refresh UI
      update();

      // Debug: print semua data petugas desa yang sudah dimuat
      print('Data petugas desa yang sudah dimuat setelah reload:');
      petugasDesaCache.forEach((key, value) {
        print('ID: $key, Nama: ${value['nama_lengkap']}');
      });
    } catch (e) {
      print('Error saat memuat ulang data petugas desa: $e');
    }
  }

  Future<void> searchDonatur(String keyword) async {
    if (keyword.length < 3) {
      hasilPencarianDonatur.clear();
      return;
    }

    isSearchingDonatur.value = true;
    try {
      final result = await _supabaseService.searchDonatur(keyword);
      if (result != null) {
        hasilPencarianDonatur.value =
            result.map((data) => DonaturModel.fromJson(data)).toList();
      } else {
        hasilPencarianDonatur.clear();
      }
    } catch (e) {
      print('Error searching donatur: $e');
      hasilPencarianDonatur.clear();
    } finally {
      isSearchingDonatur.value = false;
    }
  }

  // Metode untuk mendapatkan daftar donatur
  Future<List<DonaturModel>> getDaftarDonatur() async {
    try {
      final result = await _supabaseService.getDaftarDonatur();
      if (result != null) {
        return result.map((data) => DonaturModel.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting daftar donatur: $e');
      return [];
    }
  }

  Future<String?> tambahDonatur({
    required String nama,
    required String noHp,
    String? alamat,
    String? email,
    String? jenis,
  }) async {
    try {
      final donaturData = {
        'nama_lengkap': nama,
        'no_hp': noHp,
        'alamat': alamat,
        'email': email,
        'jenis': jenis,
        'status': 'AKTIF',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      return await _supabaseService.tambahDonatur(donaturData);
    } catch (e) {
      print('Error adding donatur: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan donatur: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Mendapatkan informasi apakah stok bantuan berupa uang
  bool isStokBantuanUang(String stokBantuanId) {
    if (!stokBantuanMap.containsKey(stokBantuanId)) {
      return false;
    }
    return stokBantuanMap[stokBantuanId]?.isUang ?? false;
  }

  // Metode baru untuk memperbarui counter
  void updateCounters() {
    int menunggu =
        daftarPenitipan.where((item) => item.status == 'MENUNGGU').length;
    int terverifikasi =
        daftarPenitipan.where((item) => item.status == 'TERVERIFIKASI').length;
    int ditolak =
        daftarPenitipan.where((item) => item.status == 'DITOLAK').length;

    // Update counter di CounterService
    _counterService.updatePenitipanCounters(
      menunggu: menunggu,
      terverifikasi: terverifikasi,
      ditolak: ditolak,
    );

    // Update counter lokal
    jumlahMenunggu.value = menunggu;
    jumlahTerverifikasi.value = terverifikasi;
    jumlahDitolak.value = ditolak;

    // Debug counter values
    print(
        'Counter updated - Menunggu: $menunggu, Terverifikasi: $terverifikasi, Ditolak: $ditolak');
  }
}
