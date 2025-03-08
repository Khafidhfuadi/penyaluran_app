import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/dashboard/controllers/dashboard_controller.dart';

class PetugasVerifikasiDashboardView extends GetView<DashboardController> {
  const PetugasVerifikasiDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Petugas Verifikasi'),
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
                  'Halo, ${controller.roleData.value?['namaLengkap'] ?? controller.user?.email ?? 'Petugas'}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Selamat datang di Dashboard Petugas Verifikasi',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Petugas Data
                if (controller.roleData.value != null) ...[
                  const Text(
                    'Data Petugas',
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
                              'NIP', controller.roleData.value?['nip'] ?? '-'),
                          _buildInfoRow('Nama',
                              controller.roleData.value?['namaLengkap'] ?? '-'),
                          _buildInfoRow('Jabatan',
                              controller.roleData.value?['jabatan'] ?? '-'),
                          _buildInfoRow('Email',
                              controller.roleData.value?['email'] ?? '-'),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Center(
                    child: Text(
                      'Data petugas belum tersedia',
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
                  'Verifikasi Data Warga',
                  'Verifikasi data warga baru',
                  Icons.verified_user,
                  Colors.blue,
                  () {
                    // Navigasi ke halaman verifikasi data warga
                  },
                ),
                const SizedBox(height: 10),
                _buildMenuCard(
                  'Verifikasi Pengajuan Bantuan',
                  'Verifikasi pengajuan bantuan',
                  Icons.fact_check,
                  Colors.green,
                  () {
                    // Navigasi ke halaman verifikasi pengajuan bantuan
                  },
                ),
                const SizedBox(height: 10),
                _buildMenuCard(
                  'Kelola Skema Bantuan',
                  'Kelola skema bantuan yang tersedia',
                  Icons.settings,
                  Colors.orange,
                  () {
                    // Navigasi ke halaman kelola skema bantuan
                  },
                ),
              ],
            );
          }),
        ),
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
