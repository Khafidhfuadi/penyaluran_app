import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';

class AuthProvider {
  final SupabaseService _supabaseService = SupabaseService.to;

  // Cache untuk menyimpan data profil pengguna
  UserModel? _cachedUser;

  // Metode untuk login
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _supabaseService.signIn(email, password);

      if (response.user != null && response.user?.email != null) {
        // Ambil profil pengguna dari database
        final profileData = await _supabaseService.getUserProfile();
        print('DEBUG: Profile data dari signIn: $profileData');

        if (profileData != null) {
          // Buat UserModel dengan data yang ada
          _cachedUser = UserModel.fromJson({
            ...profileData,
            'id': response.user!.id,
            'email': response.user!.email!,
          });
          print(
              'DEBUG: User model dibuat: ${_cachedUser?.name}, desa: ${_cachedUser?.desa?.nama}');
          return _cachedUser;
        }

        // Jika profil belum tersedia, gunakan data default
        _cachedUser = UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          role: 'WARGA', // Default role
        );
        print('DEBUG: User model default dibuat: ${_cachedUser?.email}');
        return _cachedUser;
      }
      return null;
    } catch (e) {
      print('Error pada signIn: $e');
      rethrow;
    }
  }

  // Metode untuk logout
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      _cachedUser = null; // Hapus cache saat logout
    } catch (e) {
      rethrow;
    }
  }

  // Metode untuk mendapatkan user saat ini
  Future<UserModel?> getCurrentUser() async {
    // Jika ada cache dan user masih terautentikasi, gunakan cache
    if (_cachedUser != null && _supabaseService.isAuthenticated) {
      print(
          'DEBUG: Menggunakan data user dari cache: ${_cachedUser?.name}, desa: ${_cachedUser?.desa?.nama}');
      return _cachedUser;
    }

    final user = _supabaseService.currentUser;
    if (user != null) {
      try {
        // Ambil profil pengguna dari database
        final profileData = await _supabaseService.getUserProfile();
        print('DEBUG: Profile data dari getCurrentUser: $profileData');

        if (profileData != null) {
          // Buat UserModel dengan data yang ada
          _cachedUser = UserModel.fromJson({
            ...profileData,
            'id': user.id,
            'email': user.email!,
          });
          print(
              'DEBUG: User model dibuat: ${_cachedUser?.name}, desa: ${_cachedUser?.desa?.nama}');
          return _cachedUser;
        }

        // Jika profil belum tersedia, gunakan data default
        _cachedUser = UserModel(
          id: user.id,
          email: user.email!,
          role: 'WARGA', // Default role
        );
        print('DEBUG: User model default dibuat: ${_cachedUser?.email}');
        return _cachedUser;
      } catch (e) {
        print('Error pada getCurrentUser: $e');
        // Jika terjadi error, kembalikan model dengan data minimal
        _cachedUser = UserModel(
          id: user.id,
          email: user.email!,
          role: 'WARGA', // Default role
        );
        return _cachedUser;
      }
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

    // Invalidasi cache setelah membuat profil baru
    _cachedUser = null;
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
