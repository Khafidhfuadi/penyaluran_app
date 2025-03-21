import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/dashboard_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/penyaluran_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/notifikasi_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/stok_bantuan_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/penitipan_view.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/pengaduan_view.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

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
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: controller.user?.avatar != null &&
                          controller.user!.avatar!.isNotEmpty
                      ? NetworkImage(controller.user!.avatar!)
                      : null,
                  child: controller.user?.avatar == null ||
                          controller.user!.avatar!.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  controller.user?.name ?? 'Petugas Desa',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  controller.user?.desa?.nama != null
                      ? '${controller.user?.role} - ${controller.user!.desa!.nama}'
                      : controller.user?.role ?? 'PETUGAS_DESA',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
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
              Navigator.pop(context);
              controller.changeTab(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.handshake_outlined),
            title: const Text('Penyaluran'),
            selected: controller.activeTabIndex.value == 1,
            selectedColor: AppTheme.primaryColor,
            onTap: () {
              Navigator.pop(context);
              controller.changeTab(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Penitipan'),
            selected: controller.activeTabIndex.value == 2,
            selectedColor: AppTheme.primaryColor,
            onTap: () {
              Navigator.pop(context);
              controller.changeTab(2);
            },
          ),
          Obx(() => ListTile(
                leading: controller.jumlahDiproses.value > 0
                    ? Badge(
                        label: Text(controller.jumlahDiproses.value.toString()),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.support_outlined),
                      )
                    : const Icon(Icons.support_outlined),
                title: const Text('Pengaduan'),
                selected: controller.activeTabIndex.value == 3,
                selectedColor: AppTheme.primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  controller.changeTab(3);
                },
              )),
          ListTile(
            leading: const Icon(Icons.inventory_outlined),
            title: const Text('Stok Bantuan'),
            selected: controller.activeTabIndex.value == 4,
            selectedColor: AppTheme.primaryColor,
            onTap: () {
              Navigator.pop(context);
              controller.changeTab(4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_outlined),
            title: const Text('Kelola Penerima'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/daftar-penerima');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outlined),
            title: const Text('Kelola Donatur'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/daftar-donatur');
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Laporan Penyaluran'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/laporan-penyaluran');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: () {
              Navigator.pop(context);
              controller.logout();
            },
          ),
        ],
      ),
    );
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
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
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
                      color: Colors.red,
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
