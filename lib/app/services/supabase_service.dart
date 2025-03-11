import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find<SupabaseService>();

  late final SupabaseClient client;

  // Cache untuk profil pengguna
  Map<String, dynamic>? _cachedUserProfile;

  // Ganti dengan URL dan API key Supabase Anda
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL',
      defaultValue: 'http://labulabs.net:8000');
  static const String supabaseKey = String.fromEnvironment('SUPABASE_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzMxODYyODAwLAogICJleHAiOiAxODg5NjI5MjAwCn0.4IpwhwCVbfYXxb8JlZOLSBzCt6kQmypkvuso7N8Aicc');

  Future<SupabaseService> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );

    client = Supabase.instance.client;
    return this;
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
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Metode untuk logout
  Future<void> signOut() async {
    _cachedUserProfile = null; // Hapus cache saat logout
    await client.auth.signOut();
  }

  // Metode untuk mendapatkan user saat ini
  User? get currentUser => client.auth.currentUser;

  // Metode untuk memeriksa apakah user sudah login
  bool get isAuthenticated => currentUser != null;

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

      final response = await client
          .from('penyaluran_bantuan')
          .select('*')
          .gte('tanggal_penyaluran', today.toIso8601String())
          .lt('tanggal_penyaluran', tomorrow.toIso8601String())
          .inFilter('status', ['DISETUJUI', 'BERLANGSUNG']);

      return response;
    } catch (e) {
      print('Error getting jadwal hari ini: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getJadwalMendatang() async {
    try {
      final now = DateTime.now();
      final tomorrow =
          DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

      final response = await client
          .from('penyaluran_bantuan')
          .select('*')
          .gte('tanggal_penyaluran', tomorrow.toIso8601String())
          .inFilter('status', ['DISETUJUI', 'DIJADWALKAN']);

      return response;
    } catch (e) {
      print('Error getting jadwal mendatang: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getJadwalSelesai() async {
    try {
      final response = await client
          .from('penyaluran_bantuan')
          .select('*')
          .eq('status', 'SELESAI')
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

  // Stok bantuan methods
  Future<List<Map<String, dynamic>>?> getStokBantuan() async {
    try {
      final response = await client.from('stok_bantuan').select('*');

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

  Future<void> addStok(Map<String, dynamic> stok) async {
    try {
      await client.from('stok_bantuan').insert(stok);
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
      final response = await client.from('penitipan_bantuan').select('*');

      return response;
    } catch (e) {
      print('Error getting penitipan bantuan: $e');
      return null;
    }
  }

  Future<void> verifikasiPenitipan(String penitipanId) async {
    try {
      await client.from('penitipan_bantuan').update({
        'status': 'TERVERIFIKASI',
        'tanggal_verifikasi': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', penitipanId);
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
}
