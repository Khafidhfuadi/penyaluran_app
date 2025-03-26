import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/data/models/pengaduan_model.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/widgets/status_badge.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class WargaDetailPenerimaanView extends GetView<WargaDashboardController> {
  const WargaDetailPenerimaanView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final id = args['id'];

    // Segera muat ulang data penerimaan ketika halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pastikan tidak ada dialog yang terbuka terlebih dahulu
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Kemudian muat data baru
      controller.fetchPenerimaPenyaluran();
      controller.fetchPengaduan(); // Tambahkan untuk memuat data pengaduan
    });

    if (id == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Penerimaan'),
        ),
        body: const Center(
          child: Text('ID Penerimaan tidak ditemukan'),
        ),
      );
    }

    // Konversi id ke string untuk memastikan kompatibilitas dengan model
    final String penyaluranId = id.toString();

    // Gunakan GetBuilder untuk memastikan widget dibangun ulang ketika data berubah
    return Obx(() {
      // Cari data penerimaan berdasarkan ID
      final PenerimaPenyaluranModel? penyaluran = controller.penerimaPenyaluran
          .firstWhereOrNull((item) => item.id == penyaluranId);

      if (penyaluran == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Penerimaan'),
          ),
          body: const Center(
            child: Text('Data penerimaan tidak ditemukan'),
          ),
        );
      }

      final bool isDiterima = penyaluran.statusPenerimaan == 'DITERIMA';

      // Cek apakah ada pengaduan untuk penyaluran ini
      final pengaduan = controller.pengaduan.firstWhereOrNull(
          (item) => item.penerimaPenyaluranId == penyaluranId);
      final bool hasPengaduan = pengaduan != null;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Penerimaan'),
          elevation: 0,
          backgroundColor: Get.theme.primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Get.theme.primaryColor.withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(penyaluran),
                const SizedBox(height: 16),

                // Tampilkan pengaduan yang ada (jika ada) di bagian atas
                if (hasPengaduan) ...[
                  _buildExistingPengaduanSection(pengaduan),
                  const SizedBox(height: 16),
                ],

                if (penyaluran.qrCodeHash != null &&
                    penyaluran.qrCodeHash!.isNotEmpty)
                  _buildQrCodeSection(penyaluran),
                if (penyaluran.qrCodeHash != null &&
                    penyaluran.qrCodeHash!.isNotEmpty)
                  const SizedBox(height: 16),
                _buildDetailSection(penyaluran),
                const SizedBox(height: 16),
                _buildLocationSection(penyaluran),
                const SizedBox(height: 16),
                if (isDiterima) _buildBuktiPenerimaanSection(penyaluran),
                if (isDiterima) const SizedBox(height: 16),
                _buildAdditionalInfoSection(penyaluran),

                // Tampilkan section pengaduan jika belum ada pengaduan
                if (isDiterima && !hasPengaduan) ...[
                  const SizedBox(height: 16),
                  _buildPengaduanSection(penyaluran),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeaderSection(PenerimaPenyaluranModel penyaluran) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Format jumlah bantuan berdasarkan tipe (uang atau bukan)
    String formattedJumlah = '';
    if (penyaluran.jumlahBantuan != null) {
      if (penyaluran.isUang == true) {
        formattedJumlah = currencyFormat.format(penyaluran.jumlahBantuan);
      } else {
        formattedJumlah =
            '${penyaluran.jumlahBantuan} ${penyaluran.satuan ?? ''}';
      }
    } else {
      formattedJumlah = '-';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(16),
        //   gradient: AppTheme.primaryGradient,
        // ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    penyaluran.namaPenyaluran ??
                        penyaluran.keterangan ??
                        'Bantuan',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (penyaluran.deskripsiPenyaluran != null &&
                penyaluran.deskripsiPenyaluran!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  penyaluran.deskripsiPenyaluran!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (penyaluran.isUang == true
                              ? Colors.green
                              : Colors.blue)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      penyaluran.isUang == true
                          ? Icons.attach_money
                          : Icons.inventory_2,
                      color: penyaluran.isUang == true
                          ? Colors.green
                          : Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jumlah Bantuan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          formattedJumlah,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: penyaluran.isUang == true
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                      const Text(
                        'Status Bantuan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status Penyaluran',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                StatusBadge(
                                  status: penyaluran.statusPenyaluran ?? '',
                                  fontSize: 14,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status Penerimaan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                StatusBadge(
                                  status: penyaluran.statusPenerimaan ??
                                      'BELUMMENERIMA',
                                  fontSize: 14,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(PenerimaPenyaluranModel penyaluran) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Get.theme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Detail Bantuan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.category,
              title: 'Kategori',
              value: penyaluran.kategoriNama ?? 'Tidak tersedia',
              statusColor: null,
            ),
            const Divider(height: 24),
            _buildDetailItem(
              icon: Icons.calendar_today,
              title: 'Tanggal Penerimaan',
              value: penyaluran.tanggalPenerimaan != null
                  ? DateFormat('dd MMMM yyyy', 'id_ID')
                      .format(penyaluran.tanggalPenerimaan!)
                  : 'Belum diterima',
              statusColor: null,
            ),
            const Divider(height: 24),
            _buildDetailItem(
              icon: Icons.access_time,
              title: 'Waktu Penerimaan',
              value: penyaluran.tanggalPenerimaan != null
                  ? DateFormat('HH:mm', 'id_ID')
                      .format(penyaluran.tanggalPenerimaan!)
                  : 'Belum diterima',
              statusColor: null,
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  color: Get.theme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Status Penerimaan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  status: penyaluran.statusPenerimaan ?? 'BELUMMENERIMA',
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ],
            ),
            if (penyaluran.statusPenyaluran != null &&
                penyaluran.statusPenyaluran!.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Get.theme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Status Penyaluran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    status: penyaluran.statusPenyaluran!,
                    fontSize: 12,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ],
              ),
            ],
            if (penyaluran.keterangan != null &&
                penyaluran.keterangan!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildDetailItem(
                icon: Icons.note,
                title: 'Keterangan',
                value: penyaluran.keterangan!,
                statusColor: null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(PenerimaPenyaluranModel penyaluran) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Get.theme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Lokasi Penerimaan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.place,
              title: 'Tempat Penerimaan',
              value: penyaluran.lokasiPenyaluranNama ?? 'Tidak tersedia',
              statusColor: null,
            ),
            if (penyaluran.lokasiPenyaluranAlamat != null &&
                penyaluran.lokasiPenyaluranAlamat!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildDetailItem(
                icon: Icons.map,
                title: 'Alamat',
                value: penyaluran.lokasiPenyaluranAlamat!,
                statusColor: null,
              ),
            ],
            const SizedBox(height: 16),
            // TODO: Implementasi peta lokasi jika koordinat tersedia
          ],
        ),
      ),
    );
  }

  Widget _buildBuktiPenerimaanSection(PenerimaPenyaluranModel penyaluran) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bukti Penerimaan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bukti Penerimaan (Foto)
            if (penyaluran.buktiPenerimaan != null &&
                penyaluran.buktiPenerimaan!.isNotEmpty) ...[
              const Text(
                'Foto Bukti Penerimaan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    penyaluran.buktiPenerimaan!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gambar tidak dapat dimuat',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Bukti penerimaan belum diunggah',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tanda Tangan
            const Divider(height: 24),
            const Text(
              'Tanda Tangan Penerima',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (penyaluran.tandaTangan != null &&
                penyaluran.tandaTangan!.isNotEmpty) ...[
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    penyaluran.tandaTangan!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tanda tangan tidak dapat dimuat',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.draw,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tanda tangan belum tersedia',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(PenerimaPenyaluranModel penyaluran) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.more_horiz,
                  color: Get.theme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Informasi Tambahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.numbers,
              title: 'ID Penerimaan',
              value: '${penyaluran.id}',
              statusColor: null,
            ),
            const Divider(height: 24),
            _buildDetailItem(
              icon: Icons.person,
              title: 'Penerima',
              value: controller.nama,
              statusColor: null,
            ),
            const Divider(height: 24),
            _buildDetailItem(
              icon: Icons.update,
              title: 'Terakhir Diperbarui',
              value: penyaluran.tanggalPenerimaan != null
                  ? DateFormat('dd MMMM yyyy HH:mm', 'id_ID')
                      .format(penyaluran.tanggalPenerimaan!)
                  : 'Tidak tersedia',
              statusColor: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCodeSection(PenerimaPenyaluranModel penyaluran) {
    // Pastikan menggunakan data terbaru dari model dan cetak ke log untuk debugging
    final qrData = penyaluran.qrCodeHash ?? 'invalid-qr-code';
    print('penyaluran.statusPenyaluran ${penyaluran.statusPenyaluran}');

    // Cek status penyaluran untuk disabled state
    final bool isDisabled = penyaluran.statusPenyaluran != null &&
        (penyaluran.statusPenyaluran!.toUpperCase() == 'DIJADWALKAN' ||
            penyaluran.statusPenyaluran!.toUpperCase() == 'DISETUJUI' ||
            penyaluran.statusPenyaluran!.toUpperCase() == 'BATALTERLAKSANA' ||
            penyaluran.statusPenyaluran!.toUpperCase() == 'TERLAKSANA');

    final String statusMessage;
    if (isDisabled) {
      if (penyaluran.statusPenyaluran!.toUpperCase() == 'BATALTERLAKSANA') {
        statusMessage =
            'QR Code tidak dapat digunakan karena penyaluran dibatalkan';
      } else if (penyaluran.statusPenyaluran!.toUpperCase() == 'TERLAKSANA') {
        statusMessage =
            'QR Code sudah digunakan pada penyaluran yang telah terlaksana';
      } else {
        statusMessage =
            'QR Code belum dapat digunakan karena penyaluran belum terlaksana';
      }
    } else {
      statusMessage =
          'Tunjukkan QR Code ini kepada petugas untuk verifikasi penerimaan';
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.qr_code,
                      color: isDisabled ? Colors.grey : Get.theme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'QR Code Verifikasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isDisabled)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock,
                          size: 14,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tidak Aktif',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // QR Code
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            isDisabled
                                ? Colors.grey.withOpacity(0.5)
                                : Colors.transparent,
                            BlendMode.srcATop,
                          ),
                          child: QrImageView(
                            key: UniqueKey(),
                            data: qrData,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                            errorStateBuilder: (cxt, err) {
                              return const Center(
                                child: Text(
                                  "QR Code tidak tersedia",
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),

                        // Overlay disabled jika perlu
                        if (isDisabled)
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'TIDAK AKTIF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDisabled
                            ? Colors.grey.shade700
                            : Colors.grey.shade700,
                        fontWeight:
                            isDisabled ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPengaduanSection(PenerimaPenyaluranModel penyaluran) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.report_problem,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pengaduan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apakah ada masalah dengan penyaluran ini?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan laporkan jika ada masalah atau keluhan terkait penyaluran bantuan ini.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showPengaduanDialog(penyaluran),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Pengaduan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPengaduanDialog(PenerimaPenyaluranModel penyaluran) {
    final TextEditingController judulController = TextEditingController();
    final TextEditingController deskripsiController = TextEditingController();
    final RxList<String> fotoPengaduanPaths = <String>[].obs;
    final ImagePicker imagePicker = ImagePicker();

    // Fungsi untuk mengambil foto pengaduan
    Future<void> pickFotoPengaduan(ImageSource source) async {
      try {
        final pickedFile = await imagePicker.pickImage(
          source: source,
          imageQuality: 70,
          maxWidth: 1000,
        );

        if (pickedFile != null) {
          fotoPengaduanPaths.add(pickedFile.path);
        }
      } catch (e) {
        print('Error picking image: $e');
        Get.snackbar(
          'Error',
          'Gagal mengambil gambar: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    // Fungsi untuk menampilkan dialog pilih sumber foto
    void showPilihSumberFoto() {
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
                  pickFotoPengaduan(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Get.back();
                  pickFotoPengaduan(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    }

    // Fungsi untuk menghapus foto dari daftar
    void removeFoto(int index) {
      if (index >= 0 && index < fotoPengaduanPaths.length) {
        fotoPengaduanPaths.removeAt(index);
      }
    }

    // Fungsi untuk memeriksa dan menutup loading dialog
    void closeLoadingDialog() {
      // Periksa apakah ada dialog yang terbuka sebelum menutupnya
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.report_problem,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 8),
            const Text('Buat Pengaduan'),
          ],
        ),
        content: Obx(() => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Penyaluran:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('ID: ${penyaluran.id}'),
                  Text(
                      'Nama Penyaluran: ${penyaluran.namaPenyaluran ?? 'Tidak tersedia'}'),
                  Text(
                      'Status: ${penyaluran.statusPenyaluran ?? 'Tidak tersedia'}'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: judulController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Pengaduan',
                      hintText: 'Masukkan judul pengaduan',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: deskripsiController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi Pengaduan',
                      hintText: 'Jelaskan masalah atau keluhan Anda',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),

                  // Widget untuk mengunggah foto pengaduan
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Foto Pengaduan:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: showPilihSumberFoto,
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Tambah Foto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Tampilkan foto yang sudah dipilih
                      if (fotoPengaduanPaths.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: fotoPengaduanPaths.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    margin: const EdgeInsets.only(
                                      right: 8,
                                      top: 8,
                                      bottom: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(fotoPengaduanPaths[index]),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => removeFoto(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
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
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            'Belum ada foto yang dipilih',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (judulController.text.isEmpty ||
                  deskripsiController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Judul dan deskripsi pengaduan harus diisi',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back(); // Tutup dialog terlebih dahulu

              // Tampilkan loading
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              bool success = false;
              try {
                // Simpan pengaduan ke database dengan foto
                success = await controller.addPengaduan(
                  judul: judulController.text,
                  deskripsi: deskripsiController.text,
                  penerimaPenyaluranId: penyaluran.id!,
                  fotoPengaduanPaths: fotoPengaduanPaths.toList(),
                );
              } catch (e) {
                print('Error saat membuat pengaduan: $e');
                Get.snackbar(
                  'Error',
                  'Terjadi kesalahan saat membuat pengaduan',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } finally {
                // Pastikan dialog loading ditutup dalam kondisi apapun
                closeLoadingDialog();
              }

              if (success) {
                // Refresh data halaman
                await controller.fetchPengaduan();
                await controller.fetchPenerimaPenyaluran();

                Get.snackbar(
                  'Sukses',
                  'Pengaduan berhasil dikirim dan data diperbarui',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );

                // Navigate ke halaman pengaduan jika berhasil
                controller.changeTab(2); // Tab pengaduan
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingPengaduanSection(PengaduanModel pengaduan) {
    // Tentukan warna berdasarkan status pengaduan
    Color statusColor;
    String statusText;

    switch (pengaduan.status?.toUpperCase() ?? '') {
      case 'MENUNGGU':
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      case 'TINDAKAN':
        statusColor = Colors.blue;
        statusText = 'Dalam Tindakan';
        break;
      case 'SELESAI':
        statusColor = Colors.green;
        statusText = 'Selesai';
        break;
      default:
        statusColor = Colors.grey;
        statusText = pengaduan.status ?? 'Tidak Diketahui';
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.report_problem,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Pengaduan Terdaftar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              pengaduan.judul ?? 'Pengaduan',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pengaduan.deskripsi ?? 'Tidak ada deskripsi',
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Tampilkan foto pengaduan jika ada
            if (pengaduan.fotoPengaduan != null &&
                pengaduan.fotoPengaduan!.isNotEmpty) ...[
              const Text(
                'Foto Pengaduan:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pengaduan.fotoPengaduan!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Tampilkan gambar dalam ukuran penuh ketika diklik
                        Get.dialog(
                          Dialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Get.back(),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.network(
                                  pengaduan.fotoPengaduan![index],
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            size: 48,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Gambar tidak dapat dimuat',
                                            style: TextStyle(
                                                color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            pengaduan.fotoPengaduan![index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey.shade400,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tanggal pengaduan
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  pengaduan.tanggalPengaduan != null
                      ? DateFormat('dd MMMM yyyy HH:mm', 'id_ID')
                          .format(pengaduan.tanggalPengaduan!)
                      : 'Tanggal tidak tersedia',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tombol lihat detail
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed('/warga/detail-pengaduan',
                      arguments: {'id': pengaduan.id});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.remove_red_eye),
                label: const Text('Lihat Detail Pengaduan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: statusColor ?? Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
