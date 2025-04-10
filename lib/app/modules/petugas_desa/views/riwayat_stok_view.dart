import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/riwayat_stok_model.dart';
import 'package:penyaluran_app/app/data/models/stok_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/riwayat_stok_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:penyaluran_app/app/widgets/widgets.dart';

class RiwayatStokView extends GetView<RiwayatStokController> {
  const RiwayatStokView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Stok Bantuan'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppTheme.primaryColor,
        child: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(context)),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol untuk mengurangi stok
          FloatingActionButton.small(
            onPressed: () => _showStokManualDialog(context, isAddition: false),
            backgroundColor: Colors.red,
            heroTag: 'kurangiStok',
            child: const Icon(Icons.remove, color: Colors.white),
          ),
          const SizedBox(height: 10),
          // Tombol untuk menambah stok
          FloatingActionButton(
            onPressed: () => _showStokManualDialog(context, isAddition: true),
            backgroundColor: AppTheme.primaryColor,
            heroTag: 'tambahStok',
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter dan pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildFilters(context),
          ),

          // Daftar riwayat stok
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Obx(() {
              final filteredRiwayat = controller.getFilteredRiwayatStok();
              if (filteredRiwayat.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat stok',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gunakan tombol + untuk menambah stok bantuan',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
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
                    children: [
                      const Icon(
                        Icons.history,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daftar Riwayat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          filteredRiwayat.length.toString(),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredRiwayat.length,
                    itemBuilder: (context, index) {
                      final riwayat = filteredRiwayat[index];
                      return _buildRiwayatItem(context, riwayat);
                    },
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 80), // Ruang untuk floating action button
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Filter
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter Riwayat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pencarian
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Cari riwayat stok...',
                prefixIcon: Icon(Icons.search,
                    color: AppTheme.primaryColor.withOpacity(0.7)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter jenis perubahan dan jenis bantuan
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenis Perubahan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Obx(() => DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12),
                            ),
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down,
                                color: AppTheme.primaryColor),
                            value: controller.filterJenisPerubahan.value,
                            items: [
                              DropdownMenuItem(
                                value: 'semua',
                                child: Row(
                                  children: [
                                    Icon(Icons.all_inclusive,
                                        size: 18, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    const Text('Semua'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'penambahan',
                                child: Row(
                                  children: [
                                    const Icon(Icons.add_circle_outline,
                                        size: 18, color: Colors.green),
                                    const SizedBox(width: 8),
                                    const Text('Penambahan'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'pengurangan',
                                child: Row(
                                  children: [
                                    const Icon(Icons.remove_circle_outline,
                                        size: 18, color: Colors.red),
                                    const SizedBox(width: 8),
                                    const Text('Pengurangan'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                controller.filterByJenisPerubahan(value);
                              }
                            },
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenis Bantuan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Obx(() => DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12),
                            ),
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down,
                                color: AppTheme.primaryColor),
                            value: controller.filterStokBantuanId.value,
                            items: [
                              DropdownMenuItem(
                                value: 'semua',
                                child: Row(
                                  children: [
                                    Icon(Icons.category_outlined,
                                        size: 18, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    const Text('Semua'),
                                  ],
                                ),
                              ),
                              ...controller.daftarStokBantuan.map((stok) {
                                final bool isUang = stok.isUang ?? false;
                                final String formattedJumlah = isUang
                                    ? FormatHelper.formatRupiah(
                                        stok.totalStok ?? 0)
                                    : '${stok.totalStok} ${stok.satuan}';

                                return DropdownMenuItem(
                                  value: stok.id,
                                  child: Text(
                                    '${stok.nama ?? '-'} ($formattedJumlah)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                controller.filterByStokBantuan(value);
                              }
                            },
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(BuildContext context, RiwayatStokModel riwayat) {
    final bool isPenambahan = riwayat.jenisPerubahan == 'penambahan';
    final stokBantuanNama = riwayat.stokBantuan != null
        ? riwayat.stokBantuan!['nama'] ?? 'Tidak diketahui'
        : 'Tidak diketahui';
    final stokBantuanSatuan =
        riwayat.stokBantuan != null ? riwayat.stokBantuan!['satuan'] ?? '' : '';
    final bool isUang = riwayat.stokBantuan != null
        ? riwayat.stokBantuan!['is_uang'] ?? false
        : false;
    final sumberLabels = {
      'penitipan': 'Penitipan',
      'penerimaan': 'Penerimaan',
      'manual': 'Manual',
    };
    final sumberLabel = sumberLabels[riwayat.sumber] ?? 'Tidak diketahui';
    final sumberIcons = {
      'penitipan': Icons.inventory,
      'penerimaan': Icons.local_shipping,
      'manual': Icons.edit,
    };
    final sumberIcon = sumberIcons[riwayat.sumber] ?? Icons.help_outline;
    final sumberColors = {
      'penitipan': Colors.blue,
      'penerimaan': Colors.purple,
      'manual': Colors.orange,
    };
    final sumberColor = sumberColors[riwayat.sumber] ?? Colors.grey;

    // Cek apakah memiliki id_referensi dan bukan dari sumber manual
    final bool hasSumberReferensi = riwayat.idReferensi != null &&
        riwayat.sumber != 'manual' &&
        riwayat.idReferensi!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: hasSumberReferensi
              ? () => _showReferensiDetailDialog(context, riwayat)
              : null,
          child: Column(
            children: [
              // Header dengan warna sesuai jenis perubahan
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isPenambahan ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    // Status dan jumlah
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPenambahan
                            ? Colors.green.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPenambahan ? Icons.add : Icons.remove,
                            color: isPenambahan ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUang
                                ? FormatHelper.formatRupiah(riwayat.jumlah ?? 0)
                                : '${riwayat.jumlah?.toStringAsFixed(0) ?? '0'} $stokBantuanSatuan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPenambahan ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Sumber
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: sumberColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            sumberIcon,
                            size: 14,
                            color: sumberColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sumberLabel,
                            style: TextStyle(
                              color: sumberColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Konten
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama bantuan
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.category,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stokBantuanNama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                riwayat.createdAt != null
                                    ? FormatHelper.formatDateTime(
                                        riwayat.createdAt!)
                                    : '-',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Alasan jika ada
                    if (riwayat.alasan != null &&
                        riwayat.alasan!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 44),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Alasan: ${riwayat.alasan}',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Foto bukti jika ada
                    if (riwayat.fotoBukti != null &&
                        riwayat.fotoBukti!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 44),
                        child: InkWell(
                          onTap: () =>
                              ShowImageDialog.show(context, riwayat.fotoBukti!),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.photo,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Lihat Bukti',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Info referensi jika ada
                    if (hasSumberReferensi) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 44),
                        child: Container(
                          decoration: BoxDecoration(
                            color: sumberColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                riwayat.sumber == 'penitipan'
                                    ? Icons.inventory
                                    : Icons.local_shipping,
                                size: 18,
                                color: sumberColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Lihat detail ${riwayat.sumber}',
                                style: TextStyle(
                                  color: sumberColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Petugas
                    if (riwayat.createdBy != null) ...[
                      const Divider(height: 24),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Oleh: ${riwayat.createdBy!['nama_lengkap'] ?? 'Tidak diketahui'}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStokManualDialog(BuildContext context, {required bool isAddition}) {
    // Reset form
    controller.resetForm();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        isAddition ? Icons.add_circle : Icons.remove_circle,
                        color: isAddition ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAddition
                            ? 'Tambah Stok Manual'
                            : 'Kurangi Stok Manual',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Form
                  // 1. Pilih Bantuan
                  Text(
                    'Pilih Bantuan',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<StokBantuanModel>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        hint: const Text('Pilih bantuan'),
                        value: controller.selectedStokBantuan.value,
                        items: controller.daftarStokBantuan
                            .map((StokBantuanModel stok) {
                          final bool isUang = stok.isUang ?? false;
                          final String formattedStok = isUang
                              ? FormatHelper.formatRupiah(stok.totalStok ?? 0)
                              : '${stok.totalStok} ${stok.satuan}';
                          return DropdownMenuItem<StokBantuanModel>(
                            value: stok,
                            child: Text('${stok.nama} ($formattedStok)'),
                          );
                        }).toList(),
                        onChanged: (StokBantuanModel? value) {
                          controller.setSelectedStokBantuan(value);
                        },
                      )),
                  const SizedBox(height: 16),

                  // 2. Jumlah
                  Row(
                    children: [
                      Text(
                        'Jumlah',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(width: 8),
                      // Tampilkan satuan jika bantuan sudah dipilih
                      Obx(() => controller.selectedStokBantuan.value != null
                          ? Text(
                              controller.selectedStokBantuan.value!.satuan ??
                                  '',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        controller.setJumlah(double.parse(value));
                      } else {
                        controller.setJumlah(0);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Alasan
                  Text(
                    'Alasan',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      hintText: 'Masukkan alasan perubahan stok',
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      controller.setAlasan(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Upload Bukti
                  Text(
                    'Foto Bukti',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: Obx(() {
                        if (controller.fotoBukti.value != null) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.file(
                                controller.fotoBukti.value!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.red,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      controller.fotoBukti.value = null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.camera_alt,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pilih Foto',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () {
                                  if (isAddition) {
                                    controller.tambahStokManual();
                                  } else {
                                    controller.kurangiStokManual();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isAddition ? Colors.green : Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isAddition ? 'Tambah Stok' : 'Kurangi Stok',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Tambahkan metode baru untuk menampilkan dialog detail referensi
  void _showReferensiDetailDialog(
      BuildContext context, RiwayatStokModel riwayat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: controller.getReferensiDetail(
                idReferensi: riwayat.idReferensi!, sumber: riwayat.sumber!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Terjadi kesalahan',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak dapat memuat data: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              }

              final data = snapshot.data;
              if (data == null) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.amber,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Data Tidak Ditemukan',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Detail data tidak tersedia atau mungkin sudah dihapus',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              }

              // Tampilkan detail sesuai dengan jenis sumber
              if (riwayat.sumber == 'penitipan') {
                return _buildPenitipanDetail(context, data);
              } else if (riwayat.sumber == 'penerimaan') {
                return _buildPenerimaanDetail(context, data);
              } else {
                return const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text('Tipe data tidak dikenal'),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  // Widget untuk menampilkan detail penitipan
  Widget _buildPenitipanDetail(
      BuildContext context, Map<String, dynamic> data) {
    final String tanggal = data['created_at'] != null
        ? FormatHelper.formatDateTime(DateTime.parse(data['created_at']))
        : '-';

    final String namaPenitip = data['donatur'] != null
        ? data['donatur']['nama_lengkap'] ?? 'Tidak diketahui'
        : 'Tidak diketahui';

    final String namaPetugas = data['petugas_desa'] != null
        ? data['petugas_desa']['nama_lengkap'] ?? 'Tidak diketahui'
        : 'Tidak diketahui';

    final List<dynamic> fotoBantuan = data['foto_bantuan'] ?? [];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan desain yang lebih menarik
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Detail Penitipan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Informasi detail dengan desain yang lebih menarik
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'ID Penitipan: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: data['id'] ?? '-'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'Tanggal: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: tanggal),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'Penitip: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: namaPenitip),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.admin_panel_settings,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'Petugas: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: namaPetugas),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Foto Bukti jika ada dengan desain yang lebih menarik
          if (fotoBantuan.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.photo, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Foto Bukti Penitipan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: fotoBantuan.length,
                      itemBuilder: (context, index) {
                        final String imageUrl = fotoBantuan[index];
                        return Padding(
                          padding: EdgeInsets.only(
                              right: index < fotoBantuan.length - 1 ? 8.0 : 0),
                          child: InkWell(
                            onTap: () =>
                                ShowImageDialog.show(context, imageUrl),
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey[300],
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error,
                                            color: Colors.red, size: 32),
                                        SizedBox(height: 8),
                                        Text('Gagal memuat gambar'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Ketuk untuk memperbesar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Tutup', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan detail penerimaan
  Widget _buildPenerimaanDetail(
      BuildContext context, Map<String, dynamic> data) {
    final String tanggal = data['created_at'] != null
        ? FormatHelper.formatDateTime(DateTime.parse(data['created_at']))
        : '-';

    final String namaPenerima = data['warga'] != null
        ? data['warga']['nama_lengkap'] ?? 'Tidak diketahui'
        : 'Tidak diketahui';

    final String namaPetugas =
        data['penyaluran_bantuan']['petugas_desa'] != null
            ? data['penyaluran_bantuan']['petugas_desa']['nama_lengkap'] ??
                'Tidak diketahui'
            : 'Tidak diketahui';

    final String buktiPenerimaan = data['bukti_penerimaan'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan desain yang lebih menarik
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detail Penerimaan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Informasi dalam card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID Penerimaan dengan ikon
                Row(
                  children: [
                    const Icon(Icons.tag,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'ID Penerimaan: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: data['id'] ?? '-'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tanggal dengan ikon
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'Tanggal: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: tanggal),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Penerima dengan ikon
                Row(
                  children: [
                    const Icon(Icons.person,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'Penerima: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: namaPenerima),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Petugas dengan ikon
                Row(
                  children: [
                    const Icon(Icons.admin_panel_settings,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'Petugas: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: namaPetugas),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Foto Bukti jika ada dengan desain yang lebih menarik
          if (buktiPenerimaan.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.photo, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Foto Bukti Penerimaan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => ShowImageDialog.show(context, buktiPenerimaan),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: buktiPenerimaan,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 32),
                                SizedBox(height: 8),
                                Text('Gagal memuat gambar'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Ketuk untuk memperbesar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'Tutup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
