import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';

class WargaDashboardView extends GetView<DashboardController> {
  const WargaDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Warga'),
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

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    'Halo, ${controller.user?.email ?? 'Pengguna'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Selamat datang di Dashboard Warga',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status Profil
                  Obx(() => authController.isWargaProfileComplete.value
                      ? _buildProfileCompleteCard()
                      : _buildProfileIncompleteCard(authController)),

                  const SizedBox(height: 30),

                  // Warga Data
                  if (controller.roleData.value != null) ...[
                    const Text(
                      'Data Pribadi',
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
                            _buildInfoRow('NIK',
                                controller.roleData.value?['NIK'] ?? '-'),
                            _buildInfoRow(
                                'Nama',
                                controller.roleData.value?['namaLengkap'] ??
                                    '-'),
                            _buildInfoRow(
                                'Jenis Kelamin',
                                controller.roleData.value?['jenisKelamin'] ??
                                    '-'),
                            _buildInfoRow('No. HP',
                                controller.roleData.value?['noHp'] ?? '-'),
                            _buildInfoRow('Alamat',
                                controller.roleData.value?['alamat'] ?? '-'),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const Center(
                      child: Text(
                        'Data warga belum tersedia',
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
                    'Pengajuan Bantuan',
                    'Ajukan permohonan bantuan',
                    Icons.request_page,
                    Colors.blue,
                    () {
                      // Navigasi ke halaman pengajuan bantuan
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(
                    'Pengaduan',
                    'Sampaikan pengaduan Anda',
                    Icons.report_problem,
                    Colors.orange,
                    () {
                      // Navigasi ke halaman pengaduan
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(
                    'Status Bantuan',
                    'Lihat status bantuan Anda',
                    Icons.info,
                    Colors.green,
                    () {
                      // Navigasi ke halaman status bantuan
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // Widget untuk menampilkan status profil lengkap
  Widget _buildProfileCompleteCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Profil Anda sudah lengkap',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan status profil belum lengkap dengan tombol
  Widget _buildProfileIncompleteCard(AuthController authController) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade700),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Profil Anda belum lengkap',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Lengkapi profil Anda untuk mengakses semua fitur aplikasi',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
          ],
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
                  color: color.withAlpha(26),
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
