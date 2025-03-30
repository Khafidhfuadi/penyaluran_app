import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/controllers/laporan_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'package:penyaluran_app/app/widgets/custom_app_bar.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class LaporanPenyaluranCreateView extends GetView<LaporanPenyaluranController> {
  const LaporanPenyaluranCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    final penyaluranId = Get.arguments as String;

    // Dapatkan info penyaluran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPenyaluranDetail(penyaluranId);
      controller.resetForm(); // Reset form setiap kali halaman dibuka
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Buat Laporan Penyaluran',
        // subtitle: 'Isi form untuk membuat laporan penyaluran',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informasi penyaluran
              if (controller.selectedPenyaluran.value != null) ...[
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Informasi Penyaluran',
                          // subtitle: 'Penyaluran yang akan dibuatkan laporan',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          'Nama Penyaluran',
                          controller.selectedPenyaluran.value!.nama ?? '-',
                        ),
                        _buildInfoItem(
                          'Tanggal Penyaluran',
                          controller.selectedPenyaluran.value!
                                      .tanggalPenyaluran !=
                                  null
                              ? FormatHelper.formatDateTime(controller
                                  .selectedPenyaluran.value!.tanggalPenyaluran!)
                              : '-',
                        ),
                        _buildInfoItem(
                          'Tanggal Selesai',
                          controller.selectedPenyaluran.value!.tanggalSelesai !=
                                  null
                              ? FormatHelper.formatDateTime(controller
                                  .selectedPenyaluran.value!.tanggalSelesai!)
                              : '-',
                        ),
                        _buildInfoItem(
                          'Jumlah Penerima',
                          '${controller.selectedPenyaluran.value!.jumlahPenerima ?? 0} orang',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Form laporan
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Form Laporan',
                      ),
                      const SizedBox(height: 16),

                      // Judul laporan
                      _buildTextField(
                        controller: controller.judulController,
                        label: 'Judul Laporan',
                        hint: 'Masukkan judul laporan',
                        required: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Dokumentasi dan Berita Acara
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Dokumentasi & Berita Acara',
                      ),
                      const SizedBox(height: 16),

                      // Upload Dokumentasi
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Dokumentasi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => controller.dokumentasiPath.isNotEmpty
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                            File(controller
                                                .dokumentasiPath.value),
                                            width: 200,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              width: 200,
                                              height: 120,
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child: Text(
                                                    'Pratinjau tidak tersedia'),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                controller
                                                    .dokumentasiPath.value = '';
                                              },
                                              icon: Icon(Icons.delete,
                                                  color: AppTheme.errorColor),
                                              label: Text('Hapus',
                                                  style: TextStyle(
                                                      color:
                                                          AppTheme.errorColor)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : OutlinedButton.icon(
                                    onPressed: () =>
                                        _pickDocumentationImage(context),
                                    icon: const Icon(Icons.upload_file),
                                    label:
                                        const Text('Upload Foto Dokumentasi'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      side: BorderSide(
                                          color: AppTheme.primaryColor),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Format gambar: JPG, PNG, JPEG (maks. 5MB)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Upload Berita Acara
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Berita Acara',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => controller.beritaAcaraPath.isNotEmpty
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.description,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Dokumen Berita Acara',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                controller.beritaAcaraPath.value
                                                    .split('/')
                                                    .last,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            controller.beritaAcaraPath.value =
                                                '';
                                          },
                                          icon: Icon(Icons.delete,
                                              color: AppTheme.errorColor),
                                        ),
                                      ],
                                    ),
                                  )
                                : OutlinedButton.icon(
                                    onPressed: () =>
                                        _pickBeritaAcaraFile(context),
                                    icon: const Icon(Icons.file_present),
                                    label: const Text(
                                        'Upload Dokumen Berita Acara'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      side: BorderSide(
                                          color: AppTheme.primaryColor),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Format file: PDF, DOC, DOCX (maks. 10MB)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Tombol simpan
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () {
                              if (controller.judulController.text.isEmpty) {
                                Get.snackbar(
                                  'Perhatian',
                                  'Judul laporan wajib diisi',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppTheme.warningColor,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              controller.saveLaporan(penyaluranId);
                              //kembali reload halaman
                              // Kembali dan reload halaman setelah menyimpan laporan
                              Get.back(result: true);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Simpan Laporan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // Metode untuk memilih gambar dokumentasi
  void _pickDocumentationImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Sumber Gambar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  context,
                  Icons.camera_alt,
                  'Kamera',
                  ImageSource.camera,
                  Colors.blue,
                ),
                _buildImageSourceOption(
                  context,
                  Icons.photo_library,
                  'Galeri',
                  ImageSource.gallery,
                  AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Widget untuk opsi sumber gambar
  Widget _buildImageSourceOption(
    BuildContext context,
    IconData icon,
    String label,
    ImageSource source,
    Color color,
  ) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        final ImagePicker picker = ImagePicker();
        try {
          final XFile? image = await picker.pickImage(
            source: source,
            imageQuality: 80,
          );
          if (image != null) {
            controller.dokumentasiPath.value = image.path;
          }
        } catch (e) {
          Get.snackbar(
            'Error',
            'Gagal memilih gambar: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.errorColor,
            colorText: Colors.white,
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk memilih file berita acara
  Future<void> _pickBeritaAcaraFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        controller.beritaAcaraPath.value = result.files.single.path!;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  // Widget untuk item informasi
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk input teks
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    int maxLines = 1,
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
              children: required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}
