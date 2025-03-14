import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class TambahPenyaluranView extends GetView<JadwalPenyaluranController> {
  const TambahPenyaluranView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Penyaluran Bantuan'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildTambahPenyaluranForm(context),
    );
  }

  Widget _buildTambahPenyaluranForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController namaController = TextEditingController();
    final TextEditingController deskripsiController = TextEditingController();
    final TextEditingController jumlahPenerimaController =
        TextEditingController();
    final TextEditingController tanggalPenyaluranController =
        TextEditingController();
    final TextEditingController waktuPenyaluranController =
        TextEditingController();

    // Variabel untuk menyimpan nilai yang dipilih
    final Rx<String?> selectedKategoriBantuanId = Rx<String?>(null);
    final Rx<String?> selectedLokasiPenyaluranId = Rx<String?>(null);

    // Tanggal dan waktu penyaluran
    final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
    final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

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
                'Formulir Penyaluran Bantuan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Nama Penyaluran
              Text(
                'Nama Penyaluran',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama penyaluran',
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
                    return 'Nama penyaluran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kategori Bantuan
              Text(
                'Kategori Bantuan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: const Text('Pilih kategori bantuan'),
                    value: selectedKategoriBantuanId.value,
                    items: controller.kategoriBantuanCache.entries
                        .map((entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value.nama ?? 'Tidak ada nama'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      selectedKategoriBantuanId.value = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kategori bantuan harus dipilih';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 16),

              // Lokasi Penyaluran
              Text(
                'Lokasi Penyaluran',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: const Text('Pilih lokasi penyaluran'),
                    value: selectedLokasiPenyaluranId.value,
                    items: controller.lokasiPenyaluranCache.entries
                        .map((entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value.nama),
                            ))
                        .toList(),
                    onChanged: (value) {
                      selectedLokasiPenyaluranId.value = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lokasi penyaluran harus dipilih';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 16),

              // Jumlah Penerima
              Text(
                'Jumlah Penerima',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: jumlahPenerimaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah penerima',
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
                    return 'Jumlah penerima tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Jumlah penerima harus berupa angka';
                  }
                  if (int.parse(value) <= 0) {
                    return 'Jumlah penerima harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tanggal Penyaluran
              Text(
                'Tanggal Penyaluran',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: tanggalPenyaluranController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pilih tanggal penyaluran',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    selectedDate.value = pickedDate;
                    tanggalPenyaluranController.text =
                        DateFormat('dd MMMM yyyy', 'id_ID').format(pickedDate);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal penyaluran harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Waktu Penyaluran
              Text(
                'Waktu Penyaluran',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: waktuPenyaluranController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pilih waktu penyaluran',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  suffixIcon: const Icon(Icons.access_time),
                ),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    selectedTime.value = pickedTime;
                    waktuPenyaluranController.text =
                        '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Waktu penyaluran harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi
              Text(
                'Deskripsi',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: deskripsiController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Masukkan deskripsi penyaluran',
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
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Gabungkan tanggal dan waktu
                      DateTime? tanggalWaktuPenyaluran;
                      if (selectedDate.value != null &&
                          selectedTime.value != null) {
                        tanggalWaktuPenyaluran = DateTime(
                          selectedDate.value!.year,
                          selectedDate.value!.month,
                          selectedDate.value!.day,
                          selectedTime.value!.hour,
                          selectedTime.value!.minute,
                        ).toLocal();
                      }

                      // Panggil fungsi untuk menambahkan penyaluran
                      controller.tambahPenyaluran(
                        nama: namaController.text,
                        deskripsi: deskripsiController.text,
                        kategoriBantuanId: selectedKategoriBantuanId.value!,
                        lokasiPenyaluranId: selectedLokasiPenyaluranId.value!,
                        jumlahPenerima:
                            int.parse(jumlahPenerimaController.text),
                        tanggalPenyaluran: tanggalWaktuPenyaluran,
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
                    'Simpan Penyaluran',
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
}
