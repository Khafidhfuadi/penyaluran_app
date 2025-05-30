import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/components/jadwal_section_widget.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/components/calendar_view_widget.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/tambah_penyaluran_view.dart';

class PenyaluranView extends GetView<JadwalPenyaluranController> {
  const PenyaluranView({super.key});
  @override
  Widget build(BuildContext context) {
    // Memastikan controller tersedia
    if (!Get.isRegistered<JadwalPenyaluranController>()) {
      Get.put(JadwalPenyaluranController());
    }

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
}
