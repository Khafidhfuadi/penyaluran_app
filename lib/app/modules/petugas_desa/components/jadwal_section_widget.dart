import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';

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
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
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
                child: Text(
                  'Tidak ada jadwal $title',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
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
    Color statusColor;
    switch (status) {
      case 'Aktif':
        statusColor = Colors.green;
        break;
      case 'Terjadwal':
        statusColor = Colors.blue;
        break;
      case 'Selesai':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.orange;
    }

    // Format tanggal
    String formattedDate = jadwal.tanggalPenyaluran != null
        ? DateFormat('dd MMMM yyyy').format(jadwal.tanggalPenyaluran!)
        : 'Belum ditentukan';

    // Format waktu
    String formattedTime = jadwal.tanggalPenyaluran != null
        ? DateFormat('HH:mm').format(jadwal.tanggalPenyaluran!)
        : '-';

    // Dapatkan nama lokasi dan kategori
    String lokasiName =
        controller.getLokasiPenyaluranName(jadwal.lokasiPenyaluranId);
    String kategoriName =
        controller.getKategoriBantuanName(jadwal.kategoriBantuanId);

    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman pelaksanaan penyaluran dengan data jadwal
        Get.toNamed(Routes.pelaksanaanPenyaluran, arguments: jadwal);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
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
              const SizedBox(height: 8),
              if (jadwal.deskripsi != null && jadwal.deskripsi!.isNotEmpty) ...[
                Text(
                  jadwal.deskripsi!,
                  style: textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'Lokasi: $lokasiName',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Kategori: $kategoriName',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Tanggal: $formattedDate',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Waktu: $formattedTime',
                style: textTheme.bodyMedium,
              ),
              if (jadwal.jumlahPenerima != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Jumlah Penerima: ${jadwal.jumlahPenerima}',
                  style: textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Lihat Detail',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
