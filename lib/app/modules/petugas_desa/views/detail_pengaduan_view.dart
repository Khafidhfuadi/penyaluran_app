import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/tindakan_pengaduan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/pengaduan_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:penyaluran_app/app/widgets/widgets.dart';

class DetailPengaduanView extends GetView<PengaduanController> {
  const DetailPengaduanView({super.key});

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
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.getDetailPengaduan(pengaduanId);
        },
        color: AppTheme.primaryColor,
        child: FutureBuilder<Map<String, dynamic>>(
          future: controller.getDetailPengaduan(pengaduanId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.getDetailPengaduan(pengaduanId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data;
            if (data == null || data['pengaduan'] == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Data pengaduan tidak ditemukan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pengaduan mungkin telah dihapus atau tidak tersedia',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
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
      ),
      floatingActionButton: FutureBuilder<Map<String, dynamic>>(
        future: controller.getDetailPengaduan(pengaduanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          final data = snapshot.data;
          if (data == null || data['pengaduan'] == null) {
            return const SizedBox();
          }

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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey.shade50],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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

            // Padding di bagian bawah untuk memberikan space saat ada floating action button
            const SizedBox(height: 80),
          ],
        ),
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
              _buildStatusInfo(
                'MENUNGGU',
                'Pengaduan baru yang belum ditindaklanjuti',
                statusMenungguColor,
                Icons.hourglass_empty,
              ),
              const SizedBox(height: 8),
              _buildStatusInfo(
                'TINDAKAN',
                'Pengaduan sedang dalam proses penanganan',
                statusTindakanColor,
                Icons.engineering,
              ),
              const SizedBox(height: 8),
              _buildStatusInfo(
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

  Widget _buildStatusInfo(
    String status,
    String description,
    Color color,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusPill(
                status: _getStatusText(status),
                backgroundColor: color,
                textColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'MENUNGGU':
        return 'Menunggu';
      case 'TINDAKAN':
        return 'Tindakan';
      case 'SELESAI':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'MENUNGGU':
        return statusMenungguColor;
      case 'TINDAKAN':
        return statusTindakanColor;
      case 'SELESAI':
        return statusSelesaiColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'MENUNGGU':
        return 'Pengaduan baru yang belum ditindaklanjuti oleh petugas.';
      case 'TINDAKAN':
        return 'Pengaduan sedang dalam proses penanganan oleh petugas.';
      case 'SELESAI':
        return 'Pengaduan telah selesai ditangani oleh petugas.';
      default:
        return 'Status pengaduan tidak diketahui.';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'MENUNGGU':
        return Icons.hourglass_empty;
      case 'TINDAKAN':
        return Icons.engineering;
      case 'SELESAI':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Informasi Pelapor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informasi pelapor
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Nama', namaWarga, Icons.person_outline),
                  _buildInfoRow('NIK', nikWarga, Icons.badge),
                  _buildInfoRow('Alamat', alamatWarga, Icons.home_outlined),
                  _buildInfoRow('No. HP', noHpWarga, Icons.phone_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenyaluranInfo(BuildContext context, PengaduanModel pengaduan) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory,
                    color: Colors.purple.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Informasi Penyaluran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informasi penyaluran
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Nama Penyaluran', pengaduan.namaPenyaluran,
                      Icons.label_outline),
                  _buildInfoRow('Stok Bantuan', pengaduan.stokBantuan!['nama'],
                      Icons.category_outlined),
                  _buildInfoRow(
                      'Jumlah Bantuan',
                      '${pengaduan.jumlahBantuan} ${pengaduan.stokBantuan!['satuan']}',
                      Icons.shopping_bag_outlined),
                  _buildInfoRow('Deskripsi', pengaduan.deskripsiPenyaluran,
                      Icons.description_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? '-',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: InfoCard(
            title: 'Belum Ada Tindakan',
            description:
                'Pengaduan ini belum mendapatkan tindakan dari petugas',
            icon: Icons.hourglass_empty,
            backgroundColor: Colors.orange.shade50,
            iconColor: Colors.orange,
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.timeline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Riwayat Tindakan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
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
        dotColor = Colors.green;
        break;
      case 'PROSES':
        dotColor = Colors.blue;
        break;
      default:
        dotColor = Colors.grey;
    }

    return TimelineTile(
      alignment: TimelineAlign.start,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 24,
        height: 24,
        color: dotColor,
        padding: const EdgeInsets.symmetric(vertical: 2),
        iconStyle: IconStyle(
          color: Colors.white,
          iconData:
              tindakan.statusTindakan == 'SELESAI' ? Icons.check : Icons.sync,
          fontSize: 14,
        ),
      ),
      beforeLineStyle: LineStyle(
        color: Colors.grey.shade300,
        thickness: 2,
      ),
      afterLineStyle: LineStyle(
        color: Colors.grey.shade300,
        thickness: 2,
      ),
      endChild: Container(
        margin: const EdgeInsets.only(left: 20, bottom: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan kategori dan status
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: dotColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tindakan.kategoriTindakanText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: dotColor,
                        ),
                      ),
                    ),
                    StatusPill(
                      status: tindakan.statusTindakanText,
                      backgroundColor: dotColor,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deskripsi tindakan
                    Text(
                      tindakan.tindakan ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),

                    // Catatan tindakan (jika ada)
                    if (tindakan.catatan != null &&
                        tindakan.catatan!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.note,
                              size: 16,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Catatan:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tindakan.catatan!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Hasil tindakan (jika ada)
                    if (tindakan.hasilTindakan != null &&
                        tindakan.hasilTindakan!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
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
                                const SizedBox(width: 8),
                                Text(
                                  'Hasil Tindakan:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              tindakan.hasilTindakan!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade900,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Bukti tindakan (jika ada)
                    if (tindakan.buktiTindakan != null &&
                        tindakan.buktiTindakan!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Bukti Tindakan:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: tindakan.buktiTindakan!.map((bukti) {
                              return GestureDetector(
                                onTap: () => ShowImageDialog.showFullScreen(
                                    context, bukti),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    image: DecorationImage(
                                      image: bukti.startsWith('http')
                                          ? NetworkImage(bukti)
                                          : FileImage(File(bukti))
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_in,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Footer dengan info petugas dan tanggal
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Oleh: ${tindakan.namaPetugas}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tindakan.tanggalTindakan != null
                                ? FormatHelper.formatDateTime(
                                    tindakan.tanggalTindakan!)
                                : '-',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tampilkan tombol edit jika status PROSES
              if (tindakan.statusTindakan == 'PROSES') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTambahTindakanDialog(BuildContext context, String pengaduanId) {
    final formKey = GlobalKey<FormState>();
    final tindakanController = TextEditingController();
    String? selectedKategori;
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

    // Konversi ke format DropdownItem
    final List<DropdownItem<String>> kategoriItems = kategoriOptions
        .map((kategori) => DropdownItem<String>(
              value: kategori,
              label: kategori.replaceAll('_', ' '),
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
    String selectedStatus = 'SELESAI';

    // Gunakan List untuk bukti tindakan paths
    final List<String> buktiTindakanPaths = tindakan.buktiTindakan != null
        ? List<String>.from(tindakan.buktiTindakan!)
        : [];

    // Fungsi untuk menampilkan dialog pilih sumber foto
    void showPilihSumberFoto(
        BuildContext dialogContext, Function(BuildContext, bool) pickFunction) {
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
                onTap: () => pickFunction(innerContext, true),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () => pickFunction(innerContext, false),
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
        // Fungsi untuk memilih bukti tindakan dipindahkan ke dalam StatefulBuilder
        Future<void> pickBuktiTindakan(
            BuildContext innerContext, bool fromCamera) async {
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
                context: innerContext,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );

              try {
                // Tambahkan gambar ke daftar dan update state
                setState(() {
                  buktiTindakanPaths.add(pickedFile.path);
                });

                // Tutup loading dialog
                Navigator.of(innerContext, rootNavigator: true).pop();

                // Tutup dialog pilih sumber foto
                Navigator.of(innerContext).pop();
              } catch (e) {
                // Tutup loading dialog jika terjadi error
                Navigator.of(innerContext, rootNavigator: true).pop();
                rethrow;
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
                                onTap: () => showPilihSumberFoto(
                                    stateContext, pickBuktiTindakan),
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
                                      itemCount: buktiTindakanPaths.length +
                                          1, // Tambah 1 untuk tombol tambah
                                      itemBuilder: (context, index) {
                                        if (index ==
                                            buktiTindakanPaths.length) {
                                          // Tombol tambah foto
                                          return InkWell(
                                            onTap: () => showPilihSumberFoto(
                                                stateContext,
                                                pickBuktiTindakan),
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
                                              onTap: () => ShowImageDialog
                                                  .showFullScreen(
                                                      stateContext,
                                                      buktiTindakanPaths[
                                                          index]),
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

  Widget _buildFeedbackSection(BuildContext context, PengaduanModel pengaduan) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.amber.shade50],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.feedback,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Feedback Warga',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Divider(
                color: Colors.amber.shade200,
                thickness: 1,
              ),
            ),

            // Rating display
            if (pengaduan.ratingWarga != null)
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (pengaduan.ratingWarga ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber.shade700,
                        size: 24,
                      );
                    }),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Feedback content or placeholder
            if (pengaduan.feedbackWarga != null &&
                pengaduan.feedbackWarga!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.shade100.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 18,
                          color: Colors.amber.shade400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Komentar Warga:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pengaduan.feedbackWarga!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade800,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
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
          ],
        ),
      ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
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
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusInfo(
            status,
            description,
            color,
            icon,
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        padding: const EdgeInsets.all(20),
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
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                _getStatusPill(pengaduan.status),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                pengaduan.deskripsi ?? '',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  pengaduan.tanggalPengaduan != null
                      ? FormatHelper.formatDateTime(pengaduan.tanggalPengaduan!)
                      : '-',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            if (pengaduan.fotoPengaduan != null &&
                pengaduan.fotoPengaduan!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: pengaduan.fotoPengaduan!.map((url) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                ShowImageDialog.showFullScreen(context, url),
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Tombol untuk menambahkan tindakan (hanya jika status MENUNGGU atau TINDAKAN)
            if (pengaduan.status == 'MENUNGGU' ||
                pengaduan.status == 'TINDAKAN')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showTambahTindakanDialog(context, pengaduan.id!);
                      },
                      icon: const Icon(Icons.add_task),
                      label: const Text('Tambah Tindakan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  if (pengaduan.status == 'MENUNGGU')
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _updateStatusToTindakan(pengaduan.id!);
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Proses'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  if (pengaduan.status == 'TINDAKAN')
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _handleSelesaikanPengaduan(pengaduan.id!);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Selesai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
      case 'TINDAKAN':
        return StatusPill(
          status: 'Tindakan',
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
      case 'SELESAI':
        return StatusPill.completed(status: 'Selesai');
      default:
        return StatusPill(
          status: status ?? 'Tidak Diketahui',
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
    }
  }

  // Metode untuk mengubah status pengaduan ke TINDAKAN
  void _updateStatusToTindakan(String pengaduanId) async {
    try {
      await controller.updateStatusTindakan(pengaduanId);
      Get.forceAppUpdate();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah status: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Metode untuk menyelesaikan pengaduan
  void _handleSelesaikanPengaduan(String pengaduanId) async {
    try {
      // Periksa apakah semua tindakan sudah diselesaikan
      final tindakanList = await controller.getTindakanPengaduan(pengaduanId);
      bool allTindakanSelesai = true;

      if (tindakanList.isNotEmpty) {
        allTindakanSelesai = tindakanList.every((t) {
          return t.statusTindakan == 'SELESAI';
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
        context: Get.context!,
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
}
