import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/widgets/status_badge.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WargaDetailPenerimaanView extends GetView<WargaDashboardController> {
  const WargaDetailPenerimaanView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final id = args['id'];

    // Segera muat ulang data penerimaan ketika halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPenerimaPenyaluran();
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
                _buildDetailSection(penyaluran),
                const SizedBox(height: 16),
                _buildLocationSection(penyaluran),
                const SizedBox(height: 16),
                if (isDiterima) _buildBuktiPenerimaanSection(penyaluran),
                if (isDiterima) const SizedBox(height: 16),
                _buildAdditionalInfoSection(penyaluran),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppTheme.primaryGradient,
        ),
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
                      color: Colors.white,
                    ),
                  ),
                ),
                StatusBadge(
                  status: penyaluran.statusPenerimaan ?? 'MENUNGGU',
                  fontSize: 14,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
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
                  style: TextStyle(
                    color: Colors.white,
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
            ),
            const Divider(height: 24),
            _buildDetailItem(
              icon: Icons.calendar_today,
              title: 'Tanggal Penerimaan',
              value: penyaluran.tanggalPenerimaan != null
                  ? DateFormat('dd MMMM yyyy', 'id_ID')
                      .format(penyaluran.tanggalPenerimaan!)
                  : 'Belum diterima',
            ),
            const Divider(height: 24),
            _buildDetailItem(
              icon: Icons.access_time,
              title: 'Waktu Penerimaan',
              value: penyaluran.tanggalPenerimaan != null
                  ? DateFormat('HH:mm', 'id_ID')
                      .format(penyaluran.tanggalPenerimaan!)
                  : 'Belum diterima',
            ),
            if (penyaluran.keterangan != null &&
                penyaluran.keterangan!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildDetailItem(
                icon: Icons.note,
                title: 'Keterangan',
                value: penyaluran.keterangan!,
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
            ),
            if (penyaluran.lokasiPenyaluranAlamat != null &&
                penyaluran.lokasiPenyaluranAlamat!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildDetailItem(
                icon: Icons.map,
                title: 'Alamat',
                value: penyaluran.lokasiPenyaluranAlamat!,
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
            ),
            const Divider(height: 24),
            _buildDetailItem(
              icon: Icons.person,
              title: 'Penerima',
              value: controller.nama,
            ),
            const Divider(height: 24),
            _buildDetailItem(
              icon: Icons.update,
              title: 'Terakhir Diperbarui',
              value: penyaluran.tanggalPenerimaan != null
                  ? DateFormat('dd MMMM yyyy HH:mm', 'id_ID')
                      .format(penyaluran.tanggalPenerimaan!)
                  : 'Tidak tersedia',
            ),

            // Tambahkan QR Code untuk verifikasi
            if (penyaluran.qrCodeHash != null &&
                penyaluran.qrCodeHash!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildQrCodeSection(penyaluran),
            ],
          ],
        ),
      ),
    );
  }

  // Tambahkan widget untuk menampilkan QR Code
  Widget _buildQrCodeSection(PenerimaPenyaluranModel penyaluran) {
    // Pastikan menggunakan data terbaru dari model dan cetak ke log untuk debugging
    final qrData = penyaluran.qrCodeHash ?? 'invalid-qr-code';
    print('QR Code Hash: $qrData'); // Log untuk debugging

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.qr_code,
              color: Get.theme.primaryColor,
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
                // Gunakan UniqueKey() untuk memaksa rebuild widget QR code
                QrImageView(
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
                const SizedBox(height: 12),
                Text(
                  'Tunjukkan QR Code ini kepada petugas untuk verifikasi penerimaan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
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
            color: Colors.grey.shade700,
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
