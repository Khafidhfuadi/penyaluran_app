import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';

class DonaturJadwalDetailView extends GetView<DonaturDashboardController> {
  const DonaturJadwalDetailView({super.key});

  @override
  DonaturDashboardController get controller {
    if (!Get.isRegistered<DonaturDashboardController>(
        tag: 'donatur_dashboard')) {
      return Get.put(DonaturDashboardController(),
          tag: 'donatur_dashboard', permanent: true);
    }
    return Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final jadwal = Get.arguments as PenyaluranBantuanModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jadwal Penyaluran'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(jadwal),
            _buildDetailSection(jadwal),
            _buildPelaksanaSection(jadwal),
            _buildStatusSection(jadwal),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(PenyaluranBantuanModel jadwal) {
    String statusText = 'Akan Datang';
    Color statusColor = Colors.blue;

    switch (jadwal.status) {
      case 'SELESAI':
        statusText = 'Selesai';
        statusColor = Colors.green;
        break;
      case 'DIBATALKAN':
        statusText = 'Dibatalkan';
        statusColor = Colors.red;
        break;
      case 'DALAM_PROSES':
        statusText = 'Dalam Proses';
        statusColor = Colors.orange;
        break;
      default:
        statusText = 'Akan Datang';
        statusColor = Colors.blue;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.8),
            statusColor.withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(jadwal.status),
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            jadwal.nama ?? 'Penyaluran Bantuan',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (jadwal.tanggalPenyaluran != null)
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  FormatHelper.formatDateIndonesian(jadwal.tanggalPenyaluran),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(PenyaluranBantuanModel jadwal) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Informasi Penyaluran'),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.description_outlined,
            title: 'Deskripsi',
            value: jadwal.deskripsi ?? 'Tidak ada deskripsi',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.people_outline,
            title: 'Jumlah Penerima',
            value: jadwal.jumlahPenerima != null
                ? '${jadwal.jumlahPenerima} orang'
                : 'Belum ditentukan',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.category_outlined,
            title: 'Kategori Bantuan',
            value: jadwal.kategoriNama ?? jadwal.kategoriBantuanId ?? 'Umum',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.location_on_outlined,
            title: 'Lokasi Penyaluran',
            value: jadwal.lokasiNama ??
                jadwal.lokasiPenyaluranId ??
                'Belum ditentukan',
          ),
        ],
      ),
    );
  }

  Widget _buildPelaksanaSection(PenyaluranBantuanModel jadwal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Informasi Pelaksana'),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: jadwal.fotoPetugas != null &&
                                jadwal.fotoPetugas.toString().isNotEmpty
                            ? NetworkImage(jadwal.fotoPetugas as String)
                            : null,
                        child: (jadwal.fotoPetugas == null ||
                                jadwal.fotoPetugas.toString().isEmpty)
                            ? Text(
                                jadwal.namaPetugas != null
                                    ? jadwal.namaPetugas
                                        .toString()
                                        .substring(0, 1)
                                        .toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                  fontSize: 20,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Petugas Pelaksana',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              jadwal.namaPetugas ??
                                  jadwal.petugasId ??
                                  'Belum ditugaskan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(PenyaluranBantuanModel jadwal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Status Penyaluran'),
          const SizedBox(height: 16),
          _buildStatusCard(jadwal),
        ],
      ),
    );
  }

  Widget _buildStatusCard(PenyaluranBantuanModel jadwal) {
    final status = jadwal.status;
    final bool isCompleted = status == 'TERLAKSANA';
    final bool isCancelled = status == 'BATALTERLAKSANA';
    final bool isInProgress = status == 'AKTIF';
    final bool isScheduled = status == 'Dijadwalkan';

    Color statusColor = Colors.blue;
    IconData statusIcon = Icons.schedule;
    String statusText = 'Dijadwalkan';

    if (isCompleted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Terlaksana';
    } else if (isCancelled) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Batal Terlaksana';
    } else if (isInProgress) {
      statusColor = Colors.blue;
      statusIcon = Icons.sync;
      statusText = 'Aktif';
    } else if (isScheduled) {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
      statusText = 'Dijadwalkan';
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatusDetailItem(
                title: 'Tanggal Dijadwalkan',
                value: FormatHelper.formatDateIndonesian(jadwal.createdAt),
              ),
              const SizedBox(height: 8),
              _buildStatusDetailItem(
                title: 'Tanggal Penyaluran',
                value:
                    FormatHelper.formatDateIndonesian(jadwal.tanggalPenyaluran),
              ),
              if (isCompleted) ...[
                const SizedBox(height: 8),
                _buildStatusDetailItem(
                  title: 'Tanggal Selesai',
                  value:
                      FormatHelper.formatDateIndonesian(jadwal.tanggalSelesai),
                ),
              ],
            ],
          ),
        ),
        if (isCancelled) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Penyaluran Dibatalkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Alasan pembatalan: ${jadwal.alasanPembatalan ?? 'Tidak ada alasan yang diberikan'}',
                  style: TextStyle(color: Colors.red.shade700),
                ),
                const SizedBox(height: 8),
                if (jadwal.tanggalPembatalan != null)
                  Text(
                    'Dibatalkan pada: ${FormatHelper.formatDateIndonesian(jadwal.tanggalPembatalan)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusDetailItem(
      {required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'SELESAI':
        return Icons.check_circle;
      case 'DIBATALKAN':
        return Icons.cancel;
      case 'DALAM_PROSES':
        return Icons.timelapse;
      default:
        return Icons.event_available;
    }
  }

  void _hubungiPetugas(PenyaluranBantuanModel jadwal) {
    // Implementasi untuk menghubungi petugas
    Get.snackbar(
      'Fitur Belum Tersedia',
      'Fitur untuk menghubungi petugas akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.9),
      colorText: Colors.white,
    );
  }

  void _lihatLaporan(PenyaluranBantuanModel jadwal) {
    // Navigasi ke halaman laporan
    Get.toNamed('/donatur/laporan/${jadwal.id}', arguments: jadwal);
  }
}
