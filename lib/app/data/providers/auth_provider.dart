import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';

class AuthProvider {
  final SupabaseService _supabaseService = SupabaseService.to;

  // Metode untuk mendaftar pengguna baru
  Future<UserModel?> signUp(String email, String password) async {
    try {
      final response = await _supabaseService.signUp(email, password);

      if (response.user != null) {
        // Tunggu beberapa saat agar trigger di database berjalan
        await Future.delayed(const Duration(seconds: 1));

        // Ambil profil pengguna dari database
        final profileData = await _supabaseService.getUserProfile();

        if (profileData != null) {
          return UserModel.fromJson({
            ...profileData,
            'id': response.user!.id,
            'email': response.user!.email!,
          });
        }

        // Jika profil belum tersedia, gunakan data default
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          role: 'WARGA', // Default role
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Metode untuk login
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _supabaseService.signIn(email, password);

      if (response.user != null) {
        // Ambil profil pengguna dari database
        final profileData = await _supabaseService.getUserProfile();

        if (profileData != null) {
          return UserModel.fromJson({
            ...profileData,
            'id': response.user!.id,
            'email': response.user!.email!,
          });
        }

        // Jika profil belum tersedia, gunakan data default
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          role: 'WARGA', // Default role
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Metode untuk logout
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Metode untuk mendapatkan user saat ini
  Future<UserModel?> getCurrentUser() async {
    final user = _supabaseService.currentUser;
    if (user != null) {
      // Ambil profil pengguna dari database
      final profileData = await _supabaseService.getUserProfile();

      if (profileData != null) {
        return UserModel.fromJson({
          ...profileData,
          'id': user.id,
          'email': user.email!,
        });
      }

      // Jika profil belum tersedia, gunakan data default
      return UserModel(
        id: user.id,
        email: user.email!,
        role: 'WARGA', // Default role
      );
    }
    return null;
  }

  // Metode untuk memeriksa apakah user sudah login
  bool isAuthenticated() {
    return _supabaseService.isAuthenticated;
  }

  // Metode untuk mendapatkan data warga
  Future<Map<String, dynamic>?> getWargaData() async {
    return await _supabaseService.getWargaByUserId();
  }

  // Metode untuk membuat profil warga
  Future<void> createWargaProfile({
    required String nik,
    required String namaLengkap,
    required String jenisKelamin,
    String? noHp,
    String? alamat,
    String? tempatLahir,
    DateTime? tanggalLahir,
    String? agama,
  }) async {
    await _supabaseService.createWargaProfile(
      nik: nik,
      namaLengkap: namaLengkap,
      jenisKelamin: jenisKelamin,
      noHp: noHp,
      alamat: alamat,
      tempatLahir: tempatLahir,
      tanggalLahir: tanggalLahir,
      agama: agama,
    );
  }

  // Metode untuk mendapatkan notifikasi pengguna
  Future<List<Map<String, dynamic>>> getUserNotifications(
      {bool unreadOnly = false}) async {
    return await _supabaseService.getUserNotifications(unreadOnly: unreadOnly);
  }

  // Metode untuk menandai notifikasi sebagai telah dibaca
  Future<void> markNotificationAsRead(int notificationId) async {
    await _supabaseService.markNotificationAsRead(notificationId);
  }
}
