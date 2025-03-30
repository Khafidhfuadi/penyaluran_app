import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/counter_service.dart';

/// Service untuk menangani pembaruan jadwal real-time dan sinkronisasi antar halaman
class JadwalUpdateService extends GetxService {
  static JadwalUpdateService get to => Get.find<JadwalUpdateService>();

  final SupabaseService _supabaseService = SupabaseService.to;

  // Stream controller untuk mengirim notifikasi pembaruan jadwal ke seluruh aplikasi
  final _jadwalUpdateStream =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get jadwalUpdateStream =>
      _jadwalUpdateStream.stream;

  // Digunakan untuk menyimpan status terakhir pembaruan jadwal
  final RxMap<String, DateTime> lastUpdateTimestamp = <String, DateTime>{}.obs;

  // Map untuk melacak jadwal yang sedang dalam pengawasan intensif
  final RxMap<String, DateTime> _watchedJadwal = <String, DateTime>{}.obs;

  // Timer untuk memeriksa jadwal yang sedang dalam pengawasan
  Timer? _watchTimer;

  // Mencatat controller yang berlangganan untuk pembaruan
  final List<String> _subscribedControllers = [];

  // Channel untuk realtime subscription
  RealtimeChannel? _channel;

  @override
  void onInit() {
    super.onInit();
    _setupRealtimeSubscription();
    _startWatchTimer();
  }

  @override
  void onClose() {
    _jadwalUpdateStream.close();
    _channel?.unsubscribe();
    _watchTimer?.cancel();
    super.onClose();
  }

  // Memulai timer untuk jadwal pengawasan
  void _startWatchTimer() {
    _watchTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkWatchedJadwal();
    });
  }

  // Memeriksa jadwal yang sedang diawasi
  void _checkWatchedJadwal() {
    final now = DateTime.now();
    final List<String> jadwalToUpdate = [];
    final List<String> expiredWatches = [];

    _watchedJadwal.forEach((jadwalId, targetTime) {
      // Jika sudah mencapai atau melewati waktu target
      if (now.isAtSameMomentAs(targetTime) || now.isAfter(targetTime)) {
        jadwalToUpdate.add(jadwalId);
        // Hentikan pengawasan karena sudah waktunya
        expiredWatches.add(jadwalId);
      }

      // Jika sudah lebih dari 5 menit dari waktu target, hentikan pengawasan
      if (now.difference(targetTime).inMinutes > 5) {
        expiredWatches.add(jadwalId);
      }
    });

    // Hapus jadwal yang sudah tidak perlu diawasi
    for (var jadwalId in expiredWatches) {
      _watchedJadwal.remove(jadwalId);
    }

    // Jika ada jadwal yang perlu diperbarui, kirim sinyal untuk memperbarui
    if (jadwalToUpdate.isNotEmpty) {
      print('Watched jadwal time reached: ${jadwalToUpdate.join(", ")}');
      notifyJadwalNeedsCheck();
    }
  }

  // Setup langganan ke pembaruan real-time dari Supabase
  void _setupRealtimeSubscription() {
    try {
      // Langganan pembaruan tabel penyaluran_bantuan
      _channel = _supabaseService.client
          .channel('penyaluran_bantuan_updates')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'penyaluran_bantuan',
            callback: (payload) {
              if (payload.newRecord != null) {
                // Dapatkan data jadwal yang diperbarui
                final jadwalId = payload.newRecord['id'];
                final newStatus = payload.newRecord['status'];

                print(
                    'Received realtime update for jadwal ID: $jadwalId with status: $newStatus');

                // Kirim notifikasi ke seluruh aplikasi
                _broadcastUpdate({
                  'type': 'status_update',
                  'jadwal_id': jadwalId,
                  'new_status': newStatus,
                  'timestamp': DateTime.now().toIso8601String(),
                });

                // Update timestamp
                lastUpdateTimestamp[jadwalId] = DateTime.now();
              }
            },
          );

      // Mulai berlangganan
      _channel?.subscribe();

      print(
          'Realtime subscription for penyaluran_bantuan_updates started successfully');
    } catch (e) {
      print('Error setting up realtime subscription: $e');
    }
  }

  // Mengirim pembaruan ke semua controller yang berlangganan
  void _broadcastUpdate(Map<String, dynamic> updateData) {
    _jadwalUpdateStream.add(updateData);
  }

  // Controller dapat mendaftar untuk menerima pembaruan jadwal
  void registerForUpdates(String controllerId) {
    if (!_subscribedControllers.contains(controllerId)) {
      _subscribedControllers.add(controllerId);
    }
  }

  // Controller berhenti menerima pembaruan
  void unregisterFromUpdates(String controllerId) {
    _subscribedControllers.remove(controllerId);
  }

  // Menambahkan jadwal ke pengawasan intensif
  void addJadwalToWatch(String jadwalId, DateTime targetTime) {
    print('Adding jadwal $jadwalId to intensive watch for time $targetTime');
    _watchedJadwal[jadwalId] = targetTime;
  }

  // Memicu pemeriksaan jadwal segera
  void notifyJadwalNeedsCheck() {
    try {
      // Kirim notifikasi untuk memeriksa jadwal
      _broadcastUpdate({
        'type': 'check_required',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error notifying jadwal check: $e');
    }
  }

  // Muat ulang data jadwal di semua controller yang terdaftar
  Future<void> notifyJadwalUpdate() async {
    try {
      // Kirim notifikasi untuk memuat ulang data
      _broadcastUpdate({
        'type': 'reload_required',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Perbarui counter juga saat jadwal diperbarui
      refreshCounters();

      // Tampilkan notifikasi jika user sedang melihat aplikasi
      if (Get.isDialogOpen != true && Get.context != null) {
        Get.snackbar(
          'Jadwal Diperbarui',
          'Data jadwal telah diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error notifying jadwal update: $e');
    }
  }

  // Metode untuk menyegarkan semua counter terkait penyaluran
  Future<void> refreshCounters() async {
    try {
      // Perbarui counter jika CounterService telah terinisialisasi
      if (Get.isRegistered<CounterService>()) {
        final counterService = Get.find<CounterService>();

        // Ambil data jumlah jadwal aktif
        final jadwalAktifData = await _supabaseService.getJadwalAktif();
        if (jadwalAktifData != null) {
          counterService.updateJadwalCounter(jadwalAktifData.length);
        }

        print('Counters refreshed via JadwalUpdateService');
      }
    } catch (e) {
      print('Error refreshing counters: $e');
    }
  }
}
