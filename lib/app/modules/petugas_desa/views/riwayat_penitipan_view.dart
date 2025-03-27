import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penitipan_bantuan_controller.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan status
            Container(
              color: statusColor.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.status ?? 'Tidak diketahui',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Text(
                    DateTimeHelper.formatDate(item.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Donatur info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        radius: 20,
                        child: Text(
                          donaturNama.isNotEmpty
                              ? donaturNama.substring(0, 1).toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              donaturNama,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Donatur',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Informasi bantuan
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUang
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isUang
                                        ? Icons.monetization_on
                                        : Icons.category,
                                    size: 16,
                                    color: isUang ? Colors.green : Colors.blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Kategori',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: isUang
                                              ? Colors.green
                                              : Colors.blue,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                kategoriNama,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUang
                                ? Colors.amber.withOpacity(0.1)
                                : Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isUang
                                        ? Icons.account_balance_wallet
                                        : Icons.inventory,
                                    size: 16,
                                    color: isUang
                                        ? Colors.amber.shade800
                                        : Colors.purple,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Jumlah',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: isUang
                                              ? Colors.amber.shade800
                                              : Colors.purple,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isUang
                                    ? 'Rp ${DateTimeHelper.formatNumber(item.jumlah)}'
                                    : '${DateTimeHelper.formatNumber(item.jumlah)} $kategoriSatuan',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Verifikasi info
                  if (item.status == 'TERVERIFIKASI' &&
                      item.petugasDesaId != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: 'Diverifikasi oleh ',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),
                                    TextSpan(
                                      text: controller.getPetugasDesaNama(
                                          item.petugasDesaId),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  // Alasan penolakan jika ditolak
                  if (item.status == 'DITOLAK' &&
                      item.alasanPenolakan != null &&
                      item.alasanPenolakan!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Alasan Penolakan',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.alasanPenolakan!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Footer dengan tombol aksi
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _showDetailDialog(context, item, donaturNama);
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Lihat Detail'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
