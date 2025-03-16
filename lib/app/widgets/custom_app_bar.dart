import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/theme/app_colors.dart';

/// AppBar kustom yang digunakan di seluruh aplikasi
///
/// AppBar ini dapat dikonfigurasi untuk berbagai tampilan dan fungsi.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Judul yang ditampilkan di AppBar
  final String title;

  /// Apakah menampilkan tombol kembali
  final bool showBackButton;

  /// Daftar aksi yang ditampilkan di sebelah kanan AppBar
  final List<Widget>? actions;

  /// Widget yang ditampilkan di sebelah kiri AppBar
  final Widget? leading;

  /// Apakah judul berada di tengah
  final bool centerTitle;

  /// Elevasi AppBar
  final double elevation;

  /// Warna latar belakang AppBar
  final Color? backgroundColor;

  /// Warna konten AppBar
  final Color? foregroundColor;

  /// Fungsi yang dipanggil ketika tombol kembali ditekan
  final VoidCallback? onBackPressed;

  /// Konstruktor untuk CustomAppBar
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? Colors.white,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      leading: _buildLeading(),
      actions: actions,
    );
  }

  /// Membangun widget leading berdasarkan parameter
  Widget? _buildLeading() {
    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed ?? () => Get.back(),
      );
    }
    return leading;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
