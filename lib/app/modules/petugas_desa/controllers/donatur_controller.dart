import 'package:get/get.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';

class DonaturController extends GetxController {
  final RxList<DonaturModel> daftarDonatur = <DonaturModel>[].obs;
  final RxMap<String, List<PenitipanBantuanModel>> penitipanPerDonatur =
      <String, List<PenitipanBantuanModel>>{}.obs;
  final RxBool isLoading = false.obs;
  final SupabaseService _supabaseService = SupabaseService.to;

  @override
  void onInit() {
    super.onInit();
    fetchDaftarDonatur();
  }

  @override
  void onReady() {
    super.onReady();
    // Pastikan data dimuat saat controller siap
    if (daftarDonatur.isEmpty) {
      fetchDaftarDonatur();
    }
  }

  Future<void> fetchDaftarDonatur() async {
    isLoading.value = true;

    try {
      final result = await _supabaseService.getDaftarDonatur();

      if (result != null) {
        // Konversi data ke model Donatur
        daftarDonatur.value =
            result.map((data) => DonaturModel.fromJson(data)).toList();

        // Ambil data penitipan bantuan
        await fetchPenitipanBantuan();
      } else {
        // Jika result null, tampilkan daftar kosong
        daftarDonatur.value = [];
      }
    } catch (e) {
      print('Error saat mengambil data donatur: $e');
      // Tampilkan pesan error jika diperlukan
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPenitipanBantuan() async {
    try {
      final result = await _supabaseService.getPenitipanBantuan();

      if (result != null) {
        // Reset map penitipan per donatur
        penitipanPerDonatur.clear();

        // Konversi data ke model PenitipanBantuan dan kelompokkan berdasarkan donatur_id
        for (var data in result) {
          final penitipan = PenitipanBantuanModel.fromJson(data);
          if (penitipan.donaturId != null) {
            if (!penitipanPerDonatur.containsKey(penitipan.donaturId)) {
              penitipanPerDonatur[penitipan.donaturId!] = [];
            }
            penitipanPerDonatur[penitipan.donaturId]!.add(penitipan);
          }
        }
      }
    } catch (e) {
      print('Error saat mengambil data penitipan bantuan: $e');
    }
  }

  // Mendapatkan jumlah donasi untuk donatur tertentu
  int getJumlahDonasi(String? donaturId) {
    if (donaturId == null || !penitipanPerDonatur.containsKey(donaturId)) {
      return 0;
    }
    return penitipanPerDonatur[donaturId]!.length;
  }

  // Mendapatkan total nilai donasi untuk donatur tertentu
  double getTotalNilaiDonasi(String? donaturId) {
    if (donaturId == null || !penitipanPerDonatur.containsKey(donaturId)) {
      return 0;
    }

    double total = 0;
    for (var penitipan in penitipanPerDonatur[donaturId]!) {
      if (penitipan.jumlah != null) {
        // Untuk donasi uang, kita gunakan nilai jumlah langsung
        // Untuk donasi barang, kita perlu implementasi lain jika ada nilai barang
        if (penitipan.isUang == true) {
          total += penitipan.jumlah!;
        }
        // Jika ingin menambahkan nilai barang, tambahkan logika di sini
      }
    }
    return total;
  }

  // Mendapatkan total nilai donasi uang untuk donatur tertentu
  double getTotalNilaiDonasiUang(String? donaturId) {
    if (donaturId == null || !penitipanPerDonatur.containsKey(donaturId)) {
      return 0;
    }

    double total = 0;
    for (var penitipan in penitipanPerDonatur[donaturId]!) {
      if (penitipan.jumlah != null && penitipan.isUang == true) {
        total += penitipan.jumlah!;
      }
    }
    return total;
  }

  // Mendapatkan jumlah donasi uang untuk donatur tertentu
  int getJumlahDonasiUang(String? donaturId) {
    if (donaturId == null || !penitipanPerDonatur.containsKey(donaturId)) {
      return 0;
    }

    return penitipanPerDonatur[donaturId]!
        .where((penitipan) => penitipan.isUang == true)
        .length;
  }

  // Mendapatkan jumlah donasi barang untuk donatur tertentu
  int getJumlahDonasiBarang(String? donaturId) {
    if (donaturId == null || !penitipanPerDonatur.containsKey(donaturId)) {
      return 0;
    }

    return penitipanPerDonatur[donaturId]!
        .where((penitipan) => penitipan.isUang != true)
        .length;
  }

  // Format nilai donasi ke format Rupiah
  String formatRupiah(double nominal) {
    return 'Rp ${nominal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  DonaturModel? getDonaturById(String id) {
    try {
      if (daftarDonatur.isEmpty) {
        // Jika data belum dimuat, muat data terlebih dahulu
        fetchDaftarDonatur();
        return null;
      }
      return daftarDonatur.firstWhere((donatur) => donatur.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fungsi untuk mengambil data donatur langsung dari database
  Future<DonaturModel?> fetchDonaturById(String id) async {
    try {
      final data = await _supabaseService.getDonaturById(id);
      if (data != null) {
        return DonaturModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error saat mengambil data donatur by ID: $e');
      return null;
    }
  }

  // Mendapatkan daftar penitipan bantuan untuk donatur tertentu
  List<PenitipanBantuanModel> getPenitipanBantuanByDonaturId(
      String? donaturId) {
    if (donaturId == null || !penitipanPerDonatur.containsKey(donaturId)) {
      return [];
    }

    // Urutkan berdasarkan tanggal penitipan terbaru
    final penitipanList =
        List<PenitipanBantuanModel>.from(penitipanPerDonatur[donaturId]!);
    penitipanList.sort((a, b) {
      if (a.tanggalPenitipan == null) return 1;
      if (b.tanggalPenitipan == null) return -1;
      return b.tanggalPenitipan!.compareTo(a.tanggalPenitipan!);
    });

    return penitipanList;
  }

  // Mendapatkan daftar penitipan bantuan uang untuk donatur tertentu
  List<PenitipanBantuanModel> getPenitipanBantuanUangByDonaturId(
      String? donaturId) {
    if (donaturId == null || !penitipanPerDonatur.containsKey(donaturId)) {
      return [];
    }

    // Filter penitipan uang dan urutkan berdasarkan tanggal penitipan terbaru
    final penitipanList = penitipanPerDonatur[donaturId]!
        .where((penitipan) => penitipan.isUang == true)
        .toList();

    penitipanList.sort((a, b) {
      if (a.tanggalPenitipan == null) return 1;
      if (b.tanggalPenitipan == null) return -1;
      return b.tanggalPenitipan!.compareTo(a.tanggalPenitipan!);
    });

    return penitipanList;
  }

  // Mendapatkan daftar penitipan bantuan barang untuk donatur tertentu
  List<PenitipanBantuanModel> getPenitipanBantuanBarangByDonaturId(
      String? donaturId) {
    if (donaturId == null || !penitipanPerDonatur.containsKey(donaturId)) {
      return [];
    }

    // Filter penitipan barang dan urutkan berdasarkan tanggal penitipan terbaru
    final penitipanList = penitipanPerDonatur[donaturId]!
        .where((penitipan) => penitipan.isUang != true)
        .toList();

    penitipanList.sort((a, b) {
      if (a.tanggalPenitipan == null) return 1;
      if (b.tanggalPenitipan == null) return -1;
      return b.tanggalPenitipan!.compareTo(a.tanggalPenitipan!);
    });

    return penitipanList;
  }
}
