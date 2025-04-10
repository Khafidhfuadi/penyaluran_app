import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/stok_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/stok_bantuan_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';

class StokBantuanView extends GetView<StokBantuanController> {
  const StokBantuanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(context)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Tampilkan dialog tambah stok bantuan
          _showAddStokDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Jenis Stok',
            style: TextStyle(color: Colors.white)),
        elevation: 2,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan stok bantuan
            _buildStokBantuanSummary(context),

            const SizedBox(height: 24),

            // Filter dan pencarian
            _buildFilterSearch(context),

            // Informasi terakhir update
            _buildLastUpdateInfo(context),

            const SizedBox(height: 20),

            // Daftar stok bantuan
            _buildStokBantuanList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStokBantuanSummary(BuildContext context) {
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
            'Ringkasan Stok Bantuan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total stok diperbarui otomatis saat ada penitipan bantuan terverifikasi',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.warning_amber_rounded,
                  title: 'Hampir Habis',
                  value: '${controller.getStokHampirHabis()}',
                  valueColor: controller.getStokHampirHabis() > 0
                      ? Colors.amber
                      : Colors.white,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.handshake_outlined,
                  title: 'Penitipan',
                  value: '${controller.daftarPenitipanTerverifikasi.length}',
                  valueColor: Colors.white,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.inventory_2,
                  title: 'Jenis Bantuan',
                  value: '${controller.daftarStokBantuan.length}',
                ),
              ),
            ],
          ),

          // Tampilkan total dana bantuan jika ada
          if (controller.totalDanaBantuan.value > 0) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monetization_on,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Dana Bantuan',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        Text(
                          'Rp ${FormatHelper.formatNumber(controller.totalDanaBantuan.value)}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
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
                color: valueColor ?? Colors.white,
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
              hintText: 'Cari bantuan...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.filterValue.value,
              icon: const Icon(Icons.filter_list),
              hint: const Text('Filter'),
              items: [
                DropdownMenuItem(
                  value: 'semua',
                  child: Text('Semua'),
                ),
                DropdownMenuItem(
                  value: 'uang',
                  child: Text('Uang'),
                ),
                DropdownMenuItem(
                  value: 'barang',
                  child: Text('Barang'),
                ),
                DropdownMenuItem(
                  value: 'hampir_habis',
                  child: Text('Hampir Habis'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.setFilter(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStokBantuanList(BuildContext context) {
    return Obx(() {
      final filteredList = controller.getFilteredStokBantuan();

      if (filteredList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  controller.searchQuery.isEmpty
                      ? controller.filterValue.value == 'semua'
                          ? 'Belum ada data stok bantuan'
                          : 'Tidak ada stok bantuan yang sesuai dengan filter'
                      : 'Tidak ada stok bantuan yang sesuai dengan pencarian',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
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
                'Daftar Stok Bantuan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${filteredList.length} item',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...filteredList.map((item) => _buildStokBantuanItem(context, item)),
        ],
      );
    });
  }

  Widget _buildStokBantuanItem(BuildContext context, StokBantuanModel item) {
    // Tentukan warna berdasarkan jenis bantuan
    Color categoryColor =
        item.isUang == true ? Colors.amber.shade700 : AppTheme.primaryColor;

    // Cek apakah stok hampir habis (kurang dari 10)
    bool isLowStock = !item.isUang! && item.totalStok! < 10;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(30),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan gradient berdasarkan jenis bantuan
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    categoryColor.withOpacity(0.8),
                    categoryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.nama ?? 'Tanpa Nama',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.isUang == true
                              ? Icons.monetization_on
                              : Icons.inventory_2_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.kategoriBantuan != null
                              ? (item.kategoriBantuan!['nama'] ??
                                  'Tidak Ada Kategori')
                              : 'Tidak Ada Kategori',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deskripsi
                if (item.deskripsi != null && item.deskripsi!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      item.deskripsi!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // Detail stok/dana dalam card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLowStock
                        ? Colors.red.shade50
                        : (item.isUang == true
                            ? Colors.amber.shade50
                            : Colors.blue.shade50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isLowStock
                                  ? Colors.red.shade200
                                  : (item.isUang == true
                                      ? Colors.amber.shade200
                                      : Colors.blue.shade200),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.isUang == true
                                  ? Icons.monetization_on
                                  : (isLowStock
                                      ? Icons.warning_amber_rounded
                                      : Icons.inventory),
                              size: 20,
                              color: isLowStock
                                  ? Colors.red.shade800
                                  : (item.isUang == true
                                      ? Colors.amber.shade800
                                      : Colors.blue.shade800),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.isUang == true
                                      ? 'Total Dana'
                                      : (isLowStock
                                          ? 'Stok Hampir Habis!'
                                          : 'Total Stok'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: isLowStock
                                            ? Colors.red.shade800
                                            : (item.isUang == true
                                                ? Colors.amber.shade800
                                                : Colors.blue.shade800),
                                      ),
                                ),
                                Text(
                                  item.isUang == true
                                      ? 'Rp ${FormatHelper.formatNumber(item.totalStok)}'
                                      : '${FormatHelper.formatNumber(item.totalStok)} ${item.satuan ?? ''}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isLowStock
                                            ? Colors.red.shade900
                                            : (item.isUang == true
                                                ? Colors.amber.shade900
                                                : Colors.blue.shade900),
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

                const SizedBox(height: 16),

                // Additional details
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.updatedAt != null
                            ? 'Diperbarui: ${FormatHelper.formatDateTimeWithHour(item.updatedAt!)}'
                            : 'Tidak ada data pembaruan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tombol Aksi
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Tampilkan dialog edit stok bantuan
                          _showEditStokDialog(context, item);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: BorderSide(color: Colors.blue.shade300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Tampilkan dialog konfirmasi hapus
                          _showDeleteConfirmation(context, item);
                        },
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Hapus'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.shade300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
    );
  }

  void _showAddStokDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final satuanController = TextEditingController();
    final deskripsiController = TextEditingController();
    String? selectedJenisBantuanId;
    bool isUang = false;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) => Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Jenis Stok Bantuan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Nama Bantuan
                    Text(
                      'Nama Bantuan',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: namaController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Masukkan nama bantuan',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama bantuan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Kategori Bantuan
                    Text(
                      'Kategori Bantuan',
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
                      hint: const Text('Pilih kategori bantuan'),
                      value: selectedJenisBantuanId,
                      items: controller.daftarKategoriBantuan
                          .map((kategori) => DropdownMenuItem<String>(
                                value: kategori['id'],
                                child: Text(kategori['nama'] ?? ''),
                              ))
                          .toList(),
                      onChanged: (value) {
                        selectedJenisBantuanId = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori bantuan harus dipilih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Checkbox untuk bantuan berbentuk uang
                    CheckboxListTile(
                      title: const Text('Bantuan Berbentuk Uang (Rupiah)'),
                      value: isUang,
                      onChanged: (value) {
                        setState(() {
                          isUang = value ?? false;
                          if (isUang) {
                            satuanController.text = 'Rp';
                          } else {
                            satuanController.text = '';
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),

                    // Satuan
                    Text(
                      'Satuan',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: satuanController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Contoh: Kg, Liter, Paket',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      enabled: !isUang, // Disable jika berbentuk uang
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Satuan tidak boleh kosong';
                        }
                        return null;
                      },
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
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Masukkan deskripsi bantuan',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Informasi
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Informasi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total stok dihitung otomatis dari jumlah penitipan bantuan yang telah terverifikasi dan tidak dapat diubah secara manual.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
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
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final stok = StokBantuanModel(
                                nama: namaController.text,
                                satuan: satuanController.text,
                                deskripsi: deskripsiController.text,
                                kategoriBantuanId: selectedJenisBantuanId,
                                isUang: isUang,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              controller.addStok(stok);
                              Get.back();
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
      ),
      barrierDismissible: false,
    );
  }

  void _showEditStokDialog(BuildContext context, StokBantuanModel stok) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: stok.nama);
    final satuanController = TextEditingController(text: stok.satuan);
    final deskripsiController = TextEditingController(text: stok.deskripsi);
    String? selectedJenisBantuanId = stok.kategoriBantuanId;
    bool isUang = stok.isUang ?? false;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) => Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Stok Bantuan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Nama Bantuan
                    Text(
                      'Nama Bantuan',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: namaController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Masukkan nama bantuan',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama bantuan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Kategori Bantuan
                    Text(
                      'Kategori Bantuan',
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
                      hint: const Text('Pilih kategori bantuan'),
                      value: selectedJenisBantuanId,
                      isExpanded: true,
                      items: controller.daftarKategoriBantuan
                          .map((kategori) => DropdownMenuItem<String>(
                                value: kategori['id'],
                                child: Text(
                                  kategori['nama'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        selectedJenisBantuanId = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori bantuan harus dipilih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Checkbox untuk bantuan berbentuk uang
                    CheckboxListTile(
                      title: const Text('Bantuan Berbentuk Uang (Rupiah)'),
                      value: isUang,
                      onChanged: (value) {
                        setState(() {
                          isUang = value ?? false;
                          if (isUang) {
                            satuanController.text = 'Rp';
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),

                    // Total Stok Saat Ini
                    Text(
                      isUang ? 'Total Dana Saat Ini' : 'Total Stok Saat Ini',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isUang ? Icons.monetization_on : Icons.inventory_2,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isUang
                                ? 'Rp ${FormatHelper.formatNumber(stok.totalStok)}'
                                : '${FormatHelper.formatNumber(stok.totalStok)} ${stok.satuan ?? ''}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Satuan
                    Text(
                      'Satuan',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: satuanController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Contoh: Kg, Liter, Paket',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      enabled: !isUang, // Disable jika berbentuk uang
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Satuan tidak boleh kosong';
                        }
                        return null;
                      },
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
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Masukkan deskripsi bantuan',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Informasi
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Informasi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total stok dihitung otomatis dari jumlah penitipan bantuan yang telah terverifikasi dan tidak dapat diubah secara manual.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
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
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final updatedStok = StokBantuanModel(
                                id: stok.id,
                                nama: namaController.text,
                                satuan: satuanController.text,
                                deskripsi: deskripsiController.text,
                                kategoriBantuanId: selectedJenisBantuanId,
                                isUang: isUang,
                                createdAt: stok.createdAt,
                                updatedAt: DateTime.now(),
                              );
                              controller.updateStok(updatedStok);
                              Get.back();
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
      ),
      barrierDismissible: false,
    );
  }

  void _showDeleteConfirmation(BuildContext context, StokBantuanModel stok) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Konfirmasi Hapus',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text('Apakah Anda yakin ingin menghapus stok bantuan berikut?'),
              const SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stok.nama ?? 'Tanpa Nama',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (stok.deskripsi != null &&
                        stok.deskripsi!.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        stok.deskripsi!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          stok.isUang == true
                              ? Icons.monetization_on
                              : Icons.inventory,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          stok.isUang == true
                              ? 'Rp ${FormatHelper.formatNumber(stok.totalStok)}'
                              : '${FormatHelper.formatNumber(stok.totalStok)} ${stok.satuan ?? ''}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Perhatian: Tindakan ini tidak dapat dibatalkan!',
                        style: TextStyle(
                            color: Colors.red, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      controller.deleteStok(stok.id ?? '');
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Tambahkan widget untuk menampilkan waktu terakhir update
  Widget _buildLastUpdateInfo(BuildContext context) {
    return Obx(() {
      final lastUpdate = controller.lastUpdateTime.value;
      final formattedDate = FormatHelper.formatDateTimeWithHour(lastUpdate);

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
}
