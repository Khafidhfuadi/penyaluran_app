import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/laporan_penyaluran_model.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/controllers/laporan_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'package:penyaluran_app/app/widgets/custom_app_bar.dart';
import 'package:penyaluran_app/app/widgets/status_badge.dart';

class LaporanPenyaluranView extends GetView<LaporanPenyaluranController> {
  const LaporanPenyaluranView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Laporan Penyaluran Bantuan',
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter status
          _buildStatusFilter(),

          // Daftar laporan
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.daftarLaporan.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            size: 72,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Belum Ada Laporan Penyaluran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Buat laporan baru untuk penyaluran bantuan yang telah selesai',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () => _showPenyaluranDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Buat Laporan Baru'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Filter berdasarkan status jika dipilih
              final filteredLaporan = controller.filterStatus.value == 'SEMUA'
                  ? controller.daftarLaporan
                  : controller.daftarLaporan
                      .where((laporan) =>
                          laporan.status == controller.filterStatus.value)
                      .toList();

              if (filteredLaporan.isEmpty) {
                return Center(
                  child: Text(
                      'Tidak ada laporan dengan status ${controller.filterStatus.value}'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchLaporan();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLaporan.length,
                  itemBuilder: (context, index) {
                    final laporan = filteredLaporan[index];
                    return _buildLaporanCard(context, laporan);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPenyaluranDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget untuk filter status
  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Filter Status Laporan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('SEMUA', Icons.list_alt),
                _buildFilterChip('DRAFT', Icons.edit_note),
                _buildFilterChip('FINAL', Icons.check_circle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Chip untuk filter
  Widget _buildFilterChip(String status, IconData icon) {
    return Obx(() {
      final isSelected = controller.filterStatus.value == status;
      return Container(
        margin: const EdgeInsets.only(right: 12),
        child: Material(
          elevation: isSelected ? 2 : 0,
          borderRadius: BorderRadius.circular(25),
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
          child: InkWell(
            onTap: () {
              controller.filterStatus.value = status;
            },
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // Widget untuk card laporan
  Widget _buildLaporanCard(
      BuildContext context, LaporanPenyaluranModel laporan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/laporan-penyaluran/detail', arguments: laporan.id);
        },
        child: Column(
          children: [
            // Header dengan status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      laporan.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // const SizedBox(width: 8),
                  // StatusBadge(status: laporan.status ?? 'DRAFT'),
                ],
              ),
            ),
            // Body with details
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi dengan icon
                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.calendar_today,
                        'Tanggal',
                        laporan.tanggalLaporan != null
                            ? FormatHelper.formatDateTime(
                                laporan.tanggalLaporan!)
                            : '-',
                      ),
                      const SizedBox(width: 16),
                      _buildInfoItem(
                        Icons.description,
                        'Status',
                        laporan.status ?? 'DRAFT',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (laporan.status == 'FINAL')
                        _buildActionButton(
                          icon: Icons.picture_as_pdf,
                          label: 'Ekspor PDF',
                          color: Colors.blue,
                          onTap: () {
                            controller
                                .fetchPenyaluranDetail(
                                    laporan.penyaluranBantuanId)
                                .then((_) {
                              if (controller.selectedPenyaluran.value != null) {
                                controller.exportToPdf(laporan,
                                    controller.selectedPenyaluran.value!);
                              }
                            });
                          },
                        ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Edit',
                        color: Colors.orange,
                        onTap: () {
                          Get.toNamed('/laporan-penyaluran/edit',
                              arguments: laporan.id);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.delete,
                        label: 'Hapus',
                        color: Colors.red,
                        onTap: () {
                          _showDeleteConfirmation(context, laporan.id!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk item informasi
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk tombol aksi
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog konfirmasi hapus laporan
  void _showDeleteConfirmation(BuildContext context, String laporanId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text('Hapus Laporan'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus laporan ini? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteLaporan(laporanId).then((_) {
                  Get.snackbar(
                    'Berhasil',
                    'Laporan berhasil dihapus',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Dialog pilih penyaluran untuk laporan baru
  void _showPenyaluranDialog(BuildContext context) {
    if (controller.penyaluranTanpaLaporan.isEmpty) {
      Get.snackbar(
        'Info',
        'Tidak ada penyaluran yang tersedia untuk dibuat laporan. Pastikan ada penyaluran dengan status SELESAI.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.assignment, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text('Pilih Penyaluran'),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.only(top: 16, left: 24, right: 24),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih salah satu penyaluran bantuan yang akan dibuat laporannya:',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.penyaluranTanpaLaporan.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final penyaluran =
                          controller.penyaluranTanpaLaporan[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppTheme.primaryColor.withOpacity(0.2),
                          child: const Icon(
                            Icons.inventory_2,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(
                          penyaluran.nama ??
                              'Penyaluran #${penyaluran.id?.substring(0, 8)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              penyaluran.tanggalSelesai != null
                                  ? FormatHelper.formatDateTime(
                                      penyaluran.tanggalSelesai!)
                                  : '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.of(context).pop();
                          // Arahkan ke halaman buat laporan dengan ID penyaluran
                          Get.toNamed('/laporan-penyaluran/create',
                              arguments: penyaluran.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }
}
