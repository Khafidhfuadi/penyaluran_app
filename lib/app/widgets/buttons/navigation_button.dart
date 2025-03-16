import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_colors.dart';

/// Tombol navigasi yang digunakan untuk navigasi dalam aplikasi
///
/// Tombol ini memiliki label dan ikon, dan dapat dikonfigurasi untuk
/// berbagai ukuran dan warna.
class NavigationButton extends StatelessWidget {
  /// Label yang ditampilkan pada tombol
  final String label;

  /// Ikon yang ditampilkan di sebelah label (opsional)
  final IconData? icon;

  /// Widget ikon kustom yang ditampilkan di sebelah label (opsional)
  final Widget? iconWidget;

  /// Fungsi yang dipanggil ketika tombol ditekan
  final VoidCallback onPressed;

  /// Warna latar belakang tombol
  final Color? backgroundColor;

  /// Warna teks dan ikon
  final Color? foregroundColor;

  /// Ukuran teks
  final double fontSize;

  /// Ukuran ikon
  final double iconSize;

  /// Konstruktor untuk NavigationButton
  ///
  /// Salah satu dari [icon] atau [iconWidget] harus disediakan.
  const NavigationButton({
    super.key,
    required this.label,
    this.icon,
    this.iconWidget,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize = 10,
    this.iconSize = 12,
  }) : assert(icon != null || iconWidget != null,
            'Either icon or iconWidget must be provided');

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? AppColors.primary;
    final Color fgColor = foregroundColor ?? const Color(0xFFAFF8FF);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 70),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: fgColor,
                ),
              ),
              const SizedBox(width: 4),
              if (icon != null)
                Icon(
                  icon,
                  size: iconSize,
                  color: fgColor,
                )
              else if (iconWidget != null)
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: iconWidget,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data class untuk tombol navigasi
///
/// Digunakan untuk menyimpan data tombol navigasi yang akan digunakan
/// di beberapa tempat.
class NavigationButtonData {
  /// Label yang ditampilkan pada tombol
  final String label;

  /// Ikon yang ditampilkan di sebelah label (opsional)
  final IconData? icon;

  /// Widget ikon kustom yang ditampilkan di sebelah label (opsional)
  final Widget? iconWidget;

  /// Konstruktor untuk NavigationButtonData
  ///
  /// Salah satu dari [icon] atau [iconWidget] harus disediakan.
  const NavigationButtonData({
    required this.label,
    this.icon,
    this.iconWidget,
  }) : assert(icon != null || iconWidget != null,
            'Either icon or iconWidget must be provided');
}
