import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class PengaduanView extends GetView<PetugasDesaController> {
  const PengaduanView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan pengaduan
            _buildPengaduanSummary(context),

            const SizedBox(height: 24),

            // Filter dan pencarian
            _buildFilterSearch(context),

            const SizedBox(height: 20),

            // Daftar pengaduan
            _buildPengaduanList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPengaduanSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pengaduan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.pending_actions,
                  title: 'Diproses',
                  value: '3',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.engineering,
                  title: 'Tindakan',
                  value: '2',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.check_circle,
                  title: 'Selesai',
                  value: '8',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterSearch(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari pengaduan...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              // Tampilkan dialog filter
              _showFilterDialog(context);
            },
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pengaduan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Diproses'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Tindakan'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Selesai'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  Widget _buildPengaduanList(BuildContext context) {
    final List<Map<String, dynamic>> pengaduanList = [
      {
        'id': '1',
        'nama': 'Budi Santoso',
        'nik': '3201020107030011',
        'jenis_pengaduan': 'Bantuan Tidak Diterima',
        'deskripsi':
            'Saya belum menerima bantuan beras yang dijadwalkan minggu lalu',
        'tanggal': '15 April 2023',
        'status': 'Diproses',
      },
      {
        'id': '2',
        'nama': 'Siti Rahayu',
        'nik': '3201020107030010',
        'jenis_pengaduan': 'Kualitas Bantuan',
        'deskripsi':
            'Beras yang diterima berkualitas buruk dan tidak layak konsumsi',
        'tanggal': '14 April 2023',
        'status': 'Tindakan',
      },
      {
        'id': '3',
        'nama': 'Ahmad Fauzi',
        'nik': '3201020107030013',
        'jenis_pengaduan': 'Jumlah Bantuan',
        'deskripsi':
            'Jumlah bantuan yang diterima tidak sesuai dengan yang dijanjikan',
        'tanggal': '13 April 2023',
        'status': 'Tindakan',
      },
      {
        'id': '4',
        'nama': 'Dewi Lestari',
        'nik': '3201020107030012',
        'jenis_pengaduan': 'Jadwal Penyaluran',
        'deskripsi':
            'Jadwal penyaluran bantuan sering berubah tanpa pemberitahuan',
        'tanggal': '10 April 2023',
        'status': 'Selesai',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Pengaduan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...pengaduanList.map((item) => _buildPengaduanItem(context, item)),
      ],
    );
  }

  Widget _buildPengaduanItem(BuildContext context, Map<String, dynamic> item) {
    Color statusColor;
    IconData statusIcon;

    switch (item['status']) {
      case 'MENUNGGU':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.pending;
        break;
      case 'DIPROSES':
        statusColor = AppTheme.infoColor;
        statusIcon = Icons.sync;
        break;
      case 'SELESAI':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['nama'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['status'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'NIK: ${item['nik'] ?? ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['jenis_pengaduan'] ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['deskripsi'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  item['tanggal'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(context, item),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(
      BuildContext context, Map<String, dynamic> item) {
    final status = item['status'];

    if (status == 'Diproses') {
      return [
        TextButton.icon(
          onPressed: () {
            // Implementasi untuk memproses pengaduan
            _showTindakanDialog(context, item);
          },
          icon: const Icon(Icons.engineering, size: 18),
          label: const Text('Tindakan'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            // Implementasi untuk melihat detail pengaduan
            _showDetailDialog(context, item);
          },
          icon: const Icon(Icons.info_outline, size: 18),
          label: const Text('Detail'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ];
    } else if (status == 'Tindakan') {
      return [
        TextButton.icon(
          onPressed: () {
            // Implementasi untuk menyelesaikan pengaduan
            _showSelesaikanDialog(context, item);
          },
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Selesaikan'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            // Implementasi untuk melihat detail pengaduan
            _showDetailDialog(context, item);
          },
          icon: const Icon(Icons.info_outline, size: 18),
          label: const Text('Detail'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ];
    } else {
      return [
        TextButton.icon(
          onPressed: () {
            // Implementasi untuk melihat detail pengaduan
            _showDetailDialog(context, item);
          },
          icon: const Icon(Icons.info_outline, size: 18),
          label: const Text('Detail'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ];
    }
  }

  void _showDetailDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pengaduan: ${item['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Nama', item['nama'] ?? ''),
              _buildDetailItem('NIK', item['nik'] ?? ''),
              _buildDetailItem(
                  'Jenis Pengaduan', item['jenis_pengaduan'] ?? ''),
              _buildDetailItem('Tanggal', item['tanggal'] ?? ''),
              _buildDetailItem('Status', item['status'] ?? ''),
              const SizedBox(height: 8),
              const Text(
                'Deskripsi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(item['deskripsi'] ?? ''),
              if (item['status'] == 'Tindakan' ||
                  item['status'] == 'Selesai') ...[
                const SizedBox(height: 8),
                const Text(
                  'Tindakan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(item['tindakan'] ??
                    'Pengecekan ke lokasi dan verifikasi data penerima'),
              ],
              if (item['status'] == 'Selesai') ...[
                const SizedBox(height: 8),
                const Text(
                  'Hasil:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(item['hasil'] ??
                    'Pengaduan telah diselesaikan dengan penyaluran ulang bantuan'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showTindakanDialog(BuildContext context, Map<String, dynamic> item) {
    final TextEditingController tindakanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tindakan Pengaduan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pengaduan dari: ${item['nama']}'),
            const SizedBox(height: 16),
            TextField(
              controller: tindakanController,
              decoration: const InputDecoration(
                labelText: 'Tindakan yang dilakukan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementasi untuk menyimpan tindakan
              Navigator.pop(context);
              Get.snackbar(
                'Berhasil',
                'Status pengaduan berhasil diubah menjadi Tindakan',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showSelesaikanDialog(BuildContext context, Map<String, dynamic> item) {
    final TextEditingController hasilController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Pengaduan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pengaduan dari: ${item['nama']}'),
            const SizedBox(height: 16),
            TextField(
              controller: hasilController,
              decoration: const InputDecoration(
                labelText: 'Hasil penyelesaian',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementasi untuk menyimpan hasil
              Navigator.pop(context);
              Get.snackbar(
                'Berhasil',
                'Status pengaduan berhasil diubah menjadi Selesai',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }
}
