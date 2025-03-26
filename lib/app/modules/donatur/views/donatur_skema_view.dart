import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';

class DonaturSkemaView extends GetView<DonaturDashboardController> {
  const DonaturSkemaView({super.key});

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
            await controller.fetchSkemaBantuan();
          },
          child: controller.skemaBantuan.isEmpty
              ? _buildEmptyState()
              : _buildSkemaList(),
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
              Icons.description_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Skema Bantuan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Skema bantuan belum tersedia saat ini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.fetchSkemaBantuan(),
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

  Widget _buildSkemaList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Skema Bantuan Tersedia'),
        Text(
          'Daftar skema bantuan yang dapat Anda titipkan',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        ...controller.skemaBantuan.map((skema) => _buildSkemaCard(skema)),
      ],
    );
  }

  Widget _buildSkemaCard(dynamic skema) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.volunteer_activism,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skema.nama ?? 'Skema Bantuan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (skema.kuota != null)
                          _buildInfoChip(
                            icon: Icons.people_outline,
                            label: 'Kuota: ${skema.kuota} penerima',
                            color: Colors.blue.shade700,
                          ),
                        if (skema.jumlahDiterimaPerOrang != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: _buildInfoChip(
                              icon: Icons.inventory_2_outlined,
                              label:
                                  'Jumlah per orang: ${skema.jumlahDiterimaPerOrang}',
                              color: Colors.green.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (skema.deskripsi != null && skema.deskripsi!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skema.deskripsi!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Divider(height: 24),
                  ],
                ),
              if (skema.kriteria != null && skema.kriteria!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kriteria Penerima',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skema.kriteria!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigasi ke formulir penitipan bantuan
                  controller.activeTabIndex.value = 3;
                },
                icon: const Icon(Icons.add_box_outlined, size: 18),
                label: const Text('Titipkan Bantuan'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green.shade600,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
