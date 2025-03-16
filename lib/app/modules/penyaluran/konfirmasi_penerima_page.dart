import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/bentuk_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/penyaluran/detail_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:penyaluran_app/app/utils/date_time_helper.dart';

class KonfirmasiPenerimaPage extends StatefulWidget {
  final PenerimaPenyaluranModel penerima;
  final BentukBantuanModel? bentukBantuan;
  final String? jumlahBantuan;
  final DateTime? tanggalPenyaluran;

  const KonfirmasiPenerimaPage({
    super.key,
    required this.penerima,
    this.bentukBantuan,
    this.jumlahBantuan,
    this.tanggalPenyaluran,
  });

  @override
  State<KonfirmasiPenerimaPage> createState() => _KonfirmasiPenerimaPageState();
}

class _KonfirmasiPenerimaPageState extends State<KonfirmasiPenerimaPage> {
  final controller = Get.find<DetailPenyaluranController>();
  final ImagePicker _picker = ImagePicker();
  File? _buktiPenerimaan;
  bool _setujuPenerimaan = false;
  bool _setujuPenggunaan = false;
  bool _isLoading = false;

  // Controller untuk tanda tangan
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: AppTheme.primaryColor,
    exportBackgroundColor: Colors.white,
  );

  // Untuk menyimpan gambar tanda tangan
  Uint8List? _signatureImage;

  @override
  void dispose() {
    // Pastikan controller signature dibersihkan
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warga = widget.penerima.warga;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Konfirmasi Penerimaan Bantuan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => controller.isProcessing.value || _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Sedang memproses konfirmasi...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailPenerimaSection(warga),
                      const SizedBox(height: 16),
                      _buildDetailBantuanSection(),
                      const SizedBox(height: 16),
                      _buildFotoBuktiSection(),
                      const SizedBox(height: 16),
                      _buildTandaTanganSection(),
                      const SizedBox(height: 16),
                      _buildFormPersetujuanSection(),
                      const SizedBox(height: 24),
                      _buildKonfirmasiButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDetailPenerimaSection(Map<String, dynamic>? warga) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Penerima',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Foto Identitas
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto Identitas',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: warga?['foto_identitas'] != null
                        ? DecorationImage(
                            image: NetworkImage(warga!['foto_identitas']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: warga?['foto_identitas'] == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
              ],
            ),
            const Divider(),

            // NIK
            _buildInfoRow('NIK', warga?['nik'] ?? '3201020107030010'),
            const Divider(),

            // No KK
            _buildInfoRow('No KK', warga?['no_kk'] ?? '3201020107030393'),
            const Divider(),

            // No Handphone
            _buildInfoRow(
                'No Handphone', warga?['no_telepon'] ?? '089891256532'),
            const Divider(),

            // Email
            _buildInfoRow('Email', warga?['email'] ?? 'bajiyadi@gmail.com'),
            const Divider(),

            // Jenis Kelamin
            _buildInfoRow('Jenis Kelamin', warga?['jenis_kelamin'] ?? 'Pria'),
            const Divider(),

            // Agama
            _buildInfoRow('Agama', warga?['agama'] ?? 'Islam'),
            const Divider(),

            // Tempat, Tanggal Lahir
            _buildInfoRow(
                'Tempat, Tanggal Lahir',
                warga?['tempat_lahir'] != null &&
                        warga?['tanggal_lahir'] != null
                    ? '${warga!['tempat_lahir']}, ${DateTimeHelper.formatDate(DateTime.parse(warga['tanggal_lahir']), format: 'd MMMM yyyy')}'
                    : 'Bogor, 2 Juni 1990'),
            const Divider(),

            // Alamat Lengkap
            _buildInfoRow(
                'Alamat Lengkap',
                warga?['alamat'] ??
                    'Jl. Letda Natsir No. 22 RT 001/003\nKec. Gunung Putri Kab. Bogor'),
            const Divider(),

            // Pekerjaan
            _buildInfoRow('Pekerjaan', warga?['pekerjaan'] ?? 'Petani'),
            const Divider(),

            // Pendidikan Terakhir
            _buildInfoRow('Pendidikan Terakhir',
                warga?['pendidikan_terakhir'] ?? 'Sekolah Dasar (SD)'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBantuanSection() {
    // Tentukan satuan berdasarkan data yang tersedia
    String satuan = '';
    if (widget.bentukBantuan?.satuan != null) {
      satuan = widget.bentukBantuan!.satuan!;
    } else {
      // Default satuan jika tidak ada
      satuan = 'Kg';
    }

    String tanggalWaktuPenyaluran = '';
    if (widget.tanggalPenyaluran != null) {
      final tanggal = DateTimeHelper.formatDate(widget.tanggalPenyaluran!);
      final waktuMulai = DateTimeHelper.formatTime(widget.tanggalPenyaluran!);
      final waktuSelesai = DateTimeHelper.formatTime(
          widget.tanggalPenyaluran!.add(const Duration(hours: 1)));
      tanggalWaktuPenyaluran = '$tanggal $waktuMulai-$waktuSelesai';
    } else {
      tanggalWaktuPenyaluran = '09 April 2025 13:00-14:00';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Bantuan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Bentuk Bantuan
            _buildInfoRow(
                'Bentuk Bantuan', widget.bentukBantuan?.nama ?? 'Beras'),
            const Divider(),

            // Nilai Bantuan
            _buildInfoRow(
                'Nilai Bantuan', '${widget.jumlahBantuan ?? '5'}$satuan'),
            const Divider(),

            // Tanggal Penyaluran
            _buildInfoRow('Tanggal Penyaluran', tanggalWaktuPenyaluran),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoBuktiSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Foto Bukti Penerimaan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _ambilFoto,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _buktiPenerimaan != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _buktiPenerimaan!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambah Foto',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTandaTanganSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanda Tangan Digital Penerima',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Area tanda tangan
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _signatureImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _signatureImage!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Signature(
                      controller: _signatureController,
                      backgroundColor: Colors.white,
                      height: 200,
                      width: double.infinity,
                    ),
            ),

            const SizedBox(height: 12),

            // Tombol aksi untuk tanda tangan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol hapus tanda tangan
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _signatureController.clear();
                      _signatureImage = null;
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[800],
                  ),
                ),

                // Tombol simpan tanda tangan
                ElevatedButton.icon(
                  onPressed: _saveSignature,
                  icon: const Icon(Icons.check),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    foregroundColor: Colors.green[800],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPersetujuanSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Form Persetujuan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Checkbox persetujuan 1
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _setujuPenerimaan,
                    onChanged: (value) {
                      setState(() {
                        _setujuPenerimaan = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Saya telah menerima bantuan dengan jumlah dan kondisi yang sesuai.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Checkbox persetujuan 2
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _setujuPenggunaan,
                    onChanged: (value) {
                      setState(() {
                        _setujuPenggunaan = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Saya akan menggunakan bantuan dengan sebaik-baiknya',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKonfirmasiButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _setujuPenerimaan && _setujuPenggunaan
            ? _konfirmasiPenerimaan
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
        ),
        child: const Text(
          'Konfirmasi Penerimaan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ambilFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _buktiPenerimaan = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _saveSignature() async {
    if (_signatureController.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Tanda tangan tidak boleh kosong',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Mendapatkan data tanda tangan
    final signature = await _signatureController.toPngBytes();

    if (signature != null) {
      setState(() {
        _signatureImage = signature;
      });

      Get.snackbar(
        'Sukses',
        'Tanda tangan berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _konfirmasiPenerimaan() async {
    if (!_setujuPenerimaan || !_setujuPenggunaan) {
      Get.snackbar(
        'Perhatian',
        'Anda harus menyetujui semua persyaratan',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_signatureImage == null) {
      Get.snackbar(
        'Perhatian',
        'Tanda tangan digital diperlukan',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_buktiPenerimaan == null) {
      Get.snackbar(
        'Perhatian',
        'Foto bukti penerimaan diperlukan',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Directory? tempDir;
    File? signatureFile;

    try {
      String imageUrl;
      String signatureUrl;

      // Upload bukti penerimaan
      imageUrl = await controller.uploadBuktiPenerimaan(_buktiPenerimaan!.path);

      // Simpan tanda tangan ke file sementara dan upload
      tempDir = await Directory.systemTemp.createTemp('signature');
      signatureFile = File('${tempDir.path}/signature.png');
      await signatureFile.writeAsBytes(_signatureImage!);

      print('Signature file path: ${signatureFile.path}');
      print('Signature file exists: ${signatureFile.existsSync()}');
      print('Signature file size: ${signatureFile.lengthSync()} bytes');

      signatureUrl = await controller.uploadBuktiPenerimaan(
        signatureFile.path,
        isTandaTangan: true,
      );

      // Konfirmasi penerimaan
      await controller.konfirmasiPenerimaan(
        widget.penerima,
        buktiPenerimaan: imageUrl,
        tandaTangan: signatureUrl,
      );

      // Hapus file sementara sebelum navigasi
      try {
        if (signatureFile.existsSync()) {
          await signatureFile.delete();
        }
        if (tempDir.existsSync()) {
          await tempDir.delete();
        }
      } catch (e) {
        print('Error saat menghapus file sementara: $e');
      }

      // Tutup semua snackbar yang mungkin masih terbuka
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }

      // Kembali ke halaman sebelumnya dengan hasil true (berhasil)
      // Gunakan Get.back(result: true) untuk kembali ke halaman detail penyaluran
      // dengan membawa hasil bahwa konfirmasi berhasil
      Get.back(result: true);

      // Tampilkan snackbar sukses di halaman detail penyaluran
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Sukses',
          'Konfirmasi penerimaan bantuan berhasil',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      });
    } catch (e) {
      // Tampilkan pesan error
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // Hapus file sementara jika belum dihapus
      try {
        if (signatureFile != null && signatureFile.existsSync()) {
          await signatureFile.delete();
        }
        if (tempDir != null && tempDir.existsSync()) {
          await tempDir.delete();
        }
      } catch (e) {
        print('Error saat menghapus file sementara: $e');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}
