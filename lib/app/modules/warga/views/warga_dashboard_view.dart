import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/widgets/bantuan_card.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';

class WargaDashboardView extends GetView<WargaDashboardController> {
  const WargaDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildPenerimaanSummary(),
                const SizedBox(height: 24),
                _buildRecentPenerimaan(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang,',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        controller.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.home,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Alamat tidak tersedia',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'No. HP tidak tersedia',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_city,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  controller.desa ?? 'Desa tidak tersedia',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenerimaanSummary() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Hitung total bantuan uang dan non-uang
    double totalUang = 0;
    Map<String, double> totalNonUang = {};

    for (var item in controller.penerimaPenyaluran) {
      if (item.statusPenerimaan == 'DITERIMA') {
        if (item.isUang == true && item.jumlahBantuan != null) {
          totalUang += item.jumlahBantuan!;
        } else if (item.isUang == false &&
            item.jumlahBantuan != null &&
            item.satuan != null) {
          if (totalNonUang.containsKey(item.satuan)) {
            totalNonUang[item.satuan!] =
                (totalNonUang[item.satuan] ?? 0) + item.jumlahBantuan!;
          } else {
            totalNonUang[item.satuan!] = item.jumlahBantuan!;
          }
        }
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Ringkasan Bantuan',
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (totalUang > 0)
              _buildSummaryItem(
                icon: Icons.attach_money,
                color: Colors.green,
                title: 'Total Bantuan Uang',
                value: currencyFormat.format(totalUang),
              ),
            if (totalNonUang.isNotEmpty) ...[
              if (totalUang > 0) const SizedBox(height: 12),
              ...totalNonUang.entries.map((entry) {
                return _buildSummaryItem(
                  icon: Icons.inventory_2,
                  color: Colors.blue,
                  title: 'Total Bantuan ${entry.key}',
                  value: '${entry.value} ${entry.key}',
                );
              }),
            ],
            if (totalUang == 0 && totalNonUang.isEmpty)
              _buildSummaryItem(
                icon: Icons.info_outline,
                color: Colors.grey,
                title: 'Belum Ada Bantuan',
                value: 'Anda belum menerima bantuan',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPenerimaan() {
    if (controller.penerimaPenyaluran.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxItems = controller.penerimaPenyaluran.length > 2
        ? 2
        : controller.penerimaPenyaluran.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Bantuan Terbaru',
          viewAllText: 'Lihat Semua',
          onViewAll: () {
            Get.toNamed('/warga-penerimaan');
          },
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: maxItems,
          itemBuilder: (context, index) {
            final item = controller.penerimaPenyaluran[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: BantuanCard(
                item: item,
                isCompact: true,
                onTap: () {
                  Get.toNamed('/warga/detail-penerimaan',
                      arguments: {'id': item.id});
                },
              ),
            );
          },
        ),
        if (controller.penerimaPenyaluran.length > 2)
          Center(
            child: TextButton.icon(
              onPressed: () {
                Get.toNamed('/warga-penerimaan');
              },
              icon: const Icon(Icons.list),
              label: const Text('Lihat Semua Bantuan'),
            ),
          ),
      ],
    );
  }
}
