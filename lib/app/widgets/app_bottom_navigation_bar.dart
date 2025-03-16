import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<AppBottomNavigationBarItem> items;

  const AppBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      items: items.map((item) => _buildNavigationBarItem(item)).toList(),
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem(
      AppBottomNavigationBarItem item) {
    return BottomNavigationBarItem(
      icon: item.badgeCount != null && item.badgeCount! > 0
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
                      shape: BoxShape.circle,
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
      activeIcon: item.badgeCount != null && item.badgeCount! > 0
          ? Stack(
              alignment: Alignment.center,
              children: [
                Icon(item.activeIcon ?? item.icon),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: item.badgeColor ?? Colors.red,
                      shape: BoxShape.circle,
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
          : Icon(item.activeIcon ?? item.icon),
      label: item.label,
    );
  }
}

class AppBottomNavigationBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int? badgeCount;
  final Color? badgeColor;

  AppBottomNavigationBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badgeCount,
    this.badgeColor,
  });
}
