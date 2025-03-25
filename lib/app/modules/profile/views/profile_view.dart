import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          Obx(() {
            if (controller.isEditing.value) {
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: controller.updateProfile,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: controller.toggleEditMode,
              );
            }
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildProfileForm(),
              const SizedBox(height: 24),
              _buildPasswordSection(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor,
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
                controller.user.value?.name ?? 'Pengguna',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 4),
          Obx(() => Text(
                controller.user.value?.role?.toUpperCase() ?? 'PENGGUNA',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Obx(() {
      final isEditing = controller.isEditing.value;
      final user = controller.user.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pribadi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Nama
          TextField(
            controller: controller.nameController,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
              enabled: isEditing,
            ),
          ),
          const SizedBox(height: 16),

          // Email
          TextField(
            controller: controller.emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
              enabled: false, // Email tidak bisa diubah
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Nomor Telepon
          TextField(
            controller: controller.phoneController,
            decoration: InputDecoration(
              labelText: 'Nomor Telepon',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
              enabled: isEditing,
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Informasi tambahan sesuai role
          if (user != null) ...[
            if (user.role?.toLowerCase() == 'warga') ...[
              const SizedBox(height: 24),
              const Text(
                'Informasi Warga',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final roleData = controller.roleData.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                        Icons.perm_identity, 'NIK', roleData?['nik'] ?? '-'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.wc, 'Jenis Kelamin',
                        roleData?['jenis_kelamin'] ?? '-'),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.home, 'Alamat', roleData?['alamat'] ?? '-'),
                    if (user.desa != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.location_city, 'Desa', user.desa!.nama),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, 'Kecamatan',
                          user.desa!.kecamatan ?? ''),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, 'Kabupaten',
                          user.desa!.kabupaten ?? ''),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, 'Provinsi',
                          user.desa!.provinsi ?? ''),
                    ],
                  ],
                );
              }),
            ],
            if (user.role?.toLowerCase() == 'donatur') ...[
              const SizedBox(height: 24),
              const Text(
                'Informasi Donatur',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final roleData = controller.roleData.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.business, 'Instansi',
                        roleData?['instansi'] ?? '-'),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.work, 'Jabatan', roleData?['jabatan'] ?? '-'),
                  ],
                );
              }),
            ],
            if (user.role?.toLowerCase() == 'petugas_desa') ...[
              const SizedBox(height: 24),
              const Text(
                'Informasi Petugas Desa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final roleData = controller.roleData.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.badge, 'NIP', roleData?['nip'] ?? '-'),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.work, 'Jabatan', roleData?['jabatan'] ?? '-'),
                    if (user.desa != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.location_city, 'Desa', user.desa!.nama),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, 'Kecamatan',
                          user.desa!.kecamatan ?? ''),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, 'Kabupaten',
                          user.desa!.kabupaten ?? ''),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, 'Provinsi',
                          user.desa!.provinsi ?? ''),
                    ],
                  ],
                );
              }),
            ],
          ],
        ],
      );
    });
  }

  Widget _buildPasswordSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keamanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _showChangePasswordDialog(context),
          icon: const Icon(Icons.lock),
          label: const Text('Ubah Password'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Ubah Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Password Saat Ini',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.changePassword(
                currentPasswordController.text,
                newPasswordController.text,
                confirmPasswordController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
