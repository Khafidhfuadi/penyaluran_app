import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class PelaksanaanPenyaluranView extends GetView<PetugasDesaController> {
  const PelaksanaanPenyaluranView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data jadwal dari parameter
    final jadwal = Get.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelaksanaan Penyaluran'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan informasi pelaksanaan
            _buildHeaderInfo(context, jadwal),

            // Daftar penerima bantuan
            _buildDaftarPenerima(context, jadwal),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(context, jadwal),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, Map<String, dynamic> jadwal) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jadwal['lokasi'] ?? 'Lokasi Penyaluran',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(context,
              icon: Icons.category,
              label: 'Jenis Bantuan',
              value: jadwal['jenis_bantuan'] ?? '-'),
          const SizedBox(height: 8),
          _buildInfoItem(context,
              icon: Icons.calendar_today,
              label: 'Tanggal',
              value: jadwal['tanggal'] ?? '-'),
          const SizedBox(height: 8),
          _buildInfoItem(context,
              icon: Icons.access_time,
              label: 'Waktu',
              value: jadwal['waktu'] ?? '-'),
          const SizedBox(height: 8),
          _buildInfoItem(context,
              icon: Icons.people,
              label: 'Jumlah Penerima',
              value: '${jadwal['jumlah_penerima'] ?? 0} orang'),
          const SizedBox(height: 8),
          _buildInfoItem(
            context,
            icon: Icons.flag,
            label: 'Status',
            value: jadwal['status'] ?? 'Aktif',
            isStatus: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isStatus = false,
  }) {
    Color statusColor = Colors.white;
    if (isStatus) {
      switch (value.toLowerCase()) {
        case 'aktif':
          statusColor = Colors.green;
          break;
        case 'terjadwal':
          statusColor = Colors.blue;
          break;
        case 'selesai':
          statusColor = Colors.grey;
          break;
        default:
          statusColor = Colors.orange;
      }
    }

    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isStatus ? statusColor : Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildDaftarPenerima(
      BuildContext context, Map<String, dynamic> jadwal) {
    // Simulasi data penerima bantuan
    final List<Map<String, dynamic>> daftarPenerima = [
      {
        'id': '1',
        'nama': 'Ahmad Sulaiman',
        'nik': '3201234567890001',
        'alamat': 'Dusun Sukamaju RT 02/03',
        'status': 'belum_diterima',
      },
      {
        'id': '2',
        'nama': 'Siti Aminah',
        'nik': '3201234567890002',
        'alamat': 'Dusun Sukamaju RT 01/03',
        'status': 'sudah_diterima',
      },
      {
        'id': '3',
        'nama': 'Budi Santoso',
        'nik': '3201234567890003',
        'alamat': 'Dusun Sukamaju RT 03/01',
        'status': 'belum_diterima',
      },
      {
        'id': '4',
        'nama': 'Dewi Lestari',
        'nik': '3201234567890004',
        'alamat': 'Dusun Sukamaju RT 04/02',
        'status': 'sudah_diterima',
      },
      {
        'id': '5',
        'nama': 'Joko Widodo',
        'nik': '3201234567890005',
        'alamat': 'Dusun Sukamaju RT 05/01',
        'status': 'belum_diterima',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Penerima Bantuan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${daftarPenerima.length} orang',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari penerima...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),

          const SizedBox(height: 16),

          // Filter status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'Semua', true),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Sudah Diterima', false),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Belum Diterima', false),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Daftar penerima
          ...daftarPenerima
              .map((penerima) => _buildPenerimaItem(context, penerima)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Implementasi filter
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildPenerimaItem(
      BuildContext context, Map<String, dynamic> penerima) {
    final bool sudahDiterima = penerima['status'] == 'sudah_diterima';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          penerima['nama'] ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('NIK: ${penerima['nik'] ?? ''}'),
            const SizedBox(height: 2),
            Text('Alamat: ${penerima['alamat'] ?? ''}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: sudahDiterima
                ? Colors.green.withAlpha(26)
                : Colors.orange.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            sudahDiterima ? 'Sudah Diterima' : 'Belum Diterima',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: sudahDiterima ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        onTap: () {
          // Navigasi ke halaman konfirmasi penerima
          Get.toNamed(
            '/daftar-penerima/konfirmasi',
            arguments: penerima['id'],
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons(
      BuildContext context, Map<String, dynamic> jadwal) {
    final bool isSelesai = (jadwal['status'] ?? '').toLowerCase() == 'selesai';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isSelesai
                  ? null
                  : () {
                      // Implementasi cetak laporan
                      Get.snackbar(
                        'Informasi',
                        'Mencetak laporan penyaluran...',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
              icon: const Icon(Icons.print),
              label: const Text('Cetak Laporan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isSelesai
                  ? null
                  : () {
                      // Implementasi selesaikan penyaluran
                      _showSelesaikanDialog(context, jadwal);
                    },
              icon: const Icon(Icons.check_circle),
              label: const Text('Selesaikan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelesai ? Colors.grey : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSelesaikanDialog(
      BuildContext context, Map<String, dynamic> jadwal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Penyaluran'),
        content:
            const Text('Apakah Anda yakin ingin menyelesaikan penyaluran ini? '
                'Pastikan semua penerima telah dikonfirmasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementasi selesaikan penyaluran
              Navigator.pop(context);
              Get.back(); // Kembali ke halaman sebelumnya
              Get.snackbar(
                'Berhasil',
                'Penyaluran telah diselesaikan',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }
}
