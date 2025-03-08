import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class NotifikasiView extends GetView<PetugasDesaController> {
  const NotifikasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifikasi hari ini
            _buildNotifikasiSection(
              textTheme,
              title: 'Hari Ini',
              notifikasiList: [
                {
                  'judul': 'Jadwal Penyaluran Baru',
                  'pesan':
                      'Jadwal penyaluran beras telah ditambahkan untuk hari ini',
                  'waktu': '08:30',
                  'dibaca': false,
                },
                {
                  'judul': 'Pengajuan Bantuan Baru',
                  'pesan':
                      'Ada 3 pengajuan bantuan baru yang perlu diverifikasi',
                  'waktu': '10:15',
                  'dibaca': false,
                },
              ],
            ),

            const SizedBox(height: 20),

            // Notifikasi kemarin
            _buildNotifikasiSection(
              textTheme,
              title: 'Kemarin',
              notifikasiList: [
                {
                  'judul': 'Laporan Penyaluran',
                  'pesan':
                      'Laporan penyaluran bantuan tanggal 14 April 2023 telah selesai',
                  'waktu': '16:45',
                  'dibaca': true,
                },
                {
                  'judul': 'Pengaduan Warga',
                  'pesan':
                      'Ada pengaduan baru dari warga yang perlu ditindaklanjuti',
                  'waktu': '14:20',
                  'dibaca': true,
                },
              ],
            ),

            const SizedBox(height: 20),

            // Notifikasi minggu ini
            _buildNotifikasiSection(
              textTheme,
              title: 'Minggu Ini',
              notifikasiList: [
                {
                  'judul': 'Perubahan Jadwal',
                  'pesan':
                      'Jadwal penyaluran bantuan di Balai Desa A diubah menjadi tanggal 17 April 2023',
                  'waktu': 'Sen, 13:00',
                  'dibaca': true,
                },
                {
                  'judul': 'Donasi Baru',
                  'pesan':
                      'PT Sejahtera telah mengirimkan donasi baru berupa sembako',
                  'waktu': 'Sen, 09:30',
                  'dibaca': true,
                },
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifikasiSection(
    TextTheme textTheme, {
    required String title,
    required List<Map<String, dynamic>> notifikasiList,
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
        ...notifikasiList
            .map((notifikasi) => _buildNotifikasiItem(textTheme, notifikasi)),
      ],
    );
  }

  Widget _buildNotifikasiItem(
      TextTheme textTheme, Map<String, dynamic> notifikasi) {
    final bool dibaca = notifikasi['dibaca'] as bool;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: dibaca ? Colors.white : Colors.blue.shade50,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!dibaca)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5, right: 10),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notifikasi['judul'] ?? '',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        notifikasi['waktu'] ?? '',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notifikasi['pesan'] ?? '',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
