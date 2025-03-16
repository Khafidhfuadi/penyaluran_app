import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/data/models/skema_bantuan_model.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';

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
    final TextEditingController tanggalPenyaluranController =
        TextEditingController();
    final TextEditingController waktuMulaiController = TextEditingController();

    // Variabel untuk menyimpan nilai yang dipilih
    final Rx<String?> selectedSkemaBantuanId = Rx<String?>(null);
    final Rx<String?> selectedLokasiPenyaluranId = Rx<String?>(null);
    final Rx<SkemaBantuanModel?> selectedSkemaBantuan =
        Rx<SkemaBantuanModel?>(null);
    final RxInt jumlahPenerima = 0.obs;

    // Tanggal dan waktu penyaluran
    final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
    final Rx<TimeOfDay?> selectedWaktuMulai = Rx<TimeOfDay?>(null);

    // Fungsi untuk memuat data pengajuan kelayakan bantuan
    Future<void> loadPengajuanKelayakan(String skemaId) async {
      try {
        final pengajuanData = await controller.supabaseService.client
            .from('xx02_pengajuan_kelayakan_bantuan')
            .select('*')
            .eq('skema_bantuan_id', skemaId)
            .eq('status', 'TERVERIFIKASI');
        print('pengajuan $pengajuanData');

        jumlahPenerima.value = pengajuanData.length;
      } catch (e) {
        print('Error loading pengajuan kelayakan: $e');
      }
    }

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

              // Skema Bantuan
              Text(
                'Skema Bantuan',
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
                    hint: const Text('Pilih skema bantuan'),
                    value: selectedSkemaBantuanId.value,
                    items: controller.skemaBantuanCache.entries
                        .map((entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value.nama ?? 'Tidak ada nama'),
                            ))
                        .toList(),
                    onChanged: (value) async {
                      selectedSkemaBantuanId.value = value;
                      if (value != null) {
                        selectedSkemaBantuan.value =
                            controller.skemaBantuanCache[value];
                        await loadPengajuanKelayakan(value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Skema bantuan harus dipilih';
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

              // Jumlah Penerima (Otomatis)
              Text(
                'Jumlah Penerima',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Obx(() => TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: jumlahPenerima.value.toString()),
                    decoration: InputDecoration(
                      hintText: 'Jumlah penerima akan diambil otomatis',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  )),
              const SizedBox(height: 8),
              Text(
                'Info: Jumlah penerima diambil dari data pengajuan kelayakan bantuan yang telah terverifikasi untuk skema bantuan yang dipilih.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => jumlahPenerima.value > 0
                  ? TextButton.icon(
                      onPressed: () async {
                        final pengajuanData = await controller
                            .supabaseService.client
                            .from('xx02_pengajuan_kelayakan_bantuan')
                            .select('*, warga:warga_id(*)')
                            .eq('skema_bantuan_id',
                                selectedSkemaBantuanId.value ?? '')
                            .eq('status', 'TERVERIFIKASI');

                        Get.dialog(
                          Dialog(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.8,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Daftar Penerima Bantuan',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => Get.back(),
                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SingleChildScrollView(
                                        child: DataTable(
                                          columnSpacing: 20,
                                          horizontalMargin: 20,
                                          columns: const [
                                            DataColumn(label: Text('No')),
                                            DataColumn(label: Text('Nama')),
                                            DataColumn(label: Text('NIK')),
                                            DataColumn(label: Text('Alamat')),
                                          ],
                                          rows: pengajuanData
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final warga = entry.value['warga'];
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                    Text('${entry.key + 1}')),
                                                DataCell(Text(
                                                    warga['nama_lengkap'] ??
                                                        '-')),
                                                DataCell(
                                                    Text(warga['nik'] ?? '-')),
                                                DataCell(Text(
                                                    warga['alamat'] ?? '-')),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('Lihat Daftar Penerima'),
                    )
                  : const SizedBox.shrink()),
              const SizedBox(height: 8),

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
                  // Tanggal minimal adalah 1 hari setelah hari ini
                  final DateTime tomorrow =
                      DateTime.now().add(const Duration(days: 1));
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: tomorrow,
                    firstDate: tomorrow,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    selectedDate.value = pickedDate;
                    tanggalPenyaluranController.text =
                        DateTimeHelper.formatDate(pickedDate);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal penyaluran harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Hint info tanggal minimal
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tanggal pelaksanaan minimal 1 hari sebelum dijadwalkan',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Waktu Mulai
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Waktu Mulai'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: waktuMulaiController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Pilih waktu mulai',
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
                        selectedWaktuMulai.value = pickedTime;
                        waktuMulaiController.text =
                            '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Waktu mulai harus dipilih';
                      }
                      return null;
                    },
                  ),
                ],
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
                      // Gabungkan tanggal dan waktu mulai
                      DateTime? tanggalWaktuMulai;
                      if (selectedDate.value != null &&
                          selectedWaktuMulai.value != null) {
                        tanggalWaktuMulai = DateTime(
                          selectedDate.value!.year,
                          selectedDate.value!.month,
                          selectedDate.value!.day,
                          selectedWaktuMulai.value!.hour,
                          selectedWaktuMulai.value!.minute,
                        ).toLocal();
                      }

                      // Panggil fungsi untuk menambahkan penyaluran
                      controller.tambahPenyaluran(
                        nama: namaController.text,
                        deskripsi: deskripsiController.text,
                        skemaId: selectedSkemaBantuanId.value!,
                        lokasiPenyaluranId: selectedLokasiPenyaluranId.value!,
                        jumlahPenerima: jumlahPenerima.value,
                        tanggalPenyaluran: tanggalWaktuMulai,
                        kategoriBantuanId:
                            selectedSkemaBantuan.value!.kategoriBantuanId!,
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
