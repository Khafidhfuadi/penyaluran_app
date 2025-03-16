import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/data/models/pengajuan_kelayakan_bantuan_model.dart';

class WargaDashboardView extends GetView<WargaDashboardController> {
  const WargaDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () async {
          controller.fetchData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildPenyaluranSummary(),
              const SizedBox(height: 24),
              _buildPengajuanSection(),
              const SizedBox(height: 24),
              _buildPengaduanSummary(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.blue,
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
                  const SizedBox(height: 4),
                  Text(
                    controller.nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.desa ?? 'Warga Desa',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenyaluranSummary() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Penyaluran Bantuan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Bantuan Diterima',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${controller.totalPenyaluranDiterima.value}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.volunteer_activism,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ],
                ),
                const Divider(height: 32),
                if (controller.penerimaPenyaluran.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.penerimaPenyaluran.length > 2
                        ? 2
                        : controller.penerimaPenyaluran.length,
                    itemBuilder: (context, index) {
                      final item = controller.penerimaPenyaluran[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.keterangan ?? 'Bantuan',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          item.tanggalPenerimaan != null
                              ? DateFormat('dd MMMM yyyy', 'id_ID')
                                  .format(item.tanggalPenerimaan!)
                              : '-',
                        ),
                        trailing: Text(
                          item.jumlahBantuan != null
                              ? currencyFormat.format(item.jumlahBantuan)
                              : '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      );
                    },
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Belum ada penyaluran bantuan'),
                    ),
                  ),
                if (controller.penerimaPenyaluran.length > 2)
                  TextButton(
                    onPressed: () => controller.changeTab(1),
                    child: const Text('Lihat Semua'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPengajuanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengajuan Kelayakan Bantuan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusCounter(
                      'Menunggu',
                      controller.totalPengajuanMenunggu.value,
                      Colors.orange,
                    ),
                    _buildStatusCounter(
                      'Terverifikasi',
                      controller.totalPengajuanTerverifikasi.value,
                      Colors.green,
                    ),
                    _buildStatusCounter(
                      'Ditolak',
                      controller.totalPengajuanDitolak.value,
                      Colors.red,
                    ),
                  ],
                ),
                const Divider(height: 32),
                if (controller.pengajuanKelayakan.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.pengajuanKelayakan.length > 3
                        ? 3
                        : controller.pengajuanKelayakan.length,
                    itemBuilder: (context, index) {
                      final item = controller.pengajuanKelayakan[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Pengajuan #${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          item.createdAt != null
                              ? DateFormat('dd MMMM yyyy', 'id_ID')
                                  .format(item.createdAt!)
                              : '-',
                        ),
                        trailing: _buildStatusBadge(item.status),
                      );
                    },
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Belum ada pengajuan kelayakan'),
                    ),
                  ),
                if (controller.pengajuanKelayakan.length > 3)
                  TextButton(
                    onPressed: controller.goToPengajuanDetail,
                    child: const Text('Lihat Semua'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCounter(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(StatusKelayakan? status) {
    if (status == null) return const SizedBox();

    Color color;
    String text;

    switch (status) {
      case StatusKelayakan.MENUNGGU:
        color = Colors.orange;
        text = 'Menunggu';
        break;
      case StatusKelayakan.TERVERIFIKASI:
        color = Colors.green;
        text = 'Terverifikasi';
        break;
      case StatusKelayakan.DITOLAK:
        color = Colors.red;
        text = 'Ditolak';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPengaduanSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengaduan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusCounter(
                      'Total',
                      controller.totalPengaduan.value,
                      Colors.blue,
                    ),
                    _buildStatusCounter(
                      'Proses',
                      controller.totalPengaduanProses.value,
                      Colors.orange,
                    ),
                    _buildStatusCounter(
                      'Selesai',
                      controller.totalPengaduanSelesai.value,
                      Colors.green,
                    ),
                  ],
                ),
                const Divider(height: 32),
                if (controller.pengaduan.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.pengaduan.length > 2
                        ? 2
                        : controller.pengaduan.length,
                    itemBuilder: (context, index) {
                      final item = controller.pengaduan[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.judul ?? 'Pengaduan #${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          item.tanggalPengaduan != null
                              ? DateFormat('dd MMMM yyyy', 'id_ID')
                                  .format(item.tanggalPengaduan!)
                              : '-',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: item.status == 'PROSES'
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: item.status == 'PROSES'
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                          child: Text(
                            item.status == 'PROSES' ? 'Proses' : 'Selesai',
                            style: TextStyle(
                              color: item.status == 'PROSES'
                                  ? Colors.orange
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Belum ada pengaduan'),
                    ),
                  ),
                if (controller.pengaduan.length > 2)
                  TextButton(
                    onPressed: () => controller.changeTab(2),
                    child: const Text('Lihat Semua'),
                  ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implementasi navigasi ke halaman buat pengaduan
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Pengaduan Baru'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
