import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/modules/warga/views/warga_dashboard_view.dart';
import 'package:penyaluran_app/app/modules/warga/views/warga_penerimaan_view.dart';
import 'package:penyaluran_app/app/modules/warga/views/warga_pengaduan_view.dart';
import 'package:penyaluran_app/app/widgets/app_bottom_navigation_bar.dart';
import 'package:penyaluran_app/app/widgets/app_drawer.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class WargaView extends GetView<WargaDashboardController> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  WargaView({super.key});

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
              return const Text('Penerimaan Bantuan');
            case 2:
              return const Text('Pengaduan');
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
        switch (controller.activeTabIndex.value) {
          case 0:
            return const WargaDashboardView();
          case 1:
            return const WargaPenerimaanView();
          case 2:
            return const WargaPengaduanView();
          default:
            return const WargaDashboardView();
        }
      }),
      bottomNavigationBar: Obx(() => AppBottomNavigationBar(
            currentIndex: controller.activeTabIndex.value,
            onTap: controller.changeTab,
            items: [
              AppBottomNavigationBarItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Beranda',
              ),
              AppBottomNavigationBarItem(
                icon: Icons.volunteer_activism_outlined,
                activeIcon: Icons.volunteer_activism,
                label: 'Penerimaan',
                badgeCount: controller.totalPenyaluranDiterima.value > 0
                    ? controller.totalPenyaluranDiterima.value
                    : null,
                badgeColor: Colors.green,
              ),
              AppBottomNavigationBarItem(
                icon: Icons.report_problem_outlined,
                activeIcon: Icons.report_problem,
                label: 'Pengaduan',
                badgeCount: controller.totalPengaduanProses.value > 0
                    ? controller.totalPengaduanProses.value
                    : null,
                badgeColor: Colors.orange,
              ),
            ],
          )),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    // Muat ulang data foto profil ketika drawer dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.fotoProfil.isEmpty) {
        controller.loadUserData();
      }
    });

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
            icon: Icons.volunteer_activism_outlined,
            activeIcon: Icons.volunteer_activism,
            title: 'Penerimaan Bantuan',
            isSelected: controller.activeTabIndex.value == 1,
            badgeCount: controller.totalPenyaluranDiterima.value > 0
                ? controller.totalPenyaluranDiterima.value
                : null,
            badgeColor: Colors.green,
            onTap: () {
              controller.activeTabIndex.value = 1;
            },
          ),
          DrawerMenuItem(
            icon: Icons.report_problem_outlined,
            activeIcon: Icons.report_problem,
            title: 'Pengaduan',
            isSelected: controller.activeTabIndex.value == 2,
            badgeCount: controller.totalPengaduanProses.value > 0
                ? controller.totalPengaduanProses.value
                : null,
            badgeColor: Colors.orange,
            onTap: () {
              controller.activeTabIndex.value = 2;
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
        role: 'Warga',
        desa: controller.desa,
        avatar: controller.fotoProfil.value,
        menuItems: const [], // Tidak digunakan karena menggunakan menuCategories
        menuCategories: menuCategories,
        onLogout: controller.logout,
        footerText: '© ${DateTime.now().year} DisalurKita',
      );
    });
  }
}
