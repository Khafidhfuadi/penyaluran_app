import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

/// Indikator status berbentuk pill yang digunakan untuk menampilkan status
///
/// Indikator ini memiliki teks status dan warna latar belakang yang dapat
/// dikonfigurasi.
class StatusPill extends StatelessWidget {
  /// Teks status yang ditampilkan
  final String status;

  /// Warna latar belakang pill
  final Color? backgroundColor;

  /// Gaya teks status
  final TextStyle? textStyle;

  /// Warna teks status
  final Color? textColor;

  /// Padding pill
  final EdgeInsetsGeometry padding;

  /// Radius border pill
  final double borderRadius;

  /// Konstruktor untuk StatusPill
  const StatusPill({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textStyle,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.borderRadius = 12,
  });

  /// Konstruktor factory untuk StatusPill dengan status "Terverifikasi"
  factory StatusPill.verified({String status = 'Terverifikasi'}) {
    return StatusPill(
      status: status,
      backgroundColor: AppTheme.verifiedColor,
      textColor: Colors.white,
    );
  }

  /// Konstruktor factory untuk StatusPill dengan status "Diproses"
  factory StatusPill.processed({String status = 'Diproses'}) {
    return StatusPill(
      status: status,
      backgroundColor: AppTheme.processedColor,
      textColor: Colors.white,
    );
  }

  /// Konstruktor factory untuk StatusPill dengan status "Ditolak"
  factory StatusPill.rejected({String status = 'Ditolak'}) {
    return StatusPill(
      status: status,
      backgroundColor: AppTheme.rejectedColor,
      textColor: Colors.white,
    );
  }

  /// Konstruktor factory untuk StatusPill dengan status "Dijadwalkan"
  factory StatusPill.scheduled({String status = 'Dijadwalkan'}) {
    return StatusPill(
      status: status,
      backgroundColor: AppTheme.scheduledColor,
      textColor: Colors.white,
    );
  }

  /// Konstruktor factory untuk StatusPill dengan status "Selesai"
  factory StatusPill.completed({String status = 'Selesai'}) {
    return StatusPill(
      status: status,
      backgroundColor: AppTheme.completedColor,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.verifiedColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        status,
        style: textStyle ??
            textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: textColor ?? Colors.white,
            ),
      ),
    );
  }
}
