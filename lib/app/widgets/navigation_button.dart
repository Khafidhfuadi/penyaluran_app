import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class NavigationButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback onPressed;

  const NavigationButton({
    super.key,
    required this.label,
    this.icon,
    this.iconWidget,
    required this.onPressed,
  }) : assert(icon != null || iconWidget != null,
            'Either icon or iconWidget must be provided');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 70), // Set a minimum width
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Important for preventing layout issues
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFAFF8FF),
                ),
              ),
              const SizedBox(width: 4),
              if (icon != null)
                Icon(
                  icon,
                  size: 12,
                  color: Color(0xFFAFF8FF),
                )
              else if (iconWidget != null)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: iconWidget,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data class for navigation button
class NavigationButtonData {
  final String label;
  final IconData? icon;
  final Widget? iconWidget;

  NavigationButtonData({
    required this.label,
    this.icon,
    this.iconWidget,
  }) : assert(icon != null || iconWidget != null,
            'Either icon or iconWidget must be provided');
}
