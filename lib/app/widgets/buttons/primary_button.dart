import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_colors.dart';

/// Tombol utama yang digunakan di seluruh aplikasi
///
/// Tombol ini memiliki warna latar belakang utama dan teks putih.
/// Dapat dikonfigurasi untuk berbagai ukuran dan dapat dinonaktifkan.
class PrimaryButton extends StatelessWidget {
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

  const PrimaryButton({
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
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

/// Enum untuk ukuran tombol
enum ButtonSize {
  small,
  medium,
  large,
}
