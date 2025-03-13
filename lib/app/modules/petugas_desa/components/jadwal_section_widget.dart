import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class JadwalSectionWidget extends StatelessWidget {
  final JadwalPenyaluranController controller;
  final String title;
  final List<PenyaluranBantuanModel> jadwalList;
  final String status;

  const JadwalSectionWidget({
    super.key,
    required this.controller,
    required this.title,
    required this.jadwalList,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getStatusIcon(),
              color: _getStatusColor(),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final currentJadwalList = _getCurrentJadwalList();

          if (currentJadwalList.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      _getEmptyIcon(),
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada jadwal $title',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: currentJadwalList
                .map((jadwal) => _buildJadwalItem(textTheme, jadwal))
                .toList(),
          );
        }),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'Aktif':
        return Icons.event_available;
      case 'Terjadwal':
        return Icons.pending_actions;
      case 'Selesai':
        return Icons.event_busy;
      default:
        return Icons.event_note;
    }
  }

  IconData _getEmptyIcon() {
    switch (status) {
      case 'Aktif':
        return Icons.calendar_today;
      case 'Terjadwal':
        return Icons.schedule;
      case 'Selesai':
        return Icons.task_alt;
      default:
        return Icons.event_note;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'Aktif':
        return Colors.green;
      case 'Terjadwal':
        return Colors.blue;
      case 'Selesai':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  List<PenyaluranBantuanModel> _getCurrentJadwalList() {
    switch (title) {
      case 'Hari Ini':
        return controller.jadwalHariIni.toList();
      case 'Mendatang':
        return controller.jadwalMendatang.toList();
      case 'Selesai':
        return controller.jadwalSelesai.toList();
      default:
        return jadwalList;
    }
  }

  Widget _buildJadwalItem(TextTheme textTheme, PenyaluranBantuanModel jadwal) {
    Color statusColor = _getStatusColor();

    // Format tanggal dan waktu
    String formattedDateTime = jadwal.tanggalPenyaluran != null
        ? "${DateFormat('dd MMM yyyy').format(jadwal.tanggalPenyaluran!)} ${DateFormat('HH:mm').format(jadwal.tanggalPenyaluran!)}"
        : 'Belum ditentukan';

    // Dapatkan nama lokasi dan kategori
    String lokasiName =
        controller.getLokasiPenyaluranName(jadwal.lokasiPenyaluranId);
    String kategoriName =
        controller.getKategoriBantuanName(jadwal.kategoriBantuanId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed(Routes.pelaksanaanPenyaluran, arguments: jadwal);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container(
                  //   padding: const EdgeInsets.all(10),
                  //   decoration: BoxDecoration(
                  //     color: statusColor.withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child: Icon(
                  //     _getStatusIcon(),
                  //     color: statusColor,
                  //     size: 24,
                  //   ),
                  // ),
                  // const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                jadwal.nama ?? 'Tanpa Nama',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: textTheme.bodySmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (jadwal.deskripsi != null &&
                            jadwal.deskripsi!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            jadwal.deskripsi!,
                            style: textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoItem(
                Icons.location_on_outlined,
                'Lokasi',
                lokasiName,
                textTheme,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.category_outlined,
                      'Kategori',
                      kategoriName,
                      textTheme,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.event,
                      'Jadwal',
                      formattedDateTime,
                      textTheme,
                    ),
                  ),
                ],
              ),
              if (jadwal.jumlahPenerima != null) ...[
                const SizedBox(height: 8),
                _buildInfoItem(
                  Icons.people_outline,
                  'Jumlah Penerima',
                  '${jadwal.jumlahPenerima}',
                  textTheme,
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Get.toNamed(Routes.pelaksanaanPenyaluran,
                        arguments: jadwal);
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Lihat Detail'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    TextTheme textTheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
