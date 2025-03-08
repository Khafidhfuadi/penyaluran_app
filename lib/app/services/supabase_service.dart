import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find<SupabaseService>();

  late final SupabaseClient client;

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
    await client.auth.signOut();
  }

  // Metode untuk mendapatkan user saat ini
  User? get currentUser => client.auth.currentUser;

  // Metode untuk memeriksa apakah user sudah login
  bool get isAuthenticated => currentUser != null;

  // Metode untuk mendapatkan profil pengguna
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;

    final response = await client
        .from('user_profile')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();

    return response;
  }

  // Metode untuk mendapatkan role pengguna
  Future<String?> getUserRole() async {
    final profile = await getUserProfile();
    return profile?['role'];
  }

  // Metode untuk mendapatkan data berdasarkan peran
  Future<Map<String, dynamic>?> getRoleSpecificData(String role) async {
    if (currentUser == null) return null;

    switch (role) {
      case 'WARGA':
        return await getWargaByUserId();
      case 'PETUGASVERIFIKASI':
        return await getPetugasVerifikasiData();
      case 'PETUGASDESA':
        return await getPetugasDesaData();
      case 'DONATUR':
        return await getDonaturData();
      default:
        return null;
    }
  }

  // Metode untuk mendapatkan data petugas verifikasi
  Future<Map<String, dynamic>?> getPetugasVerifikasiData() async {
    if (currentUser == null) return null;

    final response = await client
        .from('xx02_PetugasVerifikasi')
        .select()
        .eq('userId', currentUser!.id)
        .maybeSingle();

    return response;
  }

  // Metode untuk mendapatkan data petugas desa
  Future<Map<String, dynamic>?> getPetugasDesaData() async {
    if (currentUser == null) return null;

    final response = await client
        .from('xx01_PetugasDesa')
        .select()
        .eq('userId', currentUser!.id)
        .maybeSingle();

    return response;
  }

  // Metode untuk mendapatkan data donatur
  Future<Map<String, dynamic>?> getDonaturData() async {
    if (currentUser == null) return null;

    final response = await client
        .from('xx01_Donatur')
        .select()
        .eq('userId', currentUser!.id)
        .maybeSingle();

    return response;
  }

  // Metode untuk membuat data warga
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
    if (currentUser == null) return;

    await client.from('xx02_Warga').insert({
      'NIK': nik,
      'namaLengkap': namaLengkap,
      'jenisKelamin': jenisKelamin,
      'noHp': noHp,
      'alamat': alamat,
      'tempatLahir': tempatLahir,
      'tanggalLahir': tanggalLahir?.toIso8601String(),
      'agama': agama,
      'userId': currentUser!.id,
      'email': currentUser!.email,
    });
  }

  // Metode untuk mendapatkan data warga berdasarkan userId
  Future<Map<String, dynamic>?> getWargaByUserId() async {
    if (currentUser == null) return null;

    final response = await client
        .from('xx02_Warga')
        .select()
        .eq('userId', currentUser!.id)
        .maybeSingle();

    return response;
  }

  // Metode untuk mendapatkan notifikasi pengguna
  Future<List<Map<String, dynamic>>> getUserNotifications(
      {bool unreadOnly = false}) async {
    if (currentUser == null) return [];

    final query = client.from('Notification').select();

    // Tambahkan filter untuk user ID
    final filteredQuery = query.eq('userId', currentUser!.id);

    // Tambahkan filter untuk notifikasi yang belum dibaca jika diperlukan
    final finalQuery =
        unreadOnly ? filteredQuery.eq('isRead', false) : filteredQuery;

    // Tambahkan pengurutan
    final response = await finalQuery.order('CREATED_AT', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Metode untuk menandai notifikasi sebagai telah dibaca
  Future<void> markNotificationAsRead(int notificationId) async {
    await client
        .from('Notification')
        .update({'isRead': true}).eq('notificationId', notificationId);
  }

  // Metode untuk mendapatkan data verifikasi warga
  Future<List<Map<String, dynamic>>> getVerifikasiDataWarga() async {
    if (currentUser == null) return [];

    final response = await client
        .from('xx02_VerifikasiDataWarga')
        .select()
        .order('CREATED_AT', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Metode untuk mendapatkan data pengajuan bantuan
  Future<List<Map<String, dynamic>>> getPengajuanBantuan() async {
    if (currentUser == null) return [];

    final response = await client
        .from('xx02_PengajuanKelayakanBantuan')
        .select()
        .order('CREATED_AT', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Metode untuk mendapatkan data skema bantuan
  Future<List<Map<String, dynamic>>> getSkemaBantuan() async {
    if (currentUser == null) return [];

    final response = await client
        .from('xx02_SkemaBantuan')
        .select()
        .order('CREATED_AT', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Metode untuk mendapatkan data penyaluran bantuan
  Future<List<Map<String, dynamic>>> getPenyaluranBantuan() async {
    if (currentUser == null) return [];

    final response = await client
        .from('xx01_PenyaluranBantuan')
        .select()
        .order('CREATED_AT', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Metode untuk mendapatkan data penitipan bantuan
  Future<List<Map<String, dynamic>>> getPenitipanBantuan() async {
    if (currentUser == null) return [];

    final response = await client
        .from('xx01_PenitipanBantuan')
        .select()
        .order('CREATED_AT', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Metode untuk mendapatkan data pengaduan
  Future<List<Map<String, dynamic>>> getPengaduan() async {
    if (currentUser == null) return [];

    final response = await client
        .from('xx01_Pengaduan')
        .select()
        .order('CREATED_AT', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
