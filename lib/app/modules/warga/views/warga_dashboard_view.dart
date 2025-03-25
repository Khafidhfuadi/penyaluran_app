import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';
import 'package:penyaluran_app/app/widgets/bantuan_card.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';

class WargaDashboardView extends GetView<WargaDashboardController> {
  const WargaDashboardView({super.key});

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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade200, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Hero(
                      tag: 'warga-profile',
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: controller.profilePhotoUrl != null
                            ? NetworkImage(controller.profilePhotoUrl!)
                            : null,
                        child: controller.profilePhotoUrl == null
                            ? Icon(
                                Icons.person,
                                color: Colors.blue.shade700,
                                size: 30,
                              )
                            : null,
                      ),
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
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          controller.nama,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.home_rounded,
                      iconColor: Colors.blue.shade300,
                      label: 'Alamat',
                      value: controller.alamat ?? 'Alamat tidak tersedia',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    _buildInfoRow(
                      icon: Icons.phone_rounded,
                      iconColor: Colors.green.shade300,
                      label: 'No. HP',
                      value: controller.noHp ?? 'No. HP tidak tersedia',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    _buildInfoRow(
                      icon: Icons.location_city_rounded,
                      iconColor: Colors.amber.shade300,
                      label: 'Desa',
                      value: controller.desa ?? 'Desa tidak tersedia',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit_rounded,
                      label: 'Edit Profil',
                      color: Colors.blue.shade700,
                      onTap: () => Get.toNamed(Routes.PROFILE),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.notifications_rounded,
                      label: 'Notifikasi',
                      color: Colors.amber.shade700,
                      onTap: () => Get.toNamed(Routes.NOTIFIKASI),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
            Get.toNamed(Routes.wargaPenerimaan);
          },
        ),
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
