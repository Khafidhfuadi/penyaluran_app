import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/data/models/skema_bantuan_model.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';

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
    final RxDouble jumlahDiterimaPerOrang = 0.0.obs;
    final RxString namaStokBantuan = ''.obs;
    final RxString satuanStokBantuan = ''.obs;
    final RxDouble totalStokDibutuhkan = 0.0.obs;
    final RxDouble totalStokTersedia = 0.0.obs;
    final RxBool isStokCukup = false.obs;
    final RxBool isUang = false.obs;

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

        // Hitung total stok yang dibutuhkan
        totalStokDibutuhkan.value =
            jumlahPenerima.value * jumlahDiterimaPerOrang.value;

        // Perbarui status kecukupan stok
        isStokCukup.value =
            totalStokTersedia.value >= totalStokDibutuhkan.value;
      } catch (e) {
        print('Error loading pengajuan kelayakan: $e');
      }
    }

    // Fungsi untuk memuat informasi stok bantuan
    Future<void> loadStokBantuanInfo(String stokBantuanId) async {
      try {
        if (stokBantuanId.isEmpty) {
          namaStokBantuan.value = 'Tidak ada stok terkait';
          satuanStokBantuan.value = '';
          totalStokTersedia.value = 0;
          isStokCukup.value = false;
          isUang.value = false;
          return;
        }

        final stokData = await controller.supabaseService.client
            .from('stok_bantuan')
            .select('*')
            .eq('id', stokBantuanId)
            .single();

        print('stokData $stokData');

        namaStokBantuan.value = stokData['nama'] ?? 'Nama stok tidak tersedia';
        satuanStokBantuan.value = stokData['satuan'] ?? 'Tidak ada satuan';
        isUang.value = stokData['is_uang'] ?? false;

        // Ambil jumlah stok tersedia
        if (stokData['total_stok'] != null) {
          totalStokTersedia.value = stokData['total_stok'].toDouble();
        } else {
          totalStokTersedia.value = 0;
        }

        // Periksa kecukupan stok
        isStokCukup.value =
            totalStokTersedia.value >= totalStokDibutuhkan.value;
      } catch (e) {
        print('Error loading stok bantuan: $e');
        namaStokBantuan.value = 'Error memuat data stok';
        satuanStokBantuan.value = '';
        totalStokTersedia.value = 0;
        isStokCukup.value = false;
        isUang.value = false;
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

                        // Set jumlah yang diterima per orang
                        jumlahDiterimaPerOrang.value = selectedSkemaBantuan
                                .value?.jumlahDiterimaPerOrang ??
                            0.0;

                        // Load stok bantuan info
                        if (selectedSkemaBantuan.value?.stokBantuanId != null) {
                          await loadStokBantuanInfo(
                              selectedSkemaBantuan.value!.stokBantuanId!);
                        } else {
                          namaStokBantuan.value = 'Tidak ada stok terkait';
                        }

                        await loadPengajuanKelayakan(value);

                        // Periksa apakah ada penerima
                        if (jumlahPenerima.value == 0) {
                          Get.snackbar(
                            'Perhatian',
                            'Skema bantuan ini tidak memiliki penerima yang terverifikasi!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 4),
                          );
                        }
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Skema bantuan harus dipilih';
                      }
                      return null;
                    },
                  )),

              // const SizedBox(height: 16),
              // Pesan pemberitahuan jika tidak ada penerima
              Obx(() => jumlahPenerima.value == 0 &&
                      selectedSkemaBantuanId.value != null
                  ? Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Skema bantuan ini tidak memiliki penerima yang terverifikasi. Tambahkan penerima terlebih dahulu.',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox()),
              const SizedBox(height: 16),
              // Jumlah Penerima (Otomatis)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Jumlah Penerima',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(width: 4),
                            Tooltip(
                              message:
                                  'Jumlah penerima dari pengajuan kelayakan yang terverifikasi.',
                              triggerMode: TooltipTriggerMode.tap,
                              child: Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(() => TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                  text: jumlahPenerima.value.toString()),
                              decoration: InputDecoration(
                                hintText:
                                    'Jumlah penerima akan diambil otomatis',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        // Jumlah Diterima Per Orang (dari skema)
                        Row(
                          children: [
                            Text(
                              'Jumlah Per Penerima',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(width: 4),
                            Tooltip(
                              message:
                                  'Jumlah yang akan diterima setiap penerima bantuan.',
                              triggerMode: TooltipTriggerMode.tap,
                              child: Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(() => TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                  text:
                                      jumlahDiterimaPerOrang.value.toString()),
                              decoration: InputDecoration(
                                hintText:
                                    'Jumlah diterima per orang dari skema bantuan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                suffixText: satuanStokBantuan.value.isNotEmpty
                                    ? satuanStokBantuan.value
                                    : 'satuan',
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Daftar Penerima',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Obx(() => OutlinedButton.icon(
                    onPressed: jumlahPenerima.value > 0
                        ? () async {
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                DataColumn(
                                                    label: Text('Alamat')),
                                              ],
                                              rows: pengajuanData
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                final warga =
                                                    entry.value['warga'];
                                                return DataRow(
                                                  cells: [
                                                    DataCell(Text(
                                                        '${entry.key + 1}')),
                                                    DataCell(Text(
                                                        warga['nama_lengkap'] ??
                                                            '-')),
                                                    DataCell(Text(
                                                        warga['nik'] ?? '-')),
                                                    DataCell(Text(
                                                        warga['alamat'] ??
                                                            '-')),
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
                          }
                        : null,
                    icon: const Icon(Icons.people),
                    label: const Text('Lihat Daftar'),
                    style: ButtonStyle(
                      foregroundColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        return jumlahPenerima.value <= 0
                            ? Colors.grey
                            : Theme.of(context).primaryColor;
                      }),
                      backgroundColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        return jumlahPenerima.value <= 0
                            ? Colors.grey.withOpacity(0.1)
                            : Theme.of(context).primaryColor.withOpacity(0.1);
                      }),
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: jumlahPenerima.value <= 0
                                ? Colors.grey.withOpacity(0.5)
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  )),

              const SizedBox(height: 16),

              // Informasi Stok Bantuan
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Stok Bantuan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nama Stok'),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    namaStokBantuan.value,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Satuan Stok'),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    satuanStokBantuan.value,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Stok Tersedia'),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    isUang.value
                                        ? 'Rp ${DateTimeHelper.formatNumber(totalStokTersedia.value)}'
                                        : '${totalStokTersedia.value} ${satuanStokBantuan.value}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Total Stok Dibutuhkan'),
                                  const SizedBox(width: 4),
                                  Tooltip(
                                    message:
                                        'Total stok yang dibutuhkan dihitung dari jumlah penerima × jumlah yang diterima per orang',
                                    triggerMode: TooltipTriggerMode.tap,
                                    child: const Icon(Icons.info_outline,
                                        size: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    isUang.value
                                        ? 'Rp ${DateTimeHelper.formatNumber(totalStokDibutuhkan.value)}'
                                        : '${totalStokDibutuhkan.value} ${satuanStokBantuan.value}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() => selectedSkemaBantuanId.value != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isStokCukup.value
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isStokCukup.value
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isStokCukup.value
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: isStokCukup.value
                                      ? Colors.green
                                      : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isStokCukup.value
                                        ? 'Stok tersedia cukup untuk penyaluran'
                                        : 'Stok tidak cukup untuk penyaluran! Tambah stok terlebih dahulu.',
                                    style: TextStyle(
                                      color: isStokCukup.value
                                          ? Colors.green[800]
                                          : Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Nama Penyaluran
              Text(
                'Judul Penyaluran',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan judul penyaluran',
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
                    return 'Judul penyaluran tidak boleh kosong';
                  }
                  return null;
                },
              ),
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

              // Tanggal Penyaluran
              Row(
                children: [
                  Text(
                    'Tanggal Penyaluran',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message:
                        'Tanggal pelaksanaan minimal 1 hari sebelum dijadwalkan',
                    triggerMode: TooltipTriggerMode.tap,
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
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
                child: Obx(() => ElevatedButton(
                      onPressed: jumlahPenerima.value > 0
                          ? () {
                              if (formKey.currentState!.validate()) {
                                // Periksa kecukupan stok
                                if (!isStokCukup.value) {
                                  Get.snackbar(
                                    'Stok Tidak Cukup',
                                    'Stok bantuan tidak mencukupi untuk penyaluran ini. Silakan tambah stok terlebih dahulu.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 4),
                                  );
                                  return;
                                }

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
                                    lokasiPenyaluranId:
                                        selectedLokasiPenyaluranId.value!,
                                    jumlahPenerima: jumlahPenerima.value,
                                    tanggalPenyaluran: tanggalWaktuMulai,
                                    kategoriBantuanId: selectedSkemaBantuan
                                        .value!.kategoriBantuanId!,
                                    jumlahDiterimaPerOrang:
                                        jumlahDiterimaPerOrang.value,
                                    stokBantuanId: selectedSkemaBantuan
                                        .value!.stokBantuanId!,
                                    totalStokDibutuhkan:
                                        totalStokDibutuhkan.value);

                                //get back and refresh page
                                Get.back();
                                controller.refreshData();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                      ),
                      child: const Text(
                        'Simpan Penyaluran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
