import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Map<String, Color>? customColors;
  final Map<String, String>? customLabels;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.customColors,
    this.customLabels,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final String statusUpper = status.toUpperCase();

    // Default colors for common statuses menggunakan AppTheme
    final Map<String, Color> defaultColors = {
      'DITERIMA': AppTheme.verifiedColor,
      'MENUNGGU': AppTheme.processedColor,
      'DITOLAK': AppTheme.rejectedColor,
      'PROSES': AppTheme.processedColor,
      'DIPROSES': AppTheme.processedColor,
      'TINDAKAN': AppTheme.processedColor,
      'SELESAI': AppTheme.completedColor,
      'TERVERIFIKASI': AppTheme.verifiedColor,
      'BELUMMENERIMA': AppTheme.processedColor,
      'DIJADWALKAN': AppTheme.scheduledColor,
      'TERLAKSANA': AppTheme.completedColor,
      'AKTIF': AppTheme.verifiedColor,
      'DRAFT': AppTheme.processedColor,
      'FINAL': AppTheme.completedColor,
    };

    // Default labels for common statuses
    final Map<String, String> defaultLabels = {
      'DITERIMA': 'Diterima',
      'MENUNGGU': 'Menunggu',
      'DITOLAK': 'Ditolak',
      'PROSES': 'Proses',
      'DIPROSES': 'Proses',
      'TINDAKAN': 'Tindakan',
      'SELESAI': 'Selesai',
      'TERVERIFIKASI': 'Terverifikasi',
      'BELUMMENERIMA': 'Belum Menerima',
      'DIJADWALKAN': 'Dijadwalkan',
      'TERLAKSANA': 'Terlaksana',
      'AKTIF': 'Aktif',
      'DRAFT': 'Draft',
      'FINAL': 'Final',
    };

    // Determine color and label based on status
    final Color color =
        (customColors != null && customColors!.containsKey(statusUpper))
            ? customColors![statusUpper]!
            : defaultColors.containsKey(statusUpper)
                ? defaultColors[statusUpper]!
                : Colors.grey;

    final String label =
        (customLabels != null && customLabels!.containsKey(statusUpper))
            ? customLabels![statusUpper]!
            : defaultLabels.containsKey(statusUpper)
                ? defaultLabels[statusUpper]!
                : status;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
