import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/laporan_penyaluran_model.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/controllers/laporan_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';
import 'package:penyaluran_app/app/widgets/custom_app_bar.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'package:penyaluran_app/app/widgets/status_badge.dart';
import 'package:intl/intl.dart';

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.note_alt_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada laporan penyaluran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Buat laporan baru untuk penyaluran yang telah selesai',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showPenyaluranDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Buat Laporan Baru'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Filter Status',
            // subtitle: 'Tampilkan laporan berdasarkan status',
            // showDivider: false,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('SEMUA'),
                _buildFilterChip('DRAFT'),
                _buildFilterChip('FINAL'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Chip untuk filter
  Widget _buildFilterChip(String status) {
    return Obx(() {
      final isSelected = controller.filterStatus.value == status;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          selected: isSelected,
          label: Text(status),
          onSelected: (_) {
            controller.filterStatus.value = status;
          },
          backgroundColor: Colors.white,
          checkmarkColor: Colors.white,
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/laporan-penyaluran/detail', arguments: laporan.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: AppTheme.primaryGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    StatusBadge(status: laporan.status ?? 'DRAFT'),
                  ],
                ),
                const Divider(height: 24, color: Colors.white30),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tanggal: ${laporan.tanggalLaporan != null ? DateTimeHelper.formatDateTime(laporan.tanggalLaporan!) : '-'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (laporan.status == 'FINAL')
                      Material(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.picture_as_pdf,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Ekspor PDF',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Get.toNamed('/laporan-penyaluran/edit',
                              arguments: laporan.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Row(
                            children: const [
                              Icon(Icons.edit, color: Colors.orange, size: 16),
                              SizedBox(width: 4),
                              Text('Edit',
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          _showDeleteConfirmation(context, laporan.id!);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Row(
                            children: const [
                              Icon(Icons.delete, color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text('Hapus',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          title: const Text('Hapus Laporan'),
          content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteLaporan(laporanId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
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
          title: const Text('Pilih Penyaluran'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.penyaluranTanpaLaporan.length,
              itemBuilder: (context, index) {
                final penyaluran = controller.penyaluranTanpaLaporan[index];
                return ListTile(
                  title: Text(
                    penyaluran.nama ??
                        'Penyaluran #${penyaluran.id?.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Tanggal: ${penyaluran.tanggalSelesai != null ? DateFormat('dd/MM/yyyy').format(penyaluran.tanggalSelesai!) : '-'}',
                  ),
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
