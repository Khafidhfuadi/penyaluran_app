import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';

class AuthService extends GetxService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final Rx<BaseUserModel?> currentUser = Rx<BaseUserModel?>(null);
  String? _token;

  // Mendapatkan data user saat ini
  Future<BaseUserModel?> getCurrentUser() async {
    try {
      // Implementasi untuk mendapatkan data user dari API atau local storage
      // Contoh implementasi sederhana:
      final token = await _storage.read(key: 'token');
      if (token == null) return null;
      _token = token;

      final response = await _dio.get(
        '/api/user/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final user = BaseUserModel.fromJson(response.data['data']);
        currentUser.value = user;
        return user;
      }

      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Update profil user
  Future<bool> updateProfile(BaseUserModel user) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return false;

      final response = await _dio.put(
        '/api/user/profile',
        data: {
          'name': user.name,
          'email': user.email,
          // 'phone' tidak tersedia di BaseUserModel, jadi kita hilangkan atau gunakan parameter lain
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Update current user
        currentUser.value = user;
        return true;
      }

      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Ganti password
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return false;

      final response = await _dio.put(
        '/api/user/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // Login
  Future<BaseUserModel?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final user = BaseUserModel.fromJson(response.data['data']);

        // Simpan token yang datang dari respons
        if (response.data['token'] != null) {
          final token = response.data['token'].toString();
          await _storage.write(key: 'token', value: token);
          _token = token;
        }

        currentUser.value = user;
        return user;
      }

      return null;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        await _dio.post(
          '/api/auth/logout',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
    } catch (e) {
      print('Error logging out: $e');
    } finally {
      // Hapus token dan user data
      await _storage.delete(key: 'token');
      _token = null;
      currentUser.value = null;

      // Navigasi ke halaman login
      Get.offAllNamed('/login');
    }
  }

  // Mendapatkan token autentikasi
  Future<String?> getToken() async {
    if (_token != null) return _token;
    return await _storage.read(key: 'token');
  }

  // Inisialisasi service
  Future<AuthService> init() async {
    // Coba mendapatkan user saat ini
    await getCurrentUser();
    return this;
  }
}
