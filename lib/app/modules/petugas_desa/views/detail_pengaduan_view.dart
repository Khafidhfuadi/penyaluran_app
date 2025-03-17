import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/tindakan_pengaduan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/pengaduan_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/widgets/cards/info_card.dart';
import 'package:penyaluran_app/app/widgets/indicators/status_pill.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:penyaluran_app/app/widgets/inputs/dropdown_input.dart';
import 'package:penyaluran_app/app/widgets/inputs/text_input.dart';

class DetailPengaduanView extends GetView<PengaduanController> {
  const DetailPengaduanView({Key? key}) : super(key: key);

  // Definisi konstanta warna status untuk konsistensi
  static const Color statusMenungguColor = Colors.orange;
  static const Color statusTindakanColor = Colors.blue;
  static const Color statusSelesaiColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String pengaduanId = args['id'] ?? '';

    if (pengaduanId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Pengaduan'),
        ),
        body: const Center(
          child: Text('ID Pengaduan tidak valid'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengaduan'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Panduan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStatusGuide(context),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: controller.getDetailPengaduan(pengaduanId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data;
          if (data == null || data['pengaduan'] == null) {
            return const Center(
              child: Text('Data pengaduan tidak ditemukan'),
            );
          }

          final pengaduan = PengaduanModel.fromJson(data['pengaduan']);
          final List<TindakanPengaduanModel> tindakanList =
              (data['tindakan'] as List)
                  .map((item) => TindakanPengaduanModel.fromJson(item))
                  .toList();

          return _buildDetailContent(context, pengaduan, tindakanList);
        },
      ),
      floatingActionButton: FutureBuilder<Map<String, dynamic>>(
        future: controller.getDetailPengaduan(pengaduanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          final data = snapshot.data;
          if (data == null || data['pengaduan'] == null)
            return const SizedBox();

          final pengaduan = PengaduanModel.fromJson(data['pengaduan']);

          if (pengaduan.status?.toUpperCase() == 'SELESAI') {
            return const SizedBox();
          }

          return FloatingActionButton(
            onPressed: () {
              _showTambahTindakanDialog(context, pengaduanId);
            },
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    PengaduanModel pengaduan,
    List<TindakanPengaduanModel> tindakanList,
  ) {
    // Tentukan status dan warna
    Color statusColor;
    String statusText;

    switch (pengaduan.status?.toUpperCase()) {
      case 'MENUNGGU':
        statusColor = statusMenungguColor;
        statusText = 'Menunggu';
        break;
      case 'TINDAKAN':
        statusColor = statusTindakanColor;
        statusText = 'Tindakan';
        break;
      case 'SELESAI':
        statusColor = statusSelesaiColor;
        statusText = 'Selesai';
        break;
      default:
        statusColor = Colors.grey;
        statusText = pengaduan.status ?? 'Tidak Diketahui';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan status
          _buildHeaderWithStatus(context, pengaduan, statusColor, statusText),

          const SizedBox(height: 24),

          // Informasi pengaduan
          _buildPengaduanInfo(context, pengaduan),

          const SizedBox(height: 24),

          // Informasi penyaluran yang diadukan
          if (pengaduan.penerimaPenyaluran != null)
            _buildPenyaluranInfo(context, pengaduan),

          const SizedBox(height: 24),

          // Feedback warga jika status SELESAI
          if (pengaduan.status?.toUpperCase() == 'SELESAI' &&
              (pengaduan.feedbackWarga != null ||
                  pengaduan.ratingWarga != null))
            _buildFeedbackSection(context, pengaduan),

          const SizedBox(height: 24),

          // Timeline tindakan
          _buildTindakanTimeline(context, tindakanList),
        ],
      ),
    );
  }

  Widget _buildStatusGuide(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Alur Status Pengaduan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildStatusGuideItem(
                'MENUNGGU',
                'Pengaduan baru yang belum ditindaklanjuti',
                statusMenungguColor,
                Icons.hourglass_empty,
              ),
              const SizedBox(height: 8),
              _buildStatusGuideItem(
                'TINDAKAN',
                'Pengaduan sedang dalam proses penanganan',
                statusTindakanColor,
                Icons.engineering,
              ),
              const SizedBox(height: 8),
              _buildStatusGuideItem(
                'SELESAI',
                'Pengaduan telah selesai ditangani',
                statusSelesaiColor,
                Icons.check_circle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Status Tindakan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildTindakanStatusItem(
              'PROSES',
              'Dalam Proses',
              'Tindakan sedang dilakukan',
              statusTindakanColor,
              Icons.sync,
            ),
            const SizedBox(height: 8),
            _buildTindakanStatusItem(
              'SELESAI',
              'Selesai',
              'Tindakan telah selesai',
              statusSelesaiColor,
              Icons.check_circle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusGuideItem(
    String status,
    String description,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menggunakan StatusPill untuk status
              StatusPill(
                status: status,
                backgroundColor: color,
                textColor: Colors.white,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTindakanStatusItem(
    String status,
    String label,
    String description,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              // Menggunakan StatusPill untuk status tindakan
              StatusPill(
                status: label,
                backgroundColor: color,
                textColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithStatus(
    BuildContext context,
    PengaduanModel pengaduan,
    Color statusColor,
    String statusText,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pengaduan.judul ?? 'Pengaduan',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Menggunakan StatusPill untuk menampilkan status
                _getStatusPill(pengaduan.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              pengaduan.deskripsi ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  pengaduan.tanggalPengaduan != null
                      ? DateFormat('dd MMMM yyyy', 'id_ID')
                          .format(pengaduan.tanggalPengaduan!)
                      : '-',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Panel status pengaduan
            _buildStatusPanel(context, pengaduan),

            // Tampilkan feedback dan rating warga jika ada
            if (pengaduan.status?.toUpperCase() == 'SELESAI' &&
                (pengaduan.feedbackWarga != null ||
                    pengaduan.ratingWarga != null))
              Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Feedback Warga',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.amber,
                              ),
                            ),
                            if (pengaduan.ratingWarga != null)
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < (pengaduan.ratingWarga ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (pengaduan.feedbackWarga != null &&
                            pengaduan.feedbackWarga!.isNotEmpty)
                          Text(
                            pengaduan.feedbackWarga!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber.shade900,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Text(
                            'Warga belum memberikan komentar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk mendapatkan StatusPill berdasarkan status
  StatusPill _getStatusPill(String? status) {
    switch (status?.toUpperCase()) {
      case 'MENUNGGU':
        return StatusPill(
          status: 'Menunggu',
          backgroundColor: statusMenungguColor,
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
      case 'TINDAKAN':
        return StatusPill(
          status: 'Tindakan',
          backgroundColor: statusTindakanColor,
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
      case 'SELESAI':
        return StatusPill(
          status: 'Selesai',
          backgroundColor: statusSelesaiColor,
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
      default:
        return StatusPill(
          status: status ?? 'Tidak Diketahui',
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
    }
  }

  Widget _buildStatusPanel(BuildContext context, PengaduanModel pengaduan) {
    final status = pengaduan.status?.toUpperCase() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Pengaduan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              // Tambahkan tombol untuk mengubah status
              if (status != 'SELESAI')
                TextButton.icon(
                  onPressed: () {
                    _showUbahStatusDialog(context, pengaduan);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Ubah Status'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusStep(
                  'MENUNGGU',
                  'Menunggu',
                  status == 'MENUNGGU',
                  status == 'MENUNGGU' ||
                      status == 'TINDAKAN' ||
                      status == 'SELESAI',
                  statusMenungguColor,
                ),
              ),
              Expanded(
                child: _buildStatusStep(
                  'TINDAKAN',
                  'Tindakan',
                  status == 'TINDAKAN',
                  status == 'TINDAKAN' || status == 'SELESAI',
                  statusTindakanColor,
                ),
              ),
              Expanded(
                child: _buildStatusStep(
                  'SELESAI',
                  'Selesai',
                  status == 'SELESAI',
                  status == 'SELESAI',
                  statusSelesaiColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tombol aksi berdasarkan status
          if (status == 'MENUNGGU')
            ElevatedButton.icon(
              onPressed: () {
                _showTambahTindakanDialog(context, pengaduan.id!);
              },
              icon: const Icon(Icons.engineering),
              label: const Text('Tambah Tindakan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusTindakanColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
            )
          else if (status == 'TINDAKAN')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showTambahTindakanDialog(context, pengaduan.id!);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Tindakan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusTindakanColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showKonfirmasiSelesai(context, pengaduan.id!);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Selesaikan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusSelesaiColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else if (status == 'SELESAI')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusSelesaiColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusSelesaiColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: statusSelesaiColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pengaduan telah selesai ditangani',
                      style: TextStyle(
                        color: statusSelesaiColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(
    String statusValue,
    String label,
    bool isActive,
    bool isCompleted,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive
                ? color
                : (isCompleted ? color.withOpacity(0.3) : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    (statusValue == 'MENUNGGU'
                        ? '1'
                        : (statusValue == 'TINDAKAN' ? '2' : '3')),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? color : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showKonfirmasiSelesai(BuildContext context, String pengaduanId) async {
    // Cek status tindakan
    bool allTindakanSelesai = true;

    try {
      // Cek status tindakan dari Supabase
      final tindakanList =
          await SupabaseService.to.getTindakanPengaduan(pengaduanId);

      if (tindakanList != null) {
        allTindakanSelesai = tindakanList.every((t) {
          return t['status_tindakan'] == 'SELESAI';
        });
      }

      if (!allTindakanSelesai) {
        Get.snackbar(
          'Peringatan',
          'Semua tindakan harus diselesaikan terlebih dahulu sebelum menyelesaikan pengaduan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin menyelesaikan pengaduan ini? Status pengaduan akan berubah menjadi SELESAI.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await controller.selesaikanPengaduan(pengaduanId);
                  Navigator.pop(context);
                  Get.forceAppUpdate();
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Gagal menyelesaikan pengaduan: $e',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Ya, Selesaikan'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memeriksa status tindakan: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildPengaduanInfo(BuildContext context, PengaduanModel pengaduan) {
    final warga = pengaduan.warga;
    final String namaWarga = warga != null
        ? warga['nama_lengkap'] ?? 'Tidak diketahui'
        : 'Tidak diketahui';
    final String nikWarga = warga != null ? warga['nik'] ?? '-' : '-';
    final String alamatWarga = warga != null ? warga['alamat'] ?? '-' : '-';
    final String noHpWarga = warga != null ? warga['no_hp'] ?? '-' : '-';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Informasi Pelapor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            const Divider(height: 24),

            // Informasi pelapor
            _buildInfoRow('Nama', namaWarga),
            _buildInfoRow('NIK', nikWarga),
            _buildInfoRow('Alamat', alamatWarga),
            _buildInfoRow('No. HP', noHpWarga),
          ],
        ),
      ),
    );
  }

  Widget _buildPenyaluranInfo(BuildContext context, PengaduanModel pengaduan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Informasi Penyaluran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Icon(
                  Icons.inventory,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            const Divider(height: 24),

            // Informasi penyaluran
            _buildInfoRow('Nama Penyaluran', pengaduan.namaPenyaluran),
            _buildInfoRow('Stok Bantuan', pengaduan.stokBantuan!['nama']),
            _buildInfoRow('Jumlah Bantuan',
                '${pengaduan.jumlahBantuan} ${pengaduan.stokBantuan!['satuan']}'),
            _buildInfoRow('Deskripsi', pengaduan.deskripsiPenyaluran),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTindakanTimeline(
    BuildContext context,
    List<TindakanPengaduanModel> tindakanList,
  ) {
    if (tindakanList.isEmpty) {
      return InfoCard(
        title: 'Belum Ada Tindakan',
        description: 'Belum ada tindakan untuk pengaduan ini',
        icon: Icons.info_outline,
        backgroundColor: Colors.grey.shade50,
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menggunakan SectionHeader untuk judul
            SectionHeader(
              title: 'Riwayat Tindakan',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tindakanList.length,
              itemBuilder: (context, index) {
                final tindakan = tindakanList[index];
                final bool isFirst = index == 0;
                final bool isLast = index == tindakanList.length - 1;

                return _buildTimelineTile(
                  context,
                  tindakan,
                  isFirst,
                  isLast,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile(
    BuildContext context,
    TindakanPengaduanModel tindakan,
    bool isFirst,
    bool isLast,
  ) {
    Color dotColor;
    switch (tindakan.statusTindakan) {
      case 'SELESAI':
        dotColor = statusSelesaiColor;
        break;
      case 'PROSES':
        dotColor = statusTindakanColor;
        break;
      default:
        dotColor = Colors.grey;
    }

    return TimelineTile(
      alignment: TimelineAlign.start,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 20,
        color: dotColor,
        iconStyle: IconStyle(
          color: Colors.white,
          iconData:
              tindakan.statusTindakan == 'SELESAI' ? Icons.check : Icons.sync,
        ),
      ),
      endChild: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan kategori dan status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tindakan.kategoriTindakanText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  children: [
                    // Menggunakan StatusPill untuk status tindakan
                    StatusPill(
                      status: tindakan.statusTindakanText,
                      backgroundColor: dotColor,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Deskripsi tindakan
            Text(
              tindakan.tindakan ?? '',
              style: const TextStyle(fontSize: 14),
            ),

            // Catatan tindakan (jika ada)
            if (tindakan.catatan != null && tindakan.catatan!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Catatan: ${tindakan.catatan}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Hasil tindakan (jika ada)
            if (tindakan.hasilTindakan != null &&
                tindakan.hasilTindakan!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hasil Tindakan:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tindakan.hasilTindakan!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Bukti tindakan (jika ada)
            if (tindakan.buktiTindakan != null &&
                tindakan.buktiTindakan!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bukti Tindakan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tindakan.buktiTindakan!.map((bukti) {
                        return GestureDetector(
                          onTap: () => showFullScreenImage(context, bukti),
                          child: Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: bukti.startsWith('http')
                                    ? NetworkImage(bukti)
                                    : FileImage(File(bukti)) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            // Footer dengan info petugas dan tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Oleh: ${tindakan.namaPetugas}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  tindakan.tanggalTindakan != null
                      ? DateFormat('dd MMM yyyy HH:mm', 'id_ID')
                          .format(tindakan.tanggalTindakan!)
                      : '-',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // Prioritas tindakan (jika ada)
            if (tindakan.prioritas != null) ...[
              const SizedBox(height: 8),
              // Menggunakan StatusPill untuk prioritas tindakan
              StatusPill(
                status: tindakan.prioritasText,
                backgroundColor: _getPriorityColor(tindakan.prioritas),
                textColor: Colors.white,
              ),
            ],
            // Tampilkan tombol edit jika status PROSES
            if (tindakan.statusTindakan == 'PROSES') ...[
              const SizedBox(height: 8),
              //divider
              Divider(
                color: Colors.grey.shade400,
                thickness: 1,
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue),
                  ),
                  minimumSize: Size(double.infinity, 36),
                ),
                onPressed: () {
                  _showEditTindakanDialog(context, tindakan);
                },
                icon: Icon(
                  Icons.update,
                  size: 18,
                  color: Colors.blue,
                ),
                label: Text(
                  'Input Hasil Tindakan',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'TINGGI':
        return Colors.red;
      case 'SEDANG':
        return Colors.orange;
      case 'RENDAH':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showTambahTindakanDialog(BuildContext context, String pengaduanId) {
    final formKey = GlobalKey<FormState>();
    final tindakanController = TextEditingController();
    String? selectedKategori;
    String? selectedPrioritas;
    String selectedStatus = 'PROSES';

    final List<String> kategoriOptions = [
      'VERIFIKASI_DATA',
      'KUNJUNGAN_LAPANGAN',
      'KOORDINASI_LINTAS_INSTANSI',
      'PERBAIKAN_DATA_PENERIMA',
      'PENYALURAN_ULANG',
      'PENGGANTIAN_BANTUAN',
      'MEDIASI',
      'KLARIFIKASI',
      'PENYESUAIAN_JUMLAH_BANTUAN',
      'PEMERIKSAAN_KUALITAS_BANTUAN',
      'PERBAIKAN_PROSES_DISTRIBUSI',
      'EDUKASI_PENERIMA',
      'PENYELESAIAN_ADMINISTRATIF',
      'INVESTIGASI_PENYALAHGUNAAN',
      'PELAPORAN_KE_PIHAK_BERWENANG',
    ];

    final List<String> prioritasOptions = [
      'RENDAH',
      'SEDANG',
      'TINGGI',
    ];

    // Konversi ke format DropdownItem
    final List<DropdownItem<String>> kategoriItems = kategoriOptions
        .map((kategori) => DropdownItem<String>(
              value: kategori,
              label: kategori.replaceAll('_', ' '),
            ))
        .toList();

    // Konversi ke format DropdownItem untuk prioritas
    final List<DropdownItem<String>> prioritasItems = prioritasOptions
        .map((prioritas) => DropdownItem<String>(
              value: prioritas,
              label: prioritas[0].toUpperCase() +
                  prioritas.substring(1).toLowerCase(),
            ))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tindakan Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori tindakan menggunakan DropdownInput
                DropdownInput<String>(
                  label: 'Kategori Tindakan',
                  hint: 'Pilih kategori tindakan',
                  items: kategoriItems,
                  value: selectedKategori,
                  onChanged: (value) {
                    selectedKategori = value;
                  },
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih kategori tindakan';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Prioritas menggunakan DropdownInput
                DropdownInput<String>(
                  label: 'Prioritas',
                  hint: 'Pilih prioritas tindakan',
                  items: prioritasItems,
                  value: selectedPrioritas,
                  onChanged: (value) {
                    selectedPrioritas = value;
                  },
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih prioritas tindakan';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Deskripsi tindakan menggunakan TextInput
                TextInput(
                  label: 'Deskripsi Tindakan',
                  hint: 'Masukkan deskripsi tindakan',
                  controller: tindakanController,
                  maxLines: 2,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tindakan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: controller.isUploading.value
                ? null
                : () {
                    if (formKey.currentState!.validate()) {
                      controller.tambahTindakanPengaduan(
                        pengaduanId: pengaduanId,
                        tindakan: tindakanController.text,
                        kategoriTindakan: selectedKategori ?? '',
                        statusTindakan: selectedStatus,
                        prioritas: selectedPrioritas ?? '',
                        catatan: null,
                        hasilTindakan: null,
                        buktiTindakanPaths: [],
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: controller.isUploading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditTindakanDialog(
      BuildContext context, TindakanPengaduanModel tindakan) {
    final formKey = GlobalKey<FormState>();
    final catatanController = TextEditingController(text: tindakan.catatan);
    final hasilTindakanController =
        TextEditingController(text: tindakan.hasilTindakan);
    String? selectedKategori = tindakan.kategoriTindakan;
    String? selectedPrioritas = tindakan.prioritas;
    String selectedStatus = 'SELESAI';

    // Gunakan List untuk bukti tindakan paths
    final List<String> buktiTindakanPaths = tindakan.buktiTindakan != null
        ? List<String>.from(tindakan.buktiTindakan!)
        : [];

    // Fungsi untuk memilih bukti tindakan
    Future<void> pickBuktiTindakan(
        BuildContext dialogContext, bool fromCamera) async {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 80,
          maxWidth: 1200,
          maxHeight: 1200,
          preferredCameraDevice:
              fromCamera ? CameraDevice.rear : CameraDevice.front,
        );

        if (pickedFile != null) {
          // Tampilkan loading dialog
          showDialog(
            context: dialogContext,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );

          try {
            // Tambahkan gambar ke daftar
            buktiTindakanPaths.add(pickedFile.path);

            // Tutup loading dialog
            Navigator.of(dialogContext, rootNavigator: true).pop();

            // Tutup dialog pilih sumber foto
            Navigator.of(dialogContext).pop();
          } catch (e) {
            // Tutup loading dialog jika terjadi error
            Navigator.of(dialogContext, rootNavigator: true).pop();
            throw e;
          }
        }
      } catch (e) {
        print('Error picking image: $e');
        Get.snackbar(
          'Error',
          'Gagal mengambil gambar: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    // Fungsi untuk menampilkan dialog pilih sumber foto
    void showPilihSumberFoto(BuildContext dialogContext) {
      showDialog(
        context: dialogContext,
        builder: (innerContext) => AlertDialog(
          title: const Text('Pilih Sumber Foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () => pickBuktiTindakan(innerContext, true),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () => pickBuktiTindakan(innerContext, false),
              ),
            ],
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(builder: (stateContext, setState) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.update,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Input Hasil Tindakan'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade800,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informasi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dengan mengirimkan form ini, status tindakan akan berubah menjadi SELESAI dan tidak dapat diubah kembali.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextInput(
                    label: 'Hasil Tindakan',
                    hint: 'Jelaskan hasil dari tindakan yang dilakukan',
                    controller: hasilTindakanController,
                    maxLines: 3,
                    required: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hasil tindakan wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextInput(
                    label: 'Catatan',
                    hint: 'Tambahkan catatan jika diperlukan',
                    controller: catatanController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  // Bukti tindakan - wajib
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Bukti Tindakan',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (buktiTindakanPaths.isEmpty)
                              InkWell(
                                onTap: () => showPilihSumberFoto(stateContext),
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 48,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tambah Bukti Tindakan',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: buktiTindakanPaths
                                          .length, //tombol tambah jika tidak selesai
                                      itemBuilder: (context, index) {
                                        if (index ==
                                            buktiTindakanPaths.length) {
                                          // Tombol tambah foto
                                          return InkWell(
                                            onTap: () => showPilihSumberFoto(
                                                stateContext),
                                            child: Container(
                                              width: 100,
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade400),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_photo_alternate,
                                                    size: 32,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Tambah',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        // Tampilkan foto yang sudah diambil
                                        return Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () => showFullScreenImage(
                                                  stateContext,
                                                  buktiTindakanPaths[index]),
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                margin: const EdgeInsets.only(
                                                    right: 8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                    image: buktiTindakanPaths[
                                                                index]
                                                            .startsWith('http')
                                                        ? NetworkImage(
                                                            buktiTindakanPaths[
                                                                index])
                                                        : FileImage(File(
                                                                buktiTindakanPaths[
                                                                    index]))
                                                            as ImageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 12,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    buktiTindakanPaths
                                                        .removeAt(index);
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: controller.isUploading.value
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        // Validasi bukti tindakan
                        if (buktiTindakanPaths.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Bukti tindakan wajib diisi',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        try {
                          Navigator.pop(dialogContext); // Tutup dialog form

                          // Tampilkan loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );

                          // Panggil fungsi update tindakan dengan upload file
                          await controller.updateTindakanPengaduan(
                            tindakanId: tindakan.id!,
                            pengaduanId: tindakan.pengaduanId!,
                            tindakan: tindakan
                                .tindakan!, // Gunakan tindakan yang sudah ada
                            kategoriTindakan: selectedKategori ??
                                '', // Gunakan kategori yang sudah ada
                            statusTindakan: selectedStatus,
                            prioritas: selectedPrioritas ??
                                '', // Gunakan prioritas yang sudah ada
                            catatan: catatanController.text.isEmpty
                                ? null
                                : catatanController.text,
                            hasilTindakan: hasilTindakanController.text.isEmpty
                                ? null
                                : hasilTindakanController.text,
                            buktiTindakanPaths: buktiTindakanPaths,
                          );
                        } catch (e) {
                          // Tutup loading dialog jika terjadi error
                          Navigator.of(context, rootNavigator: true).pop();

                          print('Error updating tindakan: $e');
                          Get.snackbar(
                            'Error',
                            'Gagal memperbarui tindakan: ${e.toString()}',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: controller.isUploading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan Perubahan'),
            ),
          ],
        );
      }),
    );
  }

  void _showUbahStatusDialog(BuildContext context, PengaduanModel pengaduan) {
    final String currentStatus = pengaduan.status?.toUpperCase() ?? '';
    String selectedStatus = currentStatus;

    final List<String> statusOptions = [
      'MENUNGGU',
      'TINDAKAN',
      'SELESAI',
    ];

    // Hapus status yang sama dengan status saat ini dari opsi
    statusOptions.remove(currentStatus);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Status Pengaduan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status saat ini:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _getStatusPill(currentStatus),
            const SizedBox(height: 16),
            const Text(
              'Pilih status baru:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: statusOptions.map((status) {
                return RadioListTile<String>(
                  title: Text(
                    status == 'MENUNGGU'
                        ? 'Menunggu'
                        : (status == 'TINDAKAN' ? 'Tindakan' : 'Selesai'),
                  ),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    selectedStatus = value!;
                    Navigator.pop(context);
                    _showKonfirmasiUbahStatus(
                        context, pengaduan.id!, selectedStatus);
                  },
                  activeColor: status == 'MENUNGGU'
                      ? Colors.orange
                      : (status == 'TINDAKAN' ? Colors.blue : Colors.green),
                  secondary: Icon(
                    status == 'MENUNGGU'
                        ? Icons.hourglass_empty
                        : (status == 'TINDAKAN'
                            ? Icons.engineering
                            : Icons.check_circle),
                    color: status == 'MENUNGGU'
                        ? Colors.orange
                        : (status == 'TINDAKAN' ? Colors.blue : Colors.green),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showKonfirmasiUbahStatus(
      BuildContext context, String pengaduanId, String newStatus) {
    String statusText = newStatus == 'MENUNGGU'
        ? 'Menunggu'
        : (newStatus == 'TINDAKAN' ? 'Tindakan' : 'Selesai');

    Color statusColor = newStatus == 'MENUNGGU'
        ? statusMenungguColor
        : (newStatus == 'TINDAKAN' ? statusTindakanColor : statusSelesaiColor);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin mengubah status pengaduan menjadi "$statusText"?',
            ),
            const SizedBox(height: 16),
            if (newStatus == 'SELESAI')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.amber.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mengubah status menjadi Selesai akan menandai pengaduan ini telah selesai ditangani.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newStatus == 'SELESAI') {
                await controller.selesaikanPengaduan(pengaduanId);
              } else {
                // Gunakan fungsi prosesPengaduan untuk status TINDAKAN
                // atau fungsi khusus untuk status lainnya
                if (newStatus == 'TINDAKAN') {
                  await controller.prosesPengaduan(pengaduanId);
                } else {
                  // Tambahkan fungsi updateStatusPengaduan di controller
                  await controller.updateStatusPengaduan(
                      pengaduanId, newStatus);
                }
              }

              Navigator.pop(context);
              Get.forceAppUpdate();

              Get.snackbar(
                'Berhasil',
                'Status pengaduan berhasil diubah menjadi $statusText',
                snackPosition: SnackPosition.TOP,
                backgroundColor: statusColor,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: statusColor,
            ),
            child: const Text('Ya, Ubah Status'),
          ),
        ],
      ),
    );
  }

  void showFullScreenImage(BuildContext context, String imageUrl) {
    // Buat controller untuk InteractiveViewer
    final TransformationController transformationController =
        TransformationController();

    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              transformationController: transformationController,
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(
                              Icons.error,
                              size: 50,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    )
                  : Image.file(
                      File(imageUrl),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(
                              Icons.error,
                              size: 50,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Zoom in
                      final Matrix4 matrix =
                          transformationController.value.clone();
                      matrix.scale(1.5);
                      transformationController.value = matrix;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // Zoom out
                      final Matrix4 matrix =
                          transformationController.value.clone();
                      matrix.scale(0.75);
                      transformationController.value = matrix;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.zoom_out,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan feedback dan rating warga
  Widget _buildFeedbackSection(BuildContext context, PengaduanModel pengaduan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feedback Warga',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const Divider(height: 24),
            if (pengaduan.ratingWarga != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Text(
                      'Rating: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (pengaduan.ratingWarga ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            if (pengaduan.feedbackWarga != null &&
                pengaduan.feedbackWarga!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Text(
                  pengaduan.feedbackWarga!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.amber.shade900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Text(
                'Warga belum memberikan komentar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
