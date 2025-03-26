import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/controllers/laporan_penyaluran_controller.dart';
import 'package:penyaluran_app/app/widgets/custom_app_bar.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class LaporanPenyaluranEditView extends GetView<LaporanPenyaluranController> {
  const LaporanPenyaluranEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final laporanId = Get.arguments as String;

    // Dapatkan data laporan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchLaporanDetail(laporanId).then((_) {
        if (controller.selectedLaporan.value != null) {
          controller.setFormForEdit(controller.selectedLaporan.value!);
        }
      });
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Laporan Penyaluran',
        // subtitle: 'Perbarui informasi laporan penyaluran',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.selectedLaporan.value == null) {
          return const Center(
            child: Text('Laporan tidak ditemukan'),
          );
        }

        // Cek status laporan
        if (controller.selectedLaporan.value!.status == 'FINAL') {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Laporan Telah Difinalisasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Laporan yang sudah difinalisasi tidak dapat diedit lagi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Kembali ke Detail Laporan'),
                  ),
                ],
              ),
            ),
          );
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
                          // subtitle: 'Penyaluran yang terkait dengan laporan',
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
                              ? '${controller.selectedPenyaluran.value!.tanggalPenyaluran!.day}/${controller.selectedPenyaluran.value!.tanggalPenyaluran!.month}/${controller.selectedPenyaluran.value!.tanggalPenyaluran!.year}'
                              : '-',
                        ),
                        _buildInfoItem(
                          'Tanggal Selesai',
                          controller.selectedPenyaluran.value!.tanggalSelesai !=
                                  null
                              ? '${controller.selectedPenyaluran.value!.tanggalSelesai!.day}/${controller.selectedPenyaluran.value!.tanggalSelesai!.month}/${controller.selectedPenyaluran.value!.tanggalSelesai!.year}'
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
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Dokumentasi yang sudah ada
                          if (controller
                                      .selectedLaporan.value?.dokumentasiUrl !=
                                  null &&
                              controller.dokumentasiPath.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      controller.selectedLaporan.value!
                                          .dokumentasiUrl!,
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
                                          child:
                                              Text('Pratinjau tidak tersedia'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            _pickDocumentationImage(context),
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        label: const Text('Ganti',
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          // Dokumentasi yang baru dipilih
                          else if (controller.dokumentasiPath.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(controller.dokumentasiPath.value),
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
                                          child:
                                              Text('Pratinjau tidak tersedia'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          controller.dokumentasiPath.value = '';
                                        },
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        label: const Text('Hapus',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          // Tidak ada dokumentasi
                          else
                            OutlinedButton.icon(
                              onPressed: () => _pickDocumentationImage(context),
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Upload Foto Dokumentasi'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                side: BorderSide(color: Colors.blue.shade300),
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
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Berita acara yang sudah ada
                          if (controller
                                      .selectedLaporan.value?.beritaAcaraUrl !=
                                  null &&
                              controller.beritaAcaraPath.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.description,
                                          size: 40,
                                          color: Colors.blue.shade700),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Dokumen Berita Acara',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              Uri.parse(controller
                                                      .selectedLaporan
                                                      .value!
                                                      .beritaAcaraUrl!)
                                                  .pathSegments
                                                  .last,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            _pickBeritaAcaraFile(context),
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        label: const Text('Ganti',
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          // Berita acara yang baru dipilih
                          else if (controller.beritaAcaraPath.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.description,
                                          size: 40,
                                          color: Colors.blue.shade700),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              File(controller
                                                      .beritaAcaraPath.value)
                                                  .path
                                                  .split('/')
                                                  .last,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Dokumen berita acara',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          controller.beritaAcaraPath.value = '';
                                        },
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        label: const Text('Hapus',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          // Tidak ada berita acara
                          else
                            OutlinedButton.icon(
                              onPressed: () => _pickBeritaAcaraFile(context),
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Upload Dokumen Berita Acara'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                side: BorderSide(color: Colors.blue.shade300),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Format dokumen: PDF, DOC, DOCX (maks. 10MB)',
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

              const SizedBox(height: 32),

              // Tombol aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : () => controller.updateLaporan(laporanId),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: controller.isSaving.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // Widget untuk item informasi
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Text(' : '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
            children: required
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
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
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLines: maxLines,
        ),
      ],
    );
  }

  // Metode untuk memilih gambar dokumentasi
  Future<void> _pickDocumentationImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        controller.dokumentasiPath.value = image.path;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Metode untuk memilih file berita acara
  Future<void> _pickBeritaAcaraFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        controller.beritaAcaraPath.value = result.files.single.path!;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
