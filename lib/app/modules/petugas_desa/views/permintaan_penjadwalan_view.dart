import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class PermintaanPenjadwalanView extends GetView<PetugasDesaController> {
  const PermintaanPenjadwalanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller sudah diinisialisasi
    if (!Get.isRegistered<PetugasDesaController>()) {
      Get.put(PetugasDesaController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permintaan Penjadwalan'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final permintaanList = controller.permintaanPenjadwalan;

        if (permintaanList.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: permintaanList.length,
          itemBuilder: (context, index) {
            final permintaan = permintaanList[index];
            return _buildPermintaanItem(context, permintaan);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada permintaan penjadwalan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua permintaan penjadwalan akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPermintaanItem(
      BuildContext context, Map<String, dynamic> permintaan) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
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
                  permintaan['nama'] ?? '',
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
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'NIK: ${permintaan['nik'] ?? ''}'),
            _buildInfoRow(Icons.category,
                'Jenis Bantuan: ${permintaan['jenis_bantuan'] ?? ''}'),
            _buildInfoRow(Icons.calendar_today,
                'Tanggal Permintaan: ${permintaan['tanggal_permintaan'] ?? ''}'),
            _buildInfoRow(
                Icons.location_on, 'Alamat: ${permintaan['alamat'] ?? ''}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showTolakDialog(permintaan),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Tolak'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showKonfirmasiDialog(permintaan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Konfirmasi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog untuk konfirmasi permintaan
  void _showKonfirmasiDialog(Map<String, dynamic> permintaan) {
    String? selectedJadwalId;

    // Data jadwal yang tersedia dari controller
    final jadwalOptions = controller.jadwalMendatang.map((jadwal) {
      return DropdownMenuItem<String>(
        value: jadwal['id'],
        child: Text(
            '${jadwal['tanggal'] ?? ''} - ${jadwal['lokasi'] ?? ''} (${jadwal['jenis_bantuan'] ?? ''})'),
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
                'Anda akan mengkonfirmasi permintaan penjadwalan dari ${permintaan['nama'] ?? 'Penerima'}.'),
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
                controller.konfirmasiPermintaanPenjadwalan(
                  permintaan['id'] ?? '',
                  selectedJadwalId ?? '',
                );

                Get.back();
                Get.snackbar(
                  'Berhasil',
                  'Permintaan penjadwalan berhasil dikonfirmasi',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Peringatan',
                  'Silakan pilih jadwal penyaluran terlebih dahulu',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
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
  void _showTolakDialog(Map<String, dynamic> permintaan) {
    final TextEditingController alasanController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Tolak Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Anda akan menolak permintaan penjadwalan dari ${permintaan['nama'] ?? 'Penerima'}.'),
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
                controller.tolakPermintaanPenjadwalan(
                  permintaan['id'] ?? '',
                  alasanController.text.trim(),
                );

                Get.back();
                Get.snackbar(
                  'Berhasil',
                  'Permintaan penjadwalan berhasil ditolak',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Peringatan',
                  'Silakan masukkan alasan penolakan',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
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
