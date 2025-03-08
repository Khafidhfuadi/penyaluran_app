import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class JadwalView extends GetView<PetugasDesaController> {
  const JadwalView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan jadwal
            _buildJadwalSummary(context),

            const SizedBox(height: 20),
            // Jadwal hari ini
            _buildJadwalSection(
              textTheme,
              title: 'Hari Ini',
              jadwalList: [
                {
                  'lokasi': 'Kantor Kepala Desa',
                  'jenisBantuan': 'Beras',
                  'tanggal': '15 April 2023',
                  'waktu': '13:00 - 14:00',
                  'status': 'Aktif',
                },
              ],
            ),

            const SizedBox(height: 20),

            // Jadwal mendatang
            _buildJadwalSection(
              textTheme,
              title: 'Mendatang',
              jadwalList: [
                {
                  'lokasi': 'Balai Desa A',
                  'jenisBantuan': 'Sembako',
                  'tanggal': '17 April 2023',
                  'waktu': '13:00 - 14:00',
                  'status': 'Terjadwal',
                },
                {
                  'lokasi': 'Balai Desa B',
                  'jenisBantuan': 'Uang Tunai',
                  'tanggal': '20 April 2023',
                  'waktu': '10:00 - 12:00',
                  'status': 'Terjadwal',
                },
              ],
            ),

            const SizedBox(height: 20),

            // Jadwal selesai
            _buildJadwalSection(
              textTheme,
              title: 'Selesai',
              jadwalList: [
                {
                  'lokasi': 'Kantor Kepala Desa',
                  'jenisBantuan': 'Beras',
                  'tanggal': '10 April 2023',
                  'waktu': '13:00 - 14:00',
                  'status': 'Selesai',
                },
                {
                  'lokasi': 'Balai Desa C',
                  'jenisBantuan': 'Sembako',
                  'tanggal': '5 April 2023',
                  'waktu': '09:00 - 11:00',
                  'status': 'Selesai',
                },
              ],
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
                child: _buildSummaryItem(
                  context,
                  icon: Icons.pending_actions,
                  title: 'Terjadwal',
                  value: '5',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.event_available,
                  title: 'Aktif',
                  value: '1',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.event_busy,
                  title: 'Selesai',
                  value: '12',
                  color: Colors.grey,
                ),
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

  Widget _buildJadwalSection(
    TextTheme textTheme, {
    required String title,
    required List<Map<String, String>> jadwalList,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...jadwalList.map((jadwal) => _buildJadwalItem(textTheme, jadwal)),
      ],
    );
  }

  Widget _buildJadwalItem(TextTheme textTheme, Map<String, String> jadwal) {
    Color statusColor;
    switch (jadwal['status']) {
      case 'Aktif':
        statusColor = Colors.green;
        break;
      case 'Terjadwal':
        statusColor = Colors.blue;
        break;
      case 'Selesai':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
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
                  jadwal['lokasi'] ?? '',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    jadwal['status'] ?? '',
                    style: textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Jenis Bantuan: ${jadwal['jenisBantuan'] ?? ''}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tanggal: ${jadwal['tanggal'] ?? ''}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Waktu: ${jadwal['waktu'] ?? ''}',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
