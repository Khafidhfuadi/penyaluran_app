import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';

class DonaturLaporanView extends GetView<DonaturDashboardController> {
  const DonaturLaporanView({super.key});

  @override
  DonaturDashboardController get controller {
    if (!Get.isRegistered<DonaturDashboardController>(
        tag: 'donatur_dashboard')) {
      return Get.put(DonaturDashboardController(),
          tag: 'donatur_dashboard', permanent: true);
    }
    return Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchLaporanPenyaluran();
          },
          child: controller.laporanPenyaluran.isEmpty
              ? _buildEmptyState()
              : _buildLaporanList(),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Laporan Penyaluran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Laporan penyaluran bantuan belum tersedia',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.fetchLaporanPenyaluran(),
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaporanList() {
    // Urutkan laporan berdasarkan tanggal, yang terbaru di atas
    final sortedLaporan = controller.laporanPenyaluran.toList()
      ..sort((a, b) {
        if (a.tanggalLaporan == null || b.tanggalLaporan == null) {
          return 0;
        }
        return b.tanggalLaporan!.compareTo(a.tanggalLaporan!);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Laporan Penyaluran Bantuan'),
        Text(
          'Daftar laporan hasil penyaluran bantuan',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        ...sortedLaporan.map((laporan) => _buildLaporanCard(laporan)),
      ],
    );
  }

  Widget _buildLaporanCard(dynamic laporan) {
    final formattedDate = laporan.tanggalLaporan != null
        ? DateFormat('dd MMMM yyyy', 'id_ID').format(laporan.tanggalLaporan!)
        : 'Tanggal tidak tersedia';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: laporan.dokumentasiUrl != null &&
                            laporan.dokumentasiUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              laporan.dokumentasiUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.assignment,
                                  color: Colors.blue.shade700,
                                  size: 30,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.assignment,
                            color: Colors.blue.shade700,
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          laporan.judul,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (laporan.beritaAcaraUrl != null &&
                                laporan.beritaAcaraUrl!.isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Implementasi untuk membuka berita acara
                                  _openDocument(laporan.beritaAcaraUrl!);
                                },
                                icon: const Icon(Icons.description, size: 16),
                                label: const Text('Berita Acara'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(30, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                            if (laporan.dokumentasiUrl != null &&
                                laporan.dokumentasiUrl!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Implementasi untuk melihat dokumentasi
                                  _viewDocumentation(laporan.dokumentasiUrl!);
                                },
                                icon: const Icon(Icons.photo_library, size: 16),
                                label: const Text('Dokumentasi'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(30, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
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

  void _openDocument(String url) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Buka Dokumen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Anda akan membuka dokumen berita acara. Lanjutkan?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      // Implementasi untuk membuka URL dokumen
                      // Misalnya menggunakan package url_launcher
                      // launch(url);
                      Get.snackbar(
                        'Info',
                        'Membuka dokumen: $url',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Buka'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewDocumentation(String url) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dokumentasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: Get.height * 0.6,
                maxWidth: Get.width,
              ),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 50,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text('Gagal memuat gambar'),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
