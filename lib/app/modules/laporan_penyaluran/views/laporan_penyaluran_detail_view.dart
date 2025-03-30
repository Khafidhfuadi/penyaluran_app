import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/controllers/laporan_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'package:penyaluran_app/app/widgets/custom_app_bar.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'package:penyaluran_app/app/widgets/status_badge.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:url_launcher/url_launcher.dart';

class LaporanPenyaluranDetailView extends GetView<LaporanPenyaluranController> {
  const LaporanPenyaluranDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final laporanId = Get.arguments as String;

    // Ambil data detail laporan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchLaporanDetail(laporanId);
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Detail Laporan',
        // subtitle: 'Informasi lengkap tentang laporan penyaluran',
        showBackButton: true,
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return const SizedBox.shrink();
            }
            if (controller.selectedLaporan.value == null) {
              return const SizedBox.shrink();
            }
            return PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                if (controller.selectedLaporan.value!.status != 'FINAL')
                  PopupMenuItem(
                    value: 'finalize',
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Finalisasi Laporan'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: const [
                      Icon(Icons.edit, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Edit Laporan'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Obx(() => Row(
                        children: [
                          controller.isExporting.value
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.blue,
                                  ),
                                )
                              : const Icon(Icons.download, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(controller.isExporting.value
                              ? 'Mengekspor...'
                              : 'Export ke PDF'),
                        ],
                      )),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: const [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus Laporan'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'finalize') {
                  _showFinalizeConfirmation(context, laporanId);
                } else if (value == 'edit') {
                  Get.toNamed('/laporan-penyaluran/edit', arguments: laporanId);
                } else if (value == 'export') {
                  if (!controller.isExporting.value &&
                      controller.selectedLaporan.value != null &&
                      controller.selectedPenyaluran.value != null) {
                    controller.exportToPdf(controller.selectedLaporan.value!,
                        controller.selectedPenyaluran.value!);
                  }
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, laporanId);
                }
              },
            );
          }),
        ],
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

        final laporan = controller.selectedLaporan.value!;
        final penyaluran = controller.selectedPenyaluran.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status dan tanggal
              _buildStatusHeader(
                  laporan.status ?? 'DRAFT', laporan.tanggalLaporan),

              const SizedBox(height: 16),

              // Informasi laporan
              Card(
                margin: EdgeInsets.zero,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Informasi Laporan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 25),
                      _buildInfoRow(
                        'Judul Laporan',
                        laporan.judul,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Informasi penyaluran
              if (penyaluran != null)
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Informasi Penyaluran',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 25),
                        _buildInfoRow(
                            'Nama Penyaluran', penyaluran.nama ?? '-'),
                        _buildInfoRow(
                          'Tanggal Penyaluran',
                          penyaluran.tanggalPenyaluran != null
                              ? FormatHelper.formatDateTime(
                                  penyaluran.tanggalPenyaluran!)
                              : '-',
                        ),
                        _buildInfoRow(
                          'Tanggal Selesai',
                          penyaluran.tanggalSelesai != null
                              ? FormatHelper.formatDateTime(
                                  penyaluran.tanggalSelesai!)
                              : '-',
                        ),
                        _buildInfoRow('Jumlah Penerima',
                            '${penyaluran.jumlahPenerima ?? 0} orang'),
                        _buildInfoRow(
                            'Status Penyaluran', penyaluran.status ?? '-'),
                        if (penyaluran.deskripsi != null &&
                            penyaluran.deskripsi!.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            'Deskripsi Penyaluran:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              penyaluran.deskripsi!,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              // Informasi Lokasi Penyaluran
              if (controller.lokasiPenyaluran.isNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 24),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Lokasi Penyaluran',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 25),
                            _buildInfoRow('Nama Lokasi',
                                controller.lokasiPenyaluran['nama'] ?? '-'),
                            _buildInfoRow(
                                'Alamat',
                                controller.lokasiPenyaluran['alamat_lengkap'] ??
                                    '-'),
                            if (controller.desaData.isNotEmpty) ...[
                              _buildInfoRow('Desa/Kelurahan',
                                  controller.desaData['nama'] ?? '-'),
                              _buildInfoRow('Kecamatan',
                                  controller.desaData['kecamatan'] ?? '-'),
                              _buildInfoRow('Kabupaten/Kota',
                                  controller.desaData['kabupaten'] ?? '-'),
                              _buildInfoRow('Provinsi',
                                  controller.desaData['provinsi'] ?? '-'),
                            ] else ...[
                              _buildInfoRow(
                                  'Kecamatan',
                                  controller.lokasiPenyaluran['kecamatan'] ??
                                      '-'),
                              _buildInfoRow(
                                  'Kabupaten/Kota',
                                  controller
                                          .lokasiPenyaluran['kabupaten_kota'] ??
                                      '-'),
                              _buildInfoRow(
                                  'Provinsi',
                                  controller.lokasiPenyaluran['provinsi'] ??
                                      '-'),
                            ],
                            if (controller.lokasiPenyaluran['keterangan'] !=
                                    null &&
                                controller.lokasiPenyaluran['keterangan']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                'Keterangan Lokasi:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Text(
                                  controller.lokasiPenyaluran['keterangan'],
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              // Informasi Stok Bantuan yang Digunakan
              if (controller.stokBantuanUsage.isNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 24),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Stok Bantuan yang Digunakan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 25),

                            // Informasi kategori bantuan jika tersedia
                            if (controller.kategoriBantuan.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade100,
                                      Colors.blue.shade50,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.category,
                                            color: Colors.blue.shade700,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Kategori Bantuan',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                controller.kategoriBantuan[
                                                        'nama'] ??
                                                    'Tidak Diketahui',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.blue.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (controller
                                            .kategoriBantuan['deskripsi'] !=
                                        null) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size: 16,
                                              color: Colors.blue.shade800,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                controller.kategoriBantuan[
                                                    'deskripsi'],
                                                style: TextStyle(
                                                  color: Colors.blue.shade700,
                                                  fontSize: 14,
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
                              const SizedBox(height: 20),
                            ],

                            // Label daftar stok bantuan
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 15, left: 4),
                              child: Text(
                                'Daftar Stok Bantuan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),

                            // Daftar stok bantuan
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.stokBantuanUsage.length,
                              itemBuilder: (context, index) {
                                final stokId = controller.stokBantuanUsage.keys
                                    .elementAt(index);
                                final jumlah =
                                    controller.stokBantuanUsage[stokId];

                                // Find stok bantuan details
                                final stokBantuan = controller.daftarPenerima
                                    .firstWhere(
                                        (p) => p.stokBantuanId == stokId,
                                        orElse: () => PenerimaPenyaluranModel())
                                    .stokBantuan;

                                if (stokBantuan == null) {
                                  return const SizedBox.shrink();
                                }

                                final kategori =
                                    stokBantuan['kategori_bantuan'] != null
                                        ? stokBantuan['kategori_bantuan']
                                                ['nama'] ??
                                            '-'
                                        : '-';

                                final isUang = stokBantuan['is_uang'] == true;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isUang
                                          ? [
                                              Colors.green.shade100,
                                              Colors.green.shade50
                                            ]
                                          : [
                                              Colors.grey.shade200,
                                              Colors.grey.shade100
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          // Jika perlu tambahkan aksi detail
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: isUang
                                                          ? Colors
                                                              .green.shade200
                                                          : Colors
                                                              .blue.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Icon(
                                                      isUang
                                                          ? Icons
                                                              .account_balance_wallet
                                                          : Icons.inventory,
                                                      color: isUang
                                                          ? Colors
                                                              .green.shade800
                                                          : Colors
                                                              .blue.shade800,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          stokBantuan['nama'] ??
                                                              '-',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          kategori,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: isUang
                                                                ? Colors.green
                                                                    .shade800
                                                                : Colors.blue
                                                                    .shade800,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: isUang
                                                          ? Colors
                                                              .green.shade700
                                                          : Colors
                                                              .blue.shade700,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Text(
                                                      isUang
                                                          ? FormatHelper
                                                              .formatRupiah(
                                                                  jumlah)
                                                          : '$jumlah ${stokBantuan['satuan'] ?? ''}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (stokBantuan['deskripsi'] !=
                                                      null &&
                                                  stokBantuan['deskripsi']
                                                      .toString()
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.info_outline,
                                                        size: 16,
                                                        color: isUang
                                                            ? Colors
                                                                .green.shade800
                                                            : Colors
                                                                .blue.shade800,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          stokBantuan[
                                                              'deskripsi'],
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey[700],
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
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              // Daftar Penerima Bantuan
              if (controller.daftarPenerima.isNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 24),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people_alt,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Daftar Penerima',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${controller.daftarPenerima.length} Penerima',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 25),

                            // Header Tabel
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 15),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: const [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'NIK',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Nama Penerima',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Status',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Baris Data Penerima
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.daftarPenerima.length,
                                itemBuilder: (context, index) {
                                  final penerima =
                                      controller.daftarPenerima[index];
                                  final wargaNik = penerima.warga != null
                                      ? penerima.warga!['nik'] ?? '-'
                                      : '-';
                                  final wargaNama = penerima.warga != null
                                      ? penerima.warga!['nama_lengkap'] ?? '-'
                                      : '-';

                                  final statusColor = _getStatusColor(
                                      penerima.statusPenerimaan);
                                  final isEven = index % 2 == 0;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: isEven
                                          ? Colors.grey.shade50
                                          : Colors.white,
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          // Tambahkan aksi detail penerima jika perlu
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 15),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        wargaNik,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  wargaNama,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Center(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: statusColor
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      border: Border.all(
                                                        color: statusColor
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      penerima.statusPenerimaan ??
                                                          '-',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: statusColor,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
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
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              // Dokumentasi dan Berita Acara
              if (controller.selectedLaporan.value?.dokumentasiUrl != null ||
                  controller.selectedLaporan.value?.beritaAcaraUrl != null)
                Column(
                  children: [
                    const SizedBox(height: 24),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.file_copy,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Dokumentasi & Berita Acara',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 25),

                            // Dokumentasi
                            if (controller
                                    .selectedLaporan.value?.dokumentasiUrl !=
                                null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.blue.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.photo_library,
                                          color: Colors.blue.shade700,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Dokumentasi Kegiatan',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      height: 220,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          controller.selectedLaporan.value!
                                              .dokumentasiUrl!,
                                          width: double.infinity,
                                          height: 220,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: double.infinity,
                                            height: 150,
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                    size: 48,
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    'Gagal memuat gambar',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final Uri url = Uri.parse(controller
                                                .selectedLaporan
                                                .value!
                                                .dokumentasiUrl!);
                                            if (!await launchUrl(url)) {
                                              throw Exception(
                                                  'Tidak dapat membuka $url');
                                            }
                                          },
                                          icon: const Icon(Icons.open_in_new),
                                          label:
                                              const Text('Lihat Dokumentasi'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade700,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            if (controller.selectedLaporan.value
                                        ?.dokumentasiUrl !=
                                    null &&
                                controller.selectedLaporan.value
                                        ?.beritaAcaraUrl !=
                                    null)
                              const SizedBox(height: 20),

                            // Berita Acara
                            if (controller
                                    .selectedLaporan.value?.beritaAcaraUrl !=
                                null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.amber.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.description,
                                          color: Colors.amber.shade800,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Berita Acara',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.insert_drive_file,
                                              color: Colors.amber.shade800,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Dokumen Berita Acara',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'Berkas Resmi Penyaluran',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              final Uri url = Uri.parse(
                                                  controller.selectedLaporan
                                                      .value!.beritaAcaraUrl!);
                                              if (!await launchUrl(url)) {
                                                throw Exception(
                                                    'Tidak dapat membuka $url');
                                              }
                                            },
                                            icon: Icon(
                                              Icons.file_open,
                                              color: Colors.amber.shade800,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final Uri url = Uri.parse(controller
                                                .selectedLaporan
                                                .value!
                                                .beritaAcaraUrl!);
                                            if (!await launchUrl(url)) {
                                              throw Exception(
                                                  'Tidak dapat membuka $url');
                                            }
                                          },
                                          icon: const Icon(Icons.download),
                                          label:
                                              const Text('Unduh Berita Acara'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.amber.shade800,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),

              // Tombol aksi
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (laporan.status != 'FINAL')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showFinalizeConfirmation(context, laporanId),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Finalisasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      if (laporan.status != 'FINAL') const SizedBox(width: 15),
                      Expanded(
                        child: Obx(() => ElevatedButton.icon(
                              onPressed: controller.isExporting.value
                                  ? null
                                  : () {
                                      if (controller.selectedLaporan.value !=
                                              null &&
                                          controller.selectedPenyaluran.value !=
                                              null) {
                                        controller.exportToPdf(
                                            controller.selectedLaporan.value!,
                                            controller
                                                .selectedPenyaluran.value!);
                                      }
                                    },
                              icon: controller.isExporting.value
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.download),
                              label: Text(controller.isExporting.value
                                  ? 'Mengekspor...'
                                  : 'Export PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                disabledBackgroundColor:
                                    Colors.blue.withOpacity(0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Membangun header status
  Widget _buildStatusHeader(String status, DateTime? tanggalLaporan) {
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.7),
            AppTheme.primaryColor.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    statusIcon,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Status Laporan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tanggal Laporan:',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Text(
                FormatHelper.formatDateTime(tanggalLaporan),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper untuk mendapatkan icon status
  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'FINAL':
        return Icons.check_circle;
      case 'DRAFT':
        return Icons.edit_note;
      case 'DIPROSES':
        return Icons.sync;
      default:
        return Icons.info;
    }
  }

  // Helper untuk mendapatkan warna status penerimaan
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toUpperCase()) {
      case 'DITERIMA':
      case 'FINAL':
        return Colors.green;
      case 'TERTUNDA':
      case 'DRAFT':
        return Colors.orange;
      case 'DIBATALKAN':
        return Colors.red;
      case 'SEDANG DIPROSES':
      case 'DIPROSES':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Membangun baris informasi
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Menampilkan dokumen
  Widget _buildDocumentSection(String judul, String? url, IconData icon) {
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () async {
        final Uri url0 = Uri.parse(url);
        if (await canLaunchUrl(url0)) {
          await launchUrl(url0, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Error',
            'Tidak dapat membuka dokumen',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.errorColor,
            colorText: Colors.white,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap untuk membuka dokumen',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Dialog konfirmasi finalisasi laporan
  void _showFinalizeConfirmation(BuildContext context, String laporanId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                'Finalisasi Laporan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade800,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Laporan yang sudah difinalisasi tidak dapat diubah lagi.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Apakah Anda yakin ingin memfinalisasi laporan ini?',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                controller.finalizeLaporan(laporanId);
              },
              child: const Text('Finalisasi'),
            ),
          ],
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      },
    );
  }

  // Dialog konfirmasi hapus laporan
  void _showDeleteConfirmation(BuildContext context, String laporanId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                'Hapus Laporan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade800,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Laporan yang dihapus tidak dapat dikembalikan.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Apakah Anda yakin ingin menghapus laporan ini?',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteLaporan(laporanId);
              },
              child: const Text('Hapus'),
            ),
          ],
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      },
    );
  }

  // Tambahkan helper untuk membuat counter status
  Widget _buildStatusCounter(String status, Color color, int count) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
