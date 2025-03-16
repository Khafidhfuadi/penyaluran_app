import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/theme/app_colors.dart';

/// Item untuk dropdown
class DropdownItem<T> {
  /// Nilai item
  final T value;

  /// Label yang ditampilkan
  final String label;

  /// Konstruktor untuk DropdownItem
  const DropdownItem({
    required this.value,
    required this.label,
  });
}

/// Input dropdown yang digunakan di seluruh aplikasi
///
/// Input ini dapat dikonfigurasi untuk berbagai jenis dropdown dan validasi.
class DropdownInput<T> extends StatelessWidget {
  /// Label yang ditampilkan di atas input
  final String label;

  /// Hint yang ditampilkan di dalam input
  final String? hint;

  /// Daftar item dropdown
  final List<DropdownItem<T>> items;

  /// Nilai yang dipilih
  final T? value;

  /// Fungsi yang dipanggil ketika nilai dropdown berubah
  final Function(T?)? onChanged;

  /// Apakah input dinonaktifkan
  final bool enabled;

  /// Apakah input bersifat wajib
  final bool required;

  /// Pesan kesalahan yang ditampilkan di bawah input
  final String? errorText;

  /// Fungsi validasi input
  final String? Function(T?)? validator;

  /// Konstruktor untuk DropdownInput
  const DropdownInput({
    super.key,
    required this.label,
    this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.errorText,
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

        // Dropdown
        DropdownButtonFormField<T>(
          value: value,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
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
          ),
          items: items.map((DropdownItem<T> item) {
            return DropdownMenuItem<T>(
              value: item.value,
              child: Text(item.label),
            );
          }).toList(),
        ),
      ],
    );
  }
}
