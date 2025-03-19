import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class RiwayatPenyaluranView extends GetView<JadwalPenyaluranController> {
  const RiwayatPenyaluranView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Penyaluran'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Terlaksana'),
              Tab(text: 'Batal Terlaksana'),
            ],
          ),
        ),
        body: Obx(() => TabBarView(
              children: [
                // Tab Terlaksana
                _buildPenyaluranList(context, 'TERLAKSANA'),
                // Tab Batal Terlaksana
                _buildPenyaluranList(context, 'BATALTERLAKSANA'),
              ],
            )),
      ),
    );
  }

  Widget _buildPenyaluranList(BuildContext context, String status) {
    var filteredList = controller.jadwalTerlaksana
        .where((item) => item.status == status)
        .toList();

    // Filter berdasarkan pencarian jika ada teks pencarian
    final searchText = controller.searchController.text.toLowerCase();
    if (searchText.isNotEmpty) {
      filteredList = filteredList.where((item) {
        final nama = item.nama?.toLowerCase() ?? '';
        final deskripsi = item.deskripsi?.toLowerCase() ?? '';
        final lokasiNama = controller
            .getLokasiPenyaluranName(item.lokasiPenyaluranId)
            .toLowerCase();
        final kategoriNama = controller
            .getKategoriBantuanName(item.kategoriBantuanId)
            .toLowerCase();
        final tanggal =
            DateTimeHelper.formatDateTime(item.tanggalPenyaluran).toLowerCase();

        return nama.contains(searchText) ||
            deskripsi.contains(searchText) ||
            lokasiNama.contains(searchText) ||
            kategoriNama.contains(searchText) ||
            tanggal.contains(searchText);
      }).toList();
    }

    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search field
                    TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari riwayat penyaluran...',
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
                        // Trigger rebuild dengan Obx
                        controller.update();
                      },
                    ),
                    const SizedBox(height: 16),
                    // Info jumlah item
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Penyaluran ${status == 'TERLAKSANA' ? 'Terlaksana' : 'Batal'}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          '${DateTimeHelper.formatNumber(filteredList.length)} item',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Informasi jumlah item dan terakhir update
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ${DateTimeHelper.formatNumber(filteredList.length)} item',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        // Informasi terakhir update
                        Row(
                          children: [
                            Icon(Icons.update,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Update: ${DateTimeHelper.formatDateTimeWithHour(DateTime.now())}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Daftar penyaluran
                    filteredList.isEmpty
                        ? Center(
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
                                    'Tidak ada data penyaluran ${status == 'TERLAKSANA' ? 'terlaksana' : 'batal terlaksana'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              return _buildPenyaluranItem(
                                  context, filteredList[index]);
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPenyaluranItem(
      BuildContext context, PenyaluranBantuanModel item) {
    Color statusColor;
    IconData statusIcon;

    switch (item.status) {
      case 'TERLAKSANA':
        statusColor = AppTheme.completedColor;
        statusIcon = Icons.check_circle;
        break;
      case 'BATALTERLAKSANA':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    final lokasiNama =
        controller.getLokasiPenyaluranName(item.lokasiPenyaluranId);
    final kategoriNama =
        controller.getKategoriBantuanName(item.kategoriBantuanId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed('/detail-penyaluran', arguments: item);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.nama ?? 'Penyaluran tanpa nama',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.status == 'TERLAKSANA' ? 'Terlaksana' : 'Batal',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (item.deskripsi != null && item.deskripsi!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.deskripsi!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Divider(height: 24),
              _buildInfoItem(
                Icons.location_on_outlined,
                'Lokasi',
                lokasiNama,
                Theme.of(context).textTheme,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.category_outlined,
                      'Kategori',
                      kategoriNama,
                      Theme.of(context).textTheme,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.event,
                      'Tanggal',
                      DateTimeHelper.formatDateTime(item.tanggalPenyaluran,
                          format: 'dd MMM yyyy HH:mm'),
                      Theme.of(context).textTheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoItem(
                Icons.people_outline,
                'Jumlah Penerima',
                '${DateTimeHelper.formatNumber(item.jumlahPenerima ?? 0)} orang',
                Theme.of(context).textTheme,
              ),
              if (item.alasanPembatalan != null &&
                  item.alasanPembatalan!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoItem(
                  Icons.info_outline,
                  'Alasan Pembatalan',
                  item.alasanPembatalan!,
                  Theme.of(context).textTheme,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Get.toNamed('/detail-penyaluran', arguments: item);
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Lihat Detail'),
                    style: TextButton.styleFrom(
                      foregroundColor: statusColor,
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

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    TextTheme textTheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
