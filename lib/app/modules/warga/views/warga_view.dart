import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/modules/warga/views/warga_dashboard_view.dart';
import 'package:penyaluran_app/app/modules/warga/views/warga_penyaluran_view.dart';
import 'package:penyaluran_app/app/modules/warga/views/warga_pengaduan_view.dart';
import 'package:penyaluran_app/app/widgets/app_drawer.dart';
import 'package:penyaluran_app/app/widgets/app_bottom_navigation_bar.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class WargaView extends GetView<WargaDashboardController> {
  const WargaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Obx(() {
          switch (controller.activeTabIndex.value) {
            case 0:
              return const Text('Dashboard Warga');
            case 1:
              return const Text('Penyaluran Bantuan');
            case 2:
              return const Text('Pengaduan');
            default:
              return const Text('Dashboard Warga');
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
      drawer: Obx(() => AppDrawer(
            nama: controller.nama,
            role: 'Warga',
            desa: controller.desa,
            notificationCount: controller.jumlahNotifikasiBelumDibaca.value,
            onLogout: controller.logout,
            menuItems: [
              DrawerMenuItem(
                icon: Icons.dashboard_outlined,
                title: 'Dashboard',
                isSelected: controller.activeTabIndex.value == 0,
                onTap: () => controller.changeTab(0),
              ),
              DrawerMenuItem(
                icon: Icons.volunteer_activism_outlined,
                title: 'Penyaluran',
                isSelected: controller.activeTabIndex.value == 1,
                onTap: () => controller.changeTab(1),
              ),
              DrawerMenuItem(
                icon: Icons.report_problem_outlined,
                title: 'Pengaduan',
                isSelected: controller.activeTabIndex.value == 2,
                badgeCount: controller.totalPengaduanProses.value,
                badgeColor: Colors.orange,
                onTap: () => controller.changeTab(2),
              ),
              DrawerMenuItem(
                icon: Icons.assignment_outlined,
                title: 'Pengajuan Kelayakan',
                onTap: () {
                  // TODO: Navigasi ke halaman pengajuan kelayakan
                  Get.toNamed('/pengajuan-kelayakan');
                },
                badgeCount: controller.totalPengajuanMenunggu.value,
                badgeColor: Colors.blue,
              ),
            ],
          )),
      body: Obx(() {
        switch (controller.activeTabIndex.value) {
          case 0:
            return const WargaDashboardView();
          case 1:
            return const WargaPenyaluranView();
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
                label: 'Penyaluran',
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
      floatingActionButton: Obx(() {
        // Tampilkan FAB hanya di halaman pengaduan
        if (controller.activeTabIndex.value == 2) {
          return FloatingActionButton(
            onPressed: () {
              // TODO: Implementasi navigasi ke halaman buat pengaduan
              Get.toNamed('/buat-pengaduan');
            },
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}
