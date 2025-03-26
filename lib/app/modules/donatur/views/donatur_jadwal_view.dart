import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';

class DonaturJadwalView extends GetView<DonaturDashboardController> {
  const DonaturJadwalView({super.key});

  @override
  DonaturDashboardController get controller {
    if (!Get.isRegistered<DonaturDashboardController>(
        tag: 'donatur_dashboard')) {
      return Get.put(DonaturDashboardController(),
          tag: 'donatur_dashboard', permanent: true);
    }
    return Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchJadwalPenyaluran();
          },
          child: controller.jadwalPenyaluran.isEmpty
              ? _buildEmptyState()
              : _buildJadwalList(),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Jadwal Penyaluran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Jadwal penyaluran bantuan belum tersedia saat ini',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.fetchJadwalPenyaluran(),
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalList() {
    // Kelompokkan jadwal berdasarkan bulan
    Map<String, List<dynamic>> groupedJadwal = {};

    for (var jadwal in controller.jadwalPenyaluran) {
      if (jadwal.tanggalPenyaluran != null) {
        String monthYear =
            DateFormat('MMMM yyyy', 'id_ID').format(jadwal.tanggalPenyaluran!);

        if (!groupedJadwal.containsKey(monthYear)) {
          groupedJadwal[monthYear] = [];
        }

        groupedJadwal[monthYear]!.add(jadwal);
      }
    }

    // Urutkan kunci (bulan) secara kronologis
    List<String> sortedMonths = groupedJadwal.keys.toList()
      ..sort((a, b) {
        DateTime dateA = DateFormat('MMMM yyyy', 'id_ID').parse(a);
        DateTime dateB = DateFormat('MMMM yyyy', 'id_ID').parse(b);
        return dateA.compareTo(dateB);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Jadwal Penyaluran Bantuan'),
        Text(
          'Daftar jadwal penyaluran bantuan yang akan datang',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),

        // Tampilkan jadwal berdasarkan bulan
        ...sortedMonths
            .map((month) => _buildMonthSection(month, groupedJadwal[month]!)),
      ],
    );
  }

  Widget _buildMonthSection(String month, List<dynamic> jadwalList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            month,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...jadwalList.map((jadwal) => _buildJadwalCard(jadwal)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildJadwalCard(dynamic jadwal) {
    final formattedDate = jadwal.tanggalPenyaluran != null
        ? DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
            .format(jadwal.tanggalPenyaluran!)
        : 'Tanggal tidak tersedia';

    String statusText = 'Akan Datang';
    Color statusColor = Colors.blue;

    switch (jadwal.status) {
      case 'SELESAI':
        statusText = 'Selesai';
        statusColor = Colors.green;
        break;
      case 'DIBATALKAN':
        statusText = 'Dibatalkan';
        statusColor = Colors.red;
        break;
      case 'DALAM_PROSES':
        statusText = 'Dalam Proses';
        statusColor = Colors.orange;
        break;
      default:
        statusText = 'Akan Datang';
        statusColor = Colors.blue;
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (jadwal.tanggalPenyaluran != null) ...[
                          Text(
                            DateFormat('dd').format(jadwal.tanggalPenyaluran!),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          Text(
                            DateFormat('MMM', 'id_ID')
                                .format(jadwal.tanggalPenyaluran!)
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ] else
                          Icon(
                            Icons.event,
                            color: statusColor,
                            size: 24,
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
                          jadwal.nama ?? 'Penyaluran Bantuan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (jadwal.deskripsi != null && jadwal.deskripsi!.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  jadwal.deskripsi!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
