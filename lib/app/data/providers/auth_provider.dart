import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/data/models/warga_model.dart';
import 'package:penyaluran_app/app/data/models/petugas_desa_model.dart';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
import 'package:penyaluran_app/app/data/models/desa_model.dart';

class AuthProvider {
  final SupabaseService _supabaseService = SupabaseService.to;

  // Cache untuk menyimpan data pengguna
  UserData? _cachedUserData;

  // Metode untuk login
  Future<UserData?> signIn(String email, String password) async {
    try {
      // Step 1: Login
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        print('Login gagal!');
        return null;
      }

      final userId = user.id;

      // Step 2: Ambil role dari view `users_with_roles` atau tabel roles
      String roleName;
      try {
        final roleResponse = await _supabaseService.client
            .from('users_with_roles')
            .select('role_name')
            .eq('id', userId)
            .single();

        roleName = roleResponse['role_name'];
      } catch (e) {
        print('Error mengambil role dari users_with_roles: $e');
        print('Mencoba ambil role dari tabel roles...');

        // Fallback ke cara lama jika view users_with_roles tidak tersedia
        try {
          // Ambil role_id dari user metadata
          final roleId = user.userMetadata?['role_id'];
          if (roleId == null) {
            print('Tidak ada role_id di user metadata');
            return null;
          }

          final roleResponse = await _supabaseService.client
              .from('roles')
              .select('role_name')
              .eq('id', roleId)
              .single();

          roleName = roleResponse['role_name'];
        } catch (e) {
          print('Error mengambil role dari tabel roles: $e');
          return null;
        }
      }

      print('Role: $roleName');

      // Step 3: Ambil profil user berdasarkan role
      Map<String, dynamic>? profileResponse;
      dynamic roleData;
      DesaModel? desa;

      // Buat BaseUserModel
      final baseUser = BaseUserModel(
        id: userId,
        email: user.email ?? '',
        roleId: user.userMetadata?['role_id'],
        roleName: roleName,
        createdAt: DateTime.parse(user.createdAt),
        updatedAt:
            user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
      );

      if (roleName == 'warga') {
        profileResponse = await _supabaseService.client
            .from('warga')
            .select('*, desa:desa_id(id, nama, kecamatan, kabupaten, provinsi)')
            .eq('id', userId)
            .single();

        // Ekstrak data desa jika ada
        if (profileResponse['desa'] != null) {
          desa = DesaModel.fromJson(profileResponse['desa']);
          print('Data Desa: ${desa.nama}');
        }

        roleData = WargaModel.fromJson(profileResponse);
        print('Data Warga: ${roleData.namaLengkap}');
      } else if (roleName == 'petugas_desa') {
        profileResponse = await _supabaseService.client
            .from('petugas_desa')
            .select('*, desa:desa_id(id, nama, kecamatan, kabupaten, provinsi)')
            .eq('id', userId)
            .single();

        // Ekstrak data desa jika ada
        if (profileResponse['desa'] != null) {
          desa = DesaModel.fromJson(profileResponse['desa']);
          print('Data Desa: ${desa.nama}');
        }

        roleData = PetugasDesaModel.fromJson(profileResponse);
        print(
            'Data Petugas Desa: ${roleData.namaLengkap}, Desa: ${roleData.desa?.nama}');
      } else if (roleName == 'donatur') {
        profileResponse = await _supabaseService.client
            .from('donatur')
            .select('*')
            .eq('id', userId)
            .single();

        roleData = DonaturModel.fromJson(profileResponse);
        print('Data Donatur: ${roleData.namaLengkap}');
      } else {
        return null;
      }

      if (roleData == null) {
        print('Tidak menemukan data profil untuk role: $roleName');
        return null;
      }

      // Perbarui baseUser dengan data desa jika ada
      final updatedBaseUser = BaseUserModel(
        id: baseUser.id,
        email: baseUser.email,
        roleId: baseUser.roleId,
        roleName: baseUser.roleName,
        createdAt: baseUser.createdAt,
        updatedAt: baseUser.updatedAt,
        desa: desa, // Set desa dari data yang diambil
      );

      // Simpan cache user data
      final userData = UserData(
        baseUser: updatedBaseUser,
        roleData: roleData,
      );
      _cachedUserData = userData;

      return userData;
    } catch (e) {
      print('Error pada signIn: $e');
      rethrow;
    }
  }

  // Metode untuk logout
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      _cachedUserData = null; // Hapus cache saat logout
    } catch (e) {
      rethrow;
    }
  }

  // Metode untuk mendaftarkan donatur (role_id 3)
  // Implementasi baru yang tidak memerlukan konfirmasi email
  Future<void> signUpDonatur({
    required String email,
    required String password,
    required String namaLengkap,
    required String alamat,
    required String noHp,
    String? jenis,
  }) async {
    try {
      print('DEBUG: Memulai proses registrasi donatur dengan email: $email');

      // Step 1: Daftarkan user tanpa metadata dulu
      // Karena mungkin ada masalah dengan kolom role_id custom
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Gagal membuat akun donatur');
      }

      print('DEBUG: User berhasil terdaftar dengan ID: ${user.id}');

      try {
        // Step 2: Buat data donatur di tabel donatur
        print('DEBUG: Mencoba menyimpan data donatur ke tabel donatur');

        final currentTime = DateTime.now().toIso8601String();

        // Data untuk tabel donatur
        final donaturData = {
          'id': user.id,
          'nama_lengkap': namaLengkap,
          'alamat': alamat,
          'no_hp': noHp,
          'email': email,
          'jenis': jenis ?? 'Individu',
          'created_at': currentTime,
          'updated_at': currentTime,
        };

        // Insert ke tabel donatur
        print('DEBUG: Inserting data to donatur table');
        await _supabaseService.client.from('donatur').insert(donaturData);
        print('DEBUG: Berhasil menyimpan data donatur');

        // Step 3: Coba update role_id user menggunakan service yang lebih aman
        print('DEBUG: Mencoba mengupdate role_id user');
        await _supabaseService.updateUserRole(user.id, 3);
      } catch (e) {
        print('ERROR: Gagal menyimpan data donatur: $e');
        throw Exception('Gagal menyimpan data donatur. Silakan coba lagi.');
      }

      print(
          'DEBUG: Berhasil mendaftarkan donatur: $namaLengkap dengan ID: ${user.id}');
    } catch (e) {
      print('ERROR: Error pada signUpDonatur: $e');

      if (e.toString().contains('User already registered')) {
        throw Exception(
            'Email sudah terdaftar. Silakan gunakan email lain atau login dengan email tersebut.');
      } else if (e.toString().contains('Database error saving new user')) {
        throw Exception(
            'Terjadi kesalahan saat menyimpan data pengguna. Silakan coba lagi atau hubungi administrator.');
      } else if (e.toString().contains('Error sending confirmation mail')) {
        print('===== PERHATIAN PENGEMBANG =====');
        print(
            'Error ini terjadi karena Supabase gagal mengirim email konfirmasi.');
        print(
            'Untuk mengatasi ini, nonaktifkan konfirmasi email di dashboard Supabase:');
        print(
            '1. Buka project Supabase > Authentication > Email Templates > Confirmation');
        print('2. Matikan toggle "Enable email confirmations"');
        print('==============================');
        throw Exception(
            'Gagal mengirim email konfirmasi. Mohon hubungi administrator.');
      } else {
        rethrow;
      }
    }
  }

  // Metode untuk mendapatkan user saat ini
  Future<UserData?> getCurrentUser({bool skipCache = false}) async {
    // Jika ada cache dan user masih terautentikasi, gunakan cache kecuali skipCache = true
    if (!skipCache &&
        _cachedUserData != null &&
        _supabaseService.isAuthenticated) {
      print('DEBUG: Menggunakan data user dari cache');
      return _cachedUserData;
    }

    if (_supabaseService.currentUser != null) {
      try {
        // Login berhasil, lakukan proses yang sama seperti di signIn
        // tapi dengan user yang sudah ada
        final user = _supabaseService.currentUser!;
        final userId = user.id;

        // Step 2: Ambil role dari view `users_with_roles` atau tabel roles
        String roleName;
        try {
          final roleResponse = await _supabaseService.client
              .from('users_with_roles')
              .select('role_name')
              .eq('id', userId)
              .single();

          roleName = roleResponse['role_name'];
        } catch (e) {
          print('Error mengambil role dari users_with_roles: $e');
          print('Mencoba ambil role dari tabel roles...');

          // Fallback ke cara lama jika view users_with_roles tidak tersedia
          try {
            // Ambil role_id dari user metadata
            final roleId = user.userMetadata?['role_id'];
            if (roleId == null) {
              print('Tidak ada role_id di user metadata');
              return null;
            }

            final roleResponse = await _supabaseService.client
                .from('roles')
                .select('role_name')
                .eq('id', roleId)
                .single();

            roleName = roleResponse['role_name'];
          } catch (e) {
            print('Error mengambil role dari tabel roles: $e');
            return null;
          }
        }

        print('Role: $roleName');

        // Step 3: Ambil profil user berdasarkan role
        Map<String, dynamic>? profileResponse;
        dynamic roleData;
        DesaModel? desa;

        // Buat BaseUserModel
        final baseUser = BaseUserModel(
          id: userId,
          email: user.email ?? '',
          roleId: user.userMetadata?['role_id'],
          roleName: roleName ?? '',
          createdAt: DateTime.parse(user.createdAt),
          updatedAt:
              user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
        );

        if ((roleName ?? '').toLowerCase() == 'warga') {
          profileResponse = await _supabaseService.client
              .from('warga')
              .select(
                  '*, desa:desa_id(id, nama, kecamatan, kabupaten, provinsi)')
              .eq('id', userId)
              .single();

          // Ekstrak data desa jika ada
          if (profileResponse['desa'] != null) {
            desa = DesaModel.fromJson(profileResponse['desa']);
            print('Data Desa: ${desa.nama}');
          }

          roleData = WargaModel.fromJson(profileResponse);
          print('Data Warga: ${roleData.namaLengkap}');
        } else if (roleName.toLowerCase() == 'petugas_desa') {
          profileResponse = await _supabaseService.client
              .from('petugas_desa')
              .select(
                  '*, desa:desa_id(id, nama, kecamatan, kabupaten, provinsi)')
              .eq('id', userId)
              .single();

          // Ekstrak data desa jika ada
          if (profileResponse['desa'] != null) {
            desa = DesaModel.fromJson(profileResponse['desa']);
            print('Data Desa: ${desa.nama}');
          }

          roleData = PetugasDesaModel.fromJson(profileResponse);
        } else if (roleName.toLowerCase() == 'donatur') {
          profileResponse = await _supabaseService.client
              .from('donatur')
              .select('*')
              .eq('id', userId)
              .single();

          roleData = DonaturModel.fromJson(profileResponse);
        }

        if (roleData == null) {
          print('Tidak menemukan data profil untuk role: $roleName');
          return null;
        }

        // Perbarui baseUser dengan data desa jika ada
        final updatedBaseUser = BaseUserModel(
          id: baseUser.id,
          email: baseUser.email,
          roleId: baseUser.roleId,
          roleName: baseUser.roleName,
          createdAt: baseUser.createdAt,
          updatedAt: baseUser.updatedAt,
          desa: desa, // Set desa dari data yang diambil
        );

        // Simpan cache user data
        final userData = UserData(
          baseUser: updatedBaseUser,
          roleData: roleData,
        );
        _cachedUserData = userData;

        return userData;
      } catch (e) {
        print('Error pada getCurrentUser: $e');
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

  // // Metode untuk membuat profil donatur
  // Future<void> createDonaturProfile({
  //   required String namaLengkap,
  //   String? instansi,
  //   String? jabatan,
  //   String? noHp,
  //   String? alamat,
  //   String? desaId,
  // }) async {
  //   await _supabaseService.createDonaturProfile(
  //     namaLengkap: namaLengkap,
  //     instansi: instansi,
  //     jabatan: jabatan,
  //     noHp: noHp,
  //     alamat: alamat,
  //     desaId: desaId,
  //   );

  //   // Invalidasi cache setelah membuat profil baru
  //   _cachedUserData = null;
  // }

  // // Metode untuk membuat profil petugas desa
  // Future<void> createPetugasDesaProfile({
  //   required String namaLengkap,
  //   String? nip,
  //   String? jabatan,
  //   String? noHp,
  //   String? alamat,
  //   String? desaId,
  // }) async {
  //   await _supabaseService.createPetugasDesaProfile(
  //     namaLengkap: namaLengkap,
  //     nip: nip,
  //     jabatan: jabatan,
  //     noHp: noHp,
  //     alamat: alamat,
  //     desaId: desaId,
  //   );

  //   // Invalidasi cache setelah membuat profil baru
  //   _cachedUserData = null;
  // }

  // Metode untuk mendapatkan notifikasi pengguna
  Future<List<Map<String, dynamic>>> getUserNotifications(
      {bool unreadOnly = false}) async {
    return await _supabaseService.getUserNotifications(unreadOnly: unreadOnly);
  }

  // Metode untuk menandai notifikasi sebagai telah dibaca
  Future<void> markNotificationAsRead(int notificationId) async {
    await _supabaseService.markNotificationAsRead(notificationId);
  }

  // Metode untuk reset password
  Future<void> resetPasswordForEmail(String email, {String? redirectTo}) async {
    await _supabaseService.client.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo,
    );
  }
}
