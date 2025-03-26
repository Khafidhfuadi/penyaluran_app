import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/skema_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'dart:io';

class DonaturPenitipanView extends GetView<DonaturDashboardController> {
  const DonaturPenitipanView({super.key});

  @override
  DonaturDashboardController get controller {
    if (!Get.isRegistered<DonaturDashboardController>(
        tag: 'donatur_dashboard')) {
      return Get.put(DonaturDashboardController(),
          tag: 'donatur_dashboard', permanent: true);
    }
    return Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return FormPenitipanBantuan();
  }
}

class FormPenitipanBantuan extends StatefulWidget {
  const FormPenitipanBantuan({super.key});

  @override
  _FormPenitipanBantuanState createState() => _FormPenitipanBantuanState();
}

class _FormPenitipanBantuanState extends State<FormPenitipanBantuan> {
  final DonaturDashboardController controller =
      Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedStokBantuanId;
  String? selectedSkemaBantuanId;
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset foto bantuan saat form dibuka
    controller.resetFotoBantuan();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Formulir Penitipan Bantuan'),
              Text(
                'Isi formulir berikut untuk melakukan penitipan bantuan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Pilih metode penitipan
              Text(
                'Metode Penitipan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),

              // Tab pilihan metode
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedSkemaBantuanId = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedSkemaBantuanId == null
                                ? Colors.blue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Bantuan Manual',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedSkemaBantuanId == null
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            // Reset stok bantuan saat memilih skema
                            selectedStokBantuanId = null;
                            selectedSkemaBantuanId = '';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedSkemaBantuanId != null
                                ? Colors.blue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Dari Skema Bantuan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedSkemaBantuanId != null
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form berdasarkan pilihan
              if (selectedSkemaBantuanId != null) ...[
                // Form untuk skema bantuan
                Text(
                  'Pilih Skema Bantuan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    hintText: 'Pilih skema bantuan',
                  ),
                  value: selectedSkemaBantuanId == ''
                      ? null
                      : selectedSkemaBantuanId,
                  items: controller.skemaBantuan.map((skema) {
                    return DropdownMenuItem<String>(
                      value: skema.id,
                      child: Text(skema.nama ?? 'Tidak ada nama'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSkemaBantuanId = value;
                      // Jika skema dipilih, isi otomatis stok bantuan sesuai dengan skema
                      if (value != null) {
                        final selectedSkema =
                            controller.skemaBantuan.firstWhere(
                          (skema) => skema.id == value,
                          orElse: () => SkemaBantuanModel(),
                        );
                        selectedStokBantuanId = selectedSkema.stokBantuanId;

                        // Isi otomatis jumlah jika ada
                        if (selectedSkema.jumlahDiterimaPerOrang != null) {
                          jumlahController.text =
                              selectedSkema.jumlahDiterimaPerOrang.toString();
                        }
                      }
                    });
                  },
                  validator: (value) {
                    if (selectedSkemaBantuanId != null &&
                        (value == null || value.isEmpty)) {
                      return 'Skema bantuan harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Form untuk bantuan manual
                Text(
                  'Jenis Bantuan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    hintText: 'Pilih jenis bantuan',
                  ),
                  value: selectedStokBantuanId,
                  items: controller.getAvailableStokBantuan().map((stok) {
                    return DropdownMenuItem<String>(
                      value: stok.id,
                      child: Text(
                          '${stok.nama ?? 'Tidak ada nama'} (Stok: ${stok.totalStok ?? 0} ${stok.satuan ?? 'item'})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStokBantuanId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis bantuan harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Jumlah bantuan
              Text(
                'Jumlah Bantuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Masukkan jumlah bantuan',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Jumlah harus berupa angka';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi bantuan
              Text(
                'Deskripsi Bantuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: deskripsiController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Deskripsi bantuan yang dititipkan',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Foto bantuan
              Text(
                'Foto Bantuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),

              // Widget untuk foto bantuan
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tampilkan foto yang sudah dipilih
                      if (controller.fotoBantuanPaths.isNotEmpty) ...[
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.fotoBantuanPaths.length +
                                1, // +1 untuk tombol tambah
                            itemBuilder: (context, index) {
                              if (index == controller.fotoBantuanPaths.length) {
                                // Tombol tambah foto
                                return GestureDetector(
                                  onTap: _showPilihSumberFoto,
                                  child: Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 32,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tambah Foto',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // Tampilkan foto yang sudah dipilih
                              return Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                      image: DecorationImage(
                                        image: FileImage(File(controller
                                            .fotoBantuanPaths[index])),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.removeFotoBantuan(index);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        // Tampilkan placeholder untuk upload foto
                        GestureDetector(
                          onTap: _showPilihSumberFoto,
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tambah Foto Bantuan',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Upload minimal 1 foto bantuan',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  )),

              const SizedBox(height: 24),

              // Tombol kirim
              ElevatedButton.icon(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Validasi foto bantuan
                    if (controller.fotoBantuanPaths.isEmpty) {
                      Get.snackbar(
                        'Peringatan',
                        'Harap upload setidaknya 1 foto bantuan',
                        backgroundColor: Colors.amber,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 3),
                      );
                      return;
                    }

                    // Tampilkan konfirmasi sebelum mengirim
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Konfirmasi Penitipan Bantuan'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                'Apakah data yang Anda masukkan sudah benar?'),
                            const SizedBox(height: 12),
                            const Text(
                                'Penitipan bantuan akan diproses oleh petugas desa.'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              // Panggil fungsi untuk membuat penitipan bantuan
                              controller.createPenitipanBantuan(
                                selectedStokBantuanId,
                                double.parse(jumlahController.text),
                                deskripsiController.text,
                                selectedSkemaBantuanId,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Kirim'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('Kirim Penitipan Bantuan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Informasi kontak petugas
              Text(
                'Hubungi Petugas Desa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Untuk penitipan bantuan secara langsung, silahkan hubungi petugas desa terdekat atau kunjungi kantor desa terdekat.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Implementasi untuk membuka kontak petugas desa
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Informasi Kontak Petugas Desa'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContactInfo(
                            icon: Icons.phone,
                            title: 'Telepon',
                            content: '0812-3456-7890',
                          ),
                          const SizedBox(height: 16),
                          _buildContactInfo(
                            icon: Icons.email,
                            title: 'Email',
                            content: 'petugas@desa.id',
                          ),
                          const SizedBox(height: 16),
                          _buildContactInfo(
                            icon: Icons.location_on,
                            title: 'Alamat',
                            content:
                                'Jl. Desa Sejahtera No. 123, Kecamatan Makmur',
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.contact_phone),
                label: const Text('Lihat Kontak Petugas Desa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: BorderSide(color: Colors.blue.shade300),
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Fungsi untuk memilih foto
  void _showPilihSumberFoto() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                controller.pickImage(isCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                controller.pickImage(isCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
