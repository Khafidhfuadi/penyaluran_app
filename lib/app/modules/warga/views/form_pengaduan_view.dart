import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';

class FormPengaduanView extends StatefulWidget {
  final String uidPenerimaan;
  final String? judul;
  final String? deskripsi;
  final List<File>? selectedImages;

  const FormPengaduanView({
    Key? key,
    required this.uidPenerimaan,
    this.judul,
    this.deskripsi,
    this.selectedImages,
  }) : super(key: key);

  @override
  State<FormPengaduanView> createState() => _FormPengaduanViewState();
}

class _FormPengaduanViewState extends State<FormPengaduanView> {
  final WargaDashboardController wargaController =
      Get.find<WargaDashboardController>();

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    wargaController.setAutoRefreshEnabled(false);

    // Isi form dengan data yang diberikan jika ada
    if (widget.judul != null) {
      _titleController.text = widget.judul!;
    }
    if (widget.deskripsi != null) {
      _descriptionController.text = widget.deskripsi!;
    }
    if (widget.selectedImages != null && widget.selectedImages!.isNotEmpty) {
      _selectedImages = List.from(widget.selectedImages!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    wargaController.setAutoRefreshEnabled(true);
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat memilih gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      try {
        setState(() {
          _isSubmitting = true;
        });

        // Menutup keyboard sebelum memproses
        FocusScope.of(context).unfocus();

        // Menyiapkan data foto
        List<String> fotoPaths =
            _selectedImages.map((file) => file.path).toList();

        final success = await wargaController.addPengaduan(
          judul: _titleController.text,
          deskripsi: _descriptionController.text,
          penerimaPenyaluranId: widget.uidPenerimaan,
          fotoPengaduanPaths: fotoPaths,
        );

        if (success) {
          Get.back(result: true);
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal mengirim pengaduan: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pengaduan'),
        backgroundColor: Get.theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input Judul Pengaduan
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Pengaduan',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul pengaduan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Input Deskripsi Pengaduan
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Pengaduan',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  maxLines: 5,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi pengaduan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Button untuk memilih gambar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeri'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Kamera'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                // Tampilkan gambar-gambar jika sudah dipilih
                if (_selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Foto Pengaduan:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_selectedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 13,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Button untuk submit pengaduan
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Kirim Pengaduan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
