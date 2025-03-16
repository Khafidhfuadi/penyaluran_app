import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';

/// Dialog untuk menampilkan detail penitipan bantuan
///
/// Contoh penggunaan:
/// ```dart
/// // Di halaman lain
/// void showDetailPenitipan(BuildContext context, PenitipanBantuanModel item) {
///   // Dapatkan data yang diperlukan
///   final donaturNama = item.donatur?.nama ?? 'Donatur tidak ditemukan';
///   final kategoriNama = item.kategoriBantuan?.nama ?? 'Kategori tidak ditemukan';
///   final kategoriSatuan = item.kategoriBantuan?.satuan ?? '';
///
///   // Tampilkan dialog
///   DetailPenitipanDialog.show(
///     context: context,
///     item: item,
///     donaturNama: donaturNama,
///     kategoriNama: kategoriNama,
///     kategoriSatuan: kategoriSatuan,
///     getPetugasDesaNama: (String? id) => 'Nama Petugas', // Sesuaikan dengan cara mendapatkan nama petugas
///     showFullScreenImage: (String imageUrl) {
///       DetailPenitipanDialog.showFullScreenImage(context, imageUrl);
///     },
///   );
/// }
class DetailPenitipanDialog {
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
              _buildDetailItem('Donatur', donaturNama),
              _buildDetailItem('Status', item.status ?? 'Tidak diketahui'),
              _buildDetailItem('Kategori Bantuan', kategoriNama),
              _buildDetailItem(
                  'Jumlah',
                  isUang
                      ? 'Rp ${DateTimeHelper.formatNumber(item.jumlah)}'
                      : '${DateTimeHelper.formatNumber(item.jumlah)} $kategoriSatuan'),
              if (isUang) _buildDetailItem('Jenis Bantuan', 'Uang (Rupiah)'),
              _buildDetailItem(
                  'Deskripsi', item.deskripsi ?? 'Tidak ada deskripsi'),
              _buildDetailItem(
                'Tanggal Penitipan',
                DateTimeHelper.formatDateTime(item.tanggalPenitipan,
                    defaultValue: 'Tidak ada tanggal'),
              ),
              if (item.tanggalVerifikasi != null)
                _buildDetailItem(
                  'Tanggal Verifikasi',
                  DateTimeHelper.formatDateTime(item.tanggalVerifikasi),
                ),
              if (item.status == 'TERVERIFIKASI' && item.petugasDesaId != null)
                _buildDetailItem(
                  'Diverifikasi Oleh',
                  getPetugasDesaNama(item.petugasDesaId),
                ),
              _buildDetailItem('Tanggal Dibuat',
                  DateTimeHelper.formatDateTime(item.createdAt)),
              if (item.alasanPenolakan != null &&
                  item.alasanPenolakan!.isNotEmpty)
                _buildDetailItem('Alasan Penolakan', item.alasanPenolakan!),

              // Foto Bantuan
              if (!isUang &&
                  item.fotoBantuan != null &&
                  item.fotoBantuan!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Foto Bantuan:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: item.fotoBantuan!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              showFullScreenImage(item.fotoBantuan![index]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.fotoBantuan![index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              // Bukti Transfer (untuk bantuan uang)
              if (isUang &&
                  item.fotoBantuan != null &&
                  item.fotoBantuan!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Bukti Transfer:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: item.fotoBantuan!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              showFullScreenImage(item.fotoBantuan![index]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.fotoBantuan![index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              // Bukti Serah Terima
              if (item.fotoBuktiSerahTerima != null &&
                  item.fotoBuktiSerahTerima!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Bukti Serah Terima:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        showFullScreenImage(item.fotoBuktiSerahTerima!);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.fotoBuktiSerahTerima!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
          const Divider(),
        ],
      ),
    );
  }

  static void showFullScreenImage(BuildContext context, String imageUrl) {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        size: 50,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
