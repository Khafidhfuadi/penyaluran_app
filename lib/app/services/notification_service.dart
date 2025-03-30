import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final SupabaseService _supabaseService = SupabaseService.to;

  // Daftar notifikasi yang belum dibaca
  final RxList<Map<String, dynamic>> unreadNotifications =
      <Map<String, dynamic>>[].obs;

  // Mengontrol status loading
  final RxBool isLoading = false.obs;

  // Jumlah notifikasi yang belum dibaca
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // Mengambil notifikasi dari database
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;

      // Ambil notifikasi dari tabel notifikasi di database
      final userId = _supabaseService.currentUser?.id;
      if (userId != null) {
        final response = await _supabaseService.client
            .from('notifikasi_jadwal')
            .select('*')
            .eq('user_id', userId)
            .eq('is_read', false)
            .order('created_at', ascending: false)
            .limit(20);

        if (response != null) {
          unreadNotifications.value = response;
          unreadCount.value = unreadNotifications.length;
        }
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mengirim notifikasi untuk perubahan status jadwal
  Future<void> sendJadwalStatusNotification({
    required String jadwalId,
    required String newStatus,
    required String jadwalNama,
    List<String>? targetUserIds,
  }) async {
    try {
      final currentUserId = _supabaseService.currentUser?.id;
      if (currentUserId == null) return;

      // Buat pesan berdasarkan status
      String message;
      String title;

      switch (newStatus) {
        case 'AKTIF':
          title = 'Jadwal Aktif';
          message =
              'Jadwal "$jadwalNama" sekarang aktif dan siap dilaksanakan.';
          break;
        case 'TERLAKSANA':
          title = 'Jadwal Selesai';
          message = 'Jadwal "$jadwalNama" telah berhasil dilaksanakan.';
          break;
        case 'BATALTERLAKSANA':
          title = 'Jadwal Terlewat';
          message =
              'Jadwal "$jadwalNama" telah terlewat dan dibatalkan secara otomatis.';
          break;
        default:
          title = 'Perubahan Status Jadwal';
          message = 'Status jadwal "$jadwalNama" berubah menjadi $newStatus.';
      }

      // Jika tidak ada targetUserIds, notifikasi hanya untuk diri sendiri
      final users = targetUserIds ?? [currentUserId];

      // Simpan notifikasi ke database untuk setiap user
      for (final userId in users) {
        await _supabaseService.client.from('notifikasi_jadwal').insert({
          'user_id': userId,
          'title': title,
          'message': message,
          'jadwal_id': jadwalId,
          'status': newStatus,
          'is_read': false,
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'created_by': currentUserId,
        });
      }

      // Jika perubahan status dari pengguna saat ini, tampilkan notifikasi
      if (users.contains(currentUserId)) {
        showStatusChangeNotification(title, message, newStatus);
      }

      // Perbarui daftar notifikasi
      await fetchNotifications();
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Menampilkan notifikasi status di UI
  void showStatusChangeNotification(
      String title, String message, String status) {
    Color backgroundColor;

    // Pilih warna berdasarkan status
    switch (status) {
      case 'AKTIF':
        backgroundColor = Colors.green;
        break;
      case 'TERLAKSANA':
        backgroundColor = Colors.blue;
        break;
      case 'BATALTERLAKSANA':
        backgroundColor = Colors.orange;
        break;
      default:
        backgroundColor = Colors.grey;
    }

    // Tampilkan notifikasi
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      icon: Icon(
        _getIconForStatus(status),
        color: Colors.white,
      ),
    );
  }

  // Menandai notifikasi sebagai telah dibaca
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabaseService.client
          .from('notifikasi_jadwal')
          .update({'is_read': true}).eq('id', notificationId);

      // Hapus dari daftar yang belum dibaca
      unreadNotifications
          .removeWhere((notification) => notification['id'] == notificationId);
      unreadCount.value = unreadNotifications.length;
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Menandai semua notifikasi sebagai telah dibaca
  Future<void> markAllAsRead() async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) return;

      await _supabaseService.client
          .from('notifikasi_jadwal')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      // Kosongkan daftar yang belum dibaca
      unreadNotifications.clear();
      unreadCount.value = 0;
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Mendapatkan ikon berdasarkan status
  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'AKTIF':
        return Icons.event_available;
      case 'TERLAKSANA':
        return Icons.check_circle;
      case 'BATALTERLAKSANA':
        return Icons.event_busy;
      default:
        return Icons.notifications;
    }
  }
}
