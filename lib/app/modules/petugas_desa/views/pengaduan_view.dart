import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/pengaduan_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';

class PengaduanView extends GetView<PengaduanController> {
  const PengaduanView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan pengaduan
            _buildPengaduanSummary(context),

            const SizedBox(height: 24),

            // Filter dan pencarian
            _buildFilterSearch(context),

            const SizedBox(height: 20),

            // Daftar pengaduan
            _buildPengaduanList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPengaduanSummary(BuildContext context) {
    return Obx(() {
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
              'Ringkasan Pengaduan',
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
                    title: 'Diproses',
                    value: controller.jumlahDiproses.toString(),
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.engineering,
                    title: 'Tindakan',
                    value: controller.jumlahTindakan.toString(),
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.check_circle,
                    title: 'Selesai',
                    value: controller.jumlahSelesai.toString(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
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
              hintText: 'Cari pengaduan...',
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
              controller.refreshData();
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              // Tampilkan dialog filter
              _showFilterDialog(context);
            },
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pengaduan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => RadioListTile<int>(
                  title: const Text('Semua'),
                  value: 0,
                  groupValue: controller.selectedCategoryIndex.value,
                  onChanged: (value) {
                    controller.changeCategory(value!);
                    Navigator.pop(context);
                  },
                )),
            Obx(() => RadioListTile<int>(
                  title: const Text('Diproses'),
                  value: 1,
                  groupValue: controller.selectedCategoryIndex.value,
                  onChanged: (value) {
                    controller.changeCategory(value!);
                    Navigator.pop(context);
                  },
                )),
            Obx(() => RadioListTile<int>(
                  title: const Text('Tindakan'),
                  value: 2,
                  groupValue: controller.selectedCategoryIndex.value,
                  onChanged: (value) {
                    controller.changeCategory(value!);
                    Navigator.pop(context);
                  },
                )),
            Obx(() => RadioListTile<int>(
                  title: const Text('Selesai'),
                  value: 3,
                  groupValue: controller.selectedCategoryIndex.value,
                  onChanged: (value) {
                    controller.changeCategory(value!);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Widget _buildPengaduanList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final filteredPengaduan = controller.getFilteredPengaduan();

      if (filteredPengaduan.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada pengaduan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
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
                'Daftar Pengaduan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.refreshData(),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...filteredPengaduan
              .map((item) => _buildPengaduanItem(context, item)),
        ],
      );
    });
  }

  Widget _buildPengaduanItem(BuildContext context, dynamic item) {
    Color statusColor;
    IconData statusIcon;

    switch (item.status?.toUpperCase()) {
      case 'MENUNGGU':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.pending;
        break;
      case 'TINDAKAN':
        statusColor = AppTheme.infoColor;
        statusIcon = Icons.sync;
        break;
      case 'SELESAI':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    // Format tanggal menggunakan DateTimeHelper
    String formattedDate = '';
    if (item.tanggalPengaduan != null) {
      formattedDate = DateTimeHelper.formatDate(item.tanggalPengaduan);
    } else if (item.createdAt != null) {
      formattedDate = DateTimeHelper.formatDate(item.createdAt);
    }

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
                    item.warga?['nama'] ?? item.judul ?? '',
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
                        item.status ?? '',
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
            const SizedBox(height: 4),
            Text(
              'NIK: ${item.warga?['nik'] ?? ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 12),
            if (item.penerimaPenyaluran != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Penyaluran: ${item.namaPenyaluran}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Jenis: ${item.jenisBantuan}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Jumlah: ${item.jumlahBantuan}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              item.deskripsi ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(context, item),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context, dynamic item) {
    final status = item.status?.toUpperCase();

    if (status == 'MENUNGGU') {
      return [
        TextButton.icon(
          onPressed: () {
            // Implementasi untuk memproses pengaduan
            _showTindakanDialog(context, item);
          },
          icon: const Icon(Icons.engineering, size: 18),
          label: const Text('Tindakan'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            // Navigasi ke halaman detail pengaduan
            Get.toNamed('/detail-pengaduan', arguments: {'id': item.id});
          },
          icon: const Icon(Icons.info_outline, size: 18),
          label: const Text('Detail'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ];
    } else if (status == 'TINDAKAN') {
      return [
        TextButton.icon(
          onPressed: () {
            // Implementasi untuk menyelesaikan pengaduan
            _showSelesaikanDialog(context, item);
          },
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Selesaikan'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            // Navigasi ke halaman detail pengaduan
            Get.toNamed('/detail-pengaduan', arguments: {'id': item.id});
          },
          icon: const Icon(Icons.info_outline, size: 18),
          label: const Text('Detail'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ];
    } else {
      return [
        TextButton.icon(
          onPressed: () {
            // Navigasi ke halaman detail pengaduan
            Get.toNamed('/detail-pengaduan', arguments: {'id': item.id});
          },
          icon: const Icon(Icons.info_outline, size: 18),
          label: const Text('Detail'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ];
    }
  }

  void _showTindakanDialog(BuildContext context, dynamic item) {
    controller.tindakanController.clear();
    controller.catatanController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tindakan Pengaduan'),
        content: Form(
          key: controller.tindakanFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pengaduan dari: ${item.warga?['nama'] ?? ''}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.tindakanController,
                decoration: const InputDecoration(
                  labelText: 'Tindakan yang dilakukan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: controller.validateTindakan,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.catatanController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.tambahTindakan(item.id!);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showSelesaikanDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Pengaduan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pengaduan dari: ${item.warga?['nama'] ?? ''}'),
            const SizedBox(height: 16),
            const Text(
              'Apakah Anda yakin ingin menyelesaikan pengaduan ini?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.selesaikanPengaduan(item.id!);
            },
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }
}
