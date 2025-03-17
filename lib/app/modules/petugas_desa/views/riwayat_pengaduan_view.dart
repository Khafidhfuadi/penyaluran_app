import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/riwayat_pengaduan_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';

class RiwayatPengaduanView extends GetView<RiwayatPengaduanController> {
  const RiwayatPengaduanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pengaduan'),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pencarian
                _buildSearch(context),

                // Informasi terakhir update
                _buildLastUpdateInfo(context),

                const SizedBox(height: 20),

                // Daftar riwayat pengaduan
                _buildRiwayatPengaduanList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tambahkan widget untuk menampilkan waktu terakhir update
  Widget _buildLastUpdateInfo(BuildContext context) {
    final lastUpdate = DateTime.now();
    final formattedDate = DateTimeHelper.formatDateTimeWithHour(lastUpdate);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Icon(Icons.update, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            'Data terupdate: $formattedDate',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return TextField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Cari riwayat pengaduan...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onChanged: (value) {
        // Implementasi pencarian
        controller.refreshData();
      },
    );
  }

  Widget _buildRiwayatPengaduanList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final filteredPengaduan = controller.getFilteredRiwayatPengaduan();

      if (filteredPengaduan.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada riwayat pengaduan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Riwayat Pengaduan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${DateTimeHelper.formatNumber(filteredPengaduan.length)} item',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...filteredPengaduan
              .map((item) => _buildPengaduanItem(context, item)),
        ],
      );
    });
  }

  Widget _buildPengaduanItem(BuildContext context, dynamic item) {
    // Format tanggal menggunakan DateTimeHelper
    String formattedDate = '';
    if (item.tanggalPengaduan != null) {
      formattedDate = DateTimeHelper.formatDate(item.tanggalPengaduan);
    } else if (item.createdAt != null) {
      formattedDate = DateTimeHelper.formatDate(item.createdAt);
    }

    return InkWell(
      onTap: () {
        // Navigasi ke halaman detail pengaduan
        Get.toNamed('/detail-pengaduan', arguments: {'id': item.id});
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.warga?['nama'] ?? item.judul ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SELESAI',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.successColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.deskripsi ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildItemDetail(
                      context,
                      icon: Icons.person,
                      label: 'Pelapor',
                      value: item.warga?['nama_lengkap'] ?? '',
                    ),
                  ),
                  Expanded(
                    child: _buildItemDetail(
                      context,
                      icon: Icons.numbers,
                      label: 'NIK',
                      value: item.warga?['nik'] ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (item.penerimaPenyaluran != null) ...[
                Row(
                  children: [
                    Expanded(
                        child: _buildItemDetail(
                      context,
                      icon: Icons.shopping_bag,
                      label: 'Jumlah',
                      value:
                          '${item.jumlahBantuan} ${item.stokBantuan['satuan']}',
                    )),
                    Expanded(
                      child: _buildItemDetail(
                        context,
                        icon: Icons.inventory,
                        label: 'Stok Bantuan',
                        value: item.stokBantuan['nama'] ?? '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildItemDetail(
                        context,
                        icon: Icons.category,
                        label: 'Nama Penyaluran',
                        value: item.namaPenyaluran ?? '',
                      ),
                    ),
                    Expanded(
                      child: _buildItemDetail(
                        context,
                        icon: Icons.calendar_today,
                        label: 'Tanggal',
                        value: formattedDate,
                      ),
                    ),
                  ],
                ),
              ],
              if (item.ratingWarga != null && item.ratingWarga > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Feedback Warga',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.amber,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < (item.ratingWarga ?? 0)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      if (item.feedbackWarga != null &&
                          item.feedbackWarga.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${item.feedbackWarga}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Navigasi ke halaman detail pengaduan
                      Get.toNamed('/detail-pengaduan',
                          arguments: {'id': item.id});
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Detail'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemDetail(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
