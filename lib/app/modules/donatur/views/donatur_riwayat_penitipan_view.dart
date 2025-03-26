import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';

class DonaturRiwayatPenitipanView extends GetView<DonaturDashboardController> {
  DonaturRiwayatPenitipanView({Key? key}) : super(key: key);

  @override
  DonaturDashboardController get controller {
    return Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
  }

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Penitipan'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Menunggu'),
              Tab(text: 'Diterima'),
              Tab(text: 'Ditolak'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Menunggu
            _buildPenitipanList(context, 'MENUNGGU'),
            // Tab Diterima
            _buildPenitipanList(context, 'DITERIMA'),
            // Tab Ditolak
            _buildPenitipanList(context, 'DITOLAK'),
          ],
        ),
      ),
    );
  }

  Widget _buildPenitipanList(BuildContext context, String status) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Filter penitipan berdasarkan status
      var filteredList = controller.penitipanBantuan
          .where((item) => item.status == status)
          .toList();

      // Filter berdasarkan pencarian
      final searchText = searchController.text.toLowerCase();
      if (searchText.isNotEmpty) {
        filteredList = filteredList.where((item) {
          final kategoriNama = item.kategoriBantuan?.nama?.toLowerCase() ?? '';
          final deskripsi = item.deskripsi?.toLowerCase() ?? '';
          final tanggal = item.tanggalPenitipan != null
              ? DateFormat('dd MMMM yyyy', 'id_ID')
                  .format(item.tanggalPenitipan!)
                  .toLowerCase()
              : '';

          return kategoriNama.contains(searchText) ||
              deskripsi.contains(searchText) ||
              tanggal.contains(searchText);
        }).toList();
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchPenitipanBantuan();
        },
        child: filteredList.isEmpty
            ? _buildEmptyState(status)
            : _buildContentList(context, filteredList, status),
      );
    });
  }

  Widget _buildEmptyState(String status) {
    String statusText = '';
    switch (status) {
      case 'MENUNGGU':
        statusText = 'menunggu verifikasi';
        break;
      case 'DITERIMA':
        statusText = 'diterima';
        break;
      case 'DITOLAK':
        statusText = 'ditolak';
        break;
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada penitipan $statusText',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Anda belum memiliki riwayat penitipan yang $statusText',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList(
      BuildContext context, List<dynamic> filteredList, String status) {
    Color statusColor;
    switch (status) {
      case 'DITERIMA':
        statusColor = Colors.green;
        break;
      case 'DITOLAK':
        statusColor = Colors.red;
        break;
      case 'MENUNGGU':
      default:
        statusColor = Colors.orange;
        break;
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field
            TextField(
              controller: searchController,
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
                // Trigger update dengan GetX
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
            const SizedBox(height: 16),
            // Daftar penitipan
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return _buildPenitipanCard(
                    context, filteredList[index], statusColor);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenitipanCard(
      BuildContext context, dynamic penitipan, Color statusColor) {
    final formattedDate = penitipan.tanggalPenitipan != null
        ? DateFormat('dd MMMM yyyy', 'id_ID')
            .format(penitipan.tanggalPenitipan!)
        : 'Tanggal tidak tersedia';

    IconData statusIcon;

    switch (penitipan.status) {
      case 'DITERIMA':
        statusIcon = Icons.check_circle;
        break;
      case 'DITOLAK':
        statusIcon = Icons.cancel;
        break;
      case 'MENUNGGU':
      default:
        statusIcon = Icons.hourglass_empty;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                penitipan.kategoriBantuan?.nama ?? 'Bantuan',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                penitipan.status ?? 'MENUNGGU',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Jumlah: ${penitipan.jumlah ?? 0}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (penitipan.deskripsi != null &&
                  penitipan.deskripsi!.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  penitipan.deskripsi!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (penitipan.status == 'DITOLAK' &&
                  penitipan.alasanPenolakan != null &&
                  penitipan.alasanPenolakan!.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  'Alasan Penolakan:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  penitipan.alasanPenolakan!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
