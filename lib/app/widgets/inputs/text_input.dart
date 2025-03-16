import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:penyaluran_app/app/theme/app_colors.dart';

/// Input teks yang digunakan di seluruh aplikasi
///
/// Input ini dapat dikonfigurasi untuk berbagai jenis input dan validasi.
class TextInput extends StatelessWidget {
  /// Label yang ditampilkan di atas input
  final String label;

  /// Hint yang ditampilkan di dalam input
  final String? hint;

  /// Controller untuk input
  final TextEditingController? controller;

  /// Fungsi yang dipanggil ketika nilai input berubah
  final Function(String)? onChanged;

  /// Fungsi yang dipanggil ketika input selesai diedit
  final Function(String)? onSubmitted;

  /// Apakah input dinonaktifkan
  final bool enabled;

  /// Apakah input bersifat wajib
  final bool required;

  /// Apakah input bersifat rahasia (password)
  final bool obscureText;

  /// Pesan kesalahan yang ditampilkan di bawah input
  final String? errorText;

  /// Ikon yang ditampilkan di sebelah kanan input
  final IconData? suffixIcon;

  /// Fungsi yang dipanggil ketika ikon di sebelah kanan input ditekan
  final VoidCallback? onSuffixIconPressed;

  /// Jenis keyboard yang digunakan
  final TextInputType keyboardType;

  /// Daftar pemformatan input
  final List<TextInputFormatter>? inputFormatters;

  /// Jumlah baris input (untuk input multiline)
  final int? maxLines;

  /// Jumlah karakter maksimum
  final int? maxLength;

  /// Apakah input otomatis mendapatkan fokus
  final bool autofocus;

  /// Fokus node untuk input
  final FocusNode? focusNode;

  /// Fungsi validasi input
  final String? Function(String?)? validator;

  /// Konstruktor untuk TextInput
  const TextInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.required = false,
    this.obscureText = false,
    this.errorText,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Input
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          maxLength: maxLength,
          autofocus: autofocus,
          focusNode: focusNode,
          validator: validator,
          style: TextStyle(
            fontSize: 14,
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.disabled,
                width: 1,
              ),
            ),
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
