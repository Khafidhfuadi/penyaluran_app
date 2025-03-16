import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penerima_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class DetailPenerimaView extends GetView<PenerimaController> {
  const DetailPenerimaView({super.key});

  @override
  Widget build(BuildContext context) {
    final String id = Get.arguments as String;

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        children: [
          // Foto profil
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: penerima['foto'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      penerima['foto'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 50,
                          color: AppTheme.primaryColor,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 50,
                    color: AppTheme.primaryColor,
                  ),
          ),
          const SizedBox(height: 16),

          // Nama penerima
          Text(
            penerima['nama'] ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // NIK
          Text(
            penerima['nik'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),

          // Badge terverifikasi
          if (penerima['terverifikasi'] == true)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Terverifikasi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
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
}
