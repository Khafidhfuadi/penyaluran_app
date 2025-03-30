import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/components/jadwal_section_widget.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/components/calendar_view_widget.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/tambah_penyaluran_view.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';

class PenyaluranView extends GetView<JadwalPenyaluranController> {
  const PenyaluranView({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: 'Daftar Jadwal'),
                Tab(text: 'Kalender'),
              ],
              labelColor: AppTheme.primaryColor,
              indicatorColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Daftar Jadwal
                  _buildJadwalListView(),

                  // Tab 2: Kalender
                  _buildCalendarView(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol untuk menambah jadwal penyaluran
            FloatingActionButton.extended(
              heroTag: 'tambahJadwal',
              onPressed: () => Get.to(() => const TambahPenyaluranView()),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Tambah Jadwal',
                  style: TextStyle(color: Colors.white)),
              elevation: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalListView() {
    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ringkasan jadwal
                _buildJadwalSummary(Get.context!),

                const SizedBox(height: 16),

                // Tombol untuk mengelola lokasi penyaluran
                _buildLokasiPenyaluranSection(),

                const SizedBox(height: 24),

                // Jadwal hari ini
                JadwalSectionWidget(
                  controller: controller,
                  title: 'Penyaluran Aktif',
                  jadwalList: controller.jadwalAktif,
                  status: 'Aktif',
                ),

                const SizedBox(height: 24),

                // Jadwal mendatang
                JadwalSectionWidget(
                  controller: controller,
                  title: '7 Hari Mendatang',
                  jadwalList: controller.jadwalMendatang,
                  status: 'Terjadwal',
                ),

                const SizedBox(height: 60),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return CalendarViewWidget(controller: controller);
          }),
        ),
      ),
    );
  }

  Widget _buildJadwalSummary(BuildContext context) {
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
            'Ringkasan Jadwal',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildSummaryItem(
                      context,
                      icon: Icons.pending_actions,
                      title: 'Terjadwal',
                      value: '${controller.jadwalMendatang.length}',
                      color: Colors.blue,
                    )),
              ),
              Expanded(
                child: Obx(() => _buildSummaryItem(
                      context,
                      icon: Icons.event_available,
                      title: 'Aktif',
                      value: '${controller.jadwalAktif.length}',
                      color: Colors.green,
                    )),
              ),
              Expanded(
                child: Obx(() => _buildSummaryItem(
                      context,
                      icon: Icons.event_note,
                      title: 'Terlaksana',
                      value: '${controller.jadwalTerlaksana.length}',
                      color: Colors.grey,
                    )),
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

  // Widget untuk menampilkan section lokasi penyaluran
  Widget _buildLokasiPenyaluranSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100, width: 1),
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
                  'Lokasi Penyaluran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // Menampilkan dialog daftar lokasi penyaluran
                    _showLokasiPenyaluranDialog();
                  },
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('Lihat Lokasi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue.shade300),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Kelola lokasi penyaluran bantuan untuk masyarakat dengan lebih mudah',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(Routes.tambahLokasiPenyaluran),
              icon: const Icon(Icons.add_location, size: 16),
              label: const Text('Tambah Lokasi Penyaluran Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog daftar lokasi penyaluran
  void _showLokasiPenyaluranDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Lokasi Penyaluran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                constraints: BoxConstraints(
                  maxHeight: Get.height * 0.5,
                ),
                width: double.infinity,
                child: Obx(() {
                  if (controller.isLokasiLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.lokasiPenyaluranCache.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada lokasi penyaluran',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.back();
                              Get.toNamed(Routes.tambahLokasiPenyaluran);
                            },
                            icon: const Icon(Icons.add_location),
                            label: const Text('Tambah Lokasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.lokasiPenyaluranCache.length,
                    itemBuilder: (context, index) {
                      final lokasi = controller.lokasiPenyaluranCache.values
                          .elementAt(index);
                      final lokasiId = controller.lokasiPenyaluranCache.keys
                          .elementAt(index);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            lokasi.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (lokasi.alamat != null &&
                                  lokasi.alamat!.isNotEmpty)
                                Text(lokasi.alamat!),
                              Row(
                                children: [
                                  if (lokasi.isLokasiTitip)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Lokasi Penitipan',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(Routes.tambahLokasiPenyaluran);
                    },
                    child: const Text('Tambah Lokasi Baru'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
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
}
