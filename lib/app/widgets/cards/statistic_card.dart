import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

/// Kartu statistik yang digunakan untuk menampilkan data statistik
///
/// Kartu ini memiliki judul, jumlah, dan subtitle, dan dapat dikonfigurasi
/// untuk berbagai ukuran dan warna.
class StatisticCard extends StatelessWidget {
  /// Judul kartu
  final String title;

  /// Jumlah atau nilai statistik
  final String count;

  /// Subtitle atau deskripsi tambahan
  final String subtitle;

  /// Tinggi kartu
  final double height;

  /// Gradient latar belakang kartu
  final Gradient? gradient;

  /// Warna teks
  final Color textColor;

  /// Ikon yang ditampilkan di kartu (opsional)
  final IconData? icon;

  /// Warna ikon
  final Color? iconColor;

  /// Konstruktor untuk StatisticCard
  const StatisticCard({
    super.key,
    required this.title,
    required this.count,
    required this.subtitle,
    this.height = 100,
    this.gradient,
    this.textColor = Colors.white,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Gradient backgroundGradient = gradient ?? AppTheme.primaryGradient;
    final Color iconColorValue = iconColor ?? textColor;

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: textColor.withAlpha(204),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  count,
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          if (icon != null)
            Icon(
              icon,
              size: 40,
              color: iconColorValue.withAlpha(51),
            ),
        ],
      ),
    );
  }
}
