import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';

class WargaPengaduanView extends GetView<WargaDashboardController> {
  const WargaPengaduanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () async {
          controller.fetchData();
        },
        child: controller.pengaduan.isEmpty
            ? _buildEmptyState()
            : _buildPengaduanList(),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_problem,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Pengaduan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda belum membuat pengaduan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implementasi navigasi ke halaman buat pengaduan
              Get.toNamed('/buat-pengaduan');
            },
            icon: const Icon(Icons.add),
            label: const Text('Buat Pengaduan Baru'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengaduanList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.pengaduan.length,
      itemBuilder: (context, index) {
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

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () {
              // Navigasi ke detail pengaduan
              Get.toNamed('/warga/detail-pengaduan',
                  arguments: {'id': item.id});
            },
            borderRadius: BorderRadius.circular(12),
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
                          item.judul ?? 'Pengaduan #${index + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor,
                          ),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Informasi penyaluran bantuan
                  if (item.penerimaPenyaluran != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Penyaluran: ${item.namaPenyaluran}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Jenis: ${item.jenisBantuan}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Jumlah: ${item.jumlahBantuan}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  if (item.deskripsi != null && item.deskripsi!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        item.deskripsi!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.tanggalPengaduan != null
                            ? DateTimeHelper.formatDateTime(
                                item.tanggalPengaduan!)
                            : '-',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // Navigasi ke detail pengaduan
                          Get.toNamed('/warga/detail-pengaduan',
                              arguments: {'id': item.id});
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('Lihat Detail'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
