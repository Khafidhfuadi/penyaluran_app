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
        title: const Text('Tambah Penyaluran'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Form
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: AppTheme.primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Formulir Penyaluran Bantuan',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Masukkan detail penyaluran bantuan untuk dijadwalkan. Pastikan stok mencukupi dan data penerima sudah terverifikasi.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Content sections will be added here
                // Bagian 1: Skema Bantuan
                _buildSectionContainer(
                  context,
                  title: 'Skema Bantuan',
                  icon: Icons.category_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Obx(() => DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Pilih Skema Bantuan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              prefixIcon: const Icon(Icons.list_alt_rounded),
                            ),
                            hint: const Text(
                                'Pilih skema bantuan yang akan disalurkan'),
                            value: selectedSkemaBantuanId.value,
                            items: controller.skemaBantuanCache.entries
                                .map((entry) => DropdownMenuItem<String>(
                                      value: entry.key,
                                      child: Text(
                                          entry.value.nama ?? 'Tidak ada nama'),
                                    ))
                                .toList(),
                            onChanged: (value) async {
                              selectedSkemaBantuanId.value = value;
                              if (value != null) {
                                selectedSkemaBantuan.value =
                                    controller.skemaBantuanCache[value];

                                // Set jumlah yang diterima per orang
                                jumlahDiterimaPerOrang.value =
                                    selectedSkemaBantuan
                                            .value?.jumlahDiterimaPerOrang ??
                                        0.0;

                                // Load stok bantuan info
                                if (selectedSkemaBantuan.value?.stokBantuanId !=
                                    null) {
                                  await loadStokBantuanInfo(selectedSkemaBantuan
                                      .value!.stokBantuanId!);
                                } else {
                                  namaStokBantuan.value =
                                      'Tidak ada stok terkait';
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bagian 2: Informasi Penerima Bantuan
                _buildSectionContainer(
                  context,
                  title: 'Informasi Penerima',
                  icon: Icons.people_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Jumlah Penerima
                          const Text(
                            'Jumlah Penerima',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.people),
                                    const SizedBox(width: 8),
                                    Text(
                                      jumlahPenerima.value.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              )),

                          const SizedBox(height: 16),

                          // Jumlah Per Penerima
                          const Text(
                            'Jumlah Per Penerima',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    isUang.value
                                        ? const Icon(Icons.payment_rounded)
                                        : const Icon(Icons.inventory_2),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        jumlahDiterimaPerOrang.value.toString(),
                                        style: const TextStyle(fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      satuanStokBantuan.value.isNotEmpty
                                          ? satuanStokBantuan.value
                                          : 'satuan',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tombol lihat daftar penerima
                      Obx(() => Center(
                            child: ElevatedButton.icon(
                              onPressed: jumlahPenerima.value > 0
                                  ? () async {
                                      final pengajuanData = await controller
                                          .supabaseService.client
                                          .from(
                                              'xx02_pengajuan_kelayakan_bantuan')
                                          .select('*, warga:warga_id(*)')
                                          .eq(
                                              'skema_bantuan_id',
                                              selectedSkemaBantuanId.value ??
                                                  '')
                                          .eq('status', 'TERVERIFIKASI');

                                      Get.dialog(
                                        Dialog(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.8,
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.people_alt,
                                                          color: AppTheme
                                                              .primaryColor,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        const Text(
                                                          'Daftar Penerima ',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      onPressed: () =>
                                                          Get.back(),
                                                      icon: const Icon(
                                                          Icons.close),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                const Divider(),
                                                const SizedBox(height: 16),
                                                Expanded(
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: DataTable(
                                                        columnSpacing: 20,
                                                        horizontalMargin: 20,
                                                        headingRowColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .grey[100]),
                                                        columns: const [
                                                          DataColumn(
                                                              label:
                                                                  Text('No')),
                                                          DataColumn(
                                                              label:
                                                                  Text('Nama')),
                                                          DataColumn(
                                                              label:
                                                                  Text('NIK')),
                                                          DataColumn(
                                                              label: Text(
                                                                  'Alamat')),
                                                        ],
                                                        rows: pengajuanData
                                                            .asMap()
                                                            .entries
                                                            .map((entry) {
                                                          final warga = entry
                                                              .value['warga'];
                                                          return DataRow(
                                                            cells: [
                                                              DataCell(Text(
                                                                  '${entry.key + 1}')),
                                                              DataCell(Text(
                                                                  warga['nama_lengkap'] ??
                                                                      '-')),
                                                              DataCell(Text(
                                                                  warga['nik'] ??
                                                                      '-')),
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
                              icon: Icon(
                                Icons.list,
                                color: jumlahPenerima.value > 0
                                    ? Colors.white
                                    : Colors.grey[400],
                              ),
                              label: Text(
                                'Lihat Daftar Penerima',
                                style: TextStyle(
                                  color: jumlahPenerima.value > 0
                                      ? Colors.white
                                      : Colors.grey[400],
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: jumlahPenerima.value > 0
                                    ? AppTheme.primaryColor
                                    : Colors.grey[200],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bagian 3: Informasi Stok Bantuan
                _buildSectionContainer(
                  context,
                  title: 'Informasi Stok Bantuan',
                  icon: Icons.inventory_2_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Informasi stok
                      Obx(() => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: Colors.amber[800],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Detail Stok',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber[800],
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Baris pertama: Nama dan Satuan
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoItem(
                                        context,
                                        icon: Icons.inventory,
                                        title: 'Nama Stok',
                                        value: namaStokBantuan.value,
                                        iconColor: Colors.amber[800]!,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildInfoItem(
                                        context,
                                        icon: Icons.straighten,
                                        title: 'Satuan',
                                        value: satuanStokBantuan.value.isEmpty
                                            ? '-'
                                            : satuanStokBantuan.value,
                                        iconColor: Colors.amber[800]!,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Baris kedua: Total Tersedia dan Dibutuhkan
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoItem(
                                        context,
                                        icon: Icons.storage,
                                        title: 'Total Tersedia',
                                        value: isUang.value
                                            ? 'Rp ${FormatHelper.formatNumber(totalStokTersedia.value)}'
                                            : '${totalStokTersedia.value} ${satuanStokBantuan.value}',
                                        iconColor: Colors.blue[700]!,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildInfoItem(
                                        context,
                                        icon: Icons.shopping_basket,
                                        title: 'Total Dibutuhkan',
                                        value: isUang.value
                                            ? 'Rp ${FormatHelper.formatNumber(totalStokDibutuhkan.value)}'
                                            : '${totalStokDibutuhkan.value} ${satuanStokBantuan.value}',
                                        iconColor: Colors.purple[700]!,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Status kecukupan stok
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isStokCukup.value
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
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
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isStokCukup.value
                                                  ? 'Stok Tersedia Mencukupi'
                                                  : 'Stok Tidak Mencukupi',
                                              style: TextStyle(
                                                color: isStokCukup.value
                                                    ? Colors.green[800]
                                                    : Colors.red[800],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (!isStokCukup.value) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Tambah stok terlebih dahulu sebelum melanjutkan penyaluran.',
                                                style: TextStyle(
                                                  color: Colors.red[700],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (isStokCukup.value)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.green[300]!,
                                            ),
                                          ),
                                          child: Text(
                                            'Siap Disalurkan',
                                            style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bagian 4: Detail Penyaluran
                _buildSectionContainer(
                  context,
                  title: 'Detail Penyaluran',
                  icon: Icons.event_note_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: namaController,
                        decoration: InputDecoration(
                          labelText: 'Masukkan judul penyaluran',
                          hintText: 'Contoh: Penyaluran BLT Desa April 2023',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul penyaluran tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Obx(() => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Pilih lokasi penyaluran',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              prefixIcon: const Icon(Icons.location_on),
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

                      // Tanggal dan Waktu dalam satu baris
                      Row(
                        children: [
                          // Tanggal Penyaluran
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Tanggal Penyaluran',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Tooltip(
                                      message:
                                          'Tanggal pelaksanaan minimal 1 hari setelah hari ini',
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
                                    hintText: 'Pilih tanggal',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    prefixIcon:
                                        const Icon(Icons.calendar_today),
                                  ),
                                  onTap: () async {
                                    // Tanggal minimal adalah 1 hari setelah hari ini
                                    final DateTime tomorrow = DateTime.now()
                                        .add(const Duration(days: 1));
                                    final DateTime? pickedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: tomorrow,
                                      firstDate: tomorrow,
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 365)),
                                    );
                                    if (pickedDate != null) {
                                      selectedDate.value = pickedDate;
                                      tanggalPenyaluranController.text =
                                          FormatHelper.formatDateTime(
                                              pickedDate);
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Tanggal penyaluran harus dipilih';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Waktu Mulai
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Waktu Mulai',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: waktuMulaiController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: 'Pilih waktu',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    prefixIcon: const Icon(Icons.access_time),
                                  ),
                                  onTap: () async {
                                    final TimeOfDay? pickedTime =
                                        await showTimePicker(
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      Text(
                        'Deskripsi Penyaluran',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: deskripsiController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Masukkan deskripsi detail penyaluran',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 72),
                            child: Icon(Icons.description,
                                color: Colors.grey[600]),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                Container(
                  margin: const EdgeInsets.only(top: 24, bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Obx(() => !isStokCukup.value || jumlahPenerima.value <= 0
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 16),
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
                                      !isStokCukup.value
                                          ? 'Stok tidak mencukupi untuk penyaluran. Tambah stok terlebih dahulu.'
                                          : 'Tidak ada penerima bantuan yang terverifikasi.',
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
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() => ElevatedButton(
                              onPressed: (jumlahPenerima.value > 0 &&
                                      isStokCukup.value)
                                  ? () {
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
                                            skemaId:
                                                selectedSkemaBantuanId.value!,
                                            lokasiPenyaluranId:
                                                selectedLokasiPenyaluranId
                                                    .value!,
                                            jumlahPenerima:
                                                jumlahPenerima.value,
                                            tanggalPenyaluran:
                                                tanggalWaktuMulai,
                                            kategoriBantuanId:
                                                selectedSkemaBantuan
                                                    .value!.kategoriBantuanId!,
                                            jumlahDiterimaPerOrang:
                                                jumlahDiterimaPerOrang.value,
                                            stokBantuanId: selectedSkemaBantuan
                                                .value!.stokBantuanId!,
                                            totalStokDibutuhkan:
                                                totalStokDibutuhkan.value);

                                        // get back and refresh page
                                        Get.back();
                                        controller.refreshData();
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                disabledBackgroundColor: Colors.grey.shade300,
                                disabledForegroundColor: Colors.grey.shade600,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Simpan Penyaluran',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),

                // Padding bottom untuk scroll
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    String? tooltip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        if (tooltip != null) ...[
          const SizedBox(height: 8),
          Tooltip(
            message: tooltip,
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.grey,
              size: 16,
            ),
          ),
        ],
      ],
    );
  }
}
