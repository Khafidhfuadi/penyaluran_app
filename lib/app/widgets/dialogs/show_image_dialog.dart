import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

/// Dialog untuk menampilkan gambar dalam ukuran besar
///
/// Komponen ini dapat digunakan untuk menampilkan gambar dari URL
/// dengan kemampuan zoom dan pan pada gambar.
class ShowImageDialog {
  /// Menampilkan dialog gambar
  ///
  /// [context] adalah BuildContext untuk menampilkan dialog
  /// [imageUrl] adalah URL gambar yang akan ditampilkan
  /// [title] adalah judul dari dialog, default 'Bukti Foto'
  static void show(
    BuildContext context,
    String imageUrl, {
    String title = 'Bukti Foto',
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                    onPressed: () => _downloadImage(context, imageUrl),
                    tooltip: 'Unduh Gambar',
                  ),
                ],
                elevation: 0,
                backgroundColor: AppTheme.primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(16),
                  minScale: 0.5,
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Gagal memuat gambar: $error',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.zoom_in, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Cubit untuk memperbesar/memperkecil',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Menampilkan dialog gambar layar penuh
  ///
  /// Versi layar penuh dari dialog gambar
  /// [context] adalah BuildContext untuk menampilkan dialog
  /// [imageUrl] adalah URL gambar yang akan ditampilkan
  static void showFullScreen(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black87,
                ),
              ),
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, color: Colors.white, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Gagal memuat gambar',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download,
                          color: Colors.white, size: 30),
                      onPressed: () => _downloadImage(context, imageUrl),
                      tooltip: 'Unduh Gambar',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Mengunduh gambar dari URL dan menyimpannya ke penyimpanan lokal
  ///
  /// [context] adalah BuildContext untuk menampilkan snackbar
  /// [imageUrl] adalah URL gambar yang akan diunduh
  static Future<void> _downloadImage(
      BuildContext context, String imageUrl) async {
    try {
      // Tampilkan indikator loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mengunduh gambar...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Ambil data gambar dari URL
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        throw Exception('Gagal mengunduh gambar');
      }

      // Dapatkan direktori penyimpanan sementara
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'bukti_foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${tempDir.path}/$fileName');

      // Tulis data ke file
      await file.writeAsBytes(response.bodyBytes);

      // Bagikan file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Bukti Foto',
      );

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar berhasil diunduh dan siap dibagikan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunduh gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
