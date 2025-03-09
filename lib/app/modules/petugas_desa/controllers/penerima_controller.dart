import 'package:get/get.dart';

class PenerimaController extends GetxController {
  final RxList<Map<String, dynamic>> daftarPenerima =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDaftarPenerima();
  }

  @override
  void onReady() {
    super.onReady();
    // Pastikan data dimuat saat controller siap
    if (daftarPenerima.isEmpty) {
      fetchDaftarPenerima();
    }
  }

  void fetchDaftarPenerima() {
    isLoading.value = true;

    // Simulasi data penerima
    Future.delayed(const Duration(milliseconds: 500), () {
      daftarPenerima.value = [
        {
          'id': '1',
          'nama': 'Bagus Jayadi',
          'nik': '3201020107030010',
          'noKK': '3201020107030383',
          'noHandphone': '089891256532',
          'email': 'bgjayadi@gmail.com',
          'jenisKelamin': 'Pria',
          'agama': 'Islam',
          'tempatTanggalLahir': 'Bogor, 2 Juni 1990',
          'alamatLengkap':
              'Jl. Leada Natsir No. 22 RT 001/003 Kec. Gunung Putri Kab. Bogor',
          'pekerjaan': 'Petani',
          'pendidikanTerakhir': 'Sekolah Dasar (SD)',
          'status': 'Belum disalurkan',
          'foto': 'assets/images/profile.jpg',
          'terverifikasi': true,
        },
        {
          'id': '2',
          'nama': 'Siti Rahayu',
          'nik': '3201020107030011',
          'noKK': '3201020107030384',
          'noHandphone': '089891256533',
          'email': 'sitirahayu@gmail.com',
          'jenisKelamin': 'Wanita',
          'agama': 'Islam',
          'tempatTanggalLahir': 'Bogor, 15 Agustus 1985',
          'alamatLengkap':
              'Jl. Raya Bogor No. 45 RT 002/004 Kec. Gunung Putri Kab. Bogor',
          'pekerjaan': 'Ibu Rumah Tangga',
          'pendidikanTerakhir': 'SMP',
          'status': 'Selesai',
          'foto': 'assets/images/profile.jpg',
          'terverifikasi': true,
        },
        {
          'id': '3',
          'nama': 'Budi Santoso',
          'nik': '3201020107030012',
          'noKK': '3201020107030385',
          'noHandphone': '089891256534',
          'email': 'budisantoso@gmail.com',
          'jenisKelamin': 'Pria',
          'agama': 'Islam',
          'tempatTanggalLahir': 'Jakarta, 10 Januari 1980',
          'alamatLengkap':
              'Jl. Merdeka No. 12 RT 003/005 Kec. Gunung Putri Kab. Bogor',
          'pekerjaan': 'Buruh',
          'pendidikanTerakhir': 'SMA',
          'status': 'Selesai',
          'foto': 'assets/images/profile.jpg',
          'terverifikasi': true,
        },
        {
          'id': '4',
          'nama': 'Dewi Lestari',
          'nik': '3201020107030013',
          'noKK': '3201020107030386',
          'noHandphone': '089891256535',
          'email': 'dewilestari@gmail.com',
          'jenisKelamin': 'Wanita',
          'agama': 'Islam',
          'tempatTanggalLahir': 'Bandung, 5 Mei 1992',
          'alamatLengkap':
              'Jl. Pahlawan No. 8 RT 004/006 Kec. Gunung Putri Kab. Bogor',
          'pekerjaan': 'Guru',
          'pendidikanTerakhir': 'S1',
          'status': 'Selesai',
          'foto': 'assets/images/profile.jpg',
          'terverifikasi': true,
        },
        {
          'id': '5',
          'nama': 'Ahmad Fauzi',
          'nik': '3201020107030014',
          'noKK': '3201020107030387',
          'noHandphone': '089891256536',
          'email': 'ahmadfauzi@gmail.com',
          'jenisKelamin': 'Pria',
          'agama': 'Islam',
          'tempatTanggalLahir': 'Surabaya, 20 Desember 1988',
          'alamatLengkap':
              'Jl. Sudirman No. 15 RT 005/007 Kec. Gunung Putri Kab. Bogor',
          'pekerjaan': 'Wiraswasta',
          'pendidikanTerakhir': 'SMA',
          'status': 'Terjadwal',
          'foto': 'assets/images/profile.jpg',
          'terverifikasi': true,
        },
      ];
      isLoading.value = false;
    });
  }

  Map<String, dynamic>? getPenerimaById(String id) {
    try {
      if (daftarPenerima.isEmpty) {
        // Jika data belum dimuat, muat data terlebih dahulu
        fetchDaftarPenerima();
        // Kembalikan data dummy sementara
        return {
          'id': id,
          'nama': 'Memuat data...',
          'nik': 'Memuat...',
          'noKK': 'Memuat...',
          'noHandphone': 'Memuat...',
          'email': 'Memuat...',
          'jenisKelamin': 'Memuat...',
          'agama': 'Memuat...',
          'tempatTanggalLahir': 'Memuat...',
          'alamatLengkap': 'Memuat...',
          'pekerjaan': 'Memuat...',
          'pendidikanTerakhir': 'Memuat...',
          'status': 'Memuat...',
          'terverifikasi': false,
        };
      }
      return daftarPenerima.firstWhere((penerima) => penerima['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
