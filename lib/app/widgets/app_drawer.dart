import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final String nama;
  final String role;
  final String? desa;
  final String? avatar;
  final int? notificationCount;
  final VoidCallback onLogout;
  final List<DrawerMenuItem> menuItems;

  const AppDrawer({
    Key? key,
    required this.nama,
    required this.role,
    this.desa,
    this.avatar,
    this.notificationCount,
    required this.onLogout,
    required this.menuItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  backgroundImage:
                      avatar != null ? NetworkImage(avatar!) : null,
                  child: avatar == null
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desa != null ? '$role - $desa' : role,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ...menuItems.map((item) => _buildMenuItem(context, item)),
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
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigasi ke halaman pengaturan
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, DrawerMenuItem item) {
    return ListTile(
      leading: item.badgeCount != null && item.badgeCount! > 0
          ? Stack(
              alignment: Alignment.center,
              children: [
                Icon(item.icon),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: item.badgeColor ?? Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      item.badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : Icon(item.icon),
      title: Text(item.title),
      selected: item.isSelected,
      selectedColor: AppTheme.primaryColor,
      onTap: () {
        Navigator.pop(context);
        item.onTap();
      },
    );
  }
}

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;
  final Color? badgeColor;

  DrawerMenuItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
    this.badgeCount,
    this.badgeColor,
  });
}
