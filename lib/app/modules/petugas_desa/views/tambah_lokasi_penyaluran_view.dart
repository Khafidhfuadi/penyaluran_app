import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';

class TambahLokasiPenyaluranView extends GetView<JadwalPenyaluranController> {
  const TambahLokasiPenyaluranView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Lokasi Penyaluran'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _LokasiPenyaluranForm(controller: controller),
    );
  }
}

class _LokasiPenyaluranForm extends StatefulWidget {
  final JadwalPenyaluranController controller;

  const _LokasiPenyaluranForm({required this.controller});

  @override
  State<_LokasiPenyaluranForm> createState() => _LokasiPenyaluranFormState();
}

class _LokasiPenyaluranFormState extends State<_LokasiPenyaluranForm> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatLengkapController = TextEditingController();
  bool isLokasiTitip = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Form
              Text(
                'Formulir Lokasi Penyaluran',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Nama Lokasi
              Text(
                'Nama Lokasi',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama lokasi penyaluran',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lokasi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Alamat Lengkap
              Text(
                'Alamat Lengkap',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: alamatLengkapController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alamat lengkap lokasi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Checkbox Is Lokasi Titip
              Row(
                children: [
                  Checkbox(
                    value: isLokasiTitip,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (newValue) {
                      setState(() {
                        isLokasiTitip = newValue ?? false;
                      });
                    },
                  ),
                  const Text('Lokasi Titip'),
                  const SizedBox(width: 4),
                  const Tooltip(
                    message:
                        'Centang jika lokasi ini merupakan lokasi yang dapat menerima penitipan',
                    child: Icon(Icons.info_outline, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Panggil fungsi untuk menambahkan lokasi penyaluran
                      _tambahLokasiPenyaluran(
                        nama: namaController.text,
                        alamatLengkap: alamatLengkapController.text,
                        isLokasiTitip: isLokasiTitip,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Simpan Lokasi',
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
    );
  }

  Future<void> _tambahLokasiPenyaluran({
    required String nama,
    required String alamatLengkap,
    required bool isLokasiTitip,
  }) async {
    try {
      // Tampilkan loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Generate UUID untuk ID lokasi
      final uuid = const Uuid();
      final String id = uuid.v4();

      // Ambil ID petugas desa yang sedang login dari controller
      final String? petugasDesaId =
          widget.controller.supabaseService.currentUser?.id;

      if (petugasDesaId == null) {
        Get.back(); // Tutup dialog loading
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text('Sesi login tidak valid. Silakan login kembali.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Dapatkan desa_id dari data petugas desa
      // Ambil data petugas desa dari Supabase untuk mendapatkan desa_id
      final petugasDesaData = await widget.controller.supabaseService.client
          .from('petugas_desa')
          .select('desa_id')
          .eq('id', petugasDesaId)
          .single();

      final String? desaId = petugasDesaData['desa_id'];

      if (desaId == null) {
        Get.back(); // Tutup dialog loading
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text(
                'Data desa tidak ditemukan. Silakan hubungi administrator.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Data untuk insert
      final Map<String, dynamic> data = {
        'id': id,
        'nama': nama,
        'alamat_lengkap': alamatLengkap,
        'desa_id': desaId,
        'is_lokasi_titip': isLokasiTitip,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Insert data ke tabel lokasi_penyaluran
      await widget.controller.supabaseService.client
          .from('lokasi_penyaluran')
          .insert(data);

      // Tutup dialog loading
      Get.back();

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text('Lokasi penyaluran berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman sebelumnya
      Get.back();

      // Refresh data di controller
      widget.controller.refreshData();
    } catch (e) {
      // Tutup dialog loading
      Get.back();

      // Tampilkan pesan error
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan lokasi penyaluran: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
