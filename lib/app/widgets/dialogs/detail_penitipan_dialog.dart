import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'package:penyaluran_app/app/theme/app_colors.dart';
import 'package:penyaluran_app/app/widgets/dialogs/show_image_dialog.dart';

/// Dialog untuk menampilkan detail penitipan bantuan
///
/// Dialog ini menampilkan informasi lengkap tentang penitipan bantuan.
class DetailPenitipanDialog {
  /// Menampilkan dialog detail penitipan
  ///
  /// [context] adalah BuildContext
  /// [item] adalah model penitipan bantuan
  /// [donaturNama] adalah nama donatur
  /// [kategoriNama] adalah nama kategori bantuan
  /// [kategoriSatuan] adalah satuan kategori bantuan
  /// [getPetugasDesaNama] adalah fungsi untuk mendapatkan nama petugas desa
  /// [showFullScreenImage] adalah fungsi untuk menampilkan gambar layar penuh
  static void show({
    required BuildContext context,
    required PenitipanBantuanModel item,
    required String donaturNama,
    required String kategoriNama,
    required String kategoriSatuan,
    required String Function(String?) getPetugasDesaNama,
    required Function(String) showFullScreenImage,
  }) {
    // Cek apakah penitipan berbentuk uang
    final isUang = item.isUang ?? false;

    Get.dialog(
      AlertDialog(
        title: const Text('Detail Penitipan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('ID', item.id ?? '-'),
              _buildInfoRow('Donatur', donaturNama),
              _buildInfoRow('Kategori', kategoriNama),
              _buildInfoRow(
                'Jumlah',
                isUang
                    ? 'Rp ${item.jumlah?.toStringAsFixed(0) ?? '0'}'
                    : '${item.jumlah?.toString() ?? '0'} $kategoriSatuan',
              ),
              _buildInfoRow(
                'Tanggal Penitipan',
                FormatHelper.formatDateTime(
                    item.tanggalPenitipan ?? item.createdAt),
              ),
              _buildInfoRow(
                'Status',
                item.status ?? 'Belum diproses',
              ),
              if (item.petugasDesaId != null)
                _buildInfoRow(
                  'Petugas Desa',
                  getPetugasDesaNama(item.petugasDesaId),
                ),
              if (item.tanggalVerifikasi != null)
                _buildInfoRow(
                  'Tanggal Verifikasi',
                  FormatHelper.formatDateTime(item.tanggalVerifikasi),
                ),
              if (item.deskripsi != null && item.deskripsi!.isNotEmpty)
                _buildInfoRow('Deskripsi', item.deskripsi!),

              // Gambar bukti penitipan
              if (item.fotoBantuan != null && item.fotoBantuan!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Bukti Penitipan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => showFullScreenImage(item.fotoBantuan!.first),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(item.fotoBantuan!.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],

              // Bukti serah terima
              if (item.fotoBuktiSerahTerima != null &&
                  item.fotoBuktiSerahTerima!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Bukti Serah Terima',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => showFullScreenImage(item.fotoBuktiSerahTerima!),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(item.fotoBuktiSerahTerima!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Tutup',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Menampilkan gambar dalam layar penuh
  static void showFullScreenImage(BuildContext context, String imageUrl) {
    ShowImageDialog.showFullScreen(context, imageUrl);
  }

  /// Membangun baris informasi
  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
