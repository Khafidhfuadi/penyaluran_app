import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Service untuk berbagi data counter antar controller
class CounterService extends GetxService {
  static CounterService get to => Get.find<CounterService>();

  // Penyimpanan lokal
  final GetStorage _storage = GetStorage();

  // Keys untuk penyimpanan
  static const String _keyMenunggu = 'counter_menunggu';
  static const String _keyTerverifikasi = 'counter_terverifikasi';
  static const String _keyDitolak = 'counter_ditolak';
  static const String _keyDiproses = 'counter_diproses';
  static const String _keyNotifikasi = 'counter_notifikasi';
  static const String _keyJadwal = 'counter_jadwal';

  // Counter untuk penitipan
  final RxInt jumlahMenunggu = 0.obs;
  final RxInt jumlahTerverifikasi = 0.obs;
  final RxInt jumlahDitolak = 0.obs;

  // Counter untuk pengaduan
  final RxInt jumlahDiproses = 0.obs;

  // Counter untuk notifikasi
  final RxInt jumlahNotifikasiBelumDibaca = 0.obs;

  // Counter untuk jadwal
  final RxInt jumlahJadwalHariIni = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Muat nilai counter dari penyimpanan lokal
    loadCountersFromStorage();
  }

  // Metode untuk memuat counter dari penyimpanan lokal
  void loadCountersFromStorage() {
    jumlahMenunggu.value = _storage.read(_keyMenunggu) ?? 0;
    jumlahTerverifikasi.value = _storage.read(_keyTerverifikasi) ?? 0;
    jumlahDitolak.value = _storage.read(_keyDitolak) ?? 0;
    jumlahDiproses.value = _storage.read(_keyDiproses) ?? 0;
    jumlahNotifikasiBelumDibaca.value = _storage.read(_keyNotifikasi) ?? 0;
    jumlahJadwalHariIni.value = _storage.read(_keyJadwal) ?? 0;

    print(
        'Counter loaded from storage - Menunggu: ${jumlahMenunggu.value}, Terverifikasi: ${jumlahTerverifikasi.value}, Ditolak: ${jumlahDitolak.value}');
  }

  // Metode untuk memperbarui counter penitipan
  void updatePenitipanCounters({
    required int menunggu,
    required int terverifikasi,
    required int ditolak,
  }) {
    jumlahMenunggu.value = menunggu;
    jumlahTerverifikasi.value = terverifikasi;
    jumlahDitolak.value = ditolak;

    // Simpan ke penyimpanan lokal
    _storage.write(_keyMenunggu, menunggu);
    _storage.write(_keyTerverifikasi, terverifikasi);
    _storage.write(_keyDitolak, ditolak);

    print(
        'Counter updated and saved - Menunggu: $menunggu, Terverifikasi: $terverifikasi, Ditolak: $ditolak');
  }

  // Metode untuk memperbarui counter pengaduan
  void updatePengaduanCounter(int diproses) {
    jumlahDiproses.value = diproses;
    _storage.write(_keyDiproses, diproses);

    print('Counter pengaduan updated and saved - Diproses: $diproses');
  }

  // Metode untuk memperbarui counter notifikasi
  void updateNotifikasiCounter(int belumDibaca) {
    jumlahNotifikasiBelumDibaca.value = belumDibaca;
    _storage.write(_keyNotifikasi, belumDibaca);

    print('Counter notifikasi updated and saved - Belum Dibaca: $belumDibaca');
  }

  // Metode untuk memperbarui counter jadwal
  void updateJadwalCounter(int hariIni) {
    jumlahJadwalHariIni.value = hariIni;
    _storage.write(_keyJadwal, hariIni);

    print('Counter jadwal updated and saved - Hari Ini: $hariIni');
  }
}
