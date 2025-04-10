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
import 'package:penyaluran_app/app/widgets/app_drawer.dart';
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
    return Obx(() {
      Map<String, List<DrawerMenuItem>> menuCategories = {
        'Menu Utama': [
          DrawerMenuItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            title: 'Dashboard',
            isSelected: controller.activeTabIndex.value == 0,
            onTap: () {
              controller.activeTabIndex.value = 0;
            },
          ),
          DrawerMenuItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            title: 'Skema Bantuan',
            isSelected: controller.activeTabIndex.value == 1,
            onTap: () {
              controller.activeTabIndex.value = 1;
            },
          ),
          DrawerMenuItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today,
            title: 'Jadwal Penyaluran',
            isSelected: controller.activeTabIndex.value == 2,
            onTap: () {
              controller.activeTabIndex.value = 2;
            },
          ),
          DrawerMenuItem(
            icon: Icons.add_box_outlined,
            activeIcon: Icons.add_box,
            title: 'Penitipan Bantuan',
            isSelected: controller.activeTabIndex.value == 3,
            onTap: () {
              controller.activeTabIndex.value = 3;
            },
          ),
          DrawerMenuItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            title: 'Laporan Penyaluran',
            isSelected: controller.activeTabIndex.value == 4,
            onTap: () {
              controller.activeTabIndex.value = 4;
            },
          ),
        ],
        'Pengaturan': [
          DrawerMenuItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            title: 'Profil',
            onTap: () {
              Get.toNamed('/profile');
            },
          ),
          DrawerMenuItem(
            icon: Icons.info_outline,
            activeIcon: Icons.info,
            title: 'Tentang Kami',
            onTap: () {
              Get.toNamed('/about');
            },
          ),
          DrawerMenuItem(
            icon: Icons.logout,
            title: 'Keluar',
            isLogout: true,
            onTap: () {
              controller.logout();
            },
          ),
        ],
      };

      return AppDrawer(
        nama: controller.nama,
        role: 'Donatur',
        desa: controller.desa,
        avatar: controller.profilePhotoUrl,
        menuItems: const [], // Tidak digunakan karena menggunakan menuCategories
        menuCategories: menuCategories,
        onLogout: controller.logout,
        footerText: '© ${DateTime.now().year} DisalurKita',
      );
    });
  }
}
