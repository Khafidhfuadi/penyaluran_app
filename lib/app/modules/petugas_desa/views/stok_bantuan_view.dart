import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/stok_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/stok_bantuan_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/date_formatter.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tampilkan dialog tambah stok bantuan
          _showAddStokDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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
            'Data stok diambil dari penitipan bantuan terverifikasi',
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
                          'Rp ${DateFormatter.formatNumber(controller.totalDanaBantuan.value)}',
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
                    item.nama ?? 'Tanpa Nama',
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
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.isUang == true)
                        const Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                      if (item.isUang == true) const SizedBox(width: 4),
                      Text(
                        item.kategoriBantuan != null
                            ? (item.kategoriBantuan!['nama'] ??
                                'Tidak Ada Kategori')
                            : 'Tidak Ada Kategori',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.deskripsi != null && item.deskripsi!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  item.deskripsi!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon: item.isUang == true
                        ? Icons.monetization_on
                        : Icons.inventory,
                    label: item.isUang == true ? 'Total Dana' : 'Total Stok',
                    value: item.isUang == true
                        ? 'Rp ${DateFormatter.formatNumber(item.totalStok)}'
                        : '${DateFormatter.formatNumber(item.totalStok)} ${item.satuan ?? ''}',
                  ),
                ),
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon: Icons.access_time,
                    label: 'Terakhir Diperbarui',
                    value: DateFormatter.formatDateTime(item.updatedAt),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Tampilkan dialog edit stok bantuan
                    _showEditStokDialog(context, item);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Tampilkan dialog konfirmasi hapus
                    _showDeleteConfirmation(context, item);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Hapus'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
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

  void _showAddStokDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final satuanController = TextEditingController();
    final deskripsiController = TextEditingController();
    String? selectedJenisBantuanId;
    bool isUang = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Stok Bantuan'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Bantuan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama bantuan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Kategori Bantuan',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedJenisBantuanId,
                    hint: const Text('Pilih Kategori Bantuan'),
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

                  // Tambahkan checkbox untuk menandai sebagai uang
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
                  ),
                  const SizedBox(height: 16),

                  // Hapus input jumlah/stok dan hanya tampilkan input satuan
                  TextFormField(
                    controller: satuanController,
                    decoration: const InputDecoration(
                      labelText: 'Satuan',
                      border: OutlineInputBorder(),
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
                  TextFormField(
                    controller: deskripsiController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Tambahkan informasi tentang total stok
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
                          'Total stok akan dihitung otomatis dari jumlah penitipan bantuan yang telah terverifikasi.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
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
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStokDialog(BuildContext context, StokBantuanModel stok) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: stok.nama);
    final satuanController = TextEditingController(text: stok.satuan);
    final deskripsiController = TextEditingController(text: stok.deskripsi);
    String? selectedJenisBantuanId = stok.kategoriBantuanId;
    bool isUang = stok.isUang ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Stok Bantuan'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Bantuan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama bantuan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Kategori Bantuan',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedJenisBantuanId,
                    hint: const Text('Pilih Kategori Bantuan'),
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

                  // Tambahkan checkbox untuk menandai sebagai uang
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
                  ),
                  const SizedBox(height: 16),

                  // Tampilkan total stok saat ini (read-only)
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: isUang
                          ? 'Total Dana Saat Ini'
                          : 'Total Stok Saat Ini',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    child: Text(
                      isUang
                          ? 'Rp ${DateFormatter.formatNumber(stok.totalStok)}'
                          : '${DateFormatter.formatNumber(stok.totalStok)} ${stok.satuan ?? ''}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hanya tampilkan input satuan
                  TextFormField(
                    controller: satuanController,
                    decoration: const InputDecoration(
                      labelText: 'Satuan',
                      border: OutlineInputBorder(),
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
                  TextFormField(
                    controller: deskripsiController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Tambahkan informasi tentang total stok
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
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
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, StokBantuanModel stok) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
            'Apakah Anda yakin ingin menghapus stok bantuan "${stok.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteStok(stok.id ?? '');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
