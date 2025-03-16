import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_colors.dart';

/// Kartu informasi yang digunakan untuk menampilkan informasi
///
/// Kartu ini memiliki judul, deskripsi, dan ikon, dan dapat dikonfigurasi
/// untuk berbagai ukuran dan warna.
class InfoCard extends StatelessWidget {
  /// Judul kartu
  final String title;

  /// Deskripsi atau konten kartu
  final String description;

  /// Ikon yang ditampilkan di kartu (opsional)
  final IconData? icon;

  /// Widget ikon kustom yang ditampilkan di kartu (opsional)
  final Widget? iconWidget;

  /// Warna latar belakang kartu
  final Color? backgroundColor;

  /// Warna judul
  final Color? titleColor;

  /// Warna deskripsi
  final Color? descriptionColor;

  /// Warna ikon
  final Color? iconColor;

  /// Fungsi yang dipanggil ketika kartu ditekan (opsional)
  final VoidCallback? onTap;

  /// Padding kartu
  final EdgeInsetsGeometry padding;

  /// Margin kartu
  final EdgeInsetsGeometry margin;

  /// Konstruktor untuk InfoCard
  const InfoCard({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.iconWidget,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.iconColor,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
  }) : assert(
            icon != null ||
                iconWidget != null ||
                (icon == null && iconWidget == null),
            'Cannot provide both icon and iconWidget');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color bgColor = backgroundColor ?? Colors.white;
    final Color titleTextColor = titleColor ?? AppColors.textPrimary;
    final Color descTextColor = descriptionColor ?? AppColors.textSecondary;
    final Color iconColorValue = iconColor ?? AppColors.primary;

    return Card(
      margin: margin,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    icon,
                    size: 24,
                    color: iconColorValue,
                  ),
                )
              else if (iconWidget != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: iconWidget,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: titleTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: descTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
