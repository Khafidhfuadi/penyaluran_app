import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penitipan_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penitipan_bantuan_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';
import 'package:penyaluran_app/app/widgets/dialogs/detail_penitipan_dialog.dart';
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

                          // Informasi terakhir update
                          _buildLastUpdateInfo(context),

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
                  value: DateTimeHelper.formatNumber(
                      controller.jumlahMenunggu.value),
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.check_circle,
                  title: 'Terverifikasi',
                  value: DateTimeHelper.formatNumber(
                      controller.jumlahTerverifikasi.value),
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.cancel,
                  title: 'Ditolak',
                  value: DateTimeHelper.formatNumber(
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
    final filteredList = getFilteredPenitipan();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Perlu Diverifikasi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${DateTimeHelper.formatNumber(filteredList.length)} item',
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
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.pending;
        break;
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

    // Gunakan data donatur dari relasi jika tersedia
    final donaturNama = item.donatur?.nama ?? 'Donatur tidak ditemukan';

    // Cek apakah donatur manual
    final isDonaturManual = item.donatur?.isManual ?? false;

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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          donaturNama,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isDonaturManual)
                        Tooltip(
                          message: 'Donatur Manual (Diinput oleh petugas desa)',
                          child: Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.shade300),
                            ),
                            child: const Text(
                              'Manual',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
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
                    label: 'Tanggal Dibuat',
                    value: DateTimeHelper.formatDateTime(item.createdAt,
                        defaultValue: 'Tidak ada tanggal'),
                  ),
                ),
                Expanded(
                  child: item.status == 'TERVERIFIKASI' &&
                          item.petugasDesaId != null
                      ? _buildItemDetail(
                          context,
                          icon: Icons.person,
                          label: 'Diverifikasi Oleh',
                          value:
                              controller.getPetugasDesaNama(item.petugasDesaId),
                        )
                      : const SizedBox(),
                ),
              ],
            ),

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
                  snackPosition: SnackPosition.TOP,
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
                            Icons.add_photo_alternate,
                            size: 48,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pilih Foto',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kamera atau Galeri',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
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

    // Gunakan dialog yang sudah dibuat
    DetailPenitipanDialog.show(
      context: context,
      item: item,
      donaturNama: donaturNama,
      kategoriNama: kategoriNama,
      kategoriSatuan: kategoriSatuan,
      getPetugasDesaNama: (String? id) => controller.getPetugasDesaNama(id),
      showFullScreenImage: (String imageUrl) {
        DetailPenitipanDialog.showFullScreenImage(context, imageUrl);
      },
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

  // Tambahkan widget untuk menampilkan waktu terakhir update
  Widget _buildLastUpdateInfo(BuildContext context) {
    return Obx(() {
      final lastUpdate = controller.lastUpdateTime.value;
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
    });
  }

  List<PenitipanBantuanModel> getFilteredPenitipan() {
    final searchText = controller.searchController.text.toLowerCase();
    // Hanya tampilkan penitipan dengan status MENUNGGU
    var filteredList = controller.daftarPenitipan
        .where((item) => item.status == 'MENUNGGU')
        .toList();

    // Filter berdasarkan pencarian jika ada teks pencarian
    if (searchText.isNotEmpty) {
      filteredList = filteredList.where((item) {
        final donaturNama = item.donatur?.nama?.toLowerCase() ?? '';
        final kategoriNama = item.kategoriBantuan?.nama?.toLowerCase() ?? '';
        final deskripsi = item.deskripsi?.toLowerCase() ?? '';

        return donaturNama.contains(searchText) ||
            kategoriNama.contains(searchText) ||
            deskripsi.contains(searchText);
      }).toList();
    }

    return filteredList;
  }
}
