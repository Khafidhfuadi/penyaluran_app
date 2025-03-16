import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Map<String, Color>? customColors;
  final Map<String, String>? customLabels;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    Key? key,
    required this.status,
    this.customColors,
    this.customLabels,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String statusUpper = status.toUpperCase();

    // Default colors for common statuses
    final Map<String, Color> defaultColors = {
      'DITERIMA': Colors.green,
      'MENUNGGU': Colors.orange,
      'DITOLAK': Colors.red,
      'PROSES': Colors.orange,
      'DIPROSES': Colors.orange,
      'TINDAKAN': Colors.orange,
      'SELESAI': Colors.green,
      'TERVERIFIKASI': Colors.green,
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
