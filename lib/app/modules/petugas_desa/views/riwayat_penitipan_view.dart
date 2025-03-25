import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penitipan_bantuan_controller.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class RiwayatPenitipanView extends GetView<PenitipanBantuanController> {
  const RiwayatPenitipanView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Penitipan'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Terverifikasi'),
              Tab(text: 'Ditolak'),
            ],
          ),
        ),
        body: Obx(() => TabBarView(
              children: [
                // Tab Terverifikasi
                _buildPenitipanList(context, 'TERVERIFIKASI'),
                // Tab Ditolak
                _buildPenitipanList(context, 'DITOLAK'),
              ],
            )),
      ),
    );
  }

  Widget _buildPenitipanList(BuildContext context, String status) {
    var filteredList = controller.daftarPenitipan
        .where((item) => item.status == status)
        .toList();

    // Filter berdasarkan pencarian jika ada teks pencarian
    final searchText = controller.searchController.text.toLowerCase();
    if (searchText.isNotEmpty) {
      filteredList = filteredList.where((item) {
        final donaturNama = item.donatur?.nama?.toLowerCase() ?? '';
        final kategoriNama = item.kategoriBantuan?.nama?.toLowerCase() ?? '';
        final deskripsi = item.deskripsi?.toLowerCase() ?? '';
        final tanggal =
            DateTimeHelper.formatDateTime(item.tanggalPenitipan).toLowerCase();

        return donaturNama.contains(searchText) ||
            kategoriNama.contains(searchText) ||
            deskripsi.contains(searchText) ||
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
                        hintText: 'Cari riwayat penitipan...',
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
                          'Daftar Penitipan ${status.toLowerCase()}',
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
                    // Informasi jumlah item
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
                              'Update: ${DateTimeHelper.formatDateTimeWithHour(controller.lastUpdateTime.value)}',
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

                    // Daftar penitipan
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
                                    'Tidak ada data penitipan ${status.toLowerCase()}',
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
                              return _buildPenitipanItem(
                                  context, filteredList[index]);
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPenitipanItem(BuildContext context, PenitipanBantuanModel item) {
    Color statusColor;
    IconData statusIcon;

    switch (item.status) {
      case 'TERVERIFIKASI':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case 'DITOLAK':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    final donaturNama = item.donatur?.nama ?? 'Donatur tidak ditemukan';
    final kategoriNama = item.kategoriBantuan?.nama ??
        controller.getKategoriNama(item.stokBantuanId);
    final kategoriSatuan = item.kategoriBantuan?.satuan ??
        controller.getKategoriSatuan(item.stokBantuanId);
    final isUang = item.isUang ?? false;

    return Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    donaturNama,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
                        item.status ?? 'Tidak diketahui',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon: isUang ? Icons.monetization_on : Icons.category,
                    label: 'Kategori Bantuan',
                    value: kategoriNama,
                  ),
                ),
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon:
                        isUang ? Icons.account_balance_wallet : Icons.inventory,
                    label: 'Jumlah',
                    value: isUang
                        ? 'Rp ${DateTimeHelper.formatNumber(item.jumlah)}'
                        : '${DateTimeHelper.formatNumber(item.jumlah)} $kategoriSatuan',
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
                    icon: Icons.calendar_today,
                    label: item.status == 'TERVERIFIKASI'
                        ? 'Tanggal Verifikasi'
                        : 'Tanggal Penolakan',
                    value: DateTimeHelper.formatDateTime(
                        item.status == 'TERVERIFIKASI'
                            ? item.tanggalVerifikasi
                            : item.updatedAt,
                        defaultValue: 'Tidak ada tanggal'),
                  ),
                ),
                if (item.status == 'TERVERIFIKASI' &&
                    item.petugasDesaId != null)
                  Expanded(
                    child: GetBuilder<PenitipanBantuanController>(
                      id: 'petugas_data',
                      builder: (controller) => _buildItemDetail(
                        context,
                        icon: Icons.person,
                        label: 'Diverifikasi Oleh',
                        value:
                            controller.getPetugasDesaNama(item.petugasDesaId),
                      ),
                    ),
                  ),
              ],
            ),
            if (item.alasanPenolakan != null &&
                item.alasanPenolakan!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildItemDetail(
                    context,
                    icon: Icons.info_outline,
                    label: 'Alasan Penolakan',
                    value: item.alasanPenolakan!,
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _showDetailDialog(context, item, donaturNama);
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Detail'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
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

  void _showDetailDialog(
      BuildContext context, PenitipanBantuanModel item, String donaturNama) {
    final kategoriNama = item.kategoriBantuan?.nama ??
        controller.getKategoriNama(item.stokBantuanId);
    final kategoriSatuan = item.kategoriBantuan?.satuan ??
        controller.getKategoriSatuan(item.stokBantuanId);
    final isUang = item.isUang ?? false;

    Get.dialog(
      AlertDialog(
        title: const Text('Detail Penitipan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Donatur', donaturNama),
              _buildDetailItem('Status', item.status ?? 'Tidak diketahui'),
              _buildDetailItem('Kategori Bantuan', kategoriNama),
              _buildDetailItem(
                  'Jumlah',
                  isUang
                      ? 'Rp ${DateTimeHelper.formatNumber(item.jumlah)}'
                      : '${DateTimeHelper.formatNumber(item.jumlah)} $kategoriSatuan'),
              if (isUang) _buildDetailItem('Jenis Bantuan', 'Uang (Rupiah)'),
              _buildDetailItem(
                  'Deskripsi', item.deskripsi ?? 'Tidak ada deskripsi'),
              _buildDetailItem(
                'Tanggal Penitipan',
                DateTimeHelper.formatDateTime(item.tanggalPenitipan,
                    defaultValue: 'Tidak ada tanggal'),
              ),
              if (item.tanggalVerifikasi != null)
                _buildDetailItem(
                  'Tanggal Verifikasi',
                  DateTimeHelper.formatDateTime(item.tanggalVerifikasi),
                ),
              if (item.status == 'TERVERIFIKASI' && item.petugasDesaId != null)
                _buildDetailItem(
                  'Diverifikasi Oleh',
                  controller.getPetugasDesaNama(item.petugasDesaId),
                ),
              _buildDetailItem('Tanggal Dibuat',
                  DateTimeHelper.formatDateTime(item.createdAt)),
              if (item.alasanPenolakan != null &&
                  item.alasanPenolakan!.isNotEmpty)
                _buildDetailItem('Alasan Penolakan', item.alasanPenolakan!),

              // Foto Bantuan
              if (!isUang &&
                  item.fotoBantuan != null &&
                  item.fotoBantuan!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Foto Bantuan:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: item.fotoBantuan!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _showFullScreenImage(
                                  context, item.fotoBantuan![index]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.fotoBantuan![index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              // Bukti Transfer (untuk bantuan uang)
              if (isUang &&
                  item.fotoBantuan != null &&
                  item.fotoBantuan!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Bukti Transfer:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: item.fotoBantuan!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _showFullScreenImage(
                                  context, item.fotoBantuan![index]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.fotoBantuan![index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              // Bukti Serah Terima
              if (item.fotoBuktiSerahTerima != null &&
                  item.fotoBuktiSerahTerima!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Bukti Serah Terima:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _showFullScreenImage(
                            context, item.fotoBuktiSerahTerima!);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.fotoBuktiSerahTerima!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        size: 50,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
