import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahPenitipanDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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

  void _showTambahPenitipanDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController jumlahController = TextEditingController();
    final TextEditingController deskripsiController = TextEditingController();

    // Variabel untuk menyimpan nilai yang dipilih
    final Rx<String?> selectedStokBantuanId = Rx<String?>(null);
    final Rx<String?> selectedDonaturId = Rx<String?>(null);
    final Rx<DonaturModel?> selectedDonatur = Rx<DonaturModel?>(null);

    // Reset foto bantuan paths
    controller.fotoBantuanPaths.clear();
    controller.donaturSearchController.clear();
    controller.hasilPencarianDonatur.clear();

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            // Dapatkan informasi apakah stok bantuan berupa uang
            bool isUang = false;
            String satuan = '';
            if (selectedStokBantuanId.value != null) {
              isUang =
                  controller.isStokBantuanUang(selectedStokBantuanId.value!);
              satuan =
                  controller.getKategoriSatuan(selectedStokBantuanId.value);
            }

            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Manual Penitipan Bantuan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Pilih kategori bantuan
                    Text(
                      'Jenis Stok Bantuan',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      hint: const Text('Pilih jenis stok bantuan'),
                      value: selectedStokBantuanId.value,
                      items: controller.stokBantuanMap.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value.nama ?? 'Tidak ada nama'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedStokBantuanId.value = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori bantuan harus dipilih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Jumlah bantuan
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isUang ? 'Jumlah Uang (Rp)' : 'Jumlah Bantuan',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: jumlahController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  hintText:
                                      isUang ? 'Contoh: 100000' : 'Contoh: 10',
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Jumlah harus diisi';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Jumlah harus berupa angka';
                                  }
                                  if (double.parse(value) <= 0) {
                                    return 'Jumlah harus lebih dari 0';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        if (satuan.isNotEmpty && !isUang) ...[
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.only(top: 32),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Text(
                              satuan,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Donatur (wajib)
                    Text(
                      'Donatur',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedDonatur.value != null) ...[
                          // Tampilkan donatur yang dipilih
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedDonatur.value!.nama ??
                                            'Tidak ada nama',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (selectedDonatur.value!.noHp != null)
                                        Text(selectedDonatur.value!.noHp!),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    selectedDonatur.value = null;
                                    selectedDonaturId.value = null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Tampilkan pencarian donatur
                          TextFormField(
                            controller: controller.donaturSearchController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintText: 'Cari donatur (min. 3 karakter)',
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              suffixIcon: controller.isSearchingDonatur.value
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              controller.searchDonatur(value);
                            },
                            validator: (value) {
                              if (selectedDonaturId.value == null) {
                                return 'Donatur harus dipilih';
                              }
                              return null;
                            },
                          ),

                          // Hasil pencarian donatur
                          if (controller.hasilPencarianDonatur.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: const BoxConstraints(maxHeight: 150),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                    controller.hasilPencarianDonatur.length,
                                itemBuilder: (context, index) {
                                  final donatur =
                                      controller.hasilPencarianDonatur[index];
                                  return ListTile(
                                    title:
                                        Text(donatur.nama ?? 'Tidak ada nama'),
                                    subtitle: donatur.noHp != null
                                        ? Text(donatur.noHp!)
                                        : const Text('Tidak ada nomor telepon'),
                                    dense: true,
                                    onTap: () {
                                      selectedDonatur.value = donatur;
                                      selectedDonaturId.value = donatur.id;
                                      controller.donaturSearchController
                                          .clear();
                                      controller.hasilPencarianDonatur.clear();
                                    },
                                  );
                                },
                              ),
                            ),

                          // Tombol tambah donatur baru
                          if (controller.donaturSearchController.text.length >=
                                  3 &&
                              controller.hasilPencarianDonatur.isEmpty &&
                              !controller.isSearchingDonatur.value)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _showTambahDonaturDialog(context,
                                      (donaturId) {
                                    // Callback ketika donatur berhasil ditambahkan
                                    controller
                                        .getDonaturInfo(donaturId)
                                        .then((donatur) {
                                      if (donatur != null) {
                                        selectedDonatur.value = donatur;
                                        selectedDonaturId.value = donatur.id;
                                      }
                                    });
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Donatur Baru'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  foregroundColor: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: deskripsiController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Deskripsi bantuan',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Upload foto bantuan
                    Text(
                      'Foto Bantuan',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (controller.fotoBantuanPaths.isEmpty)
                      InkWell(
                        onTap: () => _showPilihSumberFoto(context),
                        child: Container(
                          height: 150,
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
                                'Tambah Foto',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.fotoBantuanPaths.length +
                                  1, // +1 untuk tombol tambah
                              itemBuilder: (context, index) {
                                if (index ==
                                    controller.fotoBantuanPaths.length) {
                                  // Tombol tambah foto
                                  return InkWell(
                                    onTap: () => _showPilihSumberFoto(context),
                                    child: Container(
                                      width: 100,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade400),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 32,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tambah',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                // Tampilkan foto yang sudah diambil
                                return Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(File(controller
                                              .fotoBantuanPaths[index])),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () =>
                                            controller.removeFotoBantuan(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
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
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Tombol aksi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: controller.isUploading.value
                              ? null
                              : () {
                                  if (formKey.currentState!.validate()) {
                                    if (controller.fotoBantuanPaths.isEmpty) {
                                      Get.snackbar(
                                        'Error',
                                        'Foto bantuan harus diupload',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }

                                    controller.tambahPenitipanBantuan(
                                      stokBantuanId:
                                          selectedStokBantuanId.value!,
                                      jumlah:
                                          double.parse(jumlahController.text),
                                      deskripsi: deskripsiController.text,
                                      donaturId: selectedDonaturId.value,
                                      isUang: isUang,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
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
                              : const Text('Simpan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showPilihSumberFoto(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Foto',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                controller.pickFotoBantuan(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                controller.pickFotoBantuan(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTambahDonaturDialog(
      BuildContext context, Function(String) onDonaturAdded) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController namaController = TextEditingController();
    final TextEditingController noHpController = TextEditingController();
    final TextEditingController alamatController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController jenisController = TextEditingController();

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Donatur Baru',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Nama donatur
                  Text(
                    'Nama Donatur',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: namaController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Masukkan nama donatur',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama donatur harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Telepon
                  Text(
                    'Nomor HP',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: noHpController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Masukkan nomor HP',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor HP harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Jenis (opsional)
                  Text(
                    'Jenis Donatur (Opsional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('Pilih jenis donatur'),
                    value: jenisController.text.isEmpty
                        ? null
                        : jenisController.text,
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'Individu',
                        child: Text('Individu'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Perusahaan',
                        child: Text('Perusahaan'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Organisasi',
                        child: Text('Organisasi'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        jenisController.text = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Alamat (opsional)
                  Text(
                    'Alamat (Opsional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: alamatController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Masukkan alamat',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email (opsional)
                  Text(
                    'Email (Opsional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Masukkan email',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol aksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final donaturId = await controller.tambahDonatur(
                              nama: namaController.text,
                              noHp: noHpController.text,
                              alamat: alamatController.text.isEmpty
                                  ? null
                                  : alamatController.text,
                              email: emailController.text.isEmpty
                                  ? null
                                  : emailController.text,
                              jenis: jenisController.text.isEmpty
                                  ? null
                                  : jenisController.text,
                            );

                            if (donaturId != null) {
                              Get.back();
                              onDonaturAdded(donaturId);
                              Get.snackbar(
                                'Sukses',
                                'Donatur berhasil ditambahkan',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
