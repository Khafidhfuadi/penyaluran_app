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
        child: const Icon(Icons.add),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.inventory_2_outlined,
                  title: 'Total Stok',
                  value: DateFormatter.formatNumber(controller.totalStok.value),
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.input,
                  title: 'Masuk',
                  value: DateFormatter.formatNumber(controller.stokMasuk.value),
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.output,
                  title: 'Keluar',
                  value:
                      DateFormatter.formatNumber(controller.stokKeluar.value),
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
          ),
          child: IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
                      ? 'Belum ada data stok bantuan'
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
                  child: Text(
                    item.jenisBantuan != null
                        ? (item.jenisBantuan!['nama'] ?? 'Tidak Ada Jenis')
                        : 'Tidak Ada Jenis',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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
                    icon: Icons.inventory,
                    label: 'Jumlah',
                    value:
                        '${DateFormatter.formatNumber(item.jumlah)} ${item.satuan ?? ''}',
                  ),
                ),
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Tanggal Masuk',
                    value: DateFormatter.formatDate(item.tanggalMasuk),
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
                    icon: Icons.timelapse,
                    label: 'Kadaluarsa',
                    value: DateFormatter.formatDate(item.tanggalKadaluarsa),
                  ),
                ),
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon: Icons.access_time,
                    label: 'Terakhir Diperbarui',
                    value: DateFormatter.formatDate(item.updatedAt),
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
    final jumlahController = TextEditingController();
    final satuanController = TextEditingController();
    final deskripsiController = TextEditingController();
    String? selectedJenisBantuanId;
    DateTime? tanggalMasuk = DateTime.now();
    DateTime? tanggalKadaluarsa;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                    labelText: 'Jenis Bantuan',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedJenisBantuanId,
                  hint: const Text('Pilih Jenis Bantuan'),
                  items: controller.daftarJenisBantuan
                      .map((jenis) => DropdownMenuItem<String>(
                            value: jenis['id'],
                            child: Text(jenis['nama'] ?? ''),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedJenisBantuanId = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis bantuan harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: jumlahController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah tidak boleh kosong';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Jumlah harus berupa angka';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: satuanController,
                        decoration: const InputDecoration(
                          labelText: 'Satuan',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Satuan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
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
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tanggalMasuk ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      tanggalMasuk = picked;
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Masuk',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormatter.formatDate(tanggalMasuk),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tanggalKadaluarsa ??
                          DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      tanggalKadaluarsa = picked;
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Kadaluarsa',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormatter.formatDate(tanggalKadaluarsa),
                    ),
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
                  jumlah: double.parse(jumlahController.text),
                  satuan: satuanController.text,
                  deskripsi: deskripsiController.text,
                  jenisBantuanId: selectedJenisBantuanId,
                  tanggalMasuk: tanggalMasuk,
                  tanggalKadaluarsa: tanggalKadaluarsa,
                  status: 'TERSEDIA',
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
    );
  }

  void _showEditStokDialog(BuildContext context, StokBantuanModel stok) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: stok.nama);
    final jumlahController =
        TextEditingController(text: stok.jumlah?.toString());
    final satuanController = TextEditingController(text: stok.satuan);
    final deskripsiController = TextEditingController(text: stok.deskripsi);
    String? selectedJenisBantuanId = stok.jenisBantuanId;
    DateTime? tanggalMasuk = stok.tanggalMasuk;
    DateTime? tanggalKadaluarsa = stok.tanggalKadaluarsa;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                    labelText: 'Jenis Bantuan',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedJenisBantuanId,
                  hint: const Text('Pilih Jenis Bantuan'),
                  items: controller.daftarJenisBantuan
                      .map((jenis) => DropdownMenuItem<String>(
                            value: jenis['id'],
                            child: Text(jenis['nama'] ?? ''),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedJenisBantuanId = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis bantuan harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: jumlahController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah tidak boleh kosong';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Jumlah harus berupa angka';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: satuanController,
                        decoration: const InputDecoration(
                          labelText: 'Satuan',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Satuan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
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
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tanggalMasuk ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      tanggalMasuk = picked;
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Masuk',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormatter.formatDate(tanggalMasuk),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tanggalKadaluarsa ??
                          DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      tanggalKadaluarsa = picked;
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Kadaluarsa',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormatter.formatDate(tanggalKadaluarsa),
                    ),
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
                  jumlah: double.parse(jumlahController.text),
                  satuan: satuanController.text,
                  deskripsi: deskripsiController.text,
                  jenisBantuanId: selectedJenisBantuanId,
                  tanggalMasuk: tanggalMasuk,
                  tanggalKadaluarsa: tanggalKadaluarsa,
                  status: stok.status,
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
