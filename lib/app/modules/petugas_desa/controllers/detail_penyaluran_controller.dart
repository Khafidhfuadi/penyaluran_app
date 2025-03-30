import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/skema_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/laporan_penyaluran_model.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/controllers/laporan_penyaluran_controller.dart';

class DetailPenyaluranController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final isLoading = true.obs;
  final isProcessing = false.obs;
  final penyaluran = Rx<PenyaluranBantuanModel?>(null);
  final skemaBantuan = Rx<SkemaBantuanModel?>(null);
  final penerimaPenyaluran = <PenerimaPenyaluranModel>[].obs;
  final laporan = Rx<LaporanPenyaluranModel?>(null);
  final isLoadingLaporan = false.obs;

  // Status untuk mengetahui apakah petugas desa
  final isPetugasDesa = false.obs;

  // Tambahkan referensi ke controller laporan
  LaporanPenyaluranController? laporanController;
  final RxBool isExporting = false.obs;

  @override
  void onInit() {
    super.onInit();
    final String? penyaluranId = Get.parameters['id'];
    final PenyaluranBantuanModel? penyaluranData =
        Get.arguments as PenyaluranBantuanModel?;

    if (penyaluranData != null) {
      // Jika data penyaluran diterima langsung dari argumen
      penyaluran.value = penyaluranData;
      if (penyaluran.value?.id != null) {
        loadPenyaluranDetails(penyaluran.value!.id!);
      }
    } else if (penyaluranId != null) {
      // Jika hanya ID penyaluran yang diterima
      loadPenyaluranData(penyaluranId);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> loadPenyaluranData(String penyaluranId) async {
    try {
      isLoading.value = true;

      // Ambil data penyaluran
      final penyaluranData = await _supabaseService.client
          .from('penyaluran_bantuan')
          .select('*')
          .eq('id', penyaluranId)
          .single();

      // Pastikan data yang diterima sesuai dengan tipe data yang diharapkan
      Map<String, dynamic> sanitizedData =
          Map<String, dynamic>.from(penyaluranData);

      // Konversi jumlah_penerima ke int jika bertipe String
      if (sanitizedData['jumlah_penerima'] is String) {
        sanitizedData['jumlah_penerima'] =
            int.tryParse(sanitizedData['jumlah_penerima'] as String) ?? 0;
      }

      penyaluran.value = PenyaluranBantuanModel.fromJson(sanitizedData);

      // Ambil data skema bantuan jika ada
      if (penyaluran.value?.skemaId != null &&
          penyaluran.value!.skemaId!.isNotEmpty) {
        final skemaData = await _supabaseService.client
            .from('xx02_skema_bantuan')
            .select('*')
            .eq('id', penyaluran.value!.skemaId!)
            .single();

        // Pastikan data skema sesuai dengan tipe data yang diharapkan
        Map<String, dynamic> sanitizedSkemaData =
            Map<String, dynamic>.from(skemaData);

        // Konversi kuota ke int jika bertipe String
        if (sanitizedSkemaData['kuota'] is String) {
          sanitizedSkemaData['kuota'] =
              int.tryParse(sanitizedSkemaData['kuota'] as String) ?? 0;
        }

        // Konversi petugas_verifikasi_id ke int jika bertipe String
        if (sanitizedSkemaData['petugas_verifikasi_id'] is String) {
          sanitizedSkemaData['petugas_verifikasi_id'] = int.tryParse(
              sanitizedSkemaData['petugas_verifikasi_id'] as String);
        }

        skemaBantuan.value = SkemaBantuanModel.fromJson(sanitizedSkemaData);
      }

      // Ambil data penerima penyaluran
      final penerimaPenyaluranData = await _supabaseService.client
          .from('penerima_penyaluran')
          .select('*, warga:warga_id(*)')
          .eq('penyaluran_bantuan_id', penyaluranId);

      final List<PenerimaPenyaluranModel> penerima = [];
      for (var item in penerimaPenyaluranData) {
        // Pastikan data penerima sesuai dengan tipe data yang diharapkan
        Map<String, dynamic> sanitizedPenerimaData =
            Map<String, dynamic>.from(item);

        // Konversi jumlah_bantuan ke double jika bertipe String
        if (sanitizedPenerimaData['jumlah_bantuan'] is String) {
          sanitizedPenerimaData['jumlah_bantuan'] = double.tryParse(
              sanitizedPenerimaData['jumlah_bantuan'] as String);
        }

        penerima.add(PenerimaPenyaluranModel.fromJson(sanitizedPenerimaData));
      }
      penerimaPenyaluran.assignAll(penerima);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data penyaluran',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    if (penyaluran.value?.id != null) {
      // Jika data penyaluran sudah ada, cukup muat detail saja
      await loadPenyaluranDetails(penyaluran.value!.id!);
    }
  }

  // Fungsi untuk memulai penyaluran bantuan
  Future<void> mulaiPenyaluran() async {
    try {
      isProcessing.value = true;

      if (penyaluran.value?.id == null) {
        throw Exception('ID penyaluran tidak ditemukan');
      }

      // Update status penyaluran menjadi "AKTIF"
      await _supabaseService.client
          .from('penyaluran_bantuan')
          .update({'status': 'AKTIF'}).eq('id', penyaluran.value!.id!);

      await refreshData();

      Get.snackbar(
        'Sukses',
        'Penyaluran bantuan telah dimulai',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memulai penyaluran bantuan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Fungsi untuk konfirmasi penerimaan bantuan oleh penerima
  Future<void> konfirmasiPenerimaan(PenerimaPenyaluranModel penerima,
      {required String buktiPenerimaan, required String tandaTangan}) async {
    try {
      isProcessing.value = true;

      if (penerima.id == null) {
        throw Exception('ID penerima tidak ditemukan');
      }

      if (buktiPenerimaan.isEmpty) {
        throw Exception('Bukti penerimaan tidak boleh kosong');
      }

      if (tandaTangan.isEmpty) {
        throw Exception('Tanda tangan tidak boleh kosong');
      }

      // Update status penerimaan menjadi "DITERIMA"
      final Map<String, dynamic> updateData = {
        'status_penerimaan': 'DITERIMA',
        'tanggal_penerimaan': DateTime.now().toIso8601String(),
        'bukti_penerimaan': buktiPenerimaan,
        'tanda_tangan': tandaTangan,
      };

      await _supabaseService.client
          .from('penerima_penyaluran')
          .update(updateData)
          .eq('id', penerima.id!);

      // Dapatkan data penerima penyaluran (stok_bantuan_id dan jumlah)
      final penerimaData = await _supabaseService.client
          .from('penerima_penyaluran')
          .select('penyaluran_bantuan_id, stok_bantuan_id, jumlah_bantuan')
          .eq('id', penerima.id!)
          .single();

      final String stokBantuanId = penerimaData['stok_bantuan_id'];
      final double jumlah = penerimaData['jumlah_bantuan'] is int
          ? penerimaData['jumlah_bantuan'].toDouble()
          : penerimaData['jumlah_bantuan'];

      // Kurangi stok dan catat riwayat
      final petugasId = _supabaseService.client.auth.currentUser?.id;
      if (petugasId != null) {
        await _supabaseService.kurangiStokDariPenyaluran(
            penerima.id!, stokBantuanId, jumlah, petugasId);
      }

      // Refresh data setelah konfirmasi berhasil
      await refreshData();

      // Tidak perlu menampilkan snackbar di sini karena sudah ditampilkan di halaman konfirmasi penerima
    } catch (e) {
      rethrow; // Melempar kembali exception agar dapat ditangkap di _konfirmasiPenerimaan
    } finally {
      isProcessing.value = false;
    }
  }

  // Fungsi untuk menyelesaikan penyaluran bantuan
  Future<void> selesaikanPenyaluran() async {
    try {
      isProcessing.value = true;

      if (penyaluran.value?.id == null) {
        throw Exception('ID penyaluran tidak ditemukan');
      }

      // Cek apakah semua penerima sudah menerima bantuan
      final belumDiterima = penerimaPenyaluran
          .where((p) => p.statusPenerimaan?.toUpperCase() != 'DITERIMA')
          .toList();

      if (belumDiterima.isNotEmpty) {
        final result = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Konfirmasi'),
            content: Text(
                'Masih ada ${belumDiterima.length} penerima yang belum menerima bantuan. Apakah Anda yakin ingin menyelesaikan penyaluran?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Ya, Selesaikan'),
              ),
            ],
          ),
        );

        if (result != true) {
          isProcessing.value = false;
          return;
        }
      }

      // Update status penyaluran menjadi "TERLAKSANA"
      await _supabaseService.client.from('penyaluran_bantuan').update({
        'status': 'TERLAKSANA',
        'tanggal_selesai': DateTime.now().toIso8601String(),
      }).eq('id', penyaluran.value!.id!);

      await refreshData();

      Get.snackbar(
        'Sukses',
        'Penyaluran bantuan telah diselesaikan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menyelesaikan penyaluran bantuan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Fungsi untuk membatalkan penyaluran bantuan
  Future<void> batalkanPenyaluran(String alasan) async {
    try {
      isProcessing.value = true;

      if (penyaluran.value?.id == null) {
        throw Exception('ID penyaluran tidak ditemukan');
      }

      // Update status penyaluran menjadi "BATALTERLAKSANA"
      await _supabaseService.client.from('penyaluran_bantuan').update({
        'status': 'BATALTERLAKSANA',
        'alasan_pembatalan': alasan,
        'tanggal_selesai': DateTime.now().toIso8601String(),
      }).eq('id', penyaluran.value!.id!);

      await refreshData();

      Get.snackbar(
        'Sukses',
        'Penyaluran bantuan telah dibatalkan',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat membatalkan penyaluran bantuan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Fungsi untuk mengupload bukti penerimaan atau tanda tangan
  Future<String> uploadBuktiPenerimaan(String filePath,
      {bool isTandaTangan = false}) async {
    try {
      final String folderName =
          isTandaTangan ? 'tanda_tangan' : 'bukti_penerimaan';
      final String filePrefix =
          isTandaTangan ? 'tanda_tangan' : 'bukti_penerimaan';
      final String fileName =
          '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);

      if (!file.existsSync()) {
        throw Exception('File tidak ditemukan: $filePath');
      }

      final storageResponse = await _supabaseService.client.storage
          .from(folderName)
          .upload(fileName, file);

      if (storageResponse.isEmpty) {
        throw Exception(
            'Gagal mengupload ${isTandaTangan ? 'tanda tangan' : 'bukti penerimaan'}');
      }

      final fileUrl = _supabaseService.client.storage
          .from(folderName)
          .getPublicUrl(fileName);

      if (fileUrl.isEmpty) {
        throw Exception(
            'Gagal mendapatkan URL ${isTandaTangan ? 'tanda tangan' : 'bukti penerimaan'}');
      }

      return fileUrl;
    } catch (e) {
      print(
          'Error upload ${isTandaTangan ? 'tanda tangan' : 'bukti penerimaan'}: $e');
      // Tidak perlu menampilkan snackbar di sini karena sudah ditampilkan di halaman konfirmasi penerima
      throw Exception(
          'Gagal mengupload ${isTandaTangan ? 'tanda tangan' : 'bukti penerimaan'}: $e');
    }
  }

  // Fungsi untuk memuat detail penyaluran (skema dan penerima) tanpa memuat ulang data penyaluran
  Future<void> loadPenyaluranDetails(String penyaluranId) async {
    try {
      isLoading.value = true;

      // Ambil data skema bantuan jika ada
      if (penyaluran.value?.skemaId != null &&
          penyaluran.value!.skemaId!.isNotEmpty) {
        final skemaData = await _supabaseService.client
            .from('xx02_skema_bantuan')
            .select('*')
            .eq('id', penyaluran.value!.skemaId!)
            .single();

        // Pastikan data skema sesuai dengan tipe data yang diharapkan
        Map<String, dynamic> sanitizedSkemaData =
            Map<String, dynamic>.from(skemaData);

        // Konversi kuota ke int jika bertipe String
        if (sanitizedSkemaData['kuota'] is String) {
          sanitizedSkemaData['kuota'] =
              int.tryParse(sanitizedSkemaData['kuota'] as String) ?? 0;
        }

        // Konversi petugas_verifikasi_id ke int jika bertipe String
        if (sanitizedSkemaData['petugas_verifikasi_id'] is String) {
          sanitizedSkemaData['petugas_verifikasi_id'] = int.tryParse(
              sanitizedSkemaData['petugas_verifikasi_id'] as String);
        }

        skemaBantuan.value = SkemaBantuanModel.fromJson(sanitizedSkemaData);
      }

      // Ambil data penerima penyaluran
      final penerimaPenyaluranData = await _supabaseService.client
          .from('penerima_penyaluran')
          .select('*, warga:warga_id(*)')
          .eq('penyaluran_bantuan_id', penyaluranId);

      final List<PenerimaPenyaluranModel> penerima = [];
      for (var item in penerimaPenyaluranData) {
        // Pastikan data penerima sesuai dengan tipe data yang diharapkan
        Map<String, dynamic> sanitizedPenerimaData =
            Map<String, dynamic>.from(item);

        // Konversi jumlah_bantuan ke double jika bertipe String
        if (sanitizedPenerimaData['jumlah_bantuan'] is String) {
          sanitizedPenerimaData['jumlah_bantuan'] = double.tryParse(
              sanitizedPenerimaData['jumlah_bantuan'] as String);
        }

        penerima.add(PenerimaPenyaluranModel.fromJson(sanitizedPenerimaData));
      }
      penerimaPenyaluran.assignAll(penerima);

      // Periksa apakah ada laporan untuk penyaluran ini
      await checkLaporanPenyaluran(penyaluranId);

      // if (penerima.isNotEmpty) {
      //   print('DetailPenyaluranController - ID penerima: ${penerima[0].id}');
      // }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat detail penyaluran',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkLaporanPenyaluran(String penyaluranId) async {
    try {
      isLoadingLaporan.value = true;

      final response = await _supabaseService.client
          .from('laporan_penyaluran')
          .select('*')
          .eq('penyaluran_bantuan_id', penyaluranId)
          .maybeSingle();

      if (response != null) {
        // Laporan ditemukan
        laporan.value = LaporanPenyaluranModel.fromJson(response);
      } else {
        // Tidak ada laporan
        laporan.value = null;
      }
    } catch (e) {
      print('Error saat memeriksa laporan penyaluran: $e');
      laporan.value = null;
    } finally {
      isLoadingLaporan.value = false;
    }
  }

  void navigateToLaporanCreate() {
    if (penyaluran.value?.id == null) return;

    // Kirim ID penyaluran langsung sebagai argument (String), bukan dalam bentuk Map
    Get.toNamed('/laporan-penyaluran/create', arguments: penyaluran.value!.id)
        ?.then((value) {
      if (value == true) {
        // Refresh data setelah membuat laporan
        checkLaporanPenyaluran(penyaluran.value!.id!);
      }
    });
  }

  void navigateToLaporanDetail() {
    if (laporan.value?.id == null) return;

    // Navigasi ke halaman detail dengan mengirimkan ID sebagai argument
    Get.toNamed('/laporan-penyaluran/detail', arguments: laporan.value!.id)
        ?.then((value) {
      if (value == true) {
        // Refresh data setelah melihat detail laporan
        checkLaporanPenyaluran(penyaluran.value!.id!);
      }
    });
  }

  // Metode untuk verifikasi penerima berdasarkan QR code
  Future<bool> verifikasiPenerimaByQrCode(
      String penyaluranId, String qrHash) async {
    try {
      isProcessing.value = true;

      // Cari penerima dengan QR hash yang sesuai
      final data = await _supabaseService.client
          .from('penerima_penyaluran')
          .select('*, warga:warga_id(*)')
          .eq('penyaluran_bantuan_id', penyaluranId)
          .eq('qr_code_hash', qrHash)
          .single();

      // Jika penerima ditemukan, konversi ke model
      final Map<String, dynamic> sanitizedPenerimaData =
          Map<String, dynamic>.from(data);

      // Konversi jumlah_bantuan ke double jika bertipe String
      if (sanitizedPenerimaData['jumlah_bantuan'] is String) {
        sanitizedPenerimaData['jumlah_bantuan'] =
            double.tryParse(sanitizedPenerimaData['jumlah_bantuan'] as String);
      }

      // Konversi data ke model
      final penerima = PenerimaPenyaluranModel.fromJson(sanitizedPenerimaData);

      // Set isProcessing ke false sebelum navigasi untuk menghindari masalah loading
      isProcessing.value = false;

      // Navigasi ke halaman konfirmasi dengan data terbaru
      await Get.toNamed('/petugas-desa/konfirmasi-penerima/${penerima.id}',
          arguments: {
            'penerima': penerima,
            'tanggal_penyaluran': penyaluran.value?.tanggalPenyaluran
          });

      // Refresh data
      await refreshData();
      return true;

      return false;
    } catch (e) {
      print('Error verifikasi QR code: $e');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // Method untuk memuat controller laporan
  Future<void> loadLaporanPenyaluranController() async {
    if (laporanController == null) {
      // Cek apakah controller sudah ada di Get
      if (Get.isRegistered<LaporanPenyaluranController>()) {
        laporanController = Get.find<LaporanPenyaluranController>();
      } else {
        // Jika belum ada, buat instance baru
        laporanController = Get.put(LaporanPenyaluranController());
      }
    }

    // Pastikan data laporan dimuat
    if (laporan.value != null && penyaluran.value != null) {
      await laporanController!.fetchLaporanDetail(laporan.value!.id!);
    }
  }

  // Method untuk export PDF
  Future<void> exportToPdf() async {
    if (laporan.value == null || penyaluran.value == null) {
      Get.snackbar(
        'Error',
        'Data laporan atau penyaluran tidak tersedia',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isExporting.value = true;
    try {
      await loadLaporanPenyaluranController();
      await laporanController!.exportToPdf(laporan.value!, penyaluran.value!);
    } catch (e) {
      print('Error saat export PDF: $e');
      Get.snackbar(
        'Error',
        'Gagal mengekspor laporan ke PDF',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExporting.value = false;
    }
  }

  // Fungsi untuk mengambil data penerima penyaluran berdasarkan ID
  Future<PenerimaPenyaluranModel?> getPenerimaPenyaluranById(
      String penerimaPenyaluranId) async {
    try {
      // Ambil data penerima penyaluran dengan relasinya
      final data = await _supabaseService.client
          .from('penerima_penyaluran')
          .select(
              '*, warga:warga_id(*), stok_bantuan:stok_bantuan_id(*), penyaluran_bantuan:penyaluran_bantuan_id(*)')
          .eq('id', penerimaPenyaluranId)
          .single();

      // Konversi data ke model
      final Map<String, dynamic> sanitizedData =
          Map<String, dynamic>.from(data);

      // Konversi jumlah_bantuan ke double jika bertipe String
      if (sanitizedData['jumlah_bantuan'] is String) {
        sanitizedData['jumlah_bantuan'] =
            double.tryParse(sanitizedData['jumlah_bantuan'] as String);
      }

      return PenerimaPenyaluranModel.fromJson(sanitizedData);
    } catch (e) {
      print('Error mengambil data penerima penyaluran: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat mengambil data penerima',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Fungsi untuk memuat penyaluran dengan id tertentu
  Future<void> getDetailPenyaluran(String penyaluranId) async {
    try {
      isLoading.value = true;

      // Ambil data penyaluran
      await loadPenyaluranData(penyaluranId);
    } catch (e) {
      print('Error getDetailPenyaluran: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data detail penyaluran',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
