import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/donatur_controller.dart';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';
import 'package:penyaluran_app/app/widgets/dialogs/detail_penitipan_dialog.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';

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

    // Pilih warna berdasarkan jenis donatur
    Color jenisColor = donatur.jenis == 'Perusahaan'
        ? Colors.blue
        : donatur.jenis == 'Organisasi'
            ? Colors.green
            : Colors.orange;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan informasi utama donatur - desain yang lebih menarik
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: jenisColor.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      jenisColor.withOpacity(0.05),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar dan nama donatur dengan layout yang lebih baik
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: jenisColor.withOpacity(0.7), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: jenisColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Hero(
                            tag: 'donatur-${donatur.id}',
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: jenisColor.withOpacity(0.1),
                              backgroundImage: donatur.fotoProfil != null &&
                                      donatur.fotoProfil!.isNotEmpty
                                  ? NetworkImage(donatur.fotoProfil!)
                                  : null,
                              child: (donatur.fotoProfil == null ||
                                      donatur.fotoProfil!.isEmpty)
                                  ? Icon(
                                      jenisIcon,
                                      size: 45,
                                      color: jenisColor.withOpacity(0.8),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                donatur.nama ?? 'Tanpa Nama',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: jenisColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: jenisColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      jenisIcon,
                                      size: 16,
                                      color: jenisColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      donatur.jenis ?? 'Tidak Diketahui',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: jenisColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: donatur.status == 'AKTIF'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: donatur.status == 'AKTIF'
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.red.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      donatur.status == 'AKTIF'
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 16,
                                      color: donatur.status == 'AKTIF'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      donatur.status == 'AKTIF'
                                          ? 'Aktif'
                                          : 'Tidak Aktif',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Summary cards for donations
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Total Donasi',
                            value: jumlahDonasi.toString(),
                            icon: Icons.volunteer_activism,
                            color: jenisColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Donasi Uang',
                            value: jumlahDonasiUang.toString(),
                            icon: Icons.attach_money,
                            color: jenisColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Donasi Barang',
                            value: jumlahDonasiBarang.toString(),
                            icon: Icons.inventory_2,
                            color: jenisColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Total nilai donasi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: jenisColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: jenisColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Total Nilai Donasi Uang',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalNilaiDonasiUangFormatted,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: jenisColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Informasi kontak
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildInfoItem(Icons.location_on, 'Alamat',
                      donatur.alamat ?? 'Tidak ada alamat'),
                  const SizedBox(height: 8),
                  _buildInfoItem(Icons.phone, 'Telepon',
                      donatur.noHp ?? 'Tidak ada telepon'),
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: color.withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
