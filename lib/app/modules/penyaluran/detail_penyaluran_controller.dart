import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/skema_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class DetailPenyaluranController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final isLoading = true.obs;
  final isProcessing = false.obs;
  final penyaluran = Rx<PenyaluranBantuanModel?>(null);
  final skemaBantuan = Rx<SkemaBantuanModel?>(null);
  final penerimaPenyaluran = <PenerimaPenyaluranModel>[].obs;

  // Status untuk mengetahui apakah petugas desa
  final isPetugasDesa = false.obs;

  @override
  void onInit() {
    super.onInit();
    final String? penyaluranId = Get.parameters['id'];
    print('DetailPenyaluranController - ID Penyaluran: $penyaluranId');
    if (penyaluranId != null) {
      loadPenyaluranData(penyaluranId);
      checkUserRole();
    } else {
      isLoading.value = false;
      print('DetailPenyaluranController - ID Penyaluran tidak ditemukan');
    }
  }

  Future<void> checkUserRole() async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user != null) {
        final userData = await _supabaseService.client
            .from('users')
            .select('role')
            .eq('id', user.id)
            .single();

        if (userData != null && userData['role'] == 'petugas_desa') {
          isPetugasDesa.value = true;
        }
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
  }

  Future<void> loadPenyaluranData(String penyaluranId) async {
    try {
      isLoading.value = true;
      print(
          'DetailPenyaluranController - Memuat data penyaluran dengan ID: $penyaluranId');

      // Ambil data penyaluran
      final penyaluranData = await _supabaseService.client
          .from('penyaluran_bantuan')
          .select('*')
          .eq('id', penyaluranId)
          .single();

      print('DetailPenyaluranController - Data penyaluran: $penyaluranData');

      if (penyaluranData != null) {
        // Pastikan data yang diterima sesuai dengan tipe data yang diharapkan
        Map<String, dynamic> sanitizedData =
            Map<String, dynamic>.from(penyaluranData);

        // Konversi jumlah_penerima ke int jika bertipe String
        if (sanitizedData['jumlah_penerima'] is String) {
          sanitizedData['jumlah_penerima'] =
              int.tryParse(sanitizedData['jumlah_penerima'] as String) ?? 0;
        }

        penyaluran.value = PenyaluranBantuanModel.fromJson(sanitizedData);
        print(
            'DetailPenyaluranController - Model penyaluran: ${penyaluran.value?.nama}');

        // Ambil data skema bantuan jika ada
        if (penyaluran.value?.skemaId != null &&
            penyaluran.value!.skemaId!.isNotEmpty) {
          print(
              'DetailPenyaluranController - Memuat skema bantuan dengan ID: ${penyaluran.value!.skemaId}');
          final skemaData = await _supabaseService.client
              .from('xx02_skema_bantuan')
              .select('*')
              .eq('id', penyaluran.value!.skemaId!)
              .single();

          print('DetailPenyaluranController - Data skema bantuan: $skemaData');
          if (skemaData != null) {
            // Pastikan data skema sesuai dengan tipe data yang diharapkan
            Map<String, dynamic> sanitizedSkemaData =
                Map<String, dynamic>.from(skemaData);

            // Konversi kuota ke int jika bertipe String
            if (sanitizedSkemaData['kuota'] is String) {
              sanitizedSkemaData['kuota'] =
                  int.tryParse(sanitizedSkemaData['kuota'] as String) ?? 0;
            }

            // Konversi petugas_verifikasi_id ke int jika bertipe String
            if (sanitizedSkemaData['petugas_verifikasi_id'] is String) {
              sanitizedSkemaData['petugas_verifikasi_id'] = int.tryParse(
                  sanitizedSkemaData['petugas_verifikasi_id'] as String);
            }

            skemaBantuan.value = SkemaBantuanModel.fromJson(sanitizedSkemaData);
            print(
                'DetailPenyaluranController - Model skema bantuan: ${skemaBantuan.value?.nama}');
          }
        }

        // Ambil data penerima penyaluran
        final penerimaPenyaluranData = await _supabaseService.client
            .from('penerima_penyaluran')
            .select('*, warga:warga_id(*)')
            .eq('penyaluran_bantuan_id', penyaluranId);

        print(
            'DetailPenyaluranController - Data penerima penyaluran: $penerimaPenyaluranData');
        if (penerimaPenyaluranData != null) {
          final List<PenerimaPenyaluranModel> penerima = [];
          for (var item in penerimaPenyaluranData) {
            // Pastikan data penerima sesuai dengan tipe data yang diharapkan
            Map<String, dynamic> sanitizedPenerimaData =
                Map<String, dynamic>.from(item);

            // Konversi id ke int jika bertipe String
            if (sanitizedPenerimaData['id'] is String) {
              sanitizedPenerimaData['id'] =
                  int.tryParse(sanitizedPenerimaData['id'] as String);
            }

            // Konversi jumlah_bantuan ke double jika bertipe String
            if (sanitizedPenerimaData['jumlah_bantuan'] is String) {
              sanitizedPenerimaData['jumlah_bantuan'] = double.tryParse(
                  sanitizedPenerimaData['jumlah_bantuan'] as String);
            }

            penerima
                .add(PenerimaPenyaluranModel.fromJson(sanitizedPenerimaData));
          }
          penerimaPenyaluran.assignAll(penerima);
          print(
              'DetailPenyaluranController - Jumlah penerima: ${penerima.length}');
        }
      }
    } catch (e) {
      print('Error loading penyaluran data: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data penyaluran',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    if (penyaluran.value?.id != null) {
      await loadPenyaluranData(penyaluran.value!.id!);
    }
  }

  // Fungsi untuk memulai penyaluran bantuan
  Future<void> mulaiPenyaluran() async {
    try {
      isProcessing.value = true;

      if (penyaluran.value?.id == null) {
        throw Exception('ID penyaluran tidak ditemukan');
      }

      // Update status penyaluran menjadi "BERLANGSUNG"
      await _supabaseService.client
          .from('penyaluran_bantuan')
          .update({'status': 'BERLANGSUNG'}).eq('id', penyaluran.value!.id!);

      await refreshData();

      Get.snackbar(
        'Sukses',
        'Penyaluran bantuan telah dimulai',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error memulai penyaluran: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memulai penyaluran bantuan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Fungsi untuk konfirmasi penerimaan bantuan oleh penerima
  Future<void> konfirmasiPenerimaan(PenerimaPenyaluranModel penerima,
      {String? buktiPenerimaan}) async {
    try {
      isProcessing.value = true;

      if (penerima.id == null) {
        throw Exception('ID penerima tidak ditemukan');
      }

      // Update status penerimaan menjadi "DITERIMA"
      final Map<String, dynamic> updateData = {
        'status_penerimaan': 'DITERIMA',
        'tanggal_penerimaan': DateTime.now().toIso8601String(),
      };

      if (buktiPenerimaan != null) {
        updateData['bukti_penerimaan'] = buktiPenerimaan;
      }

      await _supabaseService.client
          .from('penerima_penyaluran')
          .update(updateData)
          .eq('id', penerima.id!);

      await refreshData();

      Get.snackbar(
        'Sukses',
        'Konfirmasi penerimaan bantuan berhasil',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error konfirmasi penerimaan: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat konfirmasi penerimaan bantuan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Fungsi untuk menyelesaikan penyaluran bantuan
  Future<void> selesaikanPenyaluran() async {
    try {
      isProcessing.value = true;

      if (penyaluran.value?.id == null) {
        throw Exception('ID penyaluran tidak ditemukan');
      }

      // Cek apakah semua penerima sudah menerima bantuan
      final belumDiterima = penerimaPenyaluran
          .where((p) => p.statusPenerimaan?.toUpperCase() != 'DITERIMA')
          .toList();

      if (belumDiterima.isNotEmpty) {
        final result = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Konfirmasi'),
            content: Text(
                'Masih ada ${belumDiterima.length} penerima yang belum menerima bantuan. Apakah Anda yakin ingin menyelesaikan penyaluran?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Ya, Selesaikan'),
              ),
            ],
          ),
        );

        if (result != true) {
          isProcessing.value = false;
          return;
        }
      }

      // Update status penyaluran menjadi "TERLAKSANA"
      await _supabaseService.client.from('penyaluran_bantuan').update({
        'status': 'TERLAKSANA',
        'tanggal_selesai': DateTime.now().toIso8601String(),
      }).eq('id', penyaluran.value!.id!);

      await refreshData();

      Get.snackbar(
        'Sukses',
        'Penyaluran bantuan telah diselesaikan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error menyelesaikan penyaluran: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menyelesaikan penyaluran bantuan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Fungsi untuk membatalkan penyaluran bantuan
  Future<void> batalkanPenyaluran(String alasan) async {
    try {
      isProcessing.value = true;

      if (penyaluran.value?.id == null) {
        throw Exception('ID penyaluran tidak ditemukan');
      }

      // Update status penyaluran menjadi "DIBATALKAN"
      await _supabaseService.client.from('penyaluran_bantuan').update({
        'status': 'DIBATALKAN',
        'alasan_pembatalan': alasan,
        'tanggal_selesai': DateTime.now().toIso8601String(),
      }).eq('id', penyaluran.value!.id!);

      await refreshData();

      Get.snackbar(
        'Sukses',
        'Penyaluran bantuan telah dibatalkan',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error membatalkan penyaluran: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat membatalkan penyaluran bantuan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Fungsi untuk mengupload bukti penerimaan
  Future<String?> uploadBuktiPenerimaan(String filePath) async {
    try {
      final fileName =
          'bukti_penerimaan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);

      final storageResponse = await _supabaseService.client.storage
          .from('bukti_penerimaan')
          .upload(fileName, file);

      if (storageResponse.isEmpty) {
        throw Exception('Gagal mengupload bukti penerimaan');
      }

      final fileUrl = _supabaseService.client.storage
          .from('bukti_penerimaan')
          .getPublicUrl(fileName);

      return fileUrl;
    } catch (e) {
      print('Error upload bukti penerimaan: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat mengupload bukti penerimaan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
}
