import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/auth/views/forgot_password_view.dart';
import 'package:penyaluran_app/app/modules/auth/views/login_view.dart';
import 'package:penyaluran_app/app/modules/auth/views/register_donatur_view.dart';
import 'package:penyaluran_app/app/modules/auth/bindings/auth_binding.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/petugas_desa_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/bindings/petugas_desa_binding.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/permintaan_penjadwalan_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/daftar_penerima_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/detail_penerima_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/riwayat_penitipan_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/daftar_donatur_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/detail_donatur_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/tambah_penyaluran_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/tambah_lokasi_penyaluran_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/lokasi_penyaluran_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/riwayat_penyaluran_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/detail_penyaluran_page.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/bindings/penyaluran_binding.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/riwayat_pengaduan_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/bindings/riwayat_pengaduan_binding.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/qr_scanner_page.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/konfirmasi_penerima_page.dart';
import 'package:penyaluran_app/app/modules/about/views/about_view.dart';
import 'package:penyaluran_app/app/modules/about/bindings/about_binding.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/bindings/penerima_binding.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/bindings/donatur_binding.dart';
import 'package:penyaluran_app/app/modules/profile/bindings/profile_binding.dart';
import 'package:penyaluran_app/app/modules/profile/views/profile_view.dart';
import 'package:penyaluran_app/app/modules/splash/bindings/splash_binding.dart';
import 'package:penyaluran_app/app/modules/splash/views/splash_view.dart';
import 'package:penyaluran_app/app/modules/warga/bindings/warga_binding.dart';
import 'package:penyaluran_app/app/modules/warga/views/warga_view.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/modules/warga/views/warga_detail_penerimaan_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/detail_pengaduan_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/bindings/pengaduan_binding.dart';
import 'package:penyaluran_app/app/modules/warga/views/detail_pengaduan_view.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/views/laporan_penyaluran_view.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/views/laporan_penyaluran_detail_view.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/views/laporan_penyaluran_create_view.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/views/laporan_penyaluran_edit_view.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/bindings/laporan_penyaluran_binding.dart';
import 'package:penyaluran_app/app/modules/donatur/views/donatur_view.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/modules/donatur/views/donatur_jadwal_detail_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: _Paths.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.registerDonatur,
      page: () => const RegisterDonaturView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.wargaDashboard,
      page: () => WargaView(),
      binding: WargaBinding(),
    ),
    GetPage(
      name: Routes.wargaPenerimaan,
      page: () {
        final controller = Get.find<WargaDashboardController>();
        controller.activeTabIndex.value = 1;
        return WargaView();
      },
      binding: WargaBinding(),
    ),
    GetPage(
      name: Routes.wargaPengaduan,
      page: () {
        final controller = Get.find<WargaDashboardController>();
        controller.activeTabIndex.value = 2;
        return WargaView();
      },
      binding: WargaBinding(),
    ),
    GetPage(
      name: _Paths.petugasDesaDashboard,
      page: () => const PetugasDesaView(),
      binding: PetugasDesaBinding(),
    ),
    GetPage(
      name: _Paths.about,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: _Paths.permintaanPenjadwalan,
      page: () => const PermintaanPenjadwalanView(),
      binding: PetugasDesaBinding(),
    ),
    GetPage(
      name: _Paths.daftarPenerima,
      page: () => const DaftarPenerimaView(),
      binding: PenerimaBinding(),
    ),
    GetPage(
      name: _Paths.detailPenerima,
      page: () => const DetailPenerimaView(),
      binding: PenerimaBinding(),
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.riwayatPenitipan,
      page: () => const RiwayatPenitipanView(),
      binding: PetugasDesaBinding(),
    ),
    GetPage(
      name: _Paths.riwayatPenyaluran,
      page: () => const RiwayatPenyaluranView(),
      binding: PetugasDesaBinding(),
    ),
    GetPage(
      name: _Paths.daftarDonatur,
      page: () => const DaftarDonaturView(),
      binding: DonaturBinding(),
    ),
    GetPage(
      name: _Paths.detailDonatur,
      page: () => const DetailDonaturView(),
      binding: DonaturBinding(),
    ),
    GetPage(
      name: _Paths.tambahPenyaluran,
      page: () => const TambahPenyaluranView(),
      binding: PetugasDesaBinding(),
    ),
    GetPage(
      name: _Paths.tambahLokasiPenyaluran,
      page: () => const TambahLokasiPenyaluranView(),
      binding: PetugasDesaBinding(),
    ),
    GetPage(
      name: _Paths.lokasiPenyaluran,
      page: () => const LokasiPenyaluranView(),
      binding: PetugasDesaBinding(),
    ),
    GetPage(
      name: _Paths.detailPenyaluran,
      page: () => DetailPenyaluranPage(),
      binding: PenyaluranBinding(),
    ),
    GetPage(
      name: _Paths.detailPengaduan,
      page: () => const DetailPengaduanView(),
      binding: PengaduanBinding(),
    ),
    GetPage(
      name: Routes.wargaDetailPenerimaan,
      page: () => const WargaDetailPenerimaanView(),
      binding: WargaBinding(),
    ),
    GetPage(
      name: Routes.wargaDetailPengaduan,
      page: () => const WargaDetailPengaduanView(),
      binding: WargaBinding(),
    ),
    GetPage(
      name: _Paths.riwayatPengaduan,
      page: () => const RiwayatPengaduanView(),
      binding: RiwayatPengaduanBinding(),
    ),
    GetPage(
      name: _Paths.laporanPenyaluran,
      page: () => const LaporanPenyaluranView(),
      binding: LaporanPenyaluranBinding(),
    ),
    GetPage(
      name: '${_Paths.laporanPenyaluran}/detail',
      page: () => const LaporanPenyaluranDetailView(),
      binding: LaporanPenyaluranBinding(),
    ),
    GetPage(
      name: '${_Paths.laporanPenyaluran}/create',
      page: () => const LaporanPenyaluranCreateView(),
      binding: LaporanPenyaluranBinding(),
    ),
    GetPage(
      name: '${_Paths.laporanPenyaluran}/edit',
      page: () => const LaporanPenyaluranEditView(),
      binding: LaporanPenyaluranBinding(),
    ),
    GetPage(
      name: _Paths.qrScanner,
      page: () => QrScannerPage(penyaluranId: Get.parameters['id'] ?? ''),
      binding: PenyaluranBinding(),
    ),
    GetPage(
      name: _Paths.konfirmasiPenerimaQr,
      page: () {
        final penerima = Get.arguments['penerima'];
        final String penerimaPenyaluranId = penerima?.id ?? '';

        return KonfirmasiPenerimaPage(
          penerimaPenyaluranId: penerimaPenyaluranId,
          tanggalPenyaluran: Get.arguments['tanggal_penyaluran'],
        );
      },
      binding: PenyaluranBinding(),
    ),
    GetPage(
      name: Routes.donaturDashboard,
      page: () => DonaturView(),
      binding: DonaturBinding(),
    ),
    GetPage(
      name: _Paths.donaturSkema,
      page: () {
        final controller =
            Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
        controller.activeTabIndex.value = 1;
        return DonaturView();
      },
      binding: DonaturBinding(),
    ),
    GetPage(
      name: _Paths.donaturJadwal,
      page: () {
        final controller =
            Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
        controller.activeTabIndex.value = 2;
        return DonaturView();
      },
      binding: DonaturBinding(),
    ),
    GetPage(
      name: _Paths.donaturPenitipan,
      page: () {
        final controller =
            Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
        controller.activeTabIndex.value = 3;
        return DonaturView();
      },
      binding: DonaturBinding(),
    ),
    GetPage(
      name: _Paths.donaturLaporan,
      page: () {
        final controller =
            Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
        controller.activeTabIndex.value = 4;
        return DonaturView();
      },
      binding: DonaturBinding(),
    ),
    GetPage(
      name: '/donatur/jadwal/:id',
      page: () => const DonaturJadwalDetailView(),
      binding: DonaturBinding(),
    ),
  ];
}
