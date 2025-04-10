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
  final Map<String, List<DrawerMenuItem>>? menuCategories;
  final String? footerText;
  final Widget? headerExtraContent;

  const AppDrawer({
    super.key,
    required this.nama,
    required this.role,
    this.desa,
    this.avatar,
    this.notificationCount,
    required this.onLogout,
    required this.menuItems,
    this.menuCategories,
    this.footerText,
    this.headerExtraContent,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          if (menuCategories != null && menuCategories!.isNotEmpty)
            _buildCategorizedMenu()
          else
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
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
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Tentang Kami'),
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/about');
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
            ),
          if (footerText != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                footerText!,
                style: const TextStyle(
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

  Widget _buildHeader(BuildContext context) {
    return Container(
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
          Row(
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
                  backgroundImage: avatar != null && avatar!.isNotEmpty
                      ? NetworkImage(avatar!)
                      : null,
                  child: (avatar == null || avatar!.isEmpty)
                      ? Text(
                          nama.isNotEmpty
                              ? nama.substring(0, 1).toUpperCase()
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
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DisalurKita',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Salurkan dengan Pasti, Pantau dengan Bukti',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            nama,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              if (desa != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        desa!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (headerExtraContent != null) ...[
            const SizedBox(height: 8),
            headerExtraContent!,
          ],
        ],
      ),
    );
  }

  Widget _buildCategorizedMenu() {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ...menuCategories!.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuCategory(entry.key),
                  ...entry.value.map((item) => _buildMenuItem(null, item)),
                ],
              )),
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

  Widget _buildMenuItem(BuildContext? context, DrawerMenuItem item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: item.isSelected
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: item.badgeCount != null && item.badgeCount! > 0
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    item.isSelected
                        ? (item.activeIcon ?? item.icon)
                        : item.icon,
                    color: item.isSelected
                        ? AppTheme.primaryColor
                        : (item.isLogout ? Colors.red : null),
                  ),
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
            : Icon(
                item.isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                color: item.isSelected
                    ? AppTheme.primaryColor
                    : (item.isLogout ? Colors.red : null),
              ),
        title: Text(
          item.title,
          style: TextStyle(
            color: item.isSelected
                ? AppTheme.primaryColor
                : (item.isLogout ? Colors.red : null),
            fontWeight: item.isSelected ? FontWeight.bold : null,
          ),
        ),
        trailing: item.trailing,
        onTap: () {
          if (context != null) {
            Navigator.pop(context);
          } else {
            Navigator.of(Get.overlayContext!).pop();
          }

          Future.delayed(const Duration(milliseconds: 100), () {
            item.onTap();
          });
        },
      ),
    );
  }
}

class DrawerMenuItem {
  final IconData icon;
  final IconData? activeIcon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;
  final Color? badgeColor;
  final bool isLogout;
  final Widget? trailing;

  DrawerMenuItem({
    required this.icon,
    this.activeIcon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
    this.badgeCount,
    this.badgeColor,
    this.isLogout = false,
    this.trailing,
  });
}
