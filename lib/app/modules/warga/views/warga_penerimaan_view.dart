import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/widgets/bantuan_card.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class WargaPenerimaanView extends GetView<WargaDashboardController> {
  const WargaPenerimaanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Tambahkan delay untuk memastikan refresh indicator terlihat
            await Future.delayed(const Duration(milliseconds: 300));
            controller.fetchPenerimaPenyaluran();
          },
          child: controller.penerimaPenyaluran.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: Get.height *
                          0.7, // Pastikan tinggi cukup untuk memungkinkan scroll
                      child: _buildEmptyState(),
                    ),
                  ],
                )
              : _buildPenerimaanList(context),
        );
      }),
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
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.volunteer_activism,
              size: 80,
              color: AppTheme.primaryColor,
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
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenerimaanList(BuildContext context) {
    // Menggunakan CustomScrollView dan SliverList untuk layout yang lebih stabil

    // Menggunakan CustomScrollView dan SliverList untuk layout yang lebih stabil
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Pastikan index dalam batas array
                if (index >= controller.penerimaPenyaluran.length) {
                  return const SizedBox.shrink();
                }

                final item = controller.penerimaPenyaluran[index];

                // Menggunakan SizedBox untuk memberikan batas lebar dan tinggi
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: BantuanCard(
                    item: item,
                    onTap: () {
                      // Navigasi ke detail penerimaan
                      Get.toNamed('/warga/detail-penerimaan',
                          arguments: {'id': item.id});
                    },
                  ),
                );
              },
              childCount: controller.penerimaPenyaluran.length,
            ),
          ),
        ),
      ],
    );
  }
}
