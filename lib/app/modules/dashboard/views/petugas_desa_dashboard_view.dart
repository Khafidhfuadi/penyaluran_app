import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/widgets/navigation_button.dart';
import 'package:penyaluran_app/app/widgets/statistic_card.dart';
import 'package:penyaluran_app/app/widgets/status_pill.dart';

class PetugasDesaDashboardView extends GetView<DashboardController> {
  const PetugasDesaDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
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
                      color: AppTheme.primaryColor,
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
              leading: SvgPicture.asset(
                'assets/icons/home-icon.svg',
                width: 24,
                height: 24,
              ),
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
                  IconButton(
                    onPressed: () => scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu),
                  ),

                  const SizedBox(height: 10),

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
                  const SizedBox(height: 20),

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

                  // Daftar Donasi
                  _buildDonationList(textTheme),
                  // Daftar Donatur
                  _buildDonorsList(textTheme),
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
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/home-icon.svg',
              width: 24,
              height: 24,
            ),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/jadwal-icon.svg',
              width: 24,
              height: 24,
            ),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/notif-icon.svg',
              width: 24,
              height: 24,
            ),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/inventory-icon.svg',
              width: 24,
              height: 24,
            ),
            label: 'Inventaris',
          ),
        ],
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
            color: Colors.grey.withAlpha(26), // 0.1 * 255 ≈ 26
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
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Colors.white.withAlpha(204), // 0.8 * 255 ≈ 204
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
          const SizedBox(height: 8),
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
    );
  }

  Widget _buildProgressSection(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Penyaluran',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.7,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '70% Selesai',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetailRow(String label, int value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 5,
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
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$value%',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientsList(TextTheme textTheme) {
    return _buildList(
      textTheme: textTheme,
      title: 'Daftar Penerima',
      items: [
        {
          'title': 'Siti Rahayu',
          'subtitle': '3201020107030010',
          'status': 'Selesai'
        },
        {
          'title': 'Siti Rahayu',
          'subtitle': '3201020107030010',
          'status': 'Selesai'
        },
        {
          'title': 'Siti Rahayu',
          'subtitle': '3201020107030010',
          'status': 'Selesai'
        },
      ],
      idLabel: 'NIK',
    );
  }

  Widget _buildDonorsList(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Donatur',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Lihat Semua',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDonorItem('PT Sejahtera', 'D-2023-001', textTheme),
        _buildDonorItem('Yayasan Peduli', 'D-2023-002', textTheme),
        _buildDonorItem('CV Makmur', 'D-2023-003', textTheme),
      ],
    );
  }

  Widget _buildDonorItem(String name, String id, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          name,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          id,
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        trailing: NavigationButton(
          label: 'Detail',
          icon: Icons.arrow_forward_ios,
          onPressed: () {},
        ),
      ),
    );
  }

  //daftar donasi
  Widget _buildDonationList(TextTheme textTheme) {
    return _buildList(
      textTheme: textTheme,
      title: 'Daftar Donasi',
      items: [
        {
          'title': 'Rp 100.000',
          'subtitle': 'Siti Rahayu',
          'status': 'Selesai',
        },
        {
          'title': 'Rp 100.000',
          'subtitle': 'Siti Rahayu',
          'status': 'Selesai',
        },
      ],
      idLabel: '',
    );
  }

  Widget _buildList({
    required TextTheme textTheme,
    required String title,
    required List<Map<String, String>> items,
    required String idLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
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
        ...items.map((item) => _buildItem(
              item['title'] ?? '',
              item['subtitle'] ?? '',
              item['status'] ?? '',
              textTheme,
            )),
      ],
    );
  }

  Widget _buildItem(
      String title, String subtitle, String status, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Row(
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            StatusPill(status: status, backgroundColor: AppTheme.verifiedColor),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        trailing: NavigationButton(
          label: 'Detail',
          icon: Icons.arrow_forward_ios,
          onPressed: () {},
        ),
      ),
    );
  }
}
