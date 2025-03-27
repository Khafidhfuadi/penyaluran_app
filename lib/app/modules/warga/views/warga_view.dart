import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/modules/warga/views/warga_dashboard_view.dart';
import 'package:penyaluran_app/app/modules/warga/views/warga_penerimaan_view.dart';
import 'package:penyaluran_app/app/modules/warga/views/warga_pengaduan_view.dart';
import 'package:penyaluran_app/app/widgets/app_bottom_navigation_bar.dart';
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
              return const Text('Dashboard Warga');
            case 1:
              return const Text('Penerimaan Bantuan');
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
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white70,
                    backgroundImage: controller.profilePhotoUrl != null &&
                            controller.profilePhotoUrl!.isNotEmpty
                        ? NetworkImage(controller.profilePhotoUrl!)
                        : null,
                    child: controller.profilePhotoUrl == null ||
                            controller.profilePhotoUrl!.isEmpty
                        ? Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          )
                        : null,
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
                        'Warga',
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
                            controller.desa ?? 'Tidak ada desa',
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
                      icon: Icons.volunteer_activism_outlined,
                      activeIcon: Icons.volunteer_activism,
                      title: 'Penerimaan',
                      isSelected: controller.activeTabIndex.value == 1,
                      onTap: () {
                        Navigator.pop(context);
                        controller.changeTab(1);
                      },
                    )),
                Obx(() => _buildMenuItem(
                      icon: Icons.report_problem_outlined,
                      activeIcon: Icons.report_problem,
                      title: 'Pengaduan',
                      isSelected: controller.activeTabIndex.value == 2,
                      onTap: () {
                        Navigator.pop(context);
                        controller.changeTab(2);
                      },
                    )),
                _buildMenuCategory('Pengaturan'),
                _buildMenuItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  title: 'Profil',
                  onTap: () async {
                    Navigator.pop(context);
                    await Get.toNamed('/profile');
                    // Refresh data ketika kembali dari profil
                    controller.refreshData();
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
              '© ${DateTime.now().year} Aplikasi Penyaluran Bantuan',
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
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  badge,
                  style: TextStyle(
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
