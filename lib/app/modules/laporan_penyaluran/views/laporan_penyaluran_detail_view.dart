import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/laporan_penyaluran/controllers/laporan_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'package:penyaluran_app/app/widgets/custom_app_bar.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'package:penyaluran_app/app/widgets/status_badge.dart';
import 'package:intl/intl.dart';
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
                        title: 'Informasi Laporan',
                      ),
                      const SizedBox(height: 16),
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
                          // subtitle: 'Detail informasi penyaluran terkait',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                            'Nama Penyaluran', penyaluran.nama ?? '-'),
                        _buildInfoRow(
                          'Tanggal Penyaluran',
                          penyaluran.tanggalPenyaluran != null
                              ? DateTimeHelper.formatDateTime(
                                  penyaluran.tanggalPenyaluran!)
                              : '-',
                        ),
                        _buildInfoRow(
                          'Tanggal Selesai',
                          penyaluran.tanggalSelesai != null
                              ? DateTimeHelper.formatDateTime(
                                  penyaluran.tanggalSelesai!)
                              : '-',
                        ),
                        _buildInfoRow('Jumlah Penerima',
                            '${penyaluran.jumlahPenerima ?? 0} orang'),
                        _buildInfoRow(
                            'Status Penyaluran', penyaluran.status ?? '-'),
                        if (penyaluran.deskripsi != null &&
                            penyaluran.deskripsi!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Deskripsi Penyaluran:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            penyaluran.deskripsi!,
                            style: const TextStyle(fontSize: 14),
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
                              title: 'Lokasi Penyaluran',
                            ),
                            const SizedBox(height: 16),
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
                              const SizedBox(height: 16),
                              const Text(
                                'Keterangan Lokasi:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.lokasiPenyaluran['keterangan'],
                                style: const TextStyle(fontSize: 14),
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
                              title: 'Stok Bantuan yang Digunakan',
                            ),
                            const SizedBox(height: 16),

                            // Informasi kategori bantuan jika tersedia
                            if (controller.kategoriBantuan.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.blue.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.category,
                                            color: Colors.blue.shade700),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Kategori Bantuan: ${controller.kategoriBantuan['nama'] ?? 'Tidak Diketahui'}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (controller
                                            .kategoriBantuan['deskripsi'] !=
                                        null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        controller.kategoriBantuan['deskripsi'],
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

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

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Card(
                                    color: isUang
                                        ? Colors.green.shade50
                                        : Colors.grey.shade50,
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  stokBantuan['nama'] ?? '-',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isUang
                                                      ? Colors.green.shade100
                                                      : Colors.blue.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  kategori,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isUang
                                                        ? Colors.green.shade800
                                                        : Colors.blue.shade800,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Text(
                                                'Jumlah digunakan: ',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Text(
                                                isUang
                                                    ? 'Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(jumlah)}'
                                                    : '$jumlah ${stokBantuan['satuan'] ?? ''}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (stokBantuan['deskripsi'] !=
                                                  null &&
                                              stokBantuan['deskripsi']
                                                  .toString()
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              stokBantuan['deskripsi'],
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ],
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
                              title: 'Daftar Penerima Bantuan',
                            ),
                            const SizedBox(height: 16),
                            // Header Tabel
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: const [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'NIK',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Nama Penerima',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Jumlah',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Status',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Baris Data Penerima
                            ListView.builder(
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

                                final jumlah = penerima.jumlahBantuan != null
                                    ? '${penerima.jumlahBantuan} ${penerima.satuan ?? ''}'
                                    : '-';

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade200),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(wargaNik),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(wargaNama),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          jumlah,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                penerima.statusPenerimaan),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            penerima.statusPenerimaan ?? '-',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
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

              // Dokumentasi dan Berita Acara
              if (controller.selectedLaporan.value?.dokumentasiUrl != null ||
                  controller.selectedLaporan.value?.beritaAcaraUrl != null)
                Column(
                  children: [
                    const SizedBox(height: 24),
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

                            // Dokumentasi
                            if (controller
                                    .selectedLaporan.value?.dokumentasiUrl !=
                                null) ...[
                              const Text(
                                'Dokumentasi:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  controller
                                      .selectedLaporan.value!.dokumentasiUrl!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: double.infinity,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Text('Gagal memuat gambar'),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton.icon(
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
                                  icon: const Icon(Icons.image),
                                  label: const Text('Lihat Dokumentasi'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                ),
                              ),
                            ],

                            if (controller.selectedLaporan.value
                                        ?.dokumentasiUrl !=
                                    null &&
                                controller.selectedLaporan.value
                                        ?.beritaAcaraUrl !=
                                    null)
                              const SizedBox(height: 16),

                            // Berita Acara
                            if (controller
                                    .selectedLaporan.value?.beritaAcaraUrl !=
                                null) ...[
                              const Text(
                                'Berita Acara:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                leading: const Icon(
                                  Icons.description,
                                  color: Colors.blue,
                                  size: 40,
                                ),
                                title: const Text(
                                  'Dokumen Berita Acara',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle:
                                    const Text('Tap untuk membuka dokumen'),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                onTap: () async {
                                  final Uri url = Uri.parse(controller
                                      .selectedLaporan.value!.beritaAcaraUrl!);
                                  if (!await launchUrl(url)) {
                                    throw Exception('Tidak dapat membuka $url');
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Tombol aksi
              Row(
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (laporan.status != 'FINAL') const SizedBox(width: 12),
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
                                        controller.selectedPenyaluran.value!);
                                  }
                                },
                          icon: controller.isExporting.value
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text(controller.isExporting.value
                              ? 'Mengekspor...'
                              : 'Export PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            disabledBackgroundColor:
                                Colors.blue.withOpacity(0.7),
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

  // Membangun header status
  Widget _buildStatusHeader(String status, DateTime? tanggalLaporan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status Laporan',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              StatusBadge(status: status),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Tanggal Laporan',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DateTimeHelper.formatDateTime(tanggalLaporan),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Membangun baris informasi
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk mendapatkan warna status penerimaan
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toUpperCase()) {
      case 'DITERIMA':
        return Colors.green;
      case 'TERTUNDA':
        return Colors.orange;
      case 'DIBATALKAN':
        return Colors.red;
      case 'SEDANG DIPROSES':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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
          title: const Text('Finalisasi Laporan'),
          content: const Text(
              'Laporan yang sudah difinalisasi tidak dapat diubah lagi. Lanjutkan?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                controller.finalizeLaporan(laporanId);
              },
              child: const Text('Finalisasi'),
            ),
          ],
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
          title: const Text('Hapus Laporan'),
          content: const Text(
              'Laporan yang dihapus tidak dapat dikembalikan. Lanjutkan?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteLaporan(laporanId);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
