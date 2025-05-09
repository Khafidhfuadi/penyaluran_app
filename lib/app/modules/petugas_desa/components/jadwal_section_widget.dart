import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
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
        const SizedBox(height: 16),
        Obx(() {
          final currentJadwalList = _getCurrentJadwalList();

          if (currentJadwalList.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getEmptyIcon(),
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada jadwal $title',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jadwal akan muncul di sini saat tersedia',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
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
        return Icons.event_note;
      case 'Terjadwal':
        return Icons.pending_actions;
      case 'Terlaksana':
        return Icons.event_available;
      case 'Tidak Terlaksana':
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
      case 'Terlaksana':
        return Icons.task_alt;

      default:
        return Icons.event_note;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'Aktif':
        return AppTheme.scheduledColor;
      case 'Terjadwal':
        return AppTheme.processedColor;
      case 'Terlaksana':
        return AppTheme.completedColor;
      default:
        return AppTheme.infoColor;
    }
  }

  String _getStatusText(PenyaluranBantuanModel jadwal) {
    // Jika status jadwal adalah AKTIF, tampilkan sebagai "Aktif"
    if (jadwal.status == 'AKTIF') {
      return 'Aktif';
    }
    // Jika status jadwal adalah DIJADWALKAN, tampilkan sebagai "Terjadwal"
    else if (jadwal.status == 'DIJADWALKAN') {
      return 'Terjadwal';
    }
    // Jika status jadwal adalah TERLAKSANA, tampilkan sebagai "Terlaksana"
    else if (jadwal.status == 'TERLAKSANA') {
      return 'Terlaksana';
    } else if (jadwal.status == 'BATALTERLAKSANA') {
      return 'Batal Terlaksana';
    }
    // Default status
    return status;
  }

  Color _getStatusColorByJadwal(PenyaluranBantuanModel jadwal) {
    // Jika status jadwal adalah AKTIF, gunakan warna hijau
    if (jadwal.status == 'AKTIF') {
      return AppTheme.scheduledColor;
    }
    // Jika status jadwal adalah DIJADWALKAN, gunakan warna biru
    else if (jadwal.status == 'DIJADWALKAN') {
      return AppTheme.processedColor;
    } else if (jadwal.status == 'TERLAKSANA') {
      return AppTheme.completedColor;
    } else if (jadwal.status == 'BATALTERLAKSANA') {
      return AppTheme.errorColor;
    }
    // Default warna
    return _getStatusColor();
  }

  List<PenyaluranBantuanModel> _getCurrentJadwalList() {
    switch (title) {
      case 'Penyaluran Aktif':
        return controller.jadwalAktif.toList();

      case '7 Hari Mendatang':
        return controller.jadwalMendatang.toList();
      case 'Terlaksana':
        return controller.jadwalTerlaksana.toList();
      default:
        return jadwalList;
    }
  }

  Widget _buildJadwalItem(TextTheme textTheme, PenyaluranBantuanModel jadwal) {
    Color statusColor = _getStatusColorByJadwal(jadwal);
    String statusText = _getStatusText(jadwal);

    // Format tanggal dan waktu menggunakan helper
    String formattedDateTime =
        FormatHelper.formatDateTime(jadwal.tanggalPenyaluran);

    // Dapatkan nama lokasi dan kategori
    String lokasiName =
        controller.getLokasiPenyaluranName(jadwal.lokasiPenyaluranId);
    String kategoriName =
        controller.getKategoriBantuanName(jadwal.kategoriBantuanId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (jadwal.id != null) {
            Get.toNamed(Routes.detailPenyaluran,
                parameters: {'id': jadwal.id!});
          } else {
            Get.snackbar(
              'Error',
              'ID penyaluran tidak ditemukan',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                statusText,
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
                          const SizedBox(height: 6),
                          Text(
                            jadwal.deskripsi!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
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
              _buildInfoSection(
                textTheme,
                lokasiName,
                kategoriName,
                formattedDateTime,
                jadwal.jumlahPenerima,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (jadwal.id != null) {
                        Get.toNamed(Routes.detailPenyaluran,
                            parameters: {'id': jadwal.id!});
                      } else {
                        Get.snackbar(
                          'Error',
                          'ID penyaluran tidak ditemukan',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Lihat Detail'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: statusColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    TextTheme textTheme,
    String lokasiName,
    String kategoriName,
    String formattedDateTime,
    int? jumlahPenerima,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoItem(
            Icons.location_on_outlined,
            'Lokasi',
            lokasiName,
            textTheme,
          ),
          const SizedBox(height: 10),
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
          if (jumlahPenerima != null) ...[
            const SizedBox(height: 10),
            _buildInfoItem(
              Icons.people_outline,
              'Jumlah Penerima',
              '$jumlahPenerima',
              textTheme,
            ),
          ],
        ],
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
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
