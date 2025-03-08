import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/components/jadwal_section_widget.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/components/permintaan_penjadwalan_summary_widget.dart';

class PenyaluranView extends GetView<PetugasDesaController> {
  const PenyaluranView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan jadwal
            _buildJadwalSummary(context),

            const SizedBox(height: 20),

            // Ringkasan Permintaan Penjadwalan
            PermintaanPenjadwalanSummaryWidget(controller: controller),

            const SizedBox(height: 20),

            // Jadwal hari ini
            JadwalSectionWidget(
              controller: controller,
              title: 'Hari Ini',
              jadwalList: controller.jadwalHariIni,
              status: 'Aktif',
            ),

            const SizedBox(height: 20),

            // Jadwal mendatang
            JadwalSectionWidget(
              controller: controller,
              title: 'Mendatang',
              jadwalList: controller.jadwalMendatang,
              status: 'Terjadwal',
            ),

            const SizedBox(height: 20),

            // Jadwal selesai
            JadwalSectionWidget(
              controller: controller,
              title: 'Selesai',
              jadwalList: controller.jadwalSelesai,
              status: 'Selesai',
            ),
          ],
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
                      value: '${controller.jadwalHariIni.length}',
                      color: Colors.green,
                    )),
              ),
              Expanded(
                child: Obx(() => _buildSummaryItem(
                      context,
                      icon: Icons.event_busy,
                      title: 'Selesai',
                      value: '${controller.jadwalSelesai.length}',
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
