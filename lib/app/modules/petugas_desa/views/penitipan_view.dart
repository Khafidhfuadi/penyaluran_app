import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penitipan_bantuan_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/date_formatter.dart';
import 'dart:io';

class PenitipanView extends GetView<PenitipanBantuanController> {
  const PenitipanView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => RefreshIndicator(
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
                          // Ringkasan penitipan
                          _buildPenitipanSummary(context),

                          const SizedBox(height: 24),

                          // Filter dan pencarian
                          _buildFilterSearch(context),

                          const SizedBox(height: 20),

                          // Daftar penitipan
                          _buildPenitipanList(context),
                        ],
                      ),
                    ),
                  ),
          )),
    );
  }

  Widget _buildPenitipanSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Penitipan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.pending_actions,
                  title: 'Menunggu',
                  value: DateFormatter.formatNumber(
                      controller.jumlahMenunggu.value),
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.check_circle,
                  title: 'Terverifikasi',
                  value: DateFormatter.formatNumber(
                      controller.jumlahTerverifikasi.value),
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.cancel,
                  title: 'Ditolak',
                  value: DateFormatter.formatNumber(
                      controller.jumlahDitolak.value),
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterSearch(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Cari penitipan...',
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
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onSelected: (index) {
              controller.changeCategory(index);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Text('Semua'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('Menunggu'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('Terverifikasi'),
              ),
              const PopupMenuItem(
                value: 3,
                child: Text('Ditolak'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPenitipanList(BuildContext context) {
    final filteredList = controller.getFilteredPenitipan();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Penitipan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${DateFormatter.formatNumber(filteredList.length)} item',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
                        'Tidak ada data penitipan',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  return _buildPenitipanItem(context, filteredList[index]);
                },
              ),
      ],
    );
  }

  Widget _buildPenitipanItem(BuildContext context, PenitipanBantuanModel item) {
    Color statusColor;
    IconData statusIcon;

    switch (item.status) {
      case 'MENUNGGU':
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        break;
      case 'TERVERIFIKASI':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'DITOLAK':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    // Gunakan data donatur dari relasi jika tersedia
    final donaturNama = item.donatur?.nama ?? 'Donatur tidak ditemukan';

    // Debug info
    print('PenitipanItem - stokBantuanId: ${item.stokBantuanId}');

    final kategoriNama = item.kategoriBantuan?.nama ??
        controller.getKategoriNama(item.stokBantuanId);
    final kategoriSatuan = item.kategoriBantuan?.satuan ??
        controller.getKategoriSatuan(item.stokBantuanId);

    print(
        'PenitipanItem - kategoriNama: $kategoriNama, kategoriSatuan: $kategoriSatuan');

    // Cek apakah penitipan berbentuk uang
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
                        ? 'Rp ${DateFormatter.formatNumber(item.jumlah)}'
                        : '${DateFormatter.formatNumber(item.jumlah)} ${kategoriSatuan}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildItemDetail(
              context,
              icon: Icons.calendar_today,
              label: 'Tanggal Penitipan',
              value: DateFormatter.formatDateTime(item.tanggalPenitipan,
                  defaultValue: 'Tidak ada tanggal'),
            ),

            // Tampilkan informasi petugas desa jika status terverifikasi
            if (item.status == 'TERVERIFIKASI' &&
                item.petugasDesaId != null) ...[
              const SizedBox(height: 8),
              _buildItemDetail(
                context,
                icon: Icons.person,
                label: 'Diverifikasi Oleh',
                value: controller.getPetugasDesaNama(item.petugasDesaId),
              ),
            ],

            // Tampilkan thumbnail foto bantuan jika ada
            if (item.fotoBantuan != null && item.fotoBantuan!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Foto Bantuan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${item.fotoBantuan!.length} foto)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 12),
            if (item.status == 'MENUNGGU')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _showVerifikasiDialog(context, item.id ?? '');
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Terima'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showTolakDialog(context, item.id ?? '');
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Tolak'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
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
              )
            else
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

  void _showTolakDialog(BuildContext context, String penitipanId) {
    final TextEditingController alasanController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Tolak Penitipan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan alasan penolakan:'),
            const SizedBox(height: 16),
            TextField(
              controller: alasanController,
              decoration: const InputDecoration(
                hintText: 'Alasan penolakan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (alasanController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Alasan penolakan tidak boleh kosong',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              controller.tolakPenitipan(penitipanId, alasanController.text);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _showVerifikasiDialog(BuildContext context, String penitipanId) {
    // Reset path bukti serah terima
    controller.fotoBuktiSerahTerimaPath.value = null;

    Get.dialog(
      AlertDialog(
        title: const Text('Verifikasi Penitipan'),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload bukti serah terima:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (controller.fotoBuktiSerahTerimaPath.value != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(controller.fotoBuktiSerahTerimaPath.value!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            controller.fotoBuktiSerahTerimaPath.value = null;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: controller.pickfotoBuktiSerahTerima,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 48,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ambil Foto',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Catatan: Foto bukti serah terima wajib diupload untuk verifikasi penitipan.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isUploading.value
                    ? null
                    : () => controller.verifikasiPenitipan(penitipanId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: controller.isUploading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verifikasi'),
              )),
        ],
      ),
    );
  }

  void _showDetailDialog(
      BuildContext context, PenitipanBantuanModel item, String donaturNama) {
    // Gunakan data kategori dari relasi jika tersedia
    final kategoriNama = item.kategoriBantuan?.nama ??
        controller.getKategoriNama(item.stokBantuanId);
    final kategoriSatuan = item.kategoriBantuan?.satuan ??
        controller.getKategoriSatuan(item.stokBantuanId);

    // Cek apakah penitipan berbentuk uang
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
                      ? 'Rp ${DateFormatter.formatNumber(item.jumlah)}'
                      : '${DateFormatter.formatNumber(item.jumlah)} ${kategoriSatuan}'),
              if (isUang) _buildDetailItem('Jenis Bantuan', 'Uang (Rupiah)'),
              _buildDetailItem(
                  'Deskripsi', item.deskripsi ?? 'Tidak ada deskripsi'),
              _buildDetailItem(
                'Tanggal Penitipan',
                DateFormatter.formatDateTime(item.tanggalPenitipan,
                    defaultValue: 'Tidak ada tanggal'),
              ),
              if (item.tanggalVerifikasi != null)
                _buildDetailItem(
                  'Tanggal Verifikasi',
                  DateFormatter.formatDateTime(item.tanggalVerifikasi),
                ),
              if (item.status == 'TERVERIFIKASI' && item.petugasDesaId != null)
                _buildDetailItem(
                  'Diverifikasi Oleh',
                  controller.getPetugasDesaNama(item.petugasDesaId),
                ),
              _buildDetailItem('Tanggal Masuk',
                  DateFormatter.formatDateTime(item.tanggalPenitipan)),
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
