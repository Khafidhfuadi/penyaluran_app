import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/bentuk_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/penyaluran/detail_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class KonfirmasiPenerimaPage extends StatefulWidget {
  final PenerimaPenyaluranModel penerima;
  final BentukBantuanModel? bentukBantuan;
  final String? jumlahBantuan;
  final DateTime? tanggalPenyaluran;

  const KonfirmasiPenerimaPage({
    Key? key,
    required this.penerima,
    this.bentukBantuan,
    this.jumlahBantuan,
    this.tanggalPenyaluran,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final warga = widget.penerima.warga;
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Konfirmasi Penerimaan Bantuan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                    ? '${warga!['tempat_lahir']}, ${DateFormat('d MMMM yyyy').format(DateTime.parse(warga['tanggal_lahir']))}'
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
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');

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
      final tanggal = dateFormat.format(widget.tanggalPenyaluran!);
      final waktuMulai = timeFormat.format(widget.tanggalPenyaluran!);
      final waktuSelesai = timeFormat
          .format(widget.tanggalPenyaluran!.add(const Duration(hours: 1)));
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
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tanda Tangan Digital',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/signature_placeholder.png',
                    height: 50,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://i.imgur.com/JMoZ0nR.png',
                        height: 50,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ],
              ),
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

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;

      if (_buktiPenerimaan != null) {
        // Upload bukti penerimaan
        imageUrl =
            await controller.uploadBuktiPenerimaan(_buktiPenerimaan!.path);
      }

      // Konfirmasi penerimaan
      await controller.konfirmasiPenerimaan(
        widget.penerima,
        buktiPenerimaan: imageUrl,
      );

      Get.back(result: true);

      Get.snackbar(
        'Sukses',
        'Konfirmasi penerimaan bantuan berhasil',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
