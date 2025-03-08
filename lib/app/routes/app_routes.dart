part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const COMPLETE_PROFILE = _Paths.COMPLETE_PROFILE;
  static const WARGA_DASHBOARD = _Paths.WARGA_DASHBOARD;
  static const PETUGAS_VERIFIKASI_DASHBOARD =
      _Paths.PETUGAS_VERIFIKASI_DASHBOARD;
  static const PETUGAS_DESA_DASHBOARD = _Paths.PETUGAS_DESA_DASHBOARD;
  static const DONATUR_DASHBOARD = _Paths.DONATUR_DASHBOARD;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const COMPLETE_PROFILE = '/complete-profile';
  static const WARGA_DASHBOARD = '/warga-dashboard';
  static const PETUGAS_VERIFIKASI_DASHBOARD = '/petugas-verifikasi-dashboard';
  static const PETUGAS_DESA_DASHBOARD = '/petugas-desa-dashboard';
  static const DONATUR_DASHBOARD = '/donatur-dashboard';
}
