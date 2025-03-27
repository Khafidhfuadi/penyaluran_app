import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penerima_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';

class DetailPenerimaView extends GetView<PenerimaController> {
  const DetailPenerimaView({super.key});

  @override
  Widget build(BuildContext context) {
    final String id = Get.arguments as String;

    // Panggil metode untuk mengambil data penyaluran saat halaman dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPenyaluranByWargaId(id);
    });

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Penerima'),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final penerima = controller.getPenerimaById(id);

      if (penerima == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Penerima'),
          ),
          body: const Center(
            child: Text('Data penerima tidak ditemukan'),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Penerima'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header dengan foto dan nama
              _buildHeader(penerima),

              // Detail informasi penerima
              _buildDetailInfo(penerima),

              // Riwayat Penyaluran Bantuan
              _buildRiwayatPenyaluran(),

              const SizedBox(height: 20),
            ],
          ),
        ),
        // bottomNavigationBar: _buildBottomButtons(penerima),
      );
    });
  }

  Widget _buildHeader(Map<String, dynamic> penerima) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 30, left: 16, right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.primaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Foto profil dengan efek bayangan dan border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Hero(
              tag: 'penerima-${penerima['id']}',
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: penerima['foto_profil'] != null
                    ? NetworkImage(penerima['foto_profil'])
                    : null,
                child: penerima['foto_profil'] == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: AppTheme.primaryColor.withOpacity(0.7),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Nama penerima dengan stroke effect
          Text(
            penerima['nama_lengkap'] ?? '',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.black26,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // NIK dengan style yang lebih menarik
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'NIK: ${penerima['nik'] ?? 'Belum terdaftar'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Badge terverifikasi dengan animasi
          if (penerima['terverifikasi'] == true)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.successColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Terverifikasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          // Informasi status aktif
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: penerima['status'] == 'AKTIF'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              penerima['status'] == 'AKTIF' ? 'Aktif' : 'Tidak Aktif',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: penerima['status'] == 'AKTIF'
                    ? Colors.white
                    : Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInfo(Map<String, dynamic> penerima) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Penerima',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Informasi detail dalam bentuk card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow('NIK', penerima['nik'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('No KK', penerima['no_kk'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('No Handphone', penerima['no_hp'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('Email', penerima['email'] ?? '-'),
                  const Divider(),
                  _buildInfoRow(
                      'Jenis Kelamin', penerima['jenis_kelamin'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('Agama', penerima['agama'] ?? '-'),
                  const Divider(),
                  _buildInfoRow(
                      'Tempat, Tanggal Lahir', penerima['tempat_lahir'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('Alamat Lengkap', penerima['alamat'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('Pekerjaan', penerima['pekerjaan'] ?? '-'),
                  const Divider(),
                  _buildInfoRow(
                      'Pendidikan Terakhir', penerima['pendidikan'] ?? '-'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan riwayat penyaluran bantuan
  Widget _buildRiwayatPenyaluran() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Penyaluran Bantuan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            // Debug prints
            print('Loading state: ${controller.isLoadingPenyaluran.value}');
            print(
                'Daftar penyaluran length: ${controller.daftarPenyaluran.length}');

            if (controller.isLoadingPenyaluran.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.daftarPenyaluran.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat penyaluran bantuan',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.daftarPenyaluran.length,
              itemBuilder: (context, index) {
                try {
                  final penyaluran = controller.daftarPenyaluran[index];
                  return _buildPenyaluranItem(penyaluran);
                } catch (e) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Terjadi kesalahan: $e'),
                    ),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }

  // Widget untuk menampilkan item penyaluran bantuan
  Widget _buildPenyaluranItem(Map<String, dynamic> penyaluran) {
    // Status penerimaan dengan nilai default
    final String statusPenerimaan =
        penyaluran['status_penerimaan'] ?? 'BELUMMENERIMA';

    final Color statusColor = statusPenerimaan == 'DITERIMA'
        ? AppTheme.completedColor
        : statusPenerimaan == 'BELUMMENERIMA'
            ? AppTheme.processedColor
            : AppTheme.warningColor;

    final IconData statusIcon = statusPenerimaan == 'DITERIMA'
        ? Icons.check_circle
        : statusPenerimaan == 'BELUMMENERIMA'
            ? Icons.hourglass_empty
            : Icons.help;

    // Data penyaluran bantuan
    final Map<String, dynamic> penyaluranBantuan =
        penyaluran['penyaluran_bantuan'] as Map<String, dynamic>? ?? {};

    // Format tanggal menggunakan DateTimeHelper
    final tanggalPenerimaan = penyaluran['tanggal_penerimaan'] != null
        ? DateTime.parse(penyaluran['tanggal_penerimaan'])
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan nama program dan status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        penyaluranBantuan['nama'] ?? 'Program Bantuan',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (penyaluranBantuan['deskripsi'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            penyaluranBantuan['deskripsi'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusPenerimaan,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informasi waktu dan jumlah
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today,
                        'Tanggal Penerimaan',
                        DateTimeHelper.formatDateTime(tanggalPenerimaan),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.inventory_2,
                        'Jumlah Diterima',
                        '${penyaluran['jumlah_bantuan'] ?? '0'} paket',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (penyaluranBantuan['lokasi_penyaluran'] != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          Icons.location_on,
                          'Lokasi Penyaluran',
                          penyaluranBantuan['lokasi_penyaluran']['nama'] ??
                              'Tidak tersedia',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          Icons.map,
                          'Alamat Lokasi',
                          penyaluranBantuan['lokasi_penyaluran']
                                  ['alamat_lengkap'] ??
                              'Tidak tersedia',
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Bukti penerimaan dan tanda tangan
                if (penyaluran['bukti_penerimaan'] != null ||
                    penyaluran['tanda_tangan'] != null)
                  Row(
                    children: [
                      if (penyaluran['bukti_penerimaan'] != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bukti Penerimaan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  penyaluran['bukti_penerimaan'],
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (penyaluran['bukti_penerimaan'] != null &&
                          penyaluran['tanda_tangan'] != null)
                        const SizedBox(width: 16),
                      if (penyaluran['tanda_tangan'] != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tanda Tangan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  penyaluran['tanda_tangan'],
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                // QR Code
                if (penyaluran['qr_code_hash'] != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'QR Code Verifikasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.network(
                            'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${penyaluran['qr_code_hash']}',
                            height: 120,
                            width: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.qr_code_2,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
