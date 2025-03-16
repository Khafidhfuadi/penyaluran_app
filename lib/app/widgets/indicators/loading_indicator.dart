import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_colors.dart';

/// Indikator loading yang digunakan untuk menampilkan status loading
///
/// Indikator ini dapat dikonfigurasi dengan pesan, warna, dan ukuran.
class LoadingIndicator extends StatelessWidget {
  /// Pesan yang ditampilkan di bawah indikator loading (opsional)
  final String? message;

  /// Warna indikator loading
  final Color? color;

  /// Ukuran indikator loading
  final double size;

  /// Ketebalan garis indikator loading
  final double strokeWidth;

  /// Warna teks pesan
  final Color? textColor;

  /// Ukuran teks pesan
  final double textSize;

  /// Jarak antara indikator loading dan pesan
  final double spacing;

  /// Konstruktor untuk LoadingIndicator
  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 40.0,
    this.strokeWidth = 3.0,
    this.textColor,
    this.textSize = 16.0,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
              strokeWidth: strokeWidth,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: spacing),
            Text(
              message!,
              style: TextStyle(
                fontSize: textSize,
                color: textColor ?? Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
