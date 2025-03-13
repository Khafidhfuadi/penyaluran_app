import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class PermintaanPenjadwalanSummaryWidget extends StatelessWidget {
  final JadwalPenyaluranController controller;

  const PermintaanPenjadwalanSummaryWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final jumlahPermintaan = controller.jumlahPermintaanPenjadwalan.value;
      final permintaanList = controller.permintaanPenjadwalan;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: jumlahPermintaan > 0
                ? Colors.orange.withAlpha(50)
                : Colors.grey.withAlpha(30),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Permintaan Penjadwalan',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: jumlahPermintaan > 0
                        ? Colors.red.withAlpha(26)
                        : Colors.grey.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$jumlahPermintaan',
                    style: textTheme.bodySmall?.copyWith(
                      color: jumlahPermintaan > 0 ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (jumlahPermintaan == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ada permintaan penjadwalan',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  ...permintaanList.take(1).map((permintaan) =>
                      _buildPermintaanPreview(textTheme, permintaan)),
                  if (jumlahPermintaan > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${jumlahPermintaan - 1} permintaan lainnya',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.permintaanPenjadwalan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.visibility),
                label: const Text('Lihat Semua Permintaan'),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPermintaanPreview(
      TextTheme textTheme, PenyaluranBantuanModel permintaan) {
    // Format tanggal
    String formattedDate = permintaan.tanggalPermintaan != null
        ? DateFormat('dd MMMM yyyy').format(permintaan.tanggalPermintaan!)
        : 'Belum ditentukan';

    // Dapatkan nama kategori
    String kategoriName =
        controller.getKategoriBantuanName(permintaan.kategoriBantuanId);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  permintaan.nama ?? 'Tanpa Nama',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Menunggu',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (permintaan.deskripsi != null && permintaan.deskripsi!.isNotEmpty)
            Text(
              permintaan.deskripsi!,
              style: textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          Text(
            'Kategori: $kategoriName',
            style: textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Tanggal: $formattedDate',
            style: textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
