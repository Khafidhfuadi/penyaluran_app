import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
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
            FormatHelper.formatDate(jadwal.tanggalPenyaluran!, format: 'MMMM');

        if (!groupedJadwal.containsKey(monthYear)) {
          groupedJadwal[monthYear] = [];
        }

        groupedJadwal[monthYear]!.add(jadwal);
      }
    }

    // Urutkan kunci (bulan) secara kronologis
    List<String> sortedMonths = groupedJadwal.keys.toList()
      ..sort((a, b) {
        try {
          DateTime dateA = DateFormat('MMMM yyyy', 'id_ID').parse(a);
          DateTime dateB = DateFormat('MMMM yyyy', 'id_ID').parse(b);
          return dateA.compareTo(dateB);
        } catch (e) {
          // Fallback sorting jika parse error
          return a.compareTo(b);
        }
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
        ? FormatHelper.formatDateTime(jadwal.tanggalPenyaluran!)
        : 'Tanggal tidak tersedia';

    String statusText = 'Dijadwalkan';
    Color statusColor = Colors.blue;

    switch (jadwal.status) {
      case 'TERLAKSANA':
        statusText = 'Terlaksana';
        statusColor = Colors.green;
        break;
      case 'BATALTERLAKSANA':
        statusText = 'Batal Terlaksana';
        statusColor = Colors.red;
        break;
      case 'AKTIF':
        statusText = 'Aktif';
        statusColor = Colors.blue;
        break;
      default:
        statusText = 'Dijadwalkan';
        statusColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () => _navigateToDetail(jadwal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: statusColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal dalam badge khusus
                    Container(
                      width: 58,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                        border: Border.all(
                          color: statusColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Header badge
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              jadwal.tanggalPenyaluran != null
                                  ? FormatHelper.formatDate(
                                          jadwal.tanggalPenyaluran!,
                                          format: 'MMM')
                                      .toUpperCase()
                                  : 'TBD',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Tanggal
                          Expanded(
                            child: Center(
                              child: Text(
                                jadwal.tanggalPenyaluran != null
                                    ? FormatHelper.formatDate(
                                        jadwal.tanggalPenyaluran!,
                                        format: 'dd')
                                    : '-',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Informasi utama
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (jadwal.lokasiPenyaluranId != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    jadwal.lokasiNama ??
                                        jadwal.lokasiPenyaluranId!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(jadwal.status),
                                  size: 14,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (jadwal.deskripsi != null &&
                    jadwal.deskripsi!.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    jadwal.deskripsi!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                // Footer dengan informasi bantuan dan tombol detail
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Informasi bantuan yang diberikan
                    if (jadwal.jumlahBantuan != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.volunteer_activism,
                              size: 14,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${jadwal.jumlahBantuan} bantuan',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Tombol lihat detail
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade100,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lihat Detail',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'TERLAKSANA':
        return Icons.check_circle;
      case 'BATALTERLAKSANA':
        return Icons.cancel;
      case 'AKTIF':
        return Icons.timelapse;
      default:
        return Icons.event_available;
    }
  }

  void _navigateToDetail(dynamic jadwal) {
    Get.toNamed('/donatur/jadwal/${jadwal.id}', arguments: jadwal);
  }
}
