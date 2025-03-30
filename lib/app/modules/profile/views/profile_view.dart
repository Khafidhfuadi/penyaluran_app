import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'dart:io';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  // Helper untuk mengkonversi nilai role ke tampilan yang lebih baik
  String _formatRoleName(String? role) {
    if (role == null) return 'Pengguna';

    switch (role.toLowerCase()) {
      case 'warga':
        return 'Warga';
      case 'petugas_desa':
        return 'Petugas Desa';
      case 'admin_desa':
        return 'Admin Desa';
      case 'donatur':
        return 'Donatur';
      case 'admin':
        return 'Administrator';
      default:
        // Kapitalisasi setiap kata dan ganti underscore dengan spasi
        return role
            .split('_')
            .map((word) => word.isEmpty
                ? ''
                : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
            .join(' ');
    }
  }

  // Helper untuk mendapatkan warna berdasarkan role
  Color _getRoleColor(String? role) {
    if (role == null) return AppTheme.primaryColor;

    switch (role.toLowerCase()) {
      case 'warga':
        return AppTheme.infoColor;
      case 'petugas_desa':
        return AppTheme.primaryColor;

      case 'donatur':
        return AppTheme.successColor;

      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          Obx(() {
            // Hanya tampilkan tombol edit jika user bukan warga
            if (controller.user.value?.role?.toLowerCase() != 'warga') {
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
            }
            return const SizedBox
                .shrink(); // Jangan tampilkan apapun untuk warga
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
          Obx(() {
            // Jika user sedang dalam mode edit dan sudah memilih foto baru
            if (controller.isEditing.value &&
                controller.fotoProfilPath.isNotEmpty) {
              return _buildProfileImage(
                isLocalFile: true,
                imagePath: controller.fotoProfilPath.value,
              );
            }
            // Jika user sudah memiliki foto profil
            else if (controller.fotoProfil.isNotEmpty) {
              return _buildProfileImage(
                isLocalFile: false,
                imagePath: controller.fotoProfil.value,
              );
            }
            // Default jika tidak ada foto
            else {
              return _buildDefaultProfileImage();
            }
          }),

          // Tombol edit foto (hanya muncul dalam mode edit)
          Obx(() {
            if (controller.isEditing.value &&
                controller.user.value?.role?.toLowerCase() != 'warga') {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol ambil dari kamera
                    _buildPhotoActionButton(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      onPressed: () => controller.pickFotoProfilFromCamera(),
                    ),
                    const SizedBox(width: 8),

                    // Tombol ambil dari galeri
                    _buildPhotoActionButton(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onPressed: () => controller.pickFotoProfilFromGallery(),
                    ),

                    // Tombol hapus foto (hanya jika ada foto yang dipilih)
                    if (controller.fotoProfilPath.isNotEmpty ||
                        controller.fotoProfil.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: _buildPhotoActionButton(
                          icon: Icons.delete,
                          label: 'Hapus',
                          onPressed: () => controller.clearFotoProfil(),
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),

          const SizedBox(height: 16),
          // Menggunakan Obx untuk reaktif memperbarui nama
          Obx(() {
            // Mengambil nama dari roleData jika ada, atau dari user
            String displayName = '';

            final roleDataValue = controller.roleData.value;
            final userValue = controller.user.value;

            if (roleDataValue != null) {
              // Prioritaskan data dari roleData karena lebih spesifik
              if (roleDataValue['nama_lengkap'] != null) {
                displayName = roleDataValue['nama_lengkap'];
              } else if (roleDataValue['nama'] != null) {
                displayName = roleDataValue['nama'];
              }
            }

            // Gunakan data dari user jika tidak ada di roleData
            if (displayName.isEmpty && userValue != null) {
              displayName = userValue.name ?? 'Pengguna';
            }

            return Text(
              displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          const SizedBox(height: 4),
          Obx(() {
            final role = controller.user.value?.role;
            final roleColor = _getRoleColor(role);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: roleColor.withOpacity(0.3)),
              ),
              child: Text(
                _formatRoleName(role),
                style: TextStyle(
                  fontSize: 14,
                  color: roleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Widget foto profil default
  Widget _buildDefaultProfileImage() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
      child: Obx(() {
        final user = controller.user.value;
        final roleData = controller.roleData.value;

        String displayInitial = '?';

        if (roleData != null && roleData.isNotEmpty) {
          final roleDataValue = roleData;
          if (roleDataValue['nama_lengkap'] != null &&
              roleDataValue['nama_lengkap'].toString().isNotEmpty) {
            displayInitial = roleDataValue['nama_lengkap']
                .toString()
                .substring(0, 1)
                .toUpperCase();
          } else if (roleDataValue['nama'] != null &&
              roleDataValue['nama'].toString().isNotEmpty) {
            displayInitial =
                roleDataValue['nama'].toString().substring(0, 1).toUpperCase();
          }
        } else if (user != null && user.name != null && user.name!.isNotEmpty) {
          displayInitial = user.name!.substring(0, 1).toUpperCase();
        }

        return Text(
          displayInitial,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            fontSize: 60,
          ),
        );
      }),
    );
  }

  // Widget foto profil dengan gambar
  Widget _buildProfileImage(
      {required bool isLocalFile, required String imagePath}) {
    return Stack(
      children: [
        // Widget untuk menampilkan foto profil
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.5),
              width: 3,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: isLocalFile
                ? Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading local image: $error');
                      return _buildDefaultProfileImage();
                    },
                  )
                : Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading network image: $error');
                      print('Failed image URL: $imagePath');
                      return _buildDefaultProfileImage();
                    },
                  ),
          ),
        ),

        // Indikator loading saat mengupload
        if (controller.isUploadingFoto.value)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Widget tombol aksi foto
  Widget _buildPhotoActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final buttonColor = color ?? AppTheme.primaryColor;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: buttonColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: buttonColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: buttonColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Obx(() {
      final isEditing = controller.isEditing.value;
      final user = controller.user.value;
      // Form tidak bisa diedit jika usernya warga
      final bool canEdit = isEditing && user?.role?.toLowerCase() != 'warga';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, color: AppTheme.primaryColor),
                    const SizedBox(width: 10),
                    const Text(
                      'Informasi Pribadi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Menampilkan notifikasi khusus untuk warga
                if (user?.role?.toLowerCase() == 'warga') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.amber[800], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Data warga hanya dapat diubah melalui aplikasi verifikasi data warga. Silakan hubungi petugas desa untuk perubahan data.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amber[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Nama
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person),
                    enabled: canEdit,
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.phone),
                    enabled: canEdit,
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),

          // Informasi tambahan sesuai role
          if (user != null) ...[
            if (user.role?.toLowerCase() == 'warga') ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.infoColor.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_pin_circle,
                            color: AppTheme.infoColor),
                        const SizedBox(width: 10),
                        const Text(
                          'Informasi Lainnya',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final roleData = controller.roleData.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.perm_identity, 'NIK',
                              roleData?['nik'] ?? '-'),
                          _buildInfoRow(Icons.wc, 'Jenis Kelamin',
                              roleData?['jenis_kelamin'] ?? '-'),
                          _buildInfoRow(
                              Icons.home, 'Alamat', roleData?['alamat'] ?? '-'),
                          if (user.desa != null) ...[
                            _buildInfoRow(
                                Icons.location_city, 'Desa', user.desa!.nama),
                            _buildInfoRow(Icons.location_on, 'Kecamatan',
                                user.desa!.kecamatan ?? ''),
                            _buildInfoRow(Icons.location_on, 'Kabupaten',
                                user.desa!.kabupaten ?? ''),
                            _buildInfoRow(Icons.location_on, 'Provinsi',
                                user.desa!.provinsi ?? ''),
                          ],
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
            if (user.role?.toLowerCase() == 'donatur') ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.successColor.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.volunteer_activism,
                            color: AppTheme.successColor),
                        const SizedBox(width: 10),
                        const Text(
                          'Informasi Donatur',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final roleData = controller.roleData.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.business, 'Instansi',
                              roleData?['instansi'] ?? '-'),
                          _buildInfoRow(Icons.work, 'Jabatan',
                              roleData?['jabatan'] ?? '-'),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
            if (user.role?.toLowerCase() == 'petugas_desa') ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.badge, color: AppTheme.primaryColor),
                        const SizedBox(width: 10),
                        const Text(
                          'Informasi Petugas Desa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final roleData = controller.roleData.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                              Icons.badge, 'NIP', roleData?['nip'] ?? '-'),
                          if (user.desa != null) ...[
                            _buildInfoRow(
                                Icons.location_city, 'Desa', user.desa!.nama),
                            _buildInfoRow(Icons.location_on, 'Kecamatan',
                                user.desa!.kecamatan ?? ''),
                            _buildInfoRow(Icons.location_on, 'Kabupaten',
                                user.desa!.kabupaten ?? ''),
                            _buildInfoRow(Icons.location_on, 'Provinsi',
                                user.desa!.provinsi ?? ''),
                          ],
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ],
      );
    });
  }

  Widget _buildPasswordSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              const Text(
                'Keamanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_reset, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
            const Text('Ubah Password'),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Password Saat Ini',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.key),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_clock),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isEmpty ? '-' : value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
}
