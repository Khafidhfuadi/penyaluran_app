import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';

class DonaturJadwalDetailView extends GetView<DonaturDashboardController> {
  const DonaturJadwalDetailView({Key? key}) : super(key: key);

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
            _buildActionSection(jadwal),
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
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                      .format(jadwal.tanggalPenyaluran!),
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
                        child: Icon(
                          Icons.person,
                          color: Colors.blue.shade700,
                          size: 30,
                        ),
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
          _buildStatusTimeline(jadwal),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(PenyaluranBantuanModel jadwal) {
    final status = jadwal.status;
    final bool isCompleted = status == 'SELESAI';
    final bool isCancelled = status == 'DIBATALKAN';
    final bool isInProgress = status == 'DALAM_PROSES';

    return Column(
      children: [
        _buildTimelineItem(
          title: 'Dijadwalkan',
          date: jadwal.createdAt != null
              ? DateFormat('dd MMM yyyy', 'id_ID').format(jadwal.createdAt!)
              : '-',
          isCompleted: true,
          isFirst: true,
        ),
        _buildTimelineItem(
          title: 'Dalam Proses',
          date: isInProgress || isCompleted
              ? jadwal.tanggalPenyaluran != null
                  ? DateFormat('dd MMM yyyy', 'id_ID')
                      .format(jadwal.tanggalPenyaluran!)
                  : '-'
              : '-',
          isCompleted: isInProgress || isCompleted,
          isCancelled: isCancelled,
        ),
        _buildTimelineItem(
          title: 'Selesai',
          date: isCompleted
              ? jadwal.tanggalSelesai != null
                  ? DateFormat('dd MMM yyyy', 'id_ID')
                      .format(jadwal.tanggalSelesai!)
                  : '-'
              : '-',
          isCompleted: isCompleted,
          isCancelled: isCancelled,
          isLast: true,
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
                    'Dibatalkan pada: ${DateFormat('dd MMMM yyyy', 'id_ID').format(jadwal.tanggalPembatalan!)}',
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

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required bool isCompleted,
    bool isFirst = false,
    bool isLast = false,
    bool isCancelled = false,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 20,
                  color: isCompleted
                      ? Colors.green
                      : isCancelled
                          ? Colors.red
                          : Colors.grey.shade300,
                ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green
                      : isCancelled
                          ? Colors.red
                          : Colors.grey.shade300,
                  border: Border.all(
                    color: isCompleted
                        ? Colors.green
                        : isCancelled
                            ? Colors.red
                            : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : isCancelled
                        ? const Icon(Icons.close, size: 12, color: Colors.white)
                        : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 20,
                  color: isCompleted && !isCancelled
                      ? Colors.green
                      : Colors.grey.shade300,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? Colors.black
                        : isCancelled
                            ? Colors.red
                            : Colors.grey,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted
                        ? Colors.grey.shade700
                        : isCancelled
                            ? Colors.red.shade300
                            : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(PenyaluranBantuanModel jadwal) {
    if (jadwal.status == 'DIBATALKAN') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Tindakan'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _hubungiPetugas(jadwal),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Hubungi Petugas'),
                ),
              ),
              if (jadwal.status == 'SELESAI') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _lihatLaporan(jadwal),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Lihat Laporan'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
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
