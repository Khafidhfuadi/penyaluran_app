import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';

class PenerimaController extends GetxController {
  final RxList<Map<String, dynamic>> daftarPenerima =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // Variabel untuk halaman konfirmasi penerima
  final RxBool isKonfirmasiChecked = false.obs;
  final RxBool isIdentitasChecked = false.obs;
  final RxBool isDataValidChecked = false.obs;
  final RxString tanggalPenyaluran = ''.obs;
  final RxString fotoBuktiPath = ''.obs;
  final RxString tandaTanganPath = ''.obs;
  final TextEditingController catatanController = TextEditingController();

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

  @override
  void onClose() {
    catatanController.dispose();
    super.onClose();
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

  // Fungsi untuk memilih tanggal penyaluran
  Future<void> pilihTanggalPenyaluran(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E5077),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      tanggalPenyaluran.value = DateTimeHelper.formatDate(picked);
    }
  }

  // Fungsi untuk memilih foto bukti
  void pilihFotoBukti() {
    // Simulasi pemilihan foto
    // Dalam implementasi nyata, gunakan image_picker
    fotoBuktiPath.value = 'assets/images/bukti_penyaluran.jpg';
  }

  // Fungsi untuk menghapus foto bukti
  void hapusFotoBukti() {
    fotoBuktiPath.value = '';
  }

  // Fungsi untuk membuka signature pad
  void bukaSignaturePad(BuildContext context) {
    // Simulasi tanda tangan
    // Dalam implementasi nyata, gunakan signature_pad atau library serupa
    tandaTanganPath.value = 'assets/images/tanda_tangan.png';
  }

  // Fungsi untuk menghapus tanda tangan
  void hapusTandaTangan() {
    tandaTanganPath.value = '';
  }

  // Fungsi untuk konfirmasi penyaluran
  void konfirmasiPenyaluran(String id) {
    // Validasi input
    if (!isKonfirmasiChecked.value) {
      Get.snackbar(
        'Perhatian',
        'Anda harus mengkonfirmasi penyaluran bantuan',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (!isIdentitasChecked.value) {
      Get.snackbar(
        'Perhatian',
        'Anda harus memverifikasi identitas penerima',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (!isDataValidChecked.value) {
      Get.snackbar(
        'Perhatian',
        'Anda harus menyatakan kebenaran data',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (fotoBuktiPath.value.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Bukti foto penyaluran harus diunggah',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (tandaTanganPath.value.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Tanda tangan penerima harus diisi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Simulasi proses konfirmasi
    isLoading.value = true;

    // Dalam implementasi nyata, kirim data ke API
    Future.delayed(const Duration(seconds: 2), () {
      // Update status penerima
      final index =
          daftarPenerima.indexWhere((penerima) => penerima['id'] == id);
      if (index != -1) {
        final updatedPenerima =
            Map<String, dynamic>.from(daftarPenerima[index]);
        updatedPenerima['status'] = 'Selesai';
        daftarPenerima[index] = updatedPenerima;
      }

      isLoading.value = false;

      // Reset form
      isKonfirmasiChecked.value = false;
      isIdentitasChecked.value = false;
      isDataValidChecked.value = false;
      fotoBuktiPath.value = '';
      tandaTanganPath.value = '';
      catatanController.clear();

      // Tampilkan pesan sukses
      Get.snackbar(
        'Sukses',
        'Konfirmasi penyaluran bantuan berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Kembali ke halaman sebelumnya
      Get.back();
    });
  }
}
