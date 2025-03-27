import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/modules/warga/views/form_pengaduan_view.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class WargaPengaduanView extends GetView<WargaDashboardController> {
  const WargaPengaduanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Debug print untuk melihat jumlah item
        print(
            'DEBUG: Jumlah pengaduan tersedia: ${controller.pengaduan.length}');

        return RefreshIndicator(
          onRefresh: () async {
            // Tambahkan delay untuk memastikan refresh indicator terlihat
            await Future.delayed(const Duration(milliseconds: 300));
            controller.fetchData();
          },
          child: controller.pengaduan.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: Get.height * 0.7,
                      child: _buildEmptyState(),
                    ),
                  ],
                )
              : _buildPengaduanList(context),
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
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Bagus!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada pengaduan yang dibuat',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengaduanList(BuildContext context) {
    // Log untuk debugging jumlah item
    print(
        'DEBUG: Membangun ListView dengan ${controller.pengaduan.length} pengaduan');

    // Menggunakan CustomScrollView untuk layout yang lebih stabil
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Pastikan index valid
                if (index >= controller.pengaduan.length) {
                  return const SizedBox.shrink();
                }

                final item = controller.pengaduan[index];

                // Tentukan status dan warna berdasarkan status pengaduan
                Color statusColor;
                String statusText;

                switch (item.status?.toUpperCase()) {
                  case 'MENUNGGU':
                    statusColor = Colors.orange;
                    statusText = 'Menunggu';
                    break;
                  case 'TINDAKAN':
                    statusColor = Colors.blue;
                    statusText = 'Tindakan';
                    break;
                  case 'SELESAI':
                    statusColor = Colors.green;
                    statusText = 'Selesai';
                    break;
                  case 'DITOLAK':
                    statusColor = Colors.red;
                    statusText = 'Ditolak';
                    break;
                  default:
                    statusColor = Colors.grey;
                    statusText = item.status ?? 'Tidak Diketahui';
                }

                // Menggunakan SizedBox untuk memberikan batas lebar yang jelas
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    elevation: 3,
                    child: InkWell(
                      onTap: () {
                        // Navigasi ke detail pengaduan
                        Get.toNamed('/warga/detail-pengaduan',
                            arguments: {'id': item.id});
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header dengan warna sesuai status
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.report_problem,
                                        color: statusColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          item.judul ??
                                              'Pengaduan #${index + 1}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: statusColor,
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getStatusIcon(item.status),
                                        size: 14,
                                        color: statusColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Informasi penyaluran bantuan jika ada
                                if (item.penerimaPenyaluran != null)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.volunteer_activism,
                                              color: Colors.blue.shade700,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Bantuan Terkait',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Penyaluran: ${item.namaPenyaluran ?? "Tidak tersedia"}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _buildInfoItem(
                                                      'Jenis',
                                                      item.jenisBantuan ??
                                                          "Tidak tersedia",
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: _buildInfoItem(
                                                      'Jumlah',
                                                      item.jumlahBantuan ??
                                                          "Tidak tersedia",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Deskripsi pengaduan
                                if (item.deskripsi != null &&
                                    item.deskripsi!.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Deskripsi Masalah:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.deskripsi!,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Informasi tanggal
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Dilaporkan pada: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          item.tanggalPengaduan != null
                                              ? DateTimeHelper.formatDateTime(
                                                  item.tanggalPengaduan!)
                                              : '-',
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Footer dengan tombol aksi
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.black12,
                                  width: 1,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigasi ke detail pengaduan
                                    Get.toNamed('/warga/detail-pengaduan',
                                        arguments: {'id': item.id});
                                  },
                                  icon: const Icon(Icons.visibility),
                                  label: const Text('Lihat Detail'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: statusColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: controller.pengaduan.length,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method untuk mendapatkan icon berdasarkan status
  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'MENUNGGU':
        return Icons.hourglass_empty;
      case 'TINDAKAN':
        return Icons.engineering;
      case 'SELESAI':
        return Icons.check_circle;
      case 'DITOLAK':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // Widget untuk item informasi
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
