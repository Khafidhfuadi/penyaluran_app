import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/widgets/bantuan_card.dart';

class WargaPenerimaanView extends GetView<WargaDashboardController> {
  const WargaPenerimaanView({Key? key}) : super(key: key);

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
          child: controller.penerimaPenyaluran.isEmpty
              ? _buildEmptyState()
              : _buildPenerimaanList(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman riwayat penerimaan
          Get.toNamed('/riwayat-penyaluran');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.history),
        tooltip: 'Riwayat Penerimaan',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.volunteer_activism,
              size: 80,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Penerimaan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Anda belum menerima bantuan. Bantuan akan muncul di sini ketika Anda menerimanya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              controller.fetchData();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenerimaanList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.penerimaPenyaluran.length,
      itemBuilder: (context, index) {
        final item = controller.penerimaPenyaluran[index];

        return BantuanCard(
          item: item,
          onTap: () {
            // Navigasi ke detail penerimaan
            Get.toNamed('/warga/detail-penerimaan', arguments: {'id': item.id});
          },
        );
      },
    );
  }
}
