import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/dashboard/controllers/dashboard_controller.dart';

class DonaturDashboardView extends GetView<DashboardController> {
  const DonaturDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Donatur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  'Halo, ${controller.roleData.value?['namaLengkap'] ?? controller.user?.email ?? 'Donatur'}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Selamat datang di Dashboard Donatur',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Donatur Data
                if (controller.roleData.value != null) ...[
                  const Text(
                    'Data Donatur',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                              'NIK', controller.roleData.value?['NIK'] ?? '-'),
                          _buildInfoRow('Nama',
                              controller.roleData.value?['namaLengkap'] ?? '-'),
                          _buildInfoRow('No. Telp',
                              controller.roleData.value?['noTelp'] ?? '-'),
                          _buildInfoRow('Email',
                              controller.roleData.value?['email'] ?? '-'),
                          _buildInfoRow(
                              'Alamat',
                              controller.roleData.value?['alamatLengkap'] ??
                                  '-'),
                          _buildInfoRow('Desa',
                              controller.roleData.value?['namaDesa'] ?? '-'),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Center(
                    child: Text(
                      'Data donatur belum tersedia',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // Menu
                const Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildMenuCard(
                  'Penitipan Bantuan',
                  'Titipkan bantuan Anda',
                  Icons.card_giftcard,
                  Colors.blue,
                  () {
                    // Navigasi ke halaman penitipan bantuan
                  },
                ),
                const SizedBox(height: 10),
                _buildMenuCard(
                  'Riwayat Penitipan',
                  'Lihat riwayat penitipan bantuan',
                  Icons.history,
                  Colors.green,
                  () {
                    // Navigasi ke halaman riwayat penitipan
                  },
                ),
                const SizedBox(height: 10),
                _buildMenuCard(
                  'Laporan Penyaluran',
                  'Lihat laporan penyaluran bantuan',
                  Icons.assessment,
                  Colors.orange,
                  () {
                    // Navigasi ke halaman laporan penyaluran
                  },
                ),
              ],
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman penitipan bantuan baru
        },
        child: const Icon(Icons.add),
        tooltip: 'Titipkan Bantuan Baru',
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
