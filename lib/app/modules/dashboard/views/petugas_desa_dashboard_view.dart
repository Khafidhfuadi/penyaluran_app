import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class PetugasDesaDashboardView extends GetView<DashboardController> {
  const PetugasDesaDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme =
        GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: textTheme,
      ),
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E5077), Color(0xFF5882B1)],
                    transform: GradientRotation(96.93 * 3.14159 / 180),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF2E5077),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Petugas Desa',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      controller.user?.email ?? 'email@example.com',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Beranda'),
                onTap: () {
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Jadwal'),
                onTap: () {
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifikasi'),
                onTap: () {
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Inventaris'),
                onTap: () {
                  Get.back();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: controller.logout,
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan greeting
                    _buildGreetingHeader(textTheme),
                    const SizedBox(height: 20),

                    // Jadwal penyaluran hari ini
                    _buildScheduleCard(
                      textTheme,
                      title: 'Jadwal Penyaluran Hari ini',
                      location: 'Kantor Kepala Desa (Beras)',
                      dateTime: '15 April 2023, 13:00 - 14:00',
                      isToday: true,
                    ),
                    const SizedBox(height: 10),

                    // Jadwal penyaluran mendatang
                    _buildScheduleCard(
                      textTheme,
                      title: 'Jadwal Penyaluran Mendatang',
                      location: 'Balai Desa A (Sembako)',
                      dateTime: '17 April 2023, 13:00 - 14:00',
                      isToday: false,
                    ),
                    const SizedBox(height: 20),

                    // Statistik penyaluran
                    _buildStatisticsRow(textTheme),
                    const SizedBox(height: 20),

                    // Progress penyaluran
                    _buildProgressSection(textTheme),
                    const SizedBox(height: 20),

                    // Daftar penerima
                    _buildRecipientsList(textTheme),
                  ],
                );
              }),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: textTheme.bodySmall,
          unselectedLabelStyle: textTheme.bodySmall,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Inventaris',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang, Ahmad!',
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Kamu Login Sebagai Petugas Desa Jatihurip.',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    TextTheme textTheme, {
    required String title,
    required String location,
    required String dateTime,
    bool isToday = true,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E5077), Color(0xFF5882B1)],
          transform: GradientRotation(96.93 * 3.14159 / 180),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            location,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateTime,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow(TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Penerima', '3', 'Konfirmasi', textTheme),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard('Pengajuan', '1', 'Pengajuan', textTheme),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard('Pengaduan', '1', 'Pengaduan', textTheme),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String count, String subtitle, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E5077), Color(0xFF5882B1)],
          transform: GradientRotation(96.93 * 3.14159 / 180),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Penyaluran',
          style: textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 0.7,
            minHeight: 10,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E5077)),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '70% Selesai',
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E5077),
          ),
        ),
        const SizedBox(height: 10),
        _buildProgressDetailRow('Telah Menerima', 70, textTheme),
        _buildProgressDetailRow('Dijedwalkan', 20, textTheme),
        _buildProgressDetailRow('Belum Dijadwalkan', 10, textTheme),
        const SizedBox(height: 5),
        Text(
          'Total : 100 Penerima, Telah Disalurkan : 70 Penerima, Belum Disalurkan : 30',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDetailRow(String label, int value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: (MediaQuery.of(Get.context!).size.width - 32) *
                      0.7 *
                      (value / 100),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E5077),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$value',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
              onPressed: () {},
              child: Row(
                children: [
                  Text(
                    'Lihat Semua',
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF2E5077),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: const Color(0xFF2E5077),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildRecipientItem(
            'Siti Rahayu', '3201020107030010', 'Selesai', textTheme),
        _buildRecipientItem(
            'Siti Rahayu', '3201020107030010', 'Selesai', textTheme),
        _buildRecipientItem(
            'Siti Rahayu', '3201020107030010', 'Selesai', textTheme),
      ],
    );
  }

  Widget _buildRecipientItem(
      String name, String nik, String status, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          name,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'NIK: $nik',
          style: textTheme.bodyMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
