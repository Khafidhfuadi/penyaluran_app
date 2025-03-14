import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class PermintaanPenjadwalanWidget extends StatelessWidget {
  final JadwalPenyaluranController controller;

  const PermintaanPenjadwalanWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Permintaan Penjadwalan',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${controller.jumlahPermintaanPenjadwalan.value}',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final permintaanList = controller.permintaanPenjadwalan;

          // Jika tidak ada permintaan, tampilkan pesan kosong
          if (permintaanList.isEmpty) {
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
                      Icons.event_note,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada permintaan penjadwalan',
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
            children: permintaanList
                .map(
                    (permintaan) => _buildPermintaanItem(textTheme, permintaan))
                .toList(),
          );
        }),
      ],
    );
  }

  // Widget untuk menampilkan item permintaan penjadwalan
  Widget _buildPermintaanItem(
      TextTheme textTheme, PenyaluranBantuanModel permintaan) {
    return Container(
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
        border: Border.all(
          color: Colors.orange.withAlpha(50),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  permintaan.nama ?? '',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Menunggu',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${permintaan.id ?? ''}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Jenis Bantuan: ${permintaan.kategoriBantuanId ?? ''}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tanggal Permintaan: ${permintaan.createdAt?.toString().substring(0, 10) ?? ''}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Deskripsi: ${permintaan.deskripsi ?? ''}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _showTolakDialog(permintaan),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Tolak'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showKonfirmasiDialog(permintaan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Konfirmasi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dialog untuk konfirmasi permintaan
  void _showKonfirmasiDialog(PenyaluranBantuanModel permintaan) {
    String? selectedJadwalId;

    // Data jadwal yang tersedia dari controller
    final jadwalOptions = controller.jadwalMendatang.map((jadwal) {
      return DropdownMenuItem<String>(
        value: jadwal.id,
        child: Text(
            '${jadwal.tanggalPenjadwalan?.toString().substring(0, 10) ?? ''} - ${jadwal.lokasiPenyaluranId ?? ''} (${jadwal.nama ?? ''})'),
      );
    }).toList();

    // Tambahkan opsi jadwal lain jika diperlukan
    jadwalOptions.add(
      const DropdownMenuItem<String>(
        value: '3',
        child: Text('25 April 2023 - Kantor Kepala Desa (Beras)'),
      ),
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Anda akan mengkonfirmasi permintaan penjadwalan dari ${permintaan.nama}.'),
            const SizedBox(height: 16),
            const Text('Pilih jadwal penyaluran:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: jadwalOptions,
              onChanged: (value) {
                selectedJadwalId = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedJadwalId != null) {
                // Panggil metode konfirmasi di controller
                controller.approveJadwal(
                  permintaan.id ?? '',
                );

                Get.back();
                Get.snackbar(
                  'Berhasil',
                  'Permintaan penjadwalan berhasil dikonfirmasi',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              } else {
                Get.snackbar(
                  'Peringatan',
                  'Silakan pilih jadwal penyaluran terlebih dahulu',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  // Dialog untuk menolak permintaan
  void _showTolakDialog(PenyaluranBantuanModel permintaan) {
    final TextEditingController alasanController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Tolak Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Anda akan menolak permintaan penjadwalan dari ${permintaan.nama}.'),
            const SizedBox(height: 16),
            const Text('Alasan penolakan:'),
            const SizedBox(height: 8),
            TextField(
              controller: alasanController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan alasan penolakan',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (alasanController.text.trim().isNotEmpty) {
                // Panggil metode tolak di controller
                controller.rejectJadwal(
                  permintaan.id ?? '',
                  alasanController.text.trim(),
                );

                Get.back();
                Get.snackbar(
                  'Berhasil',
                  'Permintaan penjadwalan berhasil ditolak',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              } else {
                Get.snackbar(
                  'Peringatan',
                  'Silakan masukkan alasan penolakan',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }
}
