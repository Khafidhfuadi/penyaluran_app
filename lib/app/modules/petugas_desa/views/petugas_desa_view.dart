import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/dashboard_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/jadwal_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/notifikasi_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/inventaris_view.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class PetugasDesaView extends GetView<PetugasDesaController> {
  const PetugasDesaView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Obx(() {
          switch (controller.activeTabIndex.value) {
            case 0:
              return const Text('Dashboard');
            case 1:
              return const Text('Jadwal Penyaluran');
            case 2:
              return const Text('Notifikasi');
            case 3:
              return const Text('Inventaris');
            default:
              return const Text('Petugas Desa');
          }
        }),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          // Tombol aksi berdasarkan tab yang aktif
          Obx(() {
            final activeTab = controller.activeTabIndex.value;

            // Tombol notifikasi selalu ditampilkan
            final notificationButton = Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    controller.changeTab(2); // Pindah ke tab notifikasi
                  },
                ),
                if (controller.jumlahNotifikasiBelumDibaca.value > 0)
                  Positioned(
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
                  ),
              ],
            );

            // Tombol tambah untuk jadwal dan inventaris
            if (activeTab == 1) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Tambah Jadwal',
                    onPressed: () {
                      // Implementasi untuk menambah jadwal baru
                    },
                  ),
                  notificationButton,
                ],
              );
            } else if (activeTab == 2) {
              return IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Tandai Semua Dibaca',
                onPressed: () {
                  // Implementasi untuk menandai semua notifikasi sebagai dibaca
                },
              );
            } else if (activeTab == 3) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Tambah Inventaris',
                    onPressed: () {
                      // Implementasi untuk menambah inventaris baru
                    },
                  ),
                  notificationButton,
                ],
              );
            } else {
              return notificationButton;
            }
          }),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Obx(() {
        switch (controller.activeTabIndex.value) {
          case 0:
            return const DashboardView();
          case 1:
            return const JadwalView();
          case 2:
            return const NotifikasiView();
          case 3:
            return const InventarisView();
          default:
            return const DashboardView();
        }
      }),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
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
                  controller.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Petugas Desa',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            selected: controller.activeTabIndex.value == 0,
            selectedColor: AppTheme.primaryColor,
            onTap: () {
              controller.changeTab(0);
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Jadwal Penyaluran'),
            selected: controller.activeTabIndex.value == 1,
            selectedColor: AppTheme.primaryColor,
            onTap: () {
              controller.changeTab(1);
              Get.back();
            },
          ),
          ListTile(
            leading: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_outlined),
                if (controller.jumlahNotifikasiBelumDibaca.value > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        controller.jumlahNotifikasiBelumDibaca.value.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: const Text('Notifikasi'),
            selected: controller.activeTabIndex.value == 2,
            selectedColor: AppTheme.primaryColor,
            onTap: () {
              controller.changeTab(2);
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Inventaris'),
            selected: controller.activeTabIndex.value == 3,
            selectedColor: AppTheme.primaryColor,
            onTap: () {
              controller.changeTab(3);
              Get.back();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil'),
            onTap: () {
              // Navigasi ke halaman profil
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Pengaturan'),
            onTap: () {
              // Navigasi ke halaman pengaturan
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: () {
              Get.back();
              controller.logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() => BottomNavigationBar(
          currentIndex: controller.activeTabIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Inventaris',
            ),
          ],
        ));
  }
}
