import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/components/greeting_header.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/components/schedule_card.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_dashboard_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/widgets/cards/statistic_card.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DashboardView extends GetView<PetugasDesaDashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      child: Obx(() => AnimationLimiter(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : AnimationConfiguration.staggeredList(
                        position: 0,
                        delay: const Duration(milliseconds: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header DisalurKita dengan logo dan slogan
                            FadeInAnimation(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/logo-disalurkita.png',
                                      width: 50,
                                      height: 50,
                                    ),
                                    const SizedBox(width: 15),
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'DisalurKita',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1565C0),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Salurkan dengan Pasti, Pantau dengan Bukti',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Header dengan greeting
                            FadeInAnimation(
                              child: GreetingHeader(
                                name: controller.namaLengkap,
                                role: 'Petugas Desa',
                                desa: controller.desa,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Jadwal penyaluran hari ini
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 300),
                              child: _buildJadwalHariIni(),
                            ),
                            const SizedBox(height: 20),

                            // Progress penyaluran
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 400),
                              child: _buildProgressPenyaluran(),
                            ),
                            const SizedBox(height: 20),

                            // Statistik performa desa
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 500),
                              child: _buildStatistikPerforma(),
                            ),
                            const SizedBox(height: 20),

                            // Daftar penerima terbaru
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 600),
                              child: _buildRecipientsList(textTheme),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          )),
    );
  }

  Widget _buildJadwalHariIni() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal Penyaluran Hari Ini',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>?>(
          future: SupabaseService.to.getJadwalAktif(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Gagal memuat jadwal'));
            }

            final jadwalList = snapshot.data;

            if (jadwalList == null || jadwalList.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.event_busy, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Tidak ada jadwal penyaluran hari ini'),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jadwalList.length,
              itemBuilder: (context, index) {
                final jadwal = jadwalList[index];
                final DateTime tanggal =
                    DateTime.parse(jadwal['tanggal_penyaluran']);
                final String formattedDate =
                    FormatHelper.formatDateTime(tanggal);
                final kategoriBantuan =
                    jadwal['kategori_bantuan'] as Map<String, dynamic>;
                final lokasiPenyaluran =
                    jadwal['lokasi_penyaluran'] as Map<String, dynamic>;

                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: 10),
                    ScheduleCard(
                      title: kategoriBantuan['nama'] ?? 'Jadwal Penyaluran',
                      location:
                          lokasiPenyaluran['nama'] ?? 'Lokasi tidak tersedia',
                      dateTime: formattedDate,
                      isToday: true,
                      onTap: () => Get.toNamed(Routes.detailPenyaluran,
                          parameters: {'id': jadwal['id']}),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressPenyaluran() {
    // Menghitung nilai untuk progress berdasarkan status
    final terlaksana = controller.penyaluranTerlaksana.value;
    final batal = controller.penyaluranBatal.value;
    final dijadwalkan = controller.penyaluranDijadwalkan.value;
    final aktif = controller.penyaluranAktif.value;

    final total = terlaksana + batal + dijadwalkan + aktif;
    final progressValue = total > 0 ? (terlaksana + batal) / total : 0.0;
    final belumTerlaksana = dijadwalkan +
        aktif; // Yang belum terlaksana adalah yang dijadwalkan dan aktif

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Penyaluran',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 10.0,
                percent: progressValue > 1.0 ? 1.0 : progressValue,
                center: Text(
                  '${(progressValue * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                progressColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1200,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressDetailItem(
                      'Telah Terlaksana',
                      '$terlaksana',
                      Colors.white,
                    ),
                    const SizedBox(height: 8),
                    _buildProgressDetailItem(
                      'Belum Terlaksana',
                      '$belumTerlaksana',
                      Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 8),
                    _buildProgressDetailItem(
                      'Dibatalkan',
                      '$batal',
                      Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 8),
                    _buildProgressDetailItem(
                      'Total Penyaluran',
                      '$total',
                      Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetailItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistikPerforma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Performa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatisticCard(
                title: 'Penitipan',
                count: controller.jumlahMenunggu.value.toString(),
                subtitle: 'Perlu Konfirmasi',
                height: 120,
                icon: Icons.inbox,
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatisticCard(
                title: 'Pengaduan',
                count: controller.jumlahDiproses.value.toString(),
                subtitle: 'Perlu Tindakan',
                height: 120,
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.warning_amber,
              ),
            ),
          ],
        ),
      ],
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
              'Daftar Penerima Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(Routes.daftarPenerima);
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
        FutureBuilder<List<Map<String, dynamic>>?>(
          future: SupabaseService.to.getPenerimaTerbaru(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Gagal memuat data penerima'));
            }

            final penerimaList = snapshot.data;

            if (penerimaList == null || penerimaList.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_off, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Belum ada data penerima'),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: penerimaList.length > 3 ? 3 : penerimaList.length,
              itemBuilder: (context, index) {
                final penerima = penerimaList[index];
                final name = penerima['nama_lengkap'] ?? 'Nama tidak tersedia';
                final nik = penerima['nik'] ?? 'NIK tidak tersedia';
                final status = penerima['status'] ?? 'AKTIF';
                final id = penerima['id'] ?? 'ID tidak tersedia';
                final fotoProfil = penerima['foto_profil'] ?? null;

                return _buildRecipientItem(
                    name, nik, status, id, textTheme, fotoProfil);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecipientItem(String name, String nik, String status, String id,
      TextTheme textTheme, String? fotoProfil) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(Routes.detailPenerima, arguments: id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage:
                    fotoProfil != null && fotoProfil.toString().isNotEmpty
                        ? NetworkImage(fotoProfil)
                        : null,
                child: (fotoProfil == null || fotoProfil.toString().isEmpty)
                    ? Text(
                        name.toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'NIK: $nik',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
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
            ],
          ),
        ),
      ),
    );
  }
}
