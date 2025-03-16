import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_colors.dart';
import 'package:penyaluran_app/app/widgets/buttons/primary_button.dart';

/// Tombol sekunder yang digunakan di seluruh aplikasi
///
/// Tombol ini memiliki warna latar belakang putih dengan border dan teks berwarna utama.
/// Dapat dikonfigurasi untuk berbagai ukuran dan dapat dinonaktifkan.
class SecondaryButton extends StatelessWidget {
  /// Teks yang ditampilkan pada tombol
  final String text;

  /// Fungsi yang dipanggil ketika tombol ditekan
  final VoidCallback? onPressed;

  /// Ikon yang ditampilkan di sebelah kiri teks (opsional)
  final IconData? icon;

  /// Apakah tombol mengisi lebar penuh
  final bool fullWidth;

  /// Ukuran tombol (kecil, sedang, besar)
  final ButtonSize size;

  /// Apakah tombol sedang memuat
  final bool isLoading;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.fullWidth = false,
    this.size = ButtonSize.medium,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan padding berdasarkan ukuran
    final EdgeInsetsGeometry padding = _getPadding();

    // Tentukan ukuran teks berdasarkan ukuran tombol
    final double fontSize = _getFontSize();

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize + 2),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Mendapatkan padding berdasarkan ukuran tombol
  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  /// Mendapatkan ukuran font berdasarkan ukuran tombol
  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }
}
