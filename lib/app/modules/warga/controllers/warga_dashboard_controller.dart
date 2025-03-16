import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/pengajuan_kelayakan_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';

class WargaDashboardController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

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
      // TODO: Implementasi fetch data dari API
      // Contoh data dummy untuk pengembangan UI
      await Future.delayed(const Duration(seconds: 1));

      // Dummy data penerima penyaluran
      penerimaPenyaluran.value = [
        PenerimaPenyaluranModel(
          id: '1',
          statusPenerimaan: 'DITERIMA',
          tanggalPenerimaan: DateTime.now().subtract(const Duration(days: 5)),
          jumlahBantuan: 50000,
          keterangan: 'Bantuan Tunai',
        ),
        PenerimaPenyaluranModel(
          id: '2',
          statusPenerimaan: 'DITERIMA',
          tanggalPenerimaan: DateTime.now().subtract(const Duration(days: 15)),
          jumlahBantuan: 100000,
          keterangan: 'Bantuan Sembako',
        ),
      ];

      totalPenyaluranDiterima.value = penerimaPenyaluran.length;

      // Dummy data pengajuan kelayakan
      pengajuanKelayakan.value = [
        PengajuanKelayakanBantuanModel(
          id: '1',
          status: StatusKelayakan.MENUNGGU,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        PengajuanKelayakanBantuanModel(
          id: '2',
          status: StatusKelayakan.TERVERIFIKASI,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        PengajuanKelayakanBantuanModel(
          id: '3',
          status: StatusKelayakan.DITOLAK,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          alasanVerifikasi: 'Dokumen tidak lengkap',
        ),
      ];

      totalPengajuanMenunggu.value = pengajuanKelayakan
          .where((p) => p.status == StatusKelayakan.MENUNGGU)
          .length;
      totalPengajuanTerverifikasi.value = pengajuanKelayakan
          .where((p) => p.status == StatusKelayakan.TERVERIFIKASI)
          .length;
      totalPengajuanDitolak.value = pengajuanKelayakan
          .where((p) => p.status == StatusKelayakan.DITOLAK)
          .length;

      // Dummy data pengaduan
      pengaduan.value = [
        PengaduanModel(
          id: '1',
          judul: 'Bantuan tidak sesuai',
          status: 'PROSES',
          tanggalPengaduan: DateTime.now().subtract(const Duration(days: 3)),
        ),
        PengaduanModel(
          id: '2',
          judul: 'Keterlambatan penyaluran',
          status: 'SELESAI',
          tanggalPengaduan: DateTime.now().subtract(const Duration(days: 25)),
        ),
      ];

      totalPengaduan.value = pengaduan.length;
      totalPengaduanProses.value =
          pengaduan.where((p) => p.status == 'PROSES').length;
      totalPengaduanSelesai.value =
          pengaduan.where((p) => p.status == 'SELESAI').length;

      // Dummy data notifikasi
      jumlahNotifikasiBelumDibaca.value = 3;
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading.value = false;
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
