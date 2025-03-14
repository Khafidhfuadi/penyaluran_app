import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';

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

  // Metode untuk login
  Future<AuthResponse> signIn(String email, String password) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      _isSessionInitialized = true;
      print('DEBUG: Login berhasil, sesi diinisialisasi');
    }

    return response;
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

  // Metode untuk mendapatkan profil pengguna
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      // Gunakan cache jika tersedia
      if (_cachedUserProfile != null && _cachedUserProfile!['id'] == user.id) {
        print('Menggunakan data profil dari cache');
        return _cachedUserProfile;
      }

      final response = await client
          .from('user_profile')
          .select('*, desa:desa_id(id, nama, kecamatan, kabupaten, provinsi)')
          .eq('id', user.id)
          .maybeSingle();
      print('response: $response');

      // Simpan ke cache
      _cachedUserProfile = response;

      // Log untuk debugging
      if (response != null && response['desa'] != null) {
        print('Desa data: ${response['desa']}');
        print('Desa type: ${response['desa'].runtimeType}');
      }

      return response;
    } catch (e) {
      print('Error pada getUserProfile: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan role pengguna
  Future<String?> getUserRole() async {
    final profile = await getUserProfile();
    return profile?['role'];
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
          .eq('status', 'SELESAI');

      return response.length;
    } catch (e) {
      print('Error getting total penyaluran: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getNotifikasiBelumDibaca(
      String userId) async {
    try {
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
          .eq('status', 'TERLAKSANA')
          .order('tanggal_penyaluran', ascending: false)
          .limit(10);

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
          .eq('status', 'MENUNGGU');

      return response;
    } catch (e) {
      print('Error getting permintaan penjadwalan: $e');
      return null;
    }
  }

  Future<void> approveJadwal(String jadwalId) async {
    try {
      await client.from('penyaluran_bantuan').update({
        'status': 'DISETUJUI',
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
        'status': 'DITOLAK',
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
        'status': 'SELESAI',
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
          .select('*, donatur:donatur_id(*), stok_bantuan:stok_bantuan_id(*)')
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
          .select('*, donatur:donatur_id(*), stok_bantuan:stok_bantuan_id(*)')
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

      final file = await client.storage.from(bucket).upload(
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
          .order('nama', ascending: true);

      return response;
    } catch (e) {
      print('Error getting daftar donatur: $e');
      return null;
    }
  }

  // Metode untuk menambahkan donatur baru
  Future<String?> tambahDonatur(Map<String, dynamic> donaturData) async {
    try {
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
          .select('*')
          .eq('pengaduan_id', pengaduanId)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      print('Error getting tindakan pengaduan: $e');
      return null;
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
          .eq('user_id', user.id)
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

      await client.from('warga').insert({
        'user_id': user.id,
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

      // Update user profile role
      await client.from('user_profile').upsert({
        'id': user.id,
        'role': 'WARGA',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating warga profile: $e');
      throw e.toString();
    }
  }

  // Metode untuk mendapatkan notifikasi pengguna
  Future<List<Map<String, dynamic>>> getUserNotifications(
      {bool unreadOnly = false}) async {
    try {
      final user = currentUser;
      if (user == null) return [];

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

      // Coba ambil dari tabel user_profile dulu
      final response = await client
          .from('user_profile')
          .select('*')
          .eq('id', petugasDesaId)
          .eq('role', 'PETUGASDESA')
          .maybeSingle();

      print('Response: $response');

      if (response != null) {
        print(
            'Berhasil mendapatkan data petugas desa dari user_profile: $response');
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
}
