import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/donatur_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';
import 'package:penyaluran_app/app/widgets/dialogs/detail_penitipan_dialog.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';

class DetailDonaturView extends GetView<DonaturController> {
  const DetailDonaturView({super.key});

  @override
  Widget build(BuildContext context) {
    final String donaturId = Get.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Donatur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implementasi edit donatur (akan diimplementasikan nanti)
            },
          ),
        ],
      ),
      body: FutureBuilder<DonaturModel?>(
        future: controller.fetchDonaturById(donaturId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Data donatur tidak ditemukan'),
            );
          }

          final donatur = snapshot.data!;
          return _buildDetailContent(context, donatur);
        },
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, DonaturModel donatur) {
    // Pilih ikon berdasarkan jenis donatur
    IconData jenisIcon;
    switch (donatur.jenis) {
      case 'Perusahaan':
        jenisIcon = Icons.business;
        break;
      case 'Organisasi':
        jenisIcon = Icons.groups;
        break;
      case 'Individu':
        jenisIcon = Icons.person;
        break;
      default:
        jenisIcon = Icons.help_outline;
    }

    // Hitung jumlah donasi dan total nilai donasi
    final jumlahDonasi = controller.getJumlahDonasi(donatur.id);
    final jumlahDonasiUang = controller.getJumlahDonasiUang(donatur.id);
    final jumlahDonasiBarang = controller.getJumlahDonasiBarang(donatur.id);
    final totalNilaiDonasiUang = controller.getTotalNilaiDonasiUang(donatur.id);
    final totalNilaiDonasiUangFormatted =
        controller.formatRupiah(totalNilaiDonasiUang);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan informasi utama donatur
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar dan nama donatur
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          jenisIcon,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              donatur.nama ?? 'Tanpa Nama',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: donatur.jenis == 'Perusahaan'
                                    ? Colors.blue.withOpacity(0.1)
                                    : donatur.jenis == 'Organisasi'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                donatur.jenis ?? 'Tidak Diketahui',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: donatur.jenis == 'Perusahaan'
                                      ? Colors.blue
                                      : donatur.jenis == 'Organisasi'
                                          ? Colors.green
                                          : Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: donatur.status == 'AKTIF'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        donatur.status == 'AKTIF'
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 12,
                                        color: donatur.status == 'AKTIF'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        donatur.status ?? 'TIDAK AKTIF',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: donatur.status == 'AKTIF'
                                              ? Colors.green
                                              : Colors.red,
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
                  const SizedBox(height: 16),
                  // Informasi kontak
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildInfoItem(Icons.location_on, 'Alamat',
                      donatur.alamat ?? 'Tidak ada alamat'),
                  const SizedBox(height: 8),
                  _buildInfoItem(Icons.phone, 'Telepon',
                      donatur.telepon ?? 'Tidak ada telepon'),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                      Icons.email, 'Email', donatur.email ?? 'Tidak ada email'),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    Icons.calendar_today,
                    'Terdaftar Sejak',
                    donatur.createdAt != null
                        ? DateTimeHelper.formatDate(donatur.createdAt!)
                        : 'Tidak diketahui',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Ringkasan donasi
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Donasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total Donasi',
                          '$jumlahDonasi',
                          Icons.volunteer_activism,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Donasi Uang',
                          '$jumlahDonasiUang',
                          Icons.monetization_on,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Donasi Barang',
                          '$jumlahDonasiBarang',
                          Icons.inventory_2,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Total Nilai Donasi Uang:',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        totalNilaiDonasiUangFormatted,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Riwayat donasi
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat Donasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigasi ke halaman riwayat donasi lengkap
                        },
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRiwayatDonasi(donatur.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRiwayatDonasi(String? donaturId) {
    if (donaturId == null ||
        !controller.penitipanPerDonatur.containsKey(donaturId)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('Belum ada riwayat donasi'),
        ),
      );
    }

    final penitipanList = controller.penitipanPerDonatur[donaturId]!;

    // Tampilkan maksimal 3 donasi terbaru
    final displayedPenitipan =
        penitipanList.length > 3 ? penitipanList.sublist(0, 3) : penitipanList;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayedPenitipan.length,
      itemBuilder: (context, index) {
        final penitipan = displayedPenitipan[index];
        return _buildDonasiItem(penitipan);
      },
    );
  }

  Widget _buildDonasiItem(PenitipanBantuanModel penitipan) {
    final isUang = penitipan.isUang == true;
    final tanggal = penitipan.createdAt != null
        ? DateTimeHelper.formatDate(penitipan.createdAt!, format: 'dd MMM yyyy')
        : 'Tanggal tidak diketahui';

    String nilaiDonasi = '';
    if (isUang && penitipan.jumlah != null) {
      nilaiDonasi = controller.formatRupiah(penitipan.jumlah!);
    } else if (penitipan.jumlah != null) {
      final satuan = controller.getStokBantuanSatuan(penitipan.stokBantuanId);
      nilaiDonasi = '${penitipan.jumlah} $satuan';
    } else {
      nilaiDonasi = 'Jumlah tidak diketahui';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // Tampilkan dialog detail penitipan
          _showDetailPenitipan(penitipan);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isUang
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                child: Icon(
                  isUang ? Icons.monetization_on : Icons.inventory_2,
                  color: isUang ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUang
                          ? 'Donasi Uang'
                          : controller
                                  .getStokBantuanNama(penitipan.stokBantuanId)
                                  .isNotEmpty
                              ? controller
                                  .getStokBantuanNama(penitipan.stokBantuanId)
                              : penitipan.deskripsi ?? 'Donasi Barang',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tanggal,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                nilaiDonasi,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUang ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Metode untuk menampilkan dialog detail penitipan
  void _showDetailPenitipan(PenitipanBantuanModel penitipan) {
    // Dapatkan data yang diperlukan
    final donaturNama = penitipan.donatur?.nama ??
        controller.getDonaturNama(penitipan.donaturId) ??
        'Donatur tidak ditemukan';

    final kategoriNama = penitipan.kategoriBantuan?.nama ??
        controller.getStokBantuanNama(penitipan.stokBantuanId);

    final kategoriSatuan = penitipan.kategoriBantuan?.satuan ??
        controller.getStokBantuanSatuan(penitipan.stokBantuanId);

    // Tampilkan dialog
    DetailPenitipanDialog.show(
      context: Get.context!,
      item: penitipan,
      donaturNama: donaturNama,
      kategoriNama: kategoriNama,
      kategoriSatuan: kategoriSatuan,
      getPetugasDesaNama: (String? id) =>
          controller.getPetugasDesaNama(id) ?? 'Petugas tidak diketahui',
      showFullScreenImage: (String imageUrl) {
        DetailPenitipanDialog.showFullScreenImage(Get.context!, imageUrl);
      },
    );
  }
}
