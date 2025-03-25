import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
import 'package:penyaluran_app/app/data/models/petugas_desa_model.dart';
import 'package:penyaluran_app/app/data/models/user_model.dart';
import 'package:penyaluran_app/app/data/models/warga_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find<SupabaseService>();

  late final SupabaseClient client;

  // Cache untuk profil pengguna
  Map<String, dynamic>? _cachedUserProfile;

  // Flag untuk menandai apakah sesi sudah diinisialisasi
  bool _isSessionInitialized = false;

  // Ganti dengan URL dan API key Supabase Anda
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL',
      defaultValue: 'http://labulabs.net:8000');
  static const String supabaseKey = String.fromEnvironment('SUPABASE_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzMxODYyODAwLAogICJleHAiOiAxODg5NjI5MjAwCn0.4IpwhwCVbfYXxb8JlZOLSBzCt6kQmypkvuso7N8Aicc');

  Future<SupabaseService> init() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
        debug: true, // Aktifkan debug untuk melihat log autentikasi
      );

      client = Supabase.instance.client;

      // Tambahkan listener untuk perubahan autentikasi
      client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        print('DEBUG: Auth state changed: $event');

        if (event == AuthChangeEvent.signedIn) {
          print('DEBUG: User signed in');
          _isSessionInitialized = true;
        } else if (event == AuthChangeEvent.signedOut) {
          print('DEBUG: User signed out');
          _cachedUserProfile = null;
          _isSessionInitialized = false;
        } else if (event == AuthChangeEvent.tokenRefreshed) {
          print('DEBUG: Token refreshed');
          _isSessionInitialized = true;
        }
      });

      // Periksa apakah ada sesi yang aktif
      final session = client.auth.currentSession;
      if (session != null) {
        print('DEBUG: Session aktif ditemukan saat inisialisasi');
        _isSessionInitialized = true;
      } else {
        print('DEBUG: Tidak ada session aktif saat inisialisasi');
      }

      return this;
    } catch (e) {
      print('ERROR: Gagal inisialisasi Supabase: $e');
      rethrow;
    }
  }

  // Metode untuk mendaftar pengguna baru
  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'autoconfirm': true},
    );
  }

  // Metode untuk logout
  Future<void> signOut() async {
    _cachedUserProfile = null; // Hapus cache saat logout
    _isSessionInitialized = false;
    await client.auth.signOut();
    print('DEBUG: Logout berhasil, sesi dihapus');
  }

  // Metode untuk mendapatkan user saat ini
  User? get currentUser => client.auth.currentUser;

  // Metode untuk memeriksa apakah user sudah login
  bool get isAuthenticated {
    final user = currentUser;
    final session = client.auth.currentSession;

    if (user != null && session != null) {
      // Periksa apakah token masih valid
      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      final isValid = session.expiresAt != null && session.expiresAt! > now;

      if (isValid) {
        print('DEBUG: Sesi valid, user terautentikasi');
        return true;
      } else {
        print('DEBUG: Sesi kedaluwarsa, user tidak terautentikasi');
        return false;
      }
    }

    print('DEBUG: Tidak ada user atau sesi, user tidak terautentikasi');
    return false;
  }

  // Metode untuk mendapatkan profil pengguna dasar
  Future<BaseUserModel?> getBaseUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      // Gunakan auth.getUser() daripada mengakses tabel auth.users
      final userData = await client.auth.getUser();

      print('userData: ${userData.user}');

      if (userData.user == null) {
        print('Tidak ada data user ditemukan');
        return null;
      }

      // Dapatkan role dari tabel khusus roles jika diperlukan
      String roleName = 'warga'; // default
      if (userData.user!.userMetadata?['role_id'] != null) {
        try {
          final roleResponse = await client
              .from('roles')
              .select('role_name')
              .eq('id', userData.user!.userMetadata!['role_id'])
              .maybeSingle();

          print('roleResponse: $roleResponse');

          if (roleResponse != null) {
            roleName = roleResponse['role_name'];
          }
        } catch (e) {
          print('Error saat mengambil role: $e');
          // Lanjutkan dengan role default jika gagal
        }
      }

      // Gabungkan data user dan role
      Map<String, dynamic> combinedData = {
        'id': userData.user!.id,
        'email': userData.user!.email,
        'created_at': userData.user!.createdAt,
        'updated_at': userData.user!.updatedAt,
        'role_id': userData.user!.userMetadata?['role_id'],
        'roles': {'role_name': roleName}
      };

      return BaseUserModel.fromJson(combinedData);
    } catch (e) {
      print('Error pada getBaseUserProfile: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan profil pengguna dengan data lengkap
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      // Jika cache profil tersedia, gunakan
      if (_cachedUserProfile != null) {
        return _cachedUserProfile;
      }

      // Jika tidak ada cache, ambil dari database
      final user = currentUser;
      if (user == null) {
        print('DEBUG: Tidak ada user yang login');
        return null;
      }

      final userId = user.id;

      // Debug info
      print('DEBUG: Mengambil data user profile untuk ID: $userId');

      // Ambil data role dari database
      final roleResponse = await client
          .from('users_with_roles')
          .select('role_name')
          .eq('id', userId)
          .maybeSingle();

      if (roleResponse == null) {
        print('DEBUG: Tidak menemukan role untuk user ID: $userId');
        return null;
      }

      final roleName = roleResponse['role_name'];
      print('DEBUG: Role name: $roleName');

      // Ambil data khusus untuk role tersebut
      Map<String, dynamic>? roleData;
      switch (roleName.toLowerCase()) {
        case 'warga':
          final wargaResponse = await client
              .from('warga')
              .select(
                  '*, desa:desa_id(id, nama, kecamatan, kabupaten, provinsi)')
              .eq('id', userId)
              .maybeSingle();
          roleData = wargaResponse;
          break;
        case 'petugas_desa':
          final petugasResponse = await client
              .from('petugas_desa')
              .select(
                  '*, desa:desa_id(id, nama, kecamatan, kabupaten, provinsi)')
              .eq('id', userId)
              .maybeSingle();
          roleData = petugasResponse;
          break;
        case 'donatur':
          final donaturResponse = await client
              .from('donatur')
              .select('*')
              .eq('id', userId)
              .maybeSingle();
          roleData = donaturResponse;
          break;
        default:
          print('DEBUG: Role tidak dikenali: $roleName');
          return null;
      }

      if (roleData == null) {
        print('DEBUG: Tidak menemukan data untuk role: $roleName');
        return null;
      }

      // Siapkan data kombinasi dari Supabase Auth + data dari tabel role
      final combinedData = {
        'id': userId,
        'email': user.email,
        'role': roleName,
        'created_at': user.createdAt,
        'updated_at': user.updatedAt,
        'role_data': roleData,
      };

      // Tambahkan nama dari data role jika ada berdasarkan role
      switch (roleName.toLowerCase()) {
        case 'warga':
          if (roleData['nama_lengkap'] != null) {
            combinedData['name'] = roleData['nama_lengkap'];
          }
          break;
        case 'petugas_desa':
        case 'donatur':
          if (roleData['nama'] != null) {
            combinedData['name'] = roleData['nama'];
          }
          break;
      }

      // Tambahkan data role-specific
      if (roleData != null) {
        combinedData['role_data'] = roleData;

        // Tambahkan data desa jika ada
        if (roleData['desa'] != null) {
          combinedData['desa'] = roleData['desa'];
        }

        // Tambahkan nama dari data role jika ada
        if (roleData['nama_lengkap'] != null) {
          combinedData['name'] = roleData['nama_lengkap'];
        }
      }

      // Cache profil untuk penggunaan berikutnya
      _cachedUserProfile = combinedData;
      print('combinedData: $combinedData');
      return combinedData;
    } catch (e) {
      print('Error pada getUserProfile: $e');
      return null;
    }
  }

  // Metode eksplisit untuk membersihkan cache profil
  void clearUserProfileCache() {
    print('DEBUG: Membersihkan cache profil pengguna');
    _cachedUserProfile = null;
  }

  // Metode untuk mendapatkan data warga
  Future<WargaModel?> getWargaProfile(String userId) async {
    try {
      final response = await client
          .from('warga')
          .select('*, desa:desa_id(id, nama, kecamatan, kabupaten, provinsi)')
          .eq('id', userId) // id di tabel warga = userId
          .maybeSingle();

      if (response == null) {
        print('Data warga tidak ditemukan');
        return null;
      }

      return WargaModel.fromJson(response);
    } catch (e) {
      print('Error pada getWargaProfile: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan data donatur
  Future<DonaturModel?> getDonaturProfile(String userId) async {
    try {
      final response = await client
          .from('donatur')
          .select('*')
          .eq('id', userId) // id di tabel donatur = userId
          .maybeSingle();

      if (response == null) {
        print('Data donatur tidak ditemukan');
        return null;
      }

      return DonaturModel.fromJson(response);
    } catch (e) {
      print('Error pada getDonaturProfile: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan data petugas desa
  Future<PetugasDesaModel?> getPetugasDesaProfile(String userId) async {
    try {
      final response = await client
          .from('petugas_desa')
          .select('*, desa:desa_id(id, nama, kecamatan, kabupaten, provinsi)')
          .eq('id', userId) // id di tabel petugas_desa = userId
          .maybeSingle();

      if (response == null) {
        print('Data petugas desa tidak ditemukan');
        return null;
      }

      return PetugasDesaModel.fromJson(response);
    } catch (e) {
      print('Error pada getPetugasDesaProfile: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan data user lengkap berdasarkan role
  // @deprecated Gunakan AuthProvider.getCurrentUser() sebagai gantinya
  // Metode ini dipertahankan untuk kompatibilitas mundur
  Future<UserData?> getUserData() async {
    print(
        'WARNING: Menggunakan metode getUserData() yang sudah deprecated. Gunakan AuthProvider.getCurrentUser() sebagai gantinya.');

    final baseUser = await getBaseUserProfile();
    if (baseUser == null) return null;

    try {
      switch (baseUser.roleName.toLowerCase()) {
        case 'warga':
          final wargaData = await getWargaProfile(baseUser.id);
          if (wargaData != null) {
            return UserData<WargaModel>(
              baseUser: baseUser,
              roleData: wargaData,
            );
          }
          break;
        case 'donatur':
          final donaturData = await getDonaturProfile(baseUser.id);
          if (donaturData != null) {
            return UserData<DonaturModel>(
              baseUser: baseUser,
              roleData: donaturData,
            );
          }
          break;
        case 'petugas_desa':
          final petugasDesaData = await getPetugasDesaProfile(baseUser.id);
          if (petugasDesaData != null) {
            return UserData<PetugasDesaModel>(
              baseUser: baseUser,
              roleData: petugasDesaData,
            );
          }
          break;
      }

      // Jika data role-specific tidak ditemukan
      print('Data spesifik tidak ditemukan untuk role: ${baseUser.roleName}');
      return null;
    } catch (e) {
      print('Error pada getUserData: $e');
      return null;
    }
  }

  // ==================== PETUGAS DESA METHODS ====================

  // Dashboard methods
  Future<int?> getTotalPenerima() async {
    try {
      final response =
          await client.from('warga').select('id').eq('status', 'AKTIF');

      return response.length;
    } catch (e) {
      print('Error getting total penerima: $e');
      return null;
    }
  }

  Future<int?> getTotalBantuan() async {
    try {
      final response = await client.from('stok_bantuan').select('jumlah');

      double total = 0;
      for (var item in response) {
        total += (item['jumlah'] ?? 0);
      }

      return total.toInt();
    } catch (e) {
      print('Error getting total bantuan: $e');
      return null;
    }
  }

  Future<int?> getTotalPenyaluran() async {
    try {
      final response = await client
          .from('penyaluran_bantuan')
          .select('id')
          .eq('status', 'TERLAKSANA');

      return response.length;
    } catch (e) {
      print('Error getting total penyaluran: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getNotifikasiBelumDibaca(
      String userId) async {
    try {
      // Notifikasi masih menggunakan user_id karena tabelnya terpisah
      final response = await client
          .from('notifikasi')
          .select('*')
          .eq('user_id', userId)
          .eq('dibaca', false)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      print('Error getting notifikasi belum dibaca: $e');
      return null;
    }
  }

  // Jadwal penyaluran methods
  Future<List<Map<String, dynamic>>?> getJadwalHariIni() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      // Konversi ke UTC untuk query ke database
      final todayUtc = today.toUtc().toIso8601String();
      final tomorrowUtc = tomorrow.toUtc().toIso8601String();

      final response = await client
          .from('penyaluran_bantuan')
          .select('*')
          .gte('tanggal_penyaluran', todayUtc)
          .lt('tanggal_penyaluran', tomorrowUtc)
          .inFilter('status', ['AKTIF', 'DIJADWALKAN']);

      print("hari ini $response");

      return response;
    } catch (e) {
      print('Error getting jadwal hari ini: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getJadwalMendatang() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final week = today.add(const Duration(days: 7));

      // Konversi ke UTC untuk query ke database
      final tomorrowUtc = tomorrow.toUtc().toIso8601String();
      final weekUtc = week.toUtc().toIso8601String();

      final response = await client
          .from('penyaluran_bantuan')
          .select('*')
          .gte('tanggal_penyaluran', tomorrowUtc)
          .lt('tanggal_penyaluran', weekUtc)
          .inFilter('status', ['DIJADWALKAN']);

      return response;
    } catch (e) {
      print('Error getting jadwal mendatang: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getJadwalTerlaksana() async {
    try {
      final response = await client
          .from('penyaluran_bantuan')
          .select('*')
          .inFilter('status', ['TERLAKSANA', 'BATALTERLAKSANA']).order(
              'tanggal_penyaluran',
              ascending: false);

      return response;
    } catch (e) {
      print('Error getting jadwal selesai: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getPermintaanPenjadwalan() async {
    try {
      final response = await client
          .from('penyaluran_bantuan')
          .select('*')
          .eq('status', 'DIJADWALKAN');

      return response;
    } catch (e) {
      print('Error getting permintaan penjadwalan: $e');
      return null;
    }
  }

  Future<void> approveJadwal(String jadwalId) async {
    try {
      await client.from('penyaluran_bantuan').update({
        'status': 'AKTIF',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', jadwalId);
    } catch (e) {
      print('Error approving jadwal: $e');
      throw e.toString();
    }
  }

  Future<void> rejectJadwal(String jadwalId, String alasan) async {
    try {
      await client.from('penyaluran_bantuan').update({
        'status': 'BATALTERLAKSANA',
        'alasan_penolakan': alasan,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', jadwalId);
    } catch (e) {
      print('Error rejecting jadwal: $e');
      throw e.toString();
    }
  }

  Future<void> completeJadwal(String jadwalId) async {
    try {
      await client.from('penyaluran_bantuan').update({
        'status': 'TERLAKSANA',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', jadwalId);
    } catch (e) {
      print('Error completing jadwal: $e');
      throw e.toString();
    }
  }

  // Metode untuk memperbarui status jadwal
  Future<void> updateJadwalStatus(String jadwalId, String status) async {
    try {
      await client.from('penyaluran_bantuan').update({
        'status': status,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', jadwalId);
    } catch (e) {
      print('Error updating jadwal status: $e');
      throw e.toString();
    }
  }

  // Stok bantuan methods
  Future<List<Map<String, dynamic>>?> getStokBantuan() async {
    try {
      final response = await client
          .from('stok_bantuan')
          .select('*, kategori_bantuan:kategori_bantuan_id(*, nama)');

      return response;
    } catch (e) {
      print('Error getting stok bantuan: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStokStatistics() async {
    try {
      // Get stok masuk
      final masukResponse = await client.from('stok_bantuan').select('jumlah');

      double masuk = 0;
      for (var item in masukResponse) {
        masuk += (item['jumlah'] ?? 0);
      }

      // Get stok keluar
      final keluarResponse =
          await client.from('detail_penyaluran').select('jumlah');

      double keluar = 0;
      for (var item in keluarResponse) {
        keluar += (item['jumlah'] ?? 0);
      }

      return {
        'masuk': masuk,
        'keluar': keluar,
      };
    } catch (e) {
      print('Error getting stok statistics: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getBentukBantuan() async {
    try {
      final response = await client.from('bentuk_bantuan').select('*');
      return response;
    } catch (e) {
      print('Error getting bentuk bantuan: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getKategoriBantuan() async {
    try {
      final response = await client.from('kategori_bantuan').select('*');
      return response;
    } catch (e) {
      print('Error getting kategori bantuan: $e');
      return null;
    }
  }

  Future<void> addStok(Map<String, dynamic> stokData) async {
    try {
      print('stokData: $stokData');
      // Hapus id dari stokData jika ada, biarkan Supabase yang menghasilkan id
      if (stokData.containsKey('id')) {
        stokData.remove('id');
      }
      await client.from('stok_bantuan').insert(stokData);
    } catch (e) {
      print('Error adding stok: $e');
      throw e.toString();
    }
  }

  Future<void> updateStok(String stokId, Map<String, dynamic> stok) async {
    try {
      await client.from('stok_bantuan').update(stok).eq('id', stokId);
    } catch (e) {
      print('Error updating stok: $e');
      throw e.toString();
    }
  }

  Future<void> deleteStok(String stokId) async {
    try {
      await client.from('stok_bantuan').delete().eq('id', stokId);
    } catch (e) {
      print('Error deleting stok: $e');
      throw e.toString();
    }
  }

  // Penitipan bantuan methods
  Future<List<Map<String, dynamic>>?> getPenitipanBantuan() async {
    try {
      final response = await client
          .from('penitipan_bantuan')
          .select('*, donatur(*), stok_bantuan:stok_bantuan_id(*)')
          .order('tanggal_penitipan', ascending: false);

      return response;
    } catch (e) {
      print('Error getting penitipan bantuan: $e');
      return null;
    }
  }

  // Metode untuk mengambil data penitipan bantuan dengan status TERVERIFIKASI
  Future<List<Map<String, dynamic>>?> getPenitipanBantuanTerverifikasi() async {
    try {
      final response = await client
          .from('penitipan_bantuan')
          .select('*, donatur(*), stok_bantuan:stok_bantuan_id(*)')
          .eq('status', 'TERVERIFIKASI')
          .order('tanggal_penitipan', ascending: false);

      return response;
    } catch (e) {
      print('Error getting penitipan bantuan terverifikasi: $e');
      return null;
    }
  }

  // Upload file methods
  Future<String?> uploadFile(
      String filePath, String bucket, String folder) async {
    try {
      final fileName = filePath.split('/').last;
      final fileExt = fileName.split('.').last;
      final fileKey =
          '$folder/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await client.storage.from(bucket).upload(
            fileKey,
            File(filePath),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final fileUrl = client.storage.from(bucket).getPublicUrl(fileKey);
      print('File uploaded: $fileUrl');
      return fileUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<List<String>?> uploadMultipleFiles(
      List<String> filePaths, String bucket, String folder) async {
    try {
      final List<String> fileUrls = [];

      for (final filePath in filePaths) {
        final fileUrl = await uploadFile(filePath, bucket, folder);
        if (fileUrl != null) {
          fileUrls.add(fileUrl);
        }
      }

      return fileUrls;
    } catch (e) {
      print('Error uploading multiple files: $e');
      return null;
    }
  }

  Future<void> verifikasiPenitipan(
      String penitipanId, String fotoBuktiSerahTerimaPath) async {
    try {
      // Upload bukti serah terima
      final fotoBuktiSerahTerimaUrl = await uploadFile(
          fotoBuktiSerahTerimaPath, 'bantuan', 'foto_bukti_serah_terima');

      if (fotoBuktiSerahTerimaUrl == null) {
        throw 'Gagal mengupload bukti serah terima';
      }

      final petugasDesaId = client.auth.currentUser?.id;
      print(
          'Verifikasi penitipan dengan ID: $penitipanId oleh petugas desa ID: $petugasDesaId');

      final updateData = {
        'status': 'TERVERIFIKASI',
        'tanggal_verifikasi': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'foto_bukti_serah_terima': fotoBuktiSerahTerimaUrl,
        'petugas_desa_id': petugasDesaId,
      };

      print('Data yang akan diupdate: $updateData');

      await client
          .from('penitipan_bantuan')
          .update(updateData)
          .eq('id', penitipanId);

      print('Penitipan berhasil diverifikasi dan data petugas desa disimpan');
    } catch (e) {
      print('Error verifying penitipan: $e');
      throw e.toString();
    }
  }

  Future<void> tolakPenitipan(String penitipanId, String alasan) async {
    try {
      await client.from('penitipan_bantuan').update({
        'status': 'DITOLAK',
        'alasan_penolakan': alasan,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', penitipanId);
    } catch (e) {
      print('Error rejecting penitipan: $e');
      throw e.toString();
    }
  }

  // Metode untuk menambahkan penitipan bantuan baru
  Future<void> tambahPenitipanBantuan({
    required String stokBantuanId,
    required double jumlah,
    required String deskripsi,
    required List<String> fotoBantuanPaths,
    String? donaturId,
    bool isUang = false,
  }) async {
    try {
      final petugasDesaId = client.auth.currentUser?.id;
      if (petugasDesaId == null) {
        throw 'User tidak ditemukan';
      }

      // Upload foto bantuan
      final fotoBantuanUrls = await uploadMultipleFiles(
          fotoBantuanPaths, 'bantuan', 'foto_bantuan');

      if (fotoBantuanUrls == null || fotoBantuanUrls.isEmpty) {
        throw 'Gagal mengupload foto bantuan';
      }

      // Data penitipan
      final penitipanData = {
        'stok_bantuan_id': stokBantuanId,
        'jumlah': jumlah,
        'deskripsi': deskripsi,
        'status':
            'TERVERIFIKASI', // Langsung terverifikasi karena diinput oleh petugas desa
        'foto_bantuan': fotoBantuanUrls,
        'tanggal_penitipan': DateTime.now().toIso8601String(),
        'tanggal_verifikasi': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'petugas_desa_id': petugasDesaId,
        'is_uang': isUang,
      };

      // Tambahkan donatur_id jika ada
      if (donaturId != null && donaturId.isNotEmpty) {
        penitipanData['donatur_id'] = donaturId;
      }

      await client.from('penitipan_bantuan').insert(penitipanData);
    } catch (e) {
      print('Error adding penitipan bantuan: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>?> getDonaturById(String donaturId) async {
    try {
      final response =
          await client.from('donatur').select('*').eq('id', donaturId).single();

      return response;
    } catch (e) {
      print('Error getting donatur by id: $e');
      return null;
    }
  }

  // Metode untuk mencari donatur berdasarkan keyword
  Future<List<Map<String, dynamic>>?> searchDonatur(String keyword) async {
    try {
      if (keyword.length < 3) {
        return [];
      }

      final response = await client
          .from('donatur')
          .select('*')
          .ilike('nama', '%$keyword%')
          .limit(10);

      return response;
    } catch (e) {
      print('Error searching donatur: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan daftar donatur
  Future<List<Map<String, dynamic>>?> getDaftarDonatur() async {
    try {
      final response = await client
          .from('donatur')
          .select('*')
          .order('nama_lengkap', ascending: true);

      return response;
    } catch (e) {
      print('Error getting daftar donatur: $e');
      return null;
    }
  }

  // Metode untuk menambahkan donatur baru
  Future<String?> tambahDonatur(Map<String, dynamic> donaturData) async {
    try {
      // Pastikan field nama_lengkap ada di donaturData
      if (donaturData.containsKey('nama')) {
        donaturData['nama_lengkap'] = donaturData['nama'];
        donaturData.remove('nama');
      }

      final response =
          await client.from('donatur').insert(donaturData).select('id');
      if (response.isNotEmpty) {
        return response[0]['id'];
      }
      return null;
    } catch (e) {
      print('Error adding donatur: $e');
      throw e.toString();
    }
  }

  // Pengaduan methods
  Future<List<Map<String, dynamic>>?> getPengaduan() async {
    try {
      final response = await client.from('pengaduan').select('*');

      return response;
    } catch (e) {
      print('Error getting pengaduan: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan pengaduan dengan detail penerima penyaluran
  Future<List<Map<String, dynamic>>?>
      getPengaduanWithPenerimaPenyaluran() async {
    try {
      final response = await client.from('pengaduan').select('''
            *,
            penerima_penyaluran:penerima_penyaluran_id(
              *,
              penyaluran_bantuan:penyaluran_bantuan_id(*),
              stok_bantuan:stok_bantuan_id(*),
              warga:warga_id(*)
            ),
            warga:warga_id(*)
          ''').order('created_at', ascending: false);

      return response;
    } catch (e) {
      print('Error getting pengaduan with penerima penyaluran: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan pengaduan warga tertentu dengan detail penerima penyaluran
  Future<List<Map<String, dynamic>>?> getPengaduanWargaWithPenerimaPenyaluran(
      String wargaId) async {
    try {
      final response = await client.from('pengaduan').select('''
            *,
            penerima_penyaluran:penerima_penyaluran_id(
              *,
              penyaluran_bantuan:penyaluran_bantuan_id(*),
              stok_bantuan:stok_bantuan_id(*),
              warga:warga_id(*)
            ),
            warga:warga_id(*)
          ''').eq('warga_id', wargaId).order('created_at', ascending: false);

      return response;
    } catch (e) {
      print('Error getting warga pengaduan with penerima penyaluran: $e');
      return null;
    }
  }

  Future<void> prosesPengaduan(String pengaduanId) async {
    try {
      await client.from('pengaduan').update({
        'status': 'DIPROSES',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', pengaduanId);
    } catch (e) {
      print('Error processing pengaduan: $e');
      throw e.toString();
    }
  }

  Future<void> tambahTindakanPengaduan(Map<String, dynamic> tindakan) async {
    try {
      await client.from('tindakan_pengaduan').insert(tindakan);
    } catch (e) {
      print('Error adding tindakan pengaduan: $e');
      throw e.toString();
    }
  }

  Future<void> updateTindakanPengaduan(
      String tindakanId, Map<String, dynamic> tindakan) async {
    try {
      await client
          .from('tindakan_pengaduan')
          .update(tindakan)
          .eq('id', tindakanId);
    } catch (e) {
      print('Error updating tindakan pengaduan: $e');
      throw e.toString();
    }
  }

  Future<void> updateStatusPengaduan(String pengaduanId, String status) async {
    try {
      await client.from('pengaduan').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', pengaduanId);
    } catch (e) {
      print('Error updating status pengaduan: $e');
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>?> getTindakanPengaduan(
      String pengaduanId) async {
    try {
      final response = await client
          .from('tindakan_pengaduan')
          .select('''
            *,
            petugas:petugas_id(id, nama_lengkap, nip),
            verifikator:verifikator_id(id, nama_lengkap, nip)
          ''')
          .eq('pengaduan_id', pengaduanId)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      print('Error getting tindakan pengaduan: $e');
      return null;
    }
  }

  // Metode untuk menambahkan feedback dan rating pengaduan
  Future<void> addPengaduanFeedback(
      String pengaduanId, String feedback, int rating) async {
    try {
      await client.from('pengaduan').update({
        'feedback_warga': feedback,
        'rating_warga': rating,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', pengaduanId);
    } catch (e) {
      print('Error adding pengaduan feedback: $e');
      throw e.toString();
    }
  }

  // Metode untuk memperbarui feedback dan rating pengaduan
  Future<void> updatePengaduanFeedback(
      String pengaduanId, String feedback, int rating) async {
    try {
      await client.from('pengaduan').update({
        'feedback_warga': feedback,
        'rating_warga': rating,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', pengaduanId);
    } catch (e) {
      print('Error updating pengaduan feedback: $e');
      throw e.toString();
    }
  }

  // Penerima bantuan methods
  Future<List<Map<String, dynamic>>?> getPenerimaBantuan() async {
    try {
      final response = await client.from('warga').select('*');

      return response;
    } catch (e) {
      print('Error getting penerima bantuan: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan data penyaluran bantuan berdasarkan ID warga
  Future<List<Map<String, dynamic>>?> getPenyaluranBantuanByWargaId(
      String wargaId) async {
    try {
      final response = await client
          .from('penyaluran_bantuan')
          .select('*, stok_bantuan:stok_bantuan_id(*)')
          .eq('penerima_id', wargaId)
          .order('tanggal_penyaluran', ascending: false);

      return response;
    } catch (e) {
      print('Error getting penyaluran bantuan by warga id: $e');
      return null;
    }
  }

  Future<void> tambahPenerima(Map<String, dynamic> penerima) async {
    try {
      await client.from('warga').insert(penerima);
    } catch (e) {
      print('Error adding penerima: $e');
      throw e.toString();
    }
  }

  Future<void> updatePenerima(
      String penerimaId, Map<String, dynamic> penerima) async {
    try {
      await client.from('warga').update(penerima).eq('id', penerimaId);
    } catch (e) {
      print('Error updating penerima: $e');
      throw e.toString();
    }
  }

  Future<void> updateStatusPenerima(String penerimaId, String status) async {
    try {
      await client.from('warga').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', penerimaId);
    } catch (e) {
      print('Error updating status penerima: $e');
      throw e.toString();
    }
  }

  // Laporan methods
  Future<List<Map<String, dynamic>>?> getLaporan(
      DateTime? tanggalMulai, DateTime? tanggalSelesai) async {
    try {
      var query = client.from('laporan').select('*');

      if (tanggalMulai != null) {
        query = query.gte('created_at', tanggalMulai.toIso8601String());
      }

      if (tanggalSelesai != null) {
        query = query.lte('created_at', tanggalSelesai.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);

      return response;
    } catch (e) {
      print('Error getting laporan: $e');
      return null;
    }
  }

  Future<String?> generateLaporan(Map<String, dynamic> laporan) async {
    try {
      final response = await client.from('laporan').insert(laporan);

      return response[0]['id'];
    } catch (e) {
      print('Error generating laporan: $e');
      throw e.toString();
    }
  }

  Future<String?> downloadLaporan(String laporanId) async {
    try {
      final response = await client
          .from('laporan')
          .select('file_urls')
          .eq('id', laporanId)
          .single();

      final fileUrls = response['file_urls'];
      if (fileUrls != null && fileUrls.isNotEmpty) {
        return fileUrls[0];
      }

      return null;
    } catch (e) {
      print('Error downloading laporan: $e');
      return null;
    }
  }

  Future<void> deleteLaporan(String laporanId) async {
    try {
      await client.from('laporan').delete().eq('id', laporanId);
    } catch (e) {
      print('Error deleting laporan: $e');
      throw e.toString();
    }
  }

  // Metode untuk mendapatkan data warga berdasarkan user ID
  Future<Map<String, dynamic>?> getWargaByUserId() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await client
          .from('warga')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error getting warga data: $e');
      return null;
    }
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
    try {
      final user = currentUser;
      if (user == null) throw 'User tidak ditemukan';

      // Dapatkan role_id untuk warga
      final roleResponse = await client
          .from('roles')
          .select('id')
          .eq('role_name', 'warga')
          .single();

      if (roleResponse == null) {
        throw 'Role warga tidak ditemukan';
      }

      final roleId = roleResponse['id'];

      // Update role_id di auth.users
      await client
          .from('auth.users')
          .update({'role_id': roleId}).eq('id', user.id);

      // Buat profil warga
      await client.from('warga').insert({
        'id': user.id, // Gunakan id dari auth.users sebagai id di tabel warga
        'nik': nik,
        'nama_lengkap': namaLengkap,
        'jenis_kelamin': jenisKelamin,
        'no_hp': noHp,
        'alamat': alamat,
        'tempat_lahir': tempatLahir,
        'tanggal_lahir': tanggalLahir?.toIso8601String(),
        'agama': agama,
        'status': 'MENUNGGU_VERIFIKASI',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating warga profile: $e');
      throw e.toString();
    }
  }

  // Metode untuk membuat profil donatur
  Future<void> createDonaturProfile({
    required String nama_lengkap,
    String? alamat,
    String? noHp,
    String? email,
    String? jenis,
    String? deskripsi,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw 'User tidak ditemukan';

      // Dapatkan role_id untuk donatur
      final roleResponse = await client
          .from('roles')
          .select('id')
          .eq('role_name', 'donatur')
          .single();

      if (roleResponse == null) {
        throw 'Role donatur tidak ditemukan';
      }

      final roleId = roleResponse['id'];

      // Update role_id di auth.users
      await client
          .from('auth.users')
          .update({'role_id': roleId}).eq('id', user.id);

      // Buat profil donatur
      await client.from('donatur').insert({
        'id': user.id, // Gunakan id dari auth.users sebagai id di tabel donatur
        'nama_lengkap': nama_lengkap,
        'alamat': alamat,
        'no_hp': noHp,
        'email': email,
        'jenis': jenis,
        'deskripsi': deskripsi,
        'status': 'AKTIF',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating donatur profile: $e');
      throw e.toString();
    }
  }

  // Metode untuk membuat profil petugas desa
  Future<void> createPetugasDesaProfile({
    required String nama_lengkap,
    String? alamat,
    String? noHp,
    String? email,
    String? jabatan,
    String? nip,
    required String desa_id,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw 'User tidak ditemukan';

      // Dapatkan role_id untuk petugas desa
      final roleResponse = await client
          .from('roles')
          .select('id')
          .eq('role_name', 'petugas_desa')
          .single();

      if (roleResponse == null) {
        throw 'Role petugas desa tidak ditemukan';
      }

      final roleId = roleResponse['id'];

      // Update role_id di auth.users
      await client
          .from('auth.users')
          .update({'role_id': roleId}).eq('id', user.id);

      // Buat profil petugas desa
      await client.from('petugas_desa').insert({
        'id': user
            .id, // Gunakan id dari auth.users sebagai id di tabel petugas_desa
        'nama_lengkap': nama_lengkap,
        'alamat': alamat,
        'no_hp': noHp,
        'email': email,
        'jabatan': jabatan,
        'nip': nip,
        'desa_id': desa_id,
        'status': 'AKTIF',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating petugas desa profile: $e');
      throw e.toString();
    }
  }

  // Metode untuk mendapatkan notifikasi pengguna
  Future<List<Map<String, dynamic>>> getUserNotifications(
      {bool unreadOnly = false}) async {
    try {
      final user = currentUser;
      if (user == null) return [];

      // Notifikasi masih menggunakan user_id karena tabelnya terpisah
      final query = unreadOnly
          ? client
              .from('notifikasi')
              .select('*')
              .eq('user_id', user.id)
              .eq('dibaca', false)
              .order('created_at', ascending: false)
          : client
              .from('notifikasi')
              .select('*')
              .eq('user_id', user.id)
              .order('created_at', ascending: false);

      final response = await query;
      return response;
    } catch (e) {
      print('Error getting user notifications: $e');
      return [];
    }
  }

  // Metode untuk menandai notifikasi sebagai telah dibaca
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await client.from('notifikasi').update({
        'dibaca': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
      throw e.toString();
    }
  }

  // Metode untuk mendapatkan informasi petugas desa berdasarkan ID
  Future<Map<String, dynamic>?> getPetugasDesaById(String petugasDesaId) async {
    try {
      print('Mengambil data petugas desa dengan ID: $petugasDesaId');

      // Gunakan tabel petugas_desa sebagai pengganti user_profile
      final response = await client
          .from('petugas_desa')
          .select('*, desa:desa_id(id, nama, kecamatan, kabupaten, provinsi)')
          .eq('id', petugasDesaId)
          .maybeSingle();

      print('Response: $response');

      if (response != null) {
        print('Berhasil mendapatkan data petugas desa: $response');
        return response;
      }

      print('Data petugas desa tidak ditemukan untuk ID: $petugasDesaId');
      return null;
    } catch (e) {
      print('Error getting petugas desa by ID: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan semua lokasi penyaluran
  Future<List<Map<String, dynamic>>?> getAllLokasiPenyaluran() async {
    try {
      final response = await client.from('lokasi_penyaluran').select('*');
      return response;
    } catch (e) {
      print('Error getting all lokasi penyaluran: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan daftar penerima penyaluran berdasarkan ID penyaluran
  Future<List<Map<String, dynamic>>?> getPenerimaPenyaluran(
      String penyaluranId) async {
    // Metode ini tidak lagi mengambil data dari database
    // Gunakan data dummy dari controller
    return [];
  }

  // Metode untuk memperbarui status penerimaan bantuan
  Future<bool> updateStatusPenerimaan(int penerimaId, String status,
      {DateTime? tanggalPenerimaan,
      String? buktiPenerimaan,
      String? keterangan}) async {
    try {
      final Map<String, dynamic> updateData = {
        'status_penerimaan': status,
      };

      if (tanggalPenerimaan != null) {
        updateData['tanggal_penerimaan'] = tanggalPenerimaan.toIso8601String();
      }

      if (buktiPenerimaan != null) {
        updateData['bukti_penerimaan'] = buktiPenerimaan;
      }

      if (keterangan != null) {
        updateData['keterangan'] = keterangan;
      }

      await client
          .from('penerima_penyaluran')
          .update(updateData)
          .eq('id', penerimaId);

      return true;
    } catch (e) {
      print('Error updating status penerimaan: $e');
      return false;
    }
  }

  // Metode untuk mendapatkan semua kategori bantuan
  Future<List<Map<String, dynamic>>?> getAllKategoriBantuan() async {
    try {
      final response = await client
          .from('kategori_bantuan')
          .select('*')
          .order('nama', ascending: true);
      return response;
    } catch (e) {
      print('Error getting all kategori bantuan: $e');
      return null;
    }
  }

  // Metode untuk memeriksa koneksi ke Supabase
  Future<bool> checkConnection() async {
    try {
      print('DEBUG SERVICE: Memeriksa koneksi ke Supabase...');

      // Coba melakukan query sederhana
      final response =
          await client.from('penerima_penyaluran').select('count').limit(1);

      print('DEBUG SERVICE: Koneksi berhasil, response: $response');
      return true;
    } catch (e) {
      print('DEBUG SERVICE: Error saat memeriksa koneksi: $e');
      return false;
    }
  }

  // Metode untuk mendapatkan data warga berdasarkan ID
  Future<Map<String, dynamic>?> getWargaById(String wargaId) async {
    // Metode ini tidak lagi mengambil data dari database
    // Gunakan data dummy
    return {
      'id': wargaId,
      'nama_lengkap': 'Warga Dummy',
      'nik': '1234567890123456',
      'alamat': 'Alamat Dummy',
      'jenis_kelamin': 'L',
      'tanggal_lahir': '1990-01-01',
    };
  }

  // Metode untuk mencetak struktur data ke konsol
  void printDataStructure(dynamic data, {String prefix = ''}) {
    if (data == null) {
      print('$prefix Data: null');
      return;
    }

    if (data is List) {
      print('$prefix Data adalah List dengan ${data.length} item');
      if (data.isNotEmpty) {
        print('$prefix Contoh item pertama:');
        printDataStructure(data.first, prefix: '$prefix  ');
      }
      return;
    }

    if (data is Map<String, dynamic>) {
      print(
          '$prefix Data adalah Map dengan keys: ${data.keys.toList().join(', ')}');

      // Cek apakah ada key warga
      if (data.containsKey('warga')) {
        print('$prefix Data memiliki key "warga"');
        print('$prefix Tipe data warga: ${data['warga'].runtimeType}');
        printDataStructure(data['warga'], prefix: '$prefix  warga: ');
      }

      // Cek apakah ada key warga_id
      if (data.containsKey('warga_id')) {
        print('$prefix Data memiliki key "warga_id": ${data['warga_id']}');
      }

      return;
    }

    // Tipe data lainnya
    print('$prefix Data: $data (${data.runtimeType})');
  }

  // Fungsi untuk menambahkan penyaluran baru
  Future<Map<String, dynamic>> tambahPenyaluran(
      Map<String, dynamic> penyaluran) async {
    try {
      final response = await client
          .from('penyaluran_bantuan')
          .insert(penyaluran)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error menambahkan penyaluran: $e');
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>?> getAllSkemaBantuan() async {
    try {
      final response = await client
          .from('xx02_skema_bantuan')
          .select('*')
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      print('Error getting all skema bantuan: $e');
      return null;
    }
  }

  // Metode untuk update profil warga
  Future<void> updateWargaProfile({
    required String userId,
    required String namaLengkap,
    required String email,
    String? noHp,
    String? fotoProfil,
  }) async {
    try {
      // Buat map untuk update data
      final Map<String, dynamic> updateData = {
        'nama_lengkap': namaLengkap,
        'no_hp': noHp,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Tambahkan foto profil jika ada
      if (fotoProfil != null) {
        updateData['foto_profil'] = fotoProfil;
      }

      // Update data warga
      await client.from('warga').update(updateData).eq('id', userId);

      // Update email di auth.users jika berubah
      if (email != client.auth.currentUser?.email) {
        // Gunakan metode updateUserEmail
        await client.auth.updateUser(UserAttributes(
          email: email,
        ));
      }
    } catch (e) {
      print('Error updating warga profile: $e');
      throw e.toString();
    }
  }

  // Metode untuk memperbarui profil donatur
  Future<void> updateDonaturProfile({
    required String userId,
    required String nama,
    required String email,
    String? noHp,
    String? fotoProfil,
  }) async {
    try {
      // Buat map untuk update data
      final Map<String, dynamic> updateData = {
        'nama': nama,
        'nama_lengkap': nama, // Untuk konsistensi dengan field nama_lengkap
        'no_hp': noHp,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Tambahkan foto profil jika ada
      if (fotoProfil != null) {
        updateData['foto_profil'] = fotoProfil;
      }

      // Update data donatur
      await client.from('donatur').update(updateData).eq('id', userId);

      // Update email di auth.users jika berubah
      if (email != client.auth.currentUser?.email) {
        // Gunakan metode updateUserEmail
        await client.auth.updateUser(UserAttributes(
          email: email,
        ));
      }
    } catch (e) {
      print('Error updating donatur profile: $e');
      throw e.toString();
    }
  }

  // Metode untuk memperbarui profil petugas desa
  Future<void> updatePetugasDesaProfile({
    required String userId,
    required String nama,
    required String email,
    String? noHp,
    String? fotoProfil,
  }) async {
    try {
      // Buat map untuk update data
      final Map<String, dynamic> updateData = {
        'nama_lengkap': nama, // Untuk konsistensi dengan field nama_lengkap
        'no_hp': noHp,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Tambahkan foto profil jika ada
      if (fotoProfil != null) {
        updateData['foto_profil'] = fotoProfil;
      }

      // Update data petugas desa
      await client.from('petugas_desa').update(updateData).eq('id', userId);

      // Update email di auth.users jika berubah
      if (email != client.auth.currentUser?.email) {
        // Gunakan metode updateUserEmail
        await client.auth.updateUser(UserAttributes(
          email: email,
        ));
      }
    } catch (e) {
      print('Error updating petugas desa profile: $e');
      throw e.toString();
    }
  }

  // Metode untuk ganti password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      await client.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } catch (e) {
      print('Error changing password: $e');
      throw e.toString();
    }
  }
}
