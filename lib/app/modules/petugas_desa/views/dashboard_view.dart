import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/components/greeting_header.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/components/progress_section.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/components/schedule_card.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/widgets/statistic_card.dart';

class DashboardView extends GetView<PetugasDesaController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan greeting
            GreetingHeader(
              name: controller.roleData.value?['namaLengkap'] ?? 'Ahmad',
              role: 'Petugas Desa',
              desa: controller.roleData.value?['Desa'] ?? 'Jatihurip',
            ),
            const SizedBox(height: 20),

            // Jadwal penyaluran hari ini
            ScheduleCard(
              title: 'Jadwal Penyaluran Hari ini',
              location: 'Kantor Kepala Desa (Beras)',
              dateTime: '15 April 2023, 13:00 - 14:00',
              isToday: true,
              onTap: () => Get.toNamed('/petugas-desa/jadwal'),
            ),
            const SizedBox(height: 20),

            // Jadwal penyaluran mendatang
            ScheduleCard(
              title: 'Jadwal Penyaluran Mendatang',
              location: 'Balai Desa A (Sembako)',
              dateTime: '17 April 2023, 13:00 - 14:00',
              isToday: false,
              onTap: () => Get.toNamed('/petugas-desa/jadwal'),
            ),
            const SizedBox(height: 20),

            // Statistik penyaluran
            Row(
              children: [
                Expanded(
                  child: StatisticCard(
                    title: 'Penitipan',
                    count: '3',
                    subtitle: 'Perlu Konfirmasi',
                    height: 120,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatisticCard(
                    title: 'Penjadwalan',
                    count: '1',
                    subtitle: 'Perlu Konfirmasi',
                    height: 120,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatisticCard(
                    title: 'Pengaduan',
                    count: '1',
                    subtitle: 'Perlu Tindakan',
                    height: 120,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress penyaluran
            ProgressSection(
              progressValue: 0.7,
              total: 100,
              distributed: 70,
              scheduled: 20,
              unscheduled: 10,
            ),
            const SizedBox(height: 20),

            // Daftar penerima
            _buildRecipientsList(textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientsList(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Penerima',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed('/daftar-penerima');
              },
              child: Row(
                children: [
                  Text(
                    'Lihat Semua',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildRecipientItem(
            'Siti Rahayu', '3201020107030011', 'Selesai', textTheme),
        _buildRecipientItem(
            'Budi Santoso', '3201020107030012', 'Selesai', textTheme),
        _buildRecipientItem(
            'Dewi Lestari', '3201020107030013', 'Selesai', textTheme),
      ],
    );
  }

  Widget _buildRecipientItem(
      String name, String nik, String status, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigasi ke detail penerima dengan ID statis
          // Kita gunakan ID 1 untuk Siti Rahayu, 2 untuk Budi Santoso, 3 untuk Dewi Lestari
          String id = "1"; // Default
          if (nik == "3201020107030011") {
            id = "2";
          } else if (nik == "3201020107030012") {
            id = "3";
          }
          Get.toNamed('/daftar-penerima/detail', arguments: id);
        },
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          title: Text(
            name,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            'NIK: $nik',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
