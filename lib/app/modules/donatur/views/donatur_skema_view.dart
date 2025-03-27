import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'package:penyaluran_app/app/data/models/stok_bantuan_model.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'package:penyaluran_app/app/utils/date_helper.dart';

class DonaturSkemaView extends GetView<DonaturDashboardController> {
  const DonaturSkemaView({super.key});

  @override
  DonaturDashboardController get controller {
    if (!Get.isRegistered<DonaturDashboardController>(
        tag: 'donatur_dashboard')) {
      return Get.put(DonaturDashboardController(),
          tag: 'donatur_dashboard', permanent: true);
    }
    return Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchSkemaBantuan();
          },
          child: controller.skemaBantuan.isEmpty
              ? _buildEmptyState()
              : _buildSkemaList(),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Skema Bantuan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Skema bantuan belum tersedia saat ini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.fetchSkemaBantuan(),
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkemaList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Skema Bantuan Tersedia'),
        Text(
          'Daftar skema bantuan yang dapat Anda titipkan',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),
        ...controller.skemaBantuan.map((skema) => _buildSkemaCard(skema)),
      ],
    );
  }

  Widget _buildSkemaCard(dynamic skema) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.blue.shade100,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan warna gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skema.nama ?? 'Skema Bantuan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (skema.batasWaktu != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatBatasWaktu(skema.batasWaktu),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
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
            // Konten utama
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status batas waktu jika hampir habis (kurang dari 7 hari)
                  if (skema.batasWaktu != null &&
                      _isDeadlineApproaching(skema.batasWaktu))
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Segera titipkan bantuan Anda! Batas waktu akan segera berakhir.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Tambahkan informasi bantuan yang dibutuhkan
                  if (skema.stokBantuanId != null)
                    _buildBantuanDibutuhkan(skema.stokBantuanId!),

                  // Informasi kuota dan jumlah per orang
                  Row(
                    children: [
                      if (skema.kuota != null)
                        Expanded(
                          child: _buildInfoBox(
                            icon: Icons.people_outline,
                            title: 'Kuota',
                            value: '${skema.kuota} penerima',
                            color: Colors.blue.shade700,
                          ),
                        ),
                      const SizedBox(width: 12),
                      if (skema.jumlahDiterimaPerOrang != null)
                        Expanded(
                          child: _buildInfoBox(
                            icon: Icons.inventory_2_outlined,
                            title: 'Bantuan Per Orang',
                            value: _formatJumlahPerOrang(skema.stokBantuanId,
                                skema.jumlahDiterimaPerOrang!),
                            color: Colors.green.shade700,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Tombol titipkan bantuan
                  ElevatedButton.icon(
                    onPressed: () {
                      // Menyimpan ID skema bantuan yang dipilih
                      if (skema.id != null) {
                        controller.selectedSkemaBantuanId.value = skema.id!;
                      }
                      // Beralih ke tab penitipan bantuan
                      controller.activeTabIndex.value = 3;
                    },
                    icon: const Icon(Icons.add_box_outlined, size: 18),
                    label: const Text('Titipkan Bantuan'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green.shade600,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
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

  Widget _buildBantuanDibutuhkan(String stokBantuanId) {
    // Cari stok bantuan yang sesuai dengan ID di skema
    final stokBantuan = controller.stokBantuan.firstWhere(
      (stok) => stok.id == stokBantuanId,
      orElse: () => StokBantuanModel(),
    );

    if (stokBantuan.id == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2,
                color: Colors.green.shade700,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Bantuan yang Dibutuhkan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stokBantuan.nama ?? 'Tidak tersedia',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (stokBantuan.kategoriBantuan != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Kategori: ${stokBantuan.kategoriBantuan!['nama'] ?? 'Umum'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_rounded,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stokBantuan.isUang == true
                          ? 'Stok: ${_formatRupiah(stokBantuan.totalStok)}'
                          : 'Stok: ${stokBantuan.totalStok?.toStringAsFixed(0) ?? '0'} ${stokBantuan.satuan ?? ''}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (stokBantuan.deskripsi != null &&
              stokBantuan.deskripsi!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                stokBantuan.deskripsi!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Fungsi untuk memformat tanggal batas waktu
  String _formatBatasWaktu(DateTime? batasWaktu) {
    if (batasWaktu == null) return '';

    DateTime now = DateTime.now();
    Duration difference = batasWaktu.difference(now);

    if (difference.isNegative) {
      return 'Batas waktu telah berakhir';
    }

    int days = difference.inDays;
    if (days > 0) {
      return 'Batas waktu: ${days} hari lagi';
    } else {
      int hours = difference.inHours;
      if (hours > 0) {
        return 'Batas waktu: ${hours} jam lagi';
      } else {
        int minutes = difference.inMinutes;
        return 'Batas waktu: ${minutes} menit lagi';
      }
    }
  }

  // Cek apakah deadline mendekati (kurang dari 7 hari)
  bool _isDeadlineApproaching(DateTime? batasWaktu) {
    if (batasWaktu == null) return false;

    DateTime now = DateTime.now();
    Duration difference = batasWaktu.difference(now);

    return difference.inDays < 7 && !difference.isNegative;
  }

  String _formatJumlahPerOrang(
      String? stokBantuanId, dynamic jumlahDiterimaPerOrang) {
    // Jika stokBantuanId null, kembalikan nilai apa adanya
    if (stokBantuanId == null) return jumlahDiterimaPerOrang.toString();

    // Cari stok bantuan berdasarkan ID
    final stokBantuan = controller.stokBantuan.firstWhere(
      (stok) => stok.id == stokBantuanId,
      orElse: () => StokBantuanModel(),
    );

    // Jika nilai bantuan berupa uang, format sebagai Rupiah
    if (stokBantuan.isUang == true) {
      double nilai = 0;
      if (jumlahDiterimaPerOrang is int) {
        nilai = jumlahDiterimaPerOrang.toDouble();
      } else if (jumlahDiterimaPerOrang is double) {
        nilai = jumlahDiterimaPerOrang;
      } else {
        try {
          nilai = double.parse(jumlahDiterimaPerOrang.toString());
        } catch (e) {
          return jumlahDiterimaPerOrang.toString();
        }
      }
      // Format nilai sebagai Rupiah menggunakan DateHelper
      return DateHelper.formatRupiah(nilai);
    }

    // Jika bukan uang, kembalikan nilai + satuan (jika ada)
    return '${jumlahDiterimaPerOrang} ${stokBantuan.satuan ?? ''}';
  }

  String _formatRupiah(dynamic amount) {
    if (amount is num) {
      return DateHelper.formatRupiah(amount);
    } else if (amount is String) {
      try {
        double nilai = double.parse(amount);
        return DateHelper.formatRupiah(nilai);
      } catch (e) {
        return 'Rp ${amount.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
      }
    } else {
      return 'Rp 0';
    }
  }
}
