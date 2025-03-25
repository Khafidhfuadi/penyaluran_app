import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _imagePicker = ImagePicker();

  final Rx<BaseUserModel?> user = Rx<BaseUserModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isEditing = false.obs;
  final Rx<Map<String, dynamic>?> roleData = Rx<Map<String, dynamic>?>(null);

  // Untuk foto profil
  final RxString fotoProfil = ''.obs;
  final RxString fotoProfilPath = ''.obs;
  final RxBool isUploadingFoto = false.obs;

  // Form controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      // Mendapatkan data user dari service
      final userData = await _supabaseService.getUserProfile();
      if (userData != null) {
        user.value = BaseUserModel.fromJson(userData);

        // Mengisi form controllers dengan data user
        nameController.text = user.value?.name ?? '';
        emailController.text = user.value?.email ?? '';
        // Catatan: BaseUserModel tidak memiliki properti phone
        // Jika ada data role_data, simpan untuk ditampilkan
        if (userData['role_data'] != null) {
          roleData.value = userData['role_data'] as Map<String, dynamic>?;
          // Jika role adalah warga, ambil no telepon dari role data
          if (roleData.value?['no_hp'] != null) {
            phoneController.text = roleData.value?['no_hp'] ?? '';
          }

          // Ambil foto profil jika ada
          if (roleData.value?['foto_profil'] != null) {
            fotoProfil.value = roleData.value?['foto_profil'] ?? '';
            print(fotoProfil.value);
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data profil: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleEditMode() {
    isEditing.value = !isEditing.value;
  }

  // Metode untuk memilih foto profil dari kamera
  Future<void> pickFotoProfilFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        fotoProfilPath.value = pickedFile.path;
      }
    } catch (e) {
      print('Error mengambil foto dari kamera: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Metode untuk memilih foto profil dari galeri
  Future<void> pickFotoProfilFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        fotoProfilPath.value = pickedFile.path;
      }
    } catch (e) {
      print('Error mengambil foto dari galeri: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Metode untuk menghapus foto profil
  void clearFotoProfil() {
    fotoProfilPath.value = '';
  }

  // Metode untuk mengupload foto profil
  Future<String?> _uploadFotoProfil() async {
    if (fotoProfilPath.isEmpty) return null;

    try {
      isUploadingFoto.value = true;
      final userData = user.value;
      if (userData == null) throw 'Data user tidak ditemukan';

      // Upload foto ke Supabase storage
      final fotoUrl = await _supabaseService.uploadFile(
        fotoProfilPath.value,
        'profiles', // bucket name
        'profile_photos/${userData.id}', // folder path
      );

      return fotoUrl;
    } catch (e) {
      print('Error upload foto profil: $e');
      throw e.toString();
    } finally {
      isUploadingFoto.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nama tidak boleh kosong',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final userData = user.value;
      if (userData == null) throw 'Data user tidak ditemukan';

      // Upload foto profil jika ada
      String? fotoProfilUrl;
      if (fotoProfilPath.isNotEmpty) {
        fotoProfilUrl = await _uploadFotoProfil();
        if (fotoProfilUrl == null) {
          throw 'Gagal mengupload foto profil';
        }
      }

      // Update data sesuai role
      switch (userData.role?.toLowerCase() ?? 'unknown') {
        case 'warga':
          await _supabaseService.updateWargaProfile(
            userId: userData.id,
            namaLengkap: nameController.text,
            noHp: phoneController.text,
            email: emailController.text,
            fotoProfil: fotoProfilUrl,
          );
          break;
        case 'donatur':
          await _supabaseService.updateDonaturProfile(
            userId: userData.id,
            nama: nameController.text,
            noHp: phoneController.text,
            email: emailController.text,
            fotoProfil: fotoProfilUrl,
          );
          break;
        case 'petugas_desa':
          await _supabaseService.updatePetugasDesaProfile(
            userId: userData.id,
            nama: nameController.text,
            noHp: phoneController.text,
            email: emailController.text,
            fotoProfil: fotoProfilUrl,
          );
          break;
        default:
          throw 'Role tidak valid';
      }

      // Refresh data lokal
      await loadUserData();

      // Refresh data di AuthController untuk menyebarkan perubahan ke seluruh aplikasi
      await _authController.refreshUserData();

      // Reset path foto setelah update
      fotoProfilPath.value = '';

      // Keluar dari mode edit
      isEditing.value = false;

      Get.snackbar(
        'Sukses',
        'Profil berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Konfirmasi password tidak sesuai',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      // Panggil API untuk ganti password
      await _supabaseService.changePassword(currentPassword, newPassword);

      Get.back(); // Tutup dialog

      Get.snackbar(
        'Sukses',
        'Password berhasil diubah',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah password: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
