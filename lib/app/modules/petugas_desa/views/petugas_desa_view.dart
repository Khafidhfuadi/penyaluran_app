import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/dashboard_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/penyaluran_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/notifikasi_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/stok_bantuan_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/riwayat_stok_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/penitipan_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/pengaduan_view.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/riwayat_stok_controller.dart';
import 'package:penyaluran_app/app/widgets/app_drawer.dart';

class PetugasDesaView extends GetView<PetugasDesaController> {
  const PetugasDesaView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    // Perbarui counter pengaduan secara manual saat aplikasi dimulai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updatePengaduanCounter();
    });

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Obx(() {
          switch (controller.activeTabIndex.value) {
            case 0:
              return const Text('Dashboard');
            case 1:
              return const Text('Penyaluran');
            case 2:
              return const Text('Penitipan');
            case 3:
              return const Text('Pengaduan');
            case 4:
              return const Text('Stok Bantuan');
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
                    // Navigasi ke halaman notifikasi
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotifikasiView(),
                      ),
                    );
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

            // Tampilkan tombol riwayat hanya jika tab Penitipan aktif
            if (activeTab == 2) {
              return Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.toNamed('/petugas-desa/riwayat-penitipan');
                    },
                    icon: const Icon(Icons.history),
                    tooltip: 'Riwayat Penitipan',
                  ),
                  notificationButton,
                ],
              );
            }

            // Tampilkan tombol riwayat jika tab Penyaluran aktif
            if (activeTab == 1) {
              return Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.toNamed('/petugas-desa/riwayat-penyaluran');
                    },
                    icon: const Icon(Icons.history),
                    tooltip: 'Riwayat Penyaluran',
                  ),
                  notificationButton,
                ],
              );
            }

            // if 3
            if (activeTab == 3) {
              return Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.toNamed('/petugas-desa/riwayat-pengaduan');
                    },
                    icon: const Icon(Icons.history),
                    tooltip: 'Riwayat Pengaduan',
                  ),
                  notificationButton,
                ],
              );
            }

            // Tampilkan tombol riwayat stok jika tab Stok Bantuan aktif
            if (activeTab == 4) {
              return Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigasi ke halaman riwayat stok
                      if (!Get.isRegistered<RiwayatStokController>()) {
                        Get.put(RiwayatStokController());
                      }
                      Get.to(() => const RiwayatStokView());
                    },
                    icon: const Icon(Icons.history),
                    tooltip: 'Riwayat Stok',
                  ),
                  notificationButton,
                ],
              );
            }

            return notificationButton;
          }),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Obx(() {
        switch (controller.activeTabIndex.value) {
          case 0:
            return const DashboardView();
          case 1:
            return const PenyaluranView();
          case 2:
            return const PenitipanView();
          case 3:
            return const PengaduanView();
          case 4:
            return const StokBantuanView();
          default:
            return const DashboardView();
        }
      }),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
            icon: Icons.volunteer_activism_outlined,
            activeIcon: Icons.volunteer_activism,
            title: 'Penyaluran',
            isSelected: controller.activeTabIndex.value == 1,
            badgeCount: controller.jumlahMenunggu.value > 0
                ? controller.jumlahMenunggu.value
                : null,
            badgeColor: Colors.green,
            onTap: () {
              controller.activeTabIndex.value = 1;
            },
          ),
          DrawerMenuItem(
            icon: Icons.inbox_outlined,
            activeIcon: Icons.inbox,
            title: 'Penitipan',
            isSelected: controller.activeTabIndex.value == 2,
            onTap: () {
              controller.activeTabIndex.value = 2;
            },
          ),
          DrawerMenuItem(
            icon: Icons.report_problem_outlined,
            activeIcon: Icons.report_problem,
            title: 'Pengaduan',
            isSelected: controller.activeTabIndex.value == 3,
            badgeCount: controller.jumlahDiproses.value > 0
                ? controller.jumlahDiproses.value
                : null,
            badgeColor: Colors.orange,
            onTap: () {
              controller.activeTabIndex.value = 3;
            },
          ),
          DrawerMenuItem(
            icon: Icons.inventory_outlined,
            activeIcon: Icons.inventory,
            title: 'Stok Bantuan',
            isSelected: controller.activeTabIndex.value == 4,
            onTap: () {
              controller.activeTabIndex.value = 4;
            },
          ),
        ],
        'Pengaturan': [
          DrawerMenuItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            title: 'Notifikasi',
            badgeCount: controller.jumlahNotifikasiBelumDibaca.value > 0
                ? controller.jumlahNotifikasiBelumDibaca.value
                : null,
            badgeColor: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotifikasiView(),
                ),
              );
            },
          ),
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
        nama: controller.namaLengkap,
        role: 'Petugas Desa',
        desa: controller.desa,
        avatar: controller.profilePhotoUrl,
        menuItems: const [], // Tidak digunakan karena menggunakan menuCategories
        menuCategories: menuCategories,
        onLogout: controller.logout,
        footerText: '© ${DateTime.now().year} DisalurKita',
      );
    });
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() {
      return BottomNavigationBar(
        currentIndex: controller.activeTabIndex.value,
        onTap: controller.changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined),
                if (controller.jadwalHariIni.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        controller.jadwalHariIni.length.toString(),
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
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.calendar_today),
                if (controller.jadwalHariIni.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        controller.jadwalHariIni.length.toString(),
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
            label: 'Penyaluran',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.handshake_outlined),
                if (controller.jumlahMenunggu.value > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        controller.jumlahMenunggu.value.toString(),
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
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.handshake),
                if (controller.jumlahMenunggu.value > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        controller.jumlahMenunggu.value.toString(),
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
            label: 'Penitipan',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.report_problem_outlined),
                // Selalu tampilkan badge untuk debugging

                if (controller.jumlahDiproses.value > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        controller.jumlahDiproses.value.toString(),
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
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.report_problem),
                // Selalu tampilkan badge untuk debugging
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      controller.jumlahDiproses.value.toString(),
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
            label: 'Pengaduan',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Stok Bantuan',
          ),
        ],
      );
    });
  }
}
