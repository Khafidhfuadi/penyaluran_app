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
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: 'profile-photo',
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
                                      .substring(0, 1)
                                      .toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                fontSize: 30,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Halo,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                Text(
                  controller.nama,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.formattedRole,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            controller.desa,
                            style: TextStyle(
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
                        controller.changeTab(0);
                      },
                    )),
                Obx(() => _buildMenuItem(
                      icon: Icons.handshake_outlined,
                      activeIcon: Icons.handshake,
                      title: 'Penyaluran',
                      isSelected: controller.activeTabIndex.value == 1,
                      onTap: () {
                        Navigator.pop(context);
                        controller.changeTab(1);
                      },
                    )),
                Obx(() => _buildMenuItem(
                      icon: Icons.inventory_2_outlined,
                      activeIcon: Icons.inventory_2,
                      title: 'Penitipan',
                      isSelected: controller.activeTabIndex.value == 2,
                      onTap: () {
                        Navigator.pop(context);
                        controller.changeTab(2);
                      },
                    )),
                Obx(() => _buildMenuItem(
                      icon: Icons.warning_amber_outlined,
                      activeIcon: Icons.warning_amber,
                      title: 'Pengaduan',
                      isSelected: controller.activeTabIndex.value == 3,
                      onTap: () {
                        Navigator.pop(context);
                        controller.changeTab(3);
                      },
                    )),
                Obx(() => _buildMenuItem(
                      icon: Icons.inventory_outlined,
                      activeIcon: Icons.inventory,
                      title: 'Stok Bantuan',
                      isSelected: controller.activeTabIndex.value == 4,
                      onTap: () {
                        Navigator.pop(context);
                        controller.changeTab(4);
                      },
                    )),
                _buildMenuCategory('Kelola Data'),
                _buildMenuItem(
                  icon: Icons.person_add_outlined,
                  activeIcon: Icons.person_add,
                  title: 'Kelola Penerima',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/daftar-penerima');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.people_outlined,
                  activeIcon: Icons.people,
                  title: 'Kelola Donatur',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/daftar-donatur');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  activeIcon: Icons.location_on,
                  title: 'Lokasi Penyaluran',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/lokasi-penyaluran');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description,
                  title: 'Laporan Penyaluran',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/laporan-penyaluran');
                  },
                ),
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
                const Divider(),
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
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              isSelected ? (activeIcon ?? icon) : icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : isLogout
                      ? Colors.red
                      : Colors.grey[700],
              size: 24,
            ),
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppTheme.primaryColor
                : isLogout
                    ? Colors.red
                    : Colors.grey[800],
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        visualDensity: VisualDensity.compact,
        selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
        selected: isSelected,
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
