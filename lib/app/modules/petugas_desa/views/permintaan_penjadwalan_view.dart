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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan permintaan penjadwalan
              _buildPenjadwalanSummary(context),

              const SizedBox(height: 24),

              // Filter dan pencarian
              _buildFilterSearch(context),

              const SizedBox(height: 20),

              // Daftar permintaan penjadwalan
              _buildPenjadwalanList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPenjadwalanSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Permintaan Penjadwalan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.pending_actions,
                  title: 'Menunggu',
                  value: '${controller.jumlahPermintaanPenjadwalan.value}',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.check_circle,
                  title: 'Terkonfirmasi',
                  value: '0',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.cancel,
                  title: 'Ditolak',
                  value: '0',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterSearch(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari permintaan...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              // Tampilkan dialog filter
            },
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
        ),
      ],
    );
  }

  Widget _buildPenjadwalanList(BuildContext context) {
    return Obx(() {
      final permintaanList = controller.permintaanPenjadwalan;

      if (permintaanList.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Permintaan Penjadwalan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...permintaanList.map((item) => _buildPermintaanItem(context, item)),
        ],
      );
    });
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

  Widget _buildPermintaanItem(BuildContext context, Map<String, dynamic> item) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending_actions;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
                    item['nama'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Menunggu',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon: Icons.person,
                    label: 'NIK',
                    value: item['nik'] ?? '',
                  ),
                ),
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon: Icons.category,
                    label: 'Jenis Bantuan',
                    value: item['jenis_bantuan'] ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Tanggal Permintaan',
                    value: item['tanggal_permintaan'] ?? '',
                  ),
                ),
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon: Icons.location_on,
                    label: 'Alamat',
                    value: item['alamat'] ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showTolakDialog(item),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Tolak'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showKonfirmasiDialog(item),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Konfirmasi'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Implementasi untuk melihat detail permintaan
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Detail'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetail(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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
