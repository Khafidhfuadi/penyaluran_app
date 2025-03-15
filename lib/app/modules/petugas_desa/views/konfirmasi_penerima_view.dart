import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/pelaksanaan_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class KonfirmasiPenerimaView extends GetView<PelaksanaanPenyaluranController> {
  const KonfirmasiPenerimaView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data dari arguments
    final Map<String, dynamic> args = Get.arguments ?? {};

    // Pastikan semua parameter yang diperlukan tersedia
    final penerimaId = args['penerima_id'] ?? 0;
    final String penyaluranId = args['penyaluran_id']?.toString() ?? '';
    final Map<String, dynamic> warga =
        args['warga'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> jadwal =
        args['jadwal'] as Map<String, dynamic>? ?? {};
    final String statusPenerimaan =
        args['status_penerimaan']?.toString() ?? 'BELUMMENERIMA';
    final dynamic jumlahBantuan = args['jumlah_bantuan'] ?? 1;

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Konfirmasi Penerima'),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Konfirmasi Penerima'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header dengan foto dan nama
              _buildHeader(warga),

              // Detail informasi penerima
              _buildDetailInfo(warga),

              // Detail jadwal dan bantuan
              _buildDetailJadwalBantuan(jadwal, jumlahBantuan),

              // Form konfirmasi
              _buildKonfirmasiForm(context, penerimaId, penyaluranId),

              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar:
            _buildBottomButtons(penerimaId, penyaluranId, statusPenerimaan),
      );
    });
  }

  Widget _buildHeader(Map<String, dynamic> warga) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        children: [
          // Foto profil
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: warga['foto_url'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      warga['foto_url'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.primaryColor,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
          ),
          const SizedBox(height: 12),
          // Nama penerima
          Text(
            warga['nama'] ?? 'Nama tidak tersedia',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // NIK
          Text(
            warga['nik'] ?? 'NIK tidak tersedia',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Badge status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: controller.getStatusColor(
                  warga['status_penerimaan'] ?? 'BELUMMENERIMA'),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  controller.getStatusIcon(
                      warga['status_penerimaan'] ?? 'BELUMMENERIMA'),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  controller.getStatusText(
                      warga['status_penerimaan'] ?? 'BELUMMENERIMA'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInfo(Map<String, dynamic> warga) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Penerima',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('NIK', warga['nik'] ?? '-'),
                  _buildDetailRow('No KK', warga['no_kk'] ?? '-'),
                  _buildDetailRow('No Handphone', warga['no_hp'] ?? '-'),
                  _buildDetailRow('Email', warga['email'] ?? '-'),
                  _buildDetailRow(
                      'Jenis Kelamin', warga['jenis_kelamin'] ?? '-'),
                  _buildDetailRow('Agama', warga['agama'] ?? '-'),
                  _buildDetailRow('Tempat, Tanggal Lahir',
                      '${warga['tempat_lahir'] ?? '-'}, ${warga['tanggal_lahir'] ?? '-'}'),
                  _buildDetailRow('Alamat Lengkap', warga['alamat'] ?? '-'),
                  _buildDetailRow('Pekerjaan', warga['pekerjaan'] ?? '-'),
                  _buildDetailRow(
                      'Pendidikan Terakhir', warga['pendidikan'] ?? '-'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailJadwalBantuan(
      Map<String, dynamic> jadwal, dynamic jumlahBantuan) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Jadwal & Bantuan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(
                      'Tanggal Penyaluran', jadwal['tanggal'] ?? '-'),
                  _buildDetailRow('Waktu', jadwal['waktu'] ?? '-'),
                  _buildDetailRow('Lokasi', jadwal['lokasi'] ?? '-'),
                  _buildDetailRow(
                      'Jenis Bantuan', jadwal['jenis_bantuan'] ?? '-'),
                  _buildDetailRow('Jumlah Bantuan', '$jumlahBantuan item'),
                  _buildDetailRow('Keterangan', jadwal['keterangan'] ?? '-'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKonfirmasiForm(
      BuildContext context, int penerimaId, String penyaluranId) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konfirmasi Penyaluran Bantuan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status penyaluran
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.infoColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: AppTheme.infoColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Pastikan penerima hadir dan menerima bantuan sesuai dengan ketentuan.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.infoColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Checkbox persetujuan petugas
                  const Text(
                    'Persetujuan Petugas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Checkbox 1
                  Row(
                    children: [
                      Obx(() => Checkbox(
                            value: controller.isKonfirmasiChecked.value,
                            onChanged: (value) {
                              controller.isKonfirmasiChecked.value =
                                  value ?? false;
                            },
                            activeColor: AppTheme.primaryColor,
                          )),
                      const Expanded(
                        child: Text(
                          'Saya konfirmasi bahwa penerima ini telah hadir dan menerima bantuan sesuai dengan ketentuan',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  // Checkbox 2
                  Row(
                    children: [
                      Obx(() => Checkbox(
                            value: controller.isIdentitasChecked.value,
                            onChanged: (value) {
                              controller.isIdentitasChecked.value =
                                  value ?? false;
                            },
                            activeColor: AppTheme.primaryColor,
                          )),
                      const Expanded(
                        child: Text(
                          'Saya telah memverifikasi identitas penerima sesuai dengan KTP/KK yang ditunjukkan',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  // Checkbox 3
                  Row(
                    children: [
                      Obx(() => Checkbox(
                            value: controller.isDataValidChecked.value,
                            onChanged: (value) {
                              controller.isDataValidChecked.value =
                                  value ?? false;
                            },
                            activeColor: AppTheme.primaryColor,
                          )),
                      const Expanded(
                        child: Text(
                          'Saya menyatakan bahwa data yang diinput adalah benar dan dapat dipertanggungjawabkan',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Form bukti foto
                  const Text(
                    'Bukti Foto Penyaluran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => controller.pilihFotoBukti(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Obx(() => controller.fotoBuktiPath.value.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.camera_alt,
                                  color: AppTheme.primaryColor,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tambahkan Foto Bukti',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Format: JPG, PNG (Maks. 5MB)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            )
                          : Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    controller.fotoBuktiPath.value,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: () => controller.hapusFotoBukti(),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tanda tangan digital penerima
                  const Text(
                    'Tanda Tangan Digital Penerima',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => controller.bukaSignaturePad(context),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Obx(() => controller.tandaTanganPath.value.isEmpty
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.draw,
                                  color: AppTheme.primaryColor,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap untuk menambahkan tanda tangan',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    controller.tandaTanganPath.value,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        width: double.infinity,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: () => controller.hapusTandaTangan(),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Form catatan
                  const Text(
                    'Catatan Penyaluran (Opsional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.catatanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Masukkan catatan penyaluran jika ada',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(
      int penerimaId, String penyaluranId, String statusPenerimaan) {
    final bool sudahDiterima = statusPenerimaan == 'SUDAHMENERIMA';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              child: const Text('Kembali'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() => ElevatedButton(
                  onPressed: sudahDiterima
                      ? null
                      : (controller.isKonfirmasiChecked.value &&
                              controller.isIdentitasChecked.value &&
                              controller.isDataValidChecked.value &&
                              controller.fotoBuktiPath.value.isNotEmpty &&
                              controller.tandaTanganPath.value.isNotEmpty
                          ? () => controller.konfirmasiPenyaluran(
                              penerimaId, penyaluranId)
                          : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child:
                      Text(sudahDiterima ? 'Sudah Dikonfirmasi' : 'Konfirmasi'),
                )),
          ),
        ],
      ),
    );
  }
}
