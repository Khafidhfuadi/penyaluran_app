import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penerima_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:intl/intl.dart';

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

              // Status penyaluran
              _buildStatusSection(penerima),

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
            penerima['nama'] ?? '',
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
          const SizedBox(height: 12),
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
                  _buildInfoRow('No KK', penerima['noKK'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('No Handphone', penerima['noHandphone'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('Email', penerima['email'] ?? '-'),
                  const Divider(),
                  _buildInfoRow(
                      'Jenis Kelamin', penerima['jenisKelamin'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('Agama', penerima['agama'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('Tempat, Tanggal Lahir',
                      penerima['tempatTanggalLahir'] ?? '-'),
                  const Divider(),
                  _buildInfoRow(
                      'Alamat Lengkap', penerima['alamatLengkap'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('Pekerjaan', penerima['pekerjaan'] ?? '-'),
                  const Divider(),
                  _buildInfoRow('Pendidikan Terakhir',
                      penerima['pendidikanTerakhir'] ?? '-'),
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

  Widget _buildStatusSection(Map<String, dynamic> penerima) {
    Color statusColor;
    IconData statusIcon;

    switch (penerima['status']) {
      case 'Selesai':
        statusColor = AppTheme.completedColor;
        statusIcon = Icons.check_circle;
        break;
      case 'Terjadwal':
        statusColor = AppTheme.processedColor;
        statusIcon = Icons.event;
        break;
      case 'Belum disalurkan':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Penyaluran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          penerima['status'] ?? 'Tidak diketahui',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        if (penerima['status'] == 'Belum disalurkan')
                          const Text(
                            'Penerima ini belum dijadwalkan penyaluran bantuan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        if (penerima['status'] == 'Terjadwal')
                          const Text(
                            'Penerima ini sudah dijadwalkan penyaluran bantuan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        if (penerima['status'] == 'Selesai')
                          const Text(
                            'Penerima ini sudah menerima bantuan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
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
                final penyaluran = controller.daftarPenyaluran[index];
                return _buildPenyaluranItem(penyaluran);
              },
            );
          }),
        ],
      ),
    );
  }

  // Widget untuk menampilkan item penyaluran bantuan
  Widget _buildPenyaluranItem(Map<String, dynamic> penyaluran) {
    final DateTime tanggalPenyaluran =
        DateTime.parse(penyaluran['tanggal_penyaluran']);
    final String formattedDate =
        DateFormat('dd MMMM yyyy', 'id_ID').format(tanggalPenyaluran);

    final Color statusColor = penyaluran['status'] == 'TERLAKSANA'
        ? AppTheme.completedColor
        : penyaluran['status'] == 'DIJADWALKAN'
            ? AppTheme.processedColor
            : AppTheme.warningColor;

    final IconData statusIcon = penyaluran['status'] == 'TERLAKSANA'
        ? Icons.check_circle
        : penyaluran['status'] == 'DIJADWALKAN'
            ? Icons.event
            : Icons.pending;

    final Map<String, dynamic> stokBantuan =
        penyaluran['stok_bantuan'] as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris atas dengan status dan tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status penyaluran
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      penyaluran['status'] == 'TERLAKSANA'
                          ? 'Terlaksana'
                          : penyaluran['status'] == 'DIJADWALKAN'
                              ? 'Terjadwal'
                              : 'Menunggu',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Tanggal penyaluran
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 24),

            // Informasi bantuan
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon bantuan
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Detail bantuan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stokBantuan['nama'] ?? 'Bantuan',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stokBantuan['jenis'] ?? 'Umum'} • ${stokBantuan['kuantitas'] ?? '1 Paket'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        penyaluran['keterangan'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Tampilkan bukti penyaluran jika ada dan status TERLAKSANA
            if (penyaluran['status'] == 'TERLAKSANA' &&
                penyaluran['bukti_penyaluran'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 24),
                  const Text(
                    'Bukti Penyaluran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      penyaluran['bukti_penyaluran'],
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text('Gambar tidak tersedia'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
