import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/theme/app_colors.dart';

/// Dialog konfirmasi yang digunakan di seluruh aplikasi
///
/// Dialog ini dapat dikonfigurasi untuk berbagai jenis konfirmasi.
class ConfirmationDialog {
  /// Menampilkan dialog konfirmasi
  ///
  /// [title] adalah judul dialog
  /// [message] adalah pesan yang ditampilkan di dialog
  /// [confirmText] adalah teks tombol konfirmasi
  /// [cancelText] adalah teks tombol batal
  /// [onConfirm] adalah fungsi yang dipanggil ketika tombol konfirmasi ditekan
  /// [onCancel] adalah fungsi yang dipanggil ketika tombol batal ditekan
  /// [isDanger] menentukan apakah dialog bersifat berbahaya (merah)
  static Future<bool?> show({
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDanger = false,
  }) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDanger ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          // Tombol batal
          TextButton(
            onPressed: () {
              Get.back(result: false);
              if (onCancel != null) onCancel();
            },
            child: Text(
              cancelText,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Tombol konfirmasi
          TextButton(
            onPressed: () {
              Get.back(result: true);
              if (onConfirm != null) onConfirm();
            },
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDanger ? AppColors.error : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Menampilkan dialog konfirmasi berbahaya
  ///
  /// Dialog ini memiliki warna merah untuk menandakan tindakan berbahaya.
  static Future<bool?> showDanger({
    required String title,
    required String message,
    String confirmText = 'Hapus',
    String cancelText = 'Batal',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return await show(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDanger: true,
    );
  }
}
