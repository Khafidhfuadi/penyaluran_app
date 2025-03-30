import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/modules/donatur/views/donatur_dashboard_view.dart';
import 'package:penyaluran_app/app/modules/donatur/views/donatur_skema_view.dart';
import 'package:penyaluran_app/app/modules/donatur/views/donatur_jadwal_view.dart';
import 'package:penyaluran_app/app/modules/donatur/views/donatur_laporan_view.dart';
import 'package:penyaluran_app/app/modules/donatur/views/donatur_penitipan_view.dart';
import 'package:penyaluran_app/app/modules/donatur/views/donatur_riwayat_penitipan_view.dart';
import 'package:penyaluran_app/app/widgets/app_bottom_navigation_bar.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class DonaturView extends GetView<DonaturDashboardController> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  DonaturView({super.key});

  // Override untuk mendapatkan controller dengan tag
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
      key: scaffoldKey,
      appBar: AppBar(
        title: Obx(() {
          switch (controller.activeTabIndex.value) {
            case 0:
              return const Text('Dashboard');
            case 1:
              return const Text('Skema Bantuan');
            case 2:
              return const Text('Jadwal Penyaluran');
            case 3:
              return const Text('Penitipan Bantuan');
            case 4:
              return const Text('Laporan Penyaluran');
            default:
              return const Text('Dashboard');
          }
        }),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          // Tombol riwayat penitipan khusus untuk tab penitipan bantuan
          Obx(() => controller.activeTabIndex.value == 3
              ? IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () {
                    // Navigasi ke halaman riwayat penitipan
                    Get.to(
                      () => DonaturRiwayatPenitipanView(),
                      transition: Transition.rightToLeft,
                    );
                  },
                )
              : const SizedBox.shrink()),
          // Tombol notifikasi
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // Navigasi ke halaman notifikasi
                  Get.toNamed('/notifikasi');
                },
              ),
              Obx(() {
                if (controller.jumlahNotifikasiBelumDibaca.value > 0) {
                  return Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        controller.jumlahNotifikasiBelumDibaca.value.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Obx(() {
        // Tampilkan sesuai dengan tab yang aktif
        switch (controller.activeTabIndex.value) {
          case 0:
            return const DonaturDashboardView();
          case 1:
            return const DonaturSkemaView();
          case 2:
            return const DonaturJadwalView();
          case 3:
            return const DonaturPenitipanView();
          case 4:
            return const DonaturLaporanView();
          default:
            return const DonaturDashboardView();
        }
      }),
      bottomNavigationBar: Obx(() => AppBottomNavigationBar(
            currentIndex: controller.activeTabIndex.value,
            onTap: (index) {
              controller.activeTabIndex.value = index;
            },
            items: [
              AppBottomNavigationBarItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
              ),
              AppBottomNavigationBarItem(
                icon: Icons.description_outlined,
                activeIcon: Icons.description,
                label: 'Skema',
              ),
              AppBottomNavigationBarItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Jadwal',
              ),
              AppBottomNavigationBarItem(
                icon: Icons.add_box_outlined,
                activeIcon: Icons.add_box,
                label: 'Penitipan',
              ),
              AppBottomNavigationBarItem(
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment,
                label: 'Laporan',
              ),
            ],
          )),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 24,
                left: 16,
                right: 16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white70,
                    backgroundImage: controller.profilePhotoUrl != null &&
                            controller.profilePhotoUrl!.isNotEmpty
                        ? NetworkImage(controller.profilePhotoUrl!)
                        : null,
                    child: (controller.profilePhotoUrl == null ||
                            controller.profilePhotoUrl!.isEmpty)
                        ? Text(
                            controller.nama.isNotEmpty
                                ? controller.nama
                                    .toString()
                                    .substring(0, 1)
                                    .toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              fontSize: 24,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Halo,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                Text(
                  controller.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Donatur',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            controller.desa ?? 'Tidak ada desa',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuCategory('Menu Utama'),
                Obx(() => _buildMenuItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      title: 'Dashboard',
                      isSelected: controller.activeTabIndex.value == 0,
                      onTap: () {
                        Navigator.pop(context);
                        controller.activeTabIndex.value = 0;
                      },
                    )),
                Obx(() => _buildMenuItem(
                      icon: Icons.description_outlined,
                      activeIcon: Icons.description,
                      title: 'Skema Bantuan',
                      isSelected: controller.activeTabIndex.value == 1,
                      onTap: () {
                        Navigator.pop(context);
                        controller.activeTabIndex.value = 1;
                      },
                    )),
                Obx(() => _buildMenuItem(
                      icon: Icons.calendar_today_outlined,
                      activeIcon: Icons.calendar_today,
                      title: 'Jadwal Penyaluran',
                      isSelected: controller.activeTabIndex.value == 2,
                      onTap: () {
                        Navigator.pop(context);
                        controller.activeTabIndex.value = 2;
                      },
                    )),
                Obx(() => _buildMenuItem(
                      icon: Icons.add_box_outlined,
                      activeIcon: Icons.add_box,
                      title: 'Penitipan Bantuan',
                      isSelected: controller.activeTabIndex.value == 3,
                      onTap: () {
                        Navigator.pop(context);
                        controller.activeTabIndex.value = 3;
                      },
                    )),
                Obx(() => _buildMenuItem(
                      icon: Icons.assignment_outlined,
                      activeIcon: Icons.assignment,
                      title: 'Laporan Penyaluran',
                      isSelected: controller.activeTabIndex.value == 4,
                      onTap: () {
                        Navigator.pop(context);
                        controller.activeTabIndex.value = 4;
                      },
                    )),
                _buildMenuCategory('Pengaturan'),
                _buildMenuItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  title: 'Profil',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/profile');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  activeIcon: Icons.info,
                  title: 'Tentang Kami',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/about');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Keluar',
                  onTap: () {
                    Navigator.pop(context);
                    controller.logout();
                  },
                  isLogout: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '© ${DateTime.now().year} DisalurKita',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    IconData? activeIcon,
    required String title,
    bool isSelected = false,
    String? badge,
    required Function() onTap,
    bool isLogout = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          isSelected ? (activeIcon ?? icon) : icon,
          color: isSelected
              ? AppTheme.primaryColor
              : (isLogout ? Colors.red : null),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? AppTheme.primaryColor
                : (isLogout ? Colors.red : null),
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
