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
}
