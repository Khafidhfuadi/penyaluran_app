import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/laporan_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:penyaluran_app/app/utils/date_time_helper.dart';

class LaporanPenyaluranController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseService _supabaseService = SupabaseService.to;

  // Data
  final RxList<LaporanPenyaluranModel> daftarLaporan =
      <LaporanPenyaluranModel>[].obs;
  final RxList<PenyaluranBantuanModel> penyaluranTanpaLaporan =
      <PenyaluranBantuanModel>[].obs;
  final Rx<LaporanPenyaluranModel?> selectedLaporan =
      Rx<LaporanPenyaluranModel?>(null);
  final Rx<PenyaluranBantuanModel?> selectedPenyaluran =
      Rx<PenyaluranBantuanModel?>(null);
  final RxList<PenerimaPenyaluranModel> daftarPenerima =
      <PenerimaPenyaluranModel>[].obs;
  final RxMap<String, double> stokBantuanUsage = RxMap<String, double>();
  final RxMap<String, dynamic> lokasiPenyaluran = RxMap<String, dynamic>();
  final RxMap<String, dynamic> desaData = RxMap<String, dynamic>();
  final RxMap<String, dynamic> kategoriBantuan = RxMap<String, dynamic>();

  // Form controllers
  final TextEditingController judulController = TextEditingController();

  // File controllers untuk dokumentasi dan berita acara
  final RxString dokumentasiPath = RxString('');
  final RxString beritaAcaraPath = RxString('');
  final RxBool isDokumentasiUploading = false.obs;
  final RxBool isBeritaAcaraUploading = false.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isExporting = false.obs;

  // Filter status
  final RxString filterStatus = 'SEMUA'.obs;

  // Getter untuk data user
  get user => _authController.user;
  String get role => user?.role ?? 'WARGA';

  @override
  void onInit() {
    super.onInit();
    fetchLaporan();
  }

  @override
  void onClose() {
    judulController.dispose();
    super.onClose();
  }

  // Reset form untuk pembuatan laporan baru
  void resetForm() {
    judulController.clear();
    dokumentasiPath.value = '';
    beritaAcaraPath.value = '';
    isDokumentasiUploading.value = false;
    isBeritaAcaraUploading.value = false;
  }

  // Mengambil data semua laporan penyaluran
  Future<void> fetchLaporan() async {
    isLoading.value = true;
    try {
      final response = await _supabaseService.client
          .from('laporan_penyaluran')
          .select('*')
          .order('created_at', ascending: false);

      daftarLaporan.value = (response as List<dynamic>)
          .map((item) => LaporanPenyaluranModel.fromJson(item))
          .toList();

      await fetchPenyaluranTanpaLaporan();
    } catch (e) {
      print('Error fetching laporan: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data laporan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Mengambil data penyaluran yang belum memiliki laporan
  Future<void> fetchPenyaluranTanpaLaporan() async {
    try {
      // Ambil semua penyaluran dengan status TERLAKSANA
      final response = await _supabaseService.client
          .from('penyaluran_bantuan')
          .select('*')
          .eq('status', 'TERLAKSANA')
          .order('tanggal_selesai', ascending: false);

      final allPenyaluran = (response as List<dynamic>)
          .map((item) => PenyaluranBantuanModel.fromJson(item))
          .toList();

      // Filter penyaluran yang belum memiliki laporan
      final penyaluranIds =
          daftarLaporan.map((e) => e.penyaluranBantuanId).toList();
      penyaluranTanpaLaporan.value = allPenyaluran
          .where((penyaluran) => !penyaluranIds.contains(penyaluran.id))
          .toList();
    } catch (e) {
      print('Error fetching penyaluran tanpa laporan: $e');
    }
  }

  // Mendapatkan detail laporan berdasarkan ID
  Future<void> fetchLaporanDetail(String laporanId) async {
    isLoading.value = true;
    try {
      final response = await _supabaseService.client
          .from('laporan_penyaluran')
          .select('*')
          .eq('id', laporanId)
          .single();

      selectedLaporan.value = LaporanPenyaluranModel.fromJson(response);

      // Ambil data penyaluran terkait
      await fetchPenyaluranDetail(selectedLaporan.value!.penyaluranBantuanId);
    } catch (e) {
      print('Error fetching laporan detail: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat detail laporan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Mendapatkan detail penyaluran berdasarkan ID
  Future<void> fetchPenyaluranDetail(String penyaluranId) async {
    try {
      final response = await _supabaseService.client
          .from('penyaluran_bantuan')
          .select('*')
          .eq('id', penyaluranId)
          .single();

      selectedPenyaluran.value = PenyaluranBantuanModel.fromJson(response);

      // Ambil data penerima terkait
      await fetchPenerimaPenyaluran(penyaluranId);

      // Ambil data lokasi penyaluran
      if (selectedPenyaluran.value?.lokasiPenyaluranId != null) {
        await fetchLokasiPenyaluran(
            selectedPenyaluran.value!.lokasiPenyaluranId!);
      }

      // Hitung penggunaan stok bantuan
      await calculateStokBantuanUsage(penyaluranId);
    } catch (e) {
      print('Error fetching penyaluran detail: $e');
    }
  }

  // Mendapatkan daftar penerima penyaluran
  Future<void> fetchPenerimaPenyaluran(String penyaluranId) async {
    try {
      final response = await _supabaseService.client
          .from('penerima_penyaluran')
          .select('*, warga(*), stok_bantuan(*)')
          .eq('penyaluran_bantuan_id', penyaluranId);

      daftarPenerima.value = (response as List<dynamic>)
          .map((item) => PenerimaPenyaluranModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching penerima penyaluran: $e');
    }
  }

  // Mendapatkan data lokasi penyaluran
  Future<void> fetchLokasiPenyaluran(String lokasiId) async {
    try {
      final response = await _supabaseService.client
          .from('lokasi_penyaluran')
          .select('*, desa_id')
          .eq('id', lokasiId)
          .single();

      lokasiPenyaluran.value = response;

      // Ambil data desa jika ada desa_id
      if (lokasiPenyaluran['desa_id'] != null) {
        await fetchDesaData(lokasiPenyaluran['desa_id']);
      }
    } catch (e) {
      print('Error fetching lokasi penyaluran: $e');
    }
  }

  // Mendapatkan data desa
  Future<void> fetchDesaData(String desaId) async {
    try {
      final response = await _supabaseService.client
          .from('desa')
          .select('*, kecamatan, kabupaten, provinsi')
          .eq('id', desaId)
          .single();

      desaData.value = response;
    } catch (e) {
      print('Error fetching desa data: $e');
    }
  }

  // Mendapatkan data kategori bantuan berdasarkan ID
  Future<void> fetchKategoriBantuan(String kategoriId) async {
    try {
      final response = await _supabaseService.client
          .from('kategori_bantuan')
          .select('*')
          .eq('id', kategoriId)
          .single();

      kategoriBantuan.value = response;
    } catch (e) {
      print('Error fetching kategori bantuan: $e');
    }
  }

  // Menghitung penggunaan stok bantuan
  Future<void> calculateStokBantuanUsage(String penyaluranId) async {
    try {
      // Reset stok usage
      stokBantuanUsage.clear();

      // Group by stok_bantuan_id and calculate total usage
      for (var penerima in daftarPenerima) {
        if (penerima.stokBantuanId != null && penerima.jumlahBantuan != null) {
          final stokId = penerima.stokBantuanId!;
          final amount = penerima.jumlahBantuan!;

          if (stokBantuanUsage.containsKey(stokId)) {
            stokBantuanUsage[stokId] = stokBantuanUsage[stokId]! + amount;
          } else {
            stokBantuanUsage[stokId] = amount;
          }

          // Dapatkan kategori bantuan jika stok bantuan ini memilikinya
          if (penerima.stokBantuan != null &&
              penerima.stokBantuan!['kategori_bantuan_id'] != null &&
              kategoriBantuan.isEmpty) {
            await fetchKategoriBantuan(
                penerima.stokBantuan!['kategori_bantuan_id']);
          }
        }
      }
    } catch (e) {
      print('Error calculating stok bantuan usage: $e');
    }
  }

  // Set form untuk edit
  void setFormForEdit(LaporanPenyaluranModel laporan) {
    judulController.text = laporan.judul;

    // Reset dokumentasi dan berita acara path agar tampil dari URL yang sudah ada
    dokumentasiPath.value = '';
    beritaAcaraPath.value = '';
  }

  // Validasi form
  bool validateForm() {
    if (judulController.text.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Judul laporan tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  // Upload dokumentasi
  Future<String?> uploadDokumentasi(File file) async {
    isDokumentasiUploading.value = true;
    try {
      final fileExt = file.path.split('.').last;
      final fileName =
          'dokumentasi_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'dokumentasi/$fileName';

      final response = await _supabaseService.client.storage
          .from('laporan_penyaluran')
          .upload(filePath, file);

      // Dapatkan URL publik
      final String publicUrl = _supabaseService.client.storage
          .from('laporan_penyaluran')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading dokumentasi: $e');
      Get.snackbar(
        'Error',
        'Gagal mengunggah dokumentasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isDokumentasiUploading.value = false;
    }
  }

  // Upload berita acara
  Future<String?> uploadBeritaAcara(File file) async {
    isBeritaAcaraUploading.value = true;
    try {
      final fileExt = file.path.split('.').last;
      final fileName =
          'berita_acara_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'berita_acara/$fileName';

      final response = await _supabaseService.client.storage
          .from('laporan_penyaluran')
          .upload(filePath, file);

      // Dapatkan URL publik
      final String publicUrl = _supabaseService.client.storage
          .from('laporan_penyaluran')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading berita acara: $e');
      Get.snackbar(
        'Error',
        'Gagal mengunggah berita acara',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isBeritaAcaraUploading.value = false;
    }
  }

  // Menyimpan laporan baru
  Future<void> saveLaporan(String penyaluranId) async {
    if (!validateForm()) return;

    isSaving.value = true;
    try {
      // Upload dokumentasi jika ada
      String? dokumentasiUrl;
      if (dokumentasiPath.isNotEmpty) {
        dokumentasiUrl = await uploadDokumentasi(File(dokumentasiPath.value));
      }

      // Upload berita acara jika ada
      String? beritaAcaraUrl;
      if (beritaAcaraPath.isNotEmpty) {
        beritaAcaraUrl = await uploadBeritaAcara(File(beritaAcaraPath.value));
      }

      final data = {
        'penyaluran_bantuan_id': penyaluranId,
        'judul': judulController.text,
        'tanggal_laporan': DateTime.now().toUtc().toIso8601String(),
        'status': 'DRAFT',
        if (dokumentasiUrl != null) 'dokumentasi_url': dokumentasiUrl,
        if (beritaAcaraUrl != null) 'berita_acara_url': beritaAcaraUrl,
      };

      final response = await _supabaseService.client
          .from('laporan_penyaluran')
          .insert(data)
          .select()
          .single();

      Get.snackbar(
        'Sukses',
        'Laporan berhasil disimpan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      resetForm();
      Get.back();
      await fetchLaporan();
    } catch (e) {
      print('Error saving laporan: $e');
      Get.snackbar(
        'Error',
        'Gagal menyimpan laporan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Update laporan
  Future<void> updateLaporan(String laporanId) async {
    if (!validateForm()) return;

    isSaving.value = true;
    try {
      // Upload dokumentasi jika ada perubahan
      String? dokumentasiUrl;
      if (dokumentasiPath.isNotEmpty) {
        dokumentasiUrl = await uploadDokumentasi(File(dokumentasiPath.value));
      }

      // Upload berita acara jika ada perubahan
      String? beritaAcaraUrl;
      if (beritaAcaraPath.isNotEmpty) {
        beritaAcaraUrl = await uploadBeritaAcara(File(beritaAcaraPath.value));
      }

      final data = {
        'judul': judulController.text,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        if (dokumentasiUrl != null) 'dokumentasi_url': dokumentasiUrl,
        if (beritaAcaraUrl != null) 'berita_acara_url': beritaAcaraUrl,
      };

      await _supabaseService.client
          .from('laporan_penyaluran')
          .update(data)
          .eq('id', laporanId);

      Get.snackbar(
        'Sukses',
        'Laporan berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
      await fetchLaporanDetail(laporanId);
    } catch (e) {
      print('Error updating laporan: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui laporan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Finalisasi laporan
  Future<void> finalizeLaporan(String laporanId) async {
    try {
      await _supabaseService.client.from('laporan_penyaluran').update({
        'status': 'FINAL',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', laporanId);

      Get.snackbar(
        'Sukses',
        'Laporan berhasil difinalisasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await fetchLaporanDetail(laporanId);
    } catch (e) {
      print('Error finalizing laporan: $e');
      Get.snackbar(
        'Error',
        'Gagal memfinalisasi laporan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Hapus laporan
  Future<void> deleteLaporan(String laporanId) async {
    try {
      await _supabaseService.client
          .from('laporan_penyaluran')
          .delete()
          .eq('id', laporanId);

      Get.snackbar(
        'Sukses',
        'Laporan berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
      await fetchLaporan();
    } catch (e) {
      print('Error deleting laporan: $e');
      Get.snackbar(
        'Error',
        'Gagal menghapus laporan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Export laporan ke PDF
  Future<void> exportToPdf(
      LaporanPenyaluranModel laporan, PenyaluranBantuanModel penyaluran) async {
    isExporting.value = true;
    try {
      // Buat dokumen PDF
      final pdf = pw.Document();

      // Load font
      final font = await rootBundle.load("assets/font/DMSans-Regular.ttf");
      final fontBold = await rootBundle.load("assets/font/DMSans-Bold.ttf");
      final ttf = pw.Font.ttf(font);
      final ttfBold = pw.Font.ttf(fontBold);

      // Load logo - tidak perlu menampilkan error jika logo tidak ada
      pw.MemoryImage? logoImage;
      try {
        final logoBytes = await rootBundle.load('assets/img/logo.png');
        logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
      } catch (e) {
        // Logo tidak ditemukan - tidak perlu print error
        // Cukup terapkan null handling saat menggunakan logoImage
      }

      // Coba unduh gambar dokumentasi menggunakan http statis (bukan dinamis)
      pw.MemoryImage? dokumentasiImage;
      if (laporan.dokumentasiUrl != null &&
          laporan.dokumentasiUrl!.isNotEmpty) {
        try {
          // Gunakan http package secara langsung (pastikan sudah ditambahkan di pubspec.yaml)
          // import 'package:http/http.dart' as http; (tambahkan di bagian atas file)
          final response = await http.get(Uri.parse(laporan.dokumentasiUrl!));
          if (response.statusCode == 200) {
            dokumentasiImage = pw.MemoryImage(response.bodyBytes);
          }
        } catch (e) {
          // Error unduh gambar - tidak perlu mencoba import dinamis
          print('Tidak dapat mengunduh gambar dokumentasi: $e');
        }
      }

      // Tambahkan halaman
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          header: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    logoImage != null
                        ? pw.Image(logoImage, width: 60, height: 60)
                        : pw.SizedBox(width: 60),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('LAPORAN PENYALURAN BANTUAN',
                            style: pw.TextStyle(
                                font: ttfBold,
                                fontSize: 12,
                                color: PdfColors.blue900)),
                        pw.Text(
                          'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                          style: pw.TextStyle(font: ttf, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Divider(color: PdfColors.blue900, thickness: 2),
              ],
            );
          },
          footer: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Laporan Penyaluran | ${laporan.judul}',
                      style: pw.TextStyle(
                          font: ttf, fontSize: 8, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                      style: pw.TextStyle(
                          font: ttf, fontSize: 8, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            );
          },
          build: (pw.Context context) {
            return [
              // Judul Utama
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      laporan.judul.toUpperCase(),
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 16,
                        color: PdfColors.blue900,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      penyaluran.nama ?? 'Penyaluran Bantuan',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Informasi Laporan
              _buildPdfSection(
                'INFORMASI LAPORAN',
                [
                  _buildPdfRow('Judul Laporan', laporan.judul, ttf, ttfBold),
                  _buildPdfRow(
                      'Tanggal Laporan',
                      laporan.tanggalLaporan != null
                          ? DateTimeHelper.formatDateTime(
                              laporan.tanggalLaporan!)
                          : '-',
                      ttf,
                      ttfBold),
                  _buildPdfRow(
                      'Status', laporan.status ?? 'DRAFT', ttf, ttfBold),
                ],
                ttfBold,
                PdfColors.blue900,
              ),

              pw.SizedBox(height: 15),

              // Informasi Penyaluran
              _buildPdfSection(
                'INFORMASI PENYALURAN',
                [
                  _buildPdfRow(
                      'Nama Penyaluran', penyaluran.nama ?? '-', ttf, ttfBold),
                  _buildPdfRow(
                      'Tanggal Penyaluran',
                      penyaluran.tanggalPenyaluran != null
                          ? DateTimeHelper.formatDateTime(
                              penyaluran.tanggalPenyaluran!)
                          : '-',
                      ttf,
                      ttfBold),
                  _buildPdfRow(
                      'Tanggal Selesai',
                      penyaluran.tanggalSelesai != null
                          ? DateTimeHelper.formatDateTime(
                              penyaluran.tanggalSelesai!)
                          : '-',
                      ttf,
                      ttfBold),
                  _buildPdfRow('Jumlah Penerima',
                      '${penyaluran.jumlahPenerima ?? 0} orang', ttf, ttfBold),
                  _buildPdfRow('Status Penyaluran', penyaluran.status ?? '-',
                      ttf, ttfBold),
                  if (penyaluran.deskripsi != null &&
                      penyaluran.deskripsi!.isNotEmpty) ...[
                    pw.SizedBox(height: 10),
                    pw.Text('Deskripsi Penyaluran:',
                        style: pw.TextStyle(font: ttfBold)),
                    pw.SizedBox(height: 3),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(penyaluran.deskripsi!,
                          style: pw.TextStyle(font: ttf, fontSize: 10)),
                    ),
                  ],
                ],
                ttfBold,
                PdfColors.blue900,
              ),

              // Informasi Lokasi Penyaluran
              if (lokasiPenyaluran.isNotEmpty) ...[
                pw.SizedBox(height: 15),
                _buildPdfSection(
                  'LOKASI PENYALURAN',
                  [
                    _buildPdfRow('Nama Lokasi', lokasiPenyaluran['nama'] ?? '-',
                        ttf, ttfBold),
                    _buildPdfRow(
                        'Alamat',
                        lokasiPenyaluran['alamat_lengkap'] ?? '-',
                        ttf,
                        ttfBold),
                    if (desaData.isNotEmpty) ...[
                      _buildPdfRow('Desa/Kelurahan', desaData['nama'] ?? '-',
                          ttf, ttfBold),
                      _buildPdfRow('Kecamatan', desaData['kecamatan'] ?? '-',
                          ttf, ttfBold),
                      _buildPdfRow('Kabupaten/Kota',
                          desaData['kabupaten'] ?? '-', ttf, ttfBold),
                      _buildPdfRow('Provinsi', desaData['provinsi'] ?? '-', ttf,
                          ttfBold),
                    ] else ...[
                      _buildPdfRow('Kecamatan',
                          lokasiPenyaluran['kecamatan'] ?? '-', ttf, ttfBold),
                      _buildPdfRow(
                          'Kelurahan/Desa',
                          lokasiPenyaluran['kelurahan_desa'] ?? '-',
                          ttf,
                          ttfBold),
                    ],
                    if (lokasiPenyaluran['keterangan'] != null &&
                        lokasiPenyaluran['keterangan']
                            .toString()
                            .isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      pw.Text('Keterangan Lokasi:',
                          style: pw.TextStyle(font: ttfBold)),
                      pw.SizedBox(height: 3),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(lokasiPenyaluran['keterangan'],
                            style: pw.TextStyle(font: ttf, fontSize: 10)),
                      ),
                    ],
                  ],
                  ttfBold,
                  PdfColors.blue900,
                ),
              ],

              // Informasi Stok Bantuan
              pw.SizedBox(height: 15),
              pw.NewPage(),
              if (stokBantuanUsage.isNotEmpty) ...[
                _buildPdfSection(
                  'STOK BANTUAN YANG DIGUNAKAN',
                  [
                    // Informasi kategori bantuan jika tersedia
                    if (kategoriBantuan.isNotEmpty) ...[
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Kategori Bantuan: ${kategoriBantuan['nama'] ?? 'Tidak Diketahui'}',
                              style: pw.TextStyle(
                                font: ttfBold,
                                fontSize: 12,
                              ),
                            ),
                            if (kategoriBantuan['deskripsi'] != null) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                kategoriBantuan['deskripsi'],
                                style: pw.TextStyle(font: ttf, fontSize: 10),
                              ),
                            ],
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 10),
                    ],
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.blue200,
                        width: 0.5,
                      ),
                      children: [
                        // Header
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                          ),
                          children: [
                            _buildPdfTableCell('Nama Bantuan', ttfBold,
                                isHeader: true, color: PdfColors.blue900),
                            _buildPdfTableCell('Jumlah Digunakan', ttfBold,
                                isHeader: true,
                                align: pw.TextAlign.center,
                                color: PdfColors.blue900),
                          ],
                        ),
                        // Data
                        ...stokBantuanUsage.entries.map((entry) {
                          final stokId = entry.key;
                          final jumlah = entry.value;

                          // Find stok bantuan details
                          final stokBantuan = daftarPenerima
                              .firstWhere((p) => p.stokBantuanId == stokId,
                                  orElse: () => PenerimaPenyaluranModel())
                              ?.stokBantuan;

                          if (stokBantuan == null)
                            return pw.TableRow(children: [
                              _buildPdfTableCell('-', ttf),
                              _buildPdfTableCell('-', ttf),
                            ]);

                          final isUang = stokBantuan['is_uang'] == true;
                          final formattedJumlah = isUang
                              ? 'Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(jumlah)}'
                              : '$jumlah ${stokBantuan['satuan'] ?? ''}';

                          return pw.TableRow(
                            children: [
                              _buildPdfTableCell(
                                  stokBantuan['nama'] ?? '-', ttf),
                              _buildPdfTableCell(formattedJumlah, ttf,
                                  align: pw.TextAlign.center),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                  ttfBold,
                  PdfColors.blue900,
                ),
              ],

              // Daftar Penerima
              if (daftarPenerima.isNotEmpty) ...[
                pw.SizedBox(height: 15),
                _buildPdfSection(
                  'DAFTAR PENERIMA BANTUAN',
                  [
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.blue200,
                        width: 0.5,
                      ),
                      children: [
                        // Header
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                          ),
                          children: [
                            //nik
                            _buildPdfTableCell('NIK', ttfBold,
                                isHeader: true, color: PdfColors.blue900),
                            _buildPdfTableCell('Nama Penerima', ttfBold,
                                isHeader: true, color: PdfColors.blue900),

                            _buildPdfTableCell('Jumlah', ttfBold,
                                isHeader: true,
                                align: pw.TextAlign.center,
                                color: PdfColors.blue900),
                            _buildPdfTableCell('Satuan', ttfBold,
                                isHeader: true,
                                align: pw.TextAlign.center,
                                color: PdfColors.blue900),
                            _buildPdfTableCell('Status', ttfBold,
                                isHeader: true,
                                align: pw.TextAlign.center,
                                color: PdfColors.blue900),
                          ],
                        ),
                        // Data
                        ...daftarPenerima.map((penerima) {
                          final nik = penerima.warga != null
                              ? penerima.warga!['nik'] ?? '-'
                              : '-';
                          final wargaNama = penerima.warga != null
                              ? penerima.warga!['nama_lengkap'] ?? '-'
                              : '-';

                          final jumlah = penerima.jumlahBantuan != null
                              ? '${penerima.jumlahBantuan} ${penerima.satuan ?? ''}'
                              : '-';

                          return pw.TableRow(
                            children: [
                              _buildPdfTableCell(nik, ttf),
                              _buildPdfTableCell(wargaNama, ttf),
                              _buildPdfTableCell(jumlah, ttf,
                                  align: pw.TextAlign.center),
                              _buildPdfTableCell(penerima.satuan ?? '-', ttf,
                                  align: pw.TextAlign.center),
                              _buildPdfTableCell(
                                  penerima.statusPenerimaan ?? '-', ttf,
                                  align: pw.TextAlign.center),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                  ttfBold,
                  PdfColors.blue900,
                ),
              ],

              // Dokumentasi & Berita Acara
              if (laporan.dokumentasiUrl != null ||
                  laporan.beritaAcaraUrl != null ||
                  dokumentasiImage != null) ...[
                pw.SizedBox(height: 15),
                _buildPdfSection(
                  'DOKUMENTASI & BERITA ACARA',
                  [
                    // // Tampilkan preview gambar dokumentasi jika berhasil diambil
                    // if (dokumentasiImage != null) ...[
                    //   pw.Text('Preview Dokumentasi:',
                    //       style: pw.TextStyle(
                    //           font: ttfBold, color: PdfColors.blue800)),
                    //   pw.SizedBox(height: 5),
                    //   pw.Center(
                    //     child: pw.Container(
                    //       decoration: pw.BoxDecoration(
                    //         border: pw.Border.all(color: PdfColors.grey300),
                    //       ),
                    //       child: pw.Image(dokumentasiImage, height: 200),
                    //     ),
                    //   ),
                    //   pw.SizedBox(height: 10),
                    // ],

                    if (laporan.dokumentasiUrl != null) ...[
                      if (dokumentasiImage == null) ...[
                        pw.Text('Dokumentasi:',
                            style: pw.TextStyle(
                                font: ttfBold, color: PdfColors.blue800)),
                        pw.SizedBox(height: 3),
                      ],
                      pw.Text(
                          'Dokumentasi dapat diakses melalui tautan berikut:',
                          style: pw.TextStyle(font: ttf)),
                      pw.SizedBox(height: 3),
                      pw.Text(laporan.dokumentasiUrl!,
                          style: pw.TextStyle(
                            font: ttf,
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          )),
                      if (laporan.beritaAcaraUrl != null)
                        pw.SizedBox(height: 10),
                    ],

                    if (laporan.beritaAcaraUrl != null) ...[
                      pw.Text('Berita Acara:',
                          style: pw.TextStyle(
                              font: ttfBold, color: PdfColors.blue800)),
                      pw.SizedBox(height: 3),
                      pw.Text(
                          'Berita acara dapat diakses melalui tautan berikut:',
                          style: pw.TextStyle(font: ttf)),
                      pw.SizedBox(height: 3),
                      pw.Text(laporan.beritaAcaraUrl!,
                          style: pw.TextStyle(
                            font: ttf,
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          )),
                    ],
                  ],
                  ttfBold,
                  PdfColors.blue900,
                ),
              ],

              // Tanda Tangan
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Penanggung Jawab,',
                        style: pw.TextStyle(font: ttf),
                      ),
                      pw.SizedBox(height: 50), // Ruang untuk tanda tangan
                      pw.Container(
                        width: 150,
                        decoration: pw.BoxDecoration(
                            border: pw.Border(
                                top: pw.BorderSide(color: PdfColors.black))),
                        padding: const pw.EdgeInsets.only(top: 5),
                        child: pw.Text(
                          // Sesuaikan dengan properti yang ada di model user
                          user?.email ?? 'Admin Sistem',
                          style: pw.TextStyle(font: ttfBold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      // Simpan dan buka PDF
      final output = await getTemporaryDirectory();
      final file =
          File('${output.path}/laporan_penyaluran_${penyaluran.id}.pdf');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);

      Get.snackbar(
        'Sukses',
        'Laporan berhasil diekspor ke PDF',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error exporting to PDF: $e');
      Get.snackbar(
        'Error',
        'Gagal mengekspor laporan ke PDF',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isExporting.value = false;
    }
  }

  // Helper untuk membuat section pada PDF
  pw.Widget _buildPdfSection(String title, List<pw.Widget> content,
      pw.Font titleFont, PdfColor titleColor) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              border:
                  pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                  font: titleFont, fontSize: 14, color: titleColor),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat baris teks di PDF
  pw.Widget _buildPdfRow(
      String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(label,
                style: pw.TextStyle(font: boldFont, color: PdfColors.blue800)),
          ),
          pw.SizedBox(width: 10),
          pw.Text(':', style: pw.TextStyle(font: boldFont)),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: font)),
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat cell tabel di PDF
  pw.Widget _buildPdfTableCell(String text, pw.Font font,
      {bool isHeader = false,
      pw.TextAlign align = pw.TextAlign.left,
      PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 10 : 9,
          color: color,
        ),
        textAlign: align,
      ),
    );
  }
}
