import 'package:get/get.dart';

/// Service untuk berbagi data counter antar controller
class CounterService extends GetxService {
  static CounterService get to => Get.find<CounterService>();

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

  // Metode untuk memperbarui counter penitipan
  void updatePenitipanCounters({
    required int menunggu,
    required int terverifikasi,
    required int ditolak,
  }) {
    jumlahMenunggu.value = menunggu;
    jumlahTerverifikasi.value = terverifikasi;
    jumlahDitolak.value = ditolak;
  }

  // Metode untuk memperbarui counter pengaduan
  void updatePengaduanCounter(int diproses) {
    jumlahDiproses.value = diproses;
  }

  // Metode untuk memperbarui counter notifikasi
  void updateNotifikasiCounter(int belumDibaca) {
    jumlahNotifikasiBelumDibaca.value = belumDibaca;
  }

  // Metode untuk memperbarui counter jadwal
  void updateJadwalCounter(int hariIni) {
    jumlahJadwalHariIni.value = hariIni;
  }
}
