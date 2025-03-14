part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const login = _Paths.login;
  static const register = _Paths.register;
  static const wargaDashboard = _Paths.wargaDashboard;
  static const petugasVerifikasiDashboard = _Paths.petugasVerifikasiDashboard;
  static const petugasDesaDashboard = _Paths.petugasDesaDashboard;
  static const donaturDashboard = _Paths.donaturDashboard;
  static const splash = _Paths.splash;
  static const permintaanPenjadwalan = _Paths.permintaanPenjadwalan;
  static const daftarPenerima = _Paths.daftarPenerima;
  static const detailPenerima = _Paths.detailPenerima;
  static const konfirmasiPenerima = _Paths.konfirmasiPenerima;
  static const pelaksanaanPenyaluran = _Paths.pelaksanaanPenyaluran;
  static const profile = _Paths.profile;
  static const riwayatPenitipan = _Paths.riwayatPenitipan;
  static const daftarDonatur = _Paths.daftarDonatur;
  static const detailDonatur = _Paths.detailDonatur;
  static const tambahPenyaluran = _Paths.tambahPenyaluran;
  static const daftarPenerimaPenyaluran = _Paths.daftarPenerimaPenyaluran;
  static const detailPenerimaPenyaluran = _Paths.detailPenerimaPenyaluran;
  static const laporanPenyaluran = _Paths.laporanPenyaluran;
  static const detailPenyaluran = _Paths.detailPenyaluran;
}

abstract class _Paths {
  _Paths._();
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const wargaDashboard = '/warga-dashboard';
  static const petugasVerifikasiDashboard = '/petugas-verifikasi-dashboard';
  static const petugasDesaDashboard = '/petugas-desa-dashboard';
  static const donaturDashboard = '/donatur-dashboard';
  static const splash = '/splash';
  static const permintaanPenjadwalan = '/permintaan-penjadwalan';
  static const daftarPenerima = '/daftar-penerima';
  static const detailPenerima = '/daftar-penerima/detail';
  static const konfirmasiPenerima = '/daftar-penerima/konfirmasi';
  static const pelaksanaanPenyaluran = '/pelaksanaan-penyaluran';
  static const profile = '/profile';
  static const riwayatPenitipan = '/petugas-desa/riwayat-penitipan';
  static const daftarDonatur = '/daftar-donatur';
  static const detailDonatur = '/daftar-donatur/detail';
  static const tambahPenyaluran = '/tambah-penyaluran';
  static const daftarPenerimaPenyaluran = '/daftar-penerima-penyaluran';
  static const detailPenerimaPenyaluran = '/detail-penerima-penyaluran';
  static const laporanPenyaluran = '/laporan-penyaluran';
  static const detailPenyaluran = '/detail-penyaluran';
}
