import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/riwayat_stok_model.dart';
import 'package:penyaluran_app/app/data/models/stok_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/riwayat_stok_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RiwayatStokView extends GetView<RiwayatStokController> {
  const RiwayatStokView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Stok Bantuan'),
        //back button
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
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
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
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
            // Heading
            Text(
              'Riwayat Stok Bantuan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Catatan riwayat perubahan stok bantuan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),

            // Filter dan pencarian
            _buildFilters(context),
            const SizedBox(height: 16),

            // Daftar riwayat stok
            Obx(() {
              final filteredRiwayat = controller.getFilteredRiwayatStok();
              if (filteredRiwayat.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat stok',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredRiwayat.length,
                itemBuilder: (context, index) {
                  final riwayat = filteredRiwayat[index];
                  return _buildRiwayatItem(context, riwayat);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Column(
      children: [
        // Pencarian
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller.searchController,
            decoration: const InputDecoration(
              hintText: 'Cari riwayat stok...',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Filter jenis perubahan
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jenis Perubahan'),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Obx(() => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                          ),
                          isExpanded: true,
                          value: controller.filterJenisPerubahan.value,
                          items: [
                            const DropdownMenuItem(
                              value: 'semua',
                              child: Text('Semua'),
                            ),
                            const DropdownMenuItem(
                              value: 'penambahan',
                              child: Text('Penambahan'),
                            ),
                            const DropdownMenuItem(
                              value: 'pengurangan',
                              child: Text('Pengurangan'),
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
                  const Text('Jenis Bantuan'),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Obx(() => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                          ),
                          isExpanded: true,
                          value: controller.filterStokBantuanId.value,
                          items: [
                            const DropdownMenuItem(
                              value: 'semua',
                              child: Text('Semua'),
                            ),
                            ...controller.daftarStokBantuan.map((stok) {
                              return DropdownMenuItem(
                                value: stok.id,
                                child: Text(stok.nama ?? '-'),
                              );
                            }).toList(),
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
    );
  }

  Widget _buildRiwayatItem(BuildContext context, RiwayatStokModel riwayat) {
    final bool isPenambahan = riwayat.jenisPerubahan == 'penambahan';
    final stokBantuanNama = riwayat.stokBantuan != null
        ? riwayat.stokBantuan!['nama'] ?? 'Tidak diketahui'
        : 'Tidak diketahui';
    final stokBantuanSatuan =
        riwayat.stokBantuan != null ? riwayat.stokBantuan!['satuan'] ?? '' : '';
    final sumberLabels = {
      'penitipan': 'Penitipan',
      'penyaluran': 'Penyaluran',
      'manual': 'Manual',
    };
    final sumberLabel = sumberLabels[riwayat.sumber] ?? 'Tidak diketahui';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Jumlah dan waktu
            Row(
              children: [
                // Icon & Jumlah
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPenambahan ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPenambahan ? Icons.add : Icons.remove,
                        color: isPenambahan ? Colors.green : Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${riwayat.jumlah?.toStringAsFixed(0) ?? '0'} $stokBantuanSatuan',
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
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    sumberLabel,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Tanggal
                Text(
                  riwayat.createdAt != null
                      ? DateTimeHelper.formatDateTime(riwayat.createdAt!)
                      : '-',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nama bantuan
            Text(
              stokBantuanNama,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // Alasan jika ada
            if (riwayat.alasan != null && riwayat.alasan!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Alasan: ${riwayat.alasan}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            // Foto bukti jika ada
            if (riwayat.fotoBukti != null && riwayat.fotoBukti!.isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showImageDialog(context, riwayat.fotoBukti!),
                child: Row(
                  children: [
                    const Icon(
                      Icons.photo,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Lihat Bukti',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Petugas
            if (riwayat.createdBy != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Oleh: ${riwayat.createdBy!['nama_lengkap'] ?? 'Tidak diketahui'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text('Bukti Foto'),
                elevation: 0,
                backgroundColor: AppTheme.primaryColor,
              ),
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(16),
                minScale: 0.5,
                maxScale: 4,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error),
                      const SizedBox(height: 8),
                      Text('Gagal memuat gambar: $error'),
                    ],
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
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
                          return DropdownMenuItem<StokBantuanModel>(
                            value: stok,
                            child: Text(
                                '${stok.nama} (${stok.totalStok} ${stok.satuan})'),
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
}
