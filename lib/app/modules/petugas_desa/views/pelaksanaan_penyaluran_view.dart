import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class PelaksanaanPenyaluranView extends GetView<PetugasDesaController> {
  const PelaksanaanPenyaluranView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ambil data jadwal dari parameter
    final jadwal = Get.arguments as Map<String, dynamic>;

    // Debug: Tampilkan data jadwal yang diterima
    print('DEBUG: Jadwal yang diterima: $jadwal');
    print('DEBUG: ID Jadwal: ${jadwal['id']}');

    // Debug: Periksa koneksi ke Supabase menggunakan instance dari controller
    try {
      controller.supabaseService.client
          .from('penyaluran_bantuan')
          .select('id')
          .limit(1)
          .then((_) {
        print('DEBUG: Koneksi ke Supabase berhasil');
      }).catchError((error) {
        print('DEBUG: Koneksi ke Supabase gagal: $error');
      });
    } catch (e) {
      print('DEBUG: Error saat memeriksa koneksi Supabase: $e');
    }

    // Debug: Periksa struktur data jadwal
    controller.debugJadwalData(jadwal);

    // Muat data penerima saat halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.reloadPenerimaPenyaluran();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelaksanaan Penyaluran'),
        // actions: [
        //   // Tombol debug untuk melihat SQL query
        //   IconButton(
        //     icon: const Icon(Icons.code),
        //     onPressed: () {
        //       final penyaluranId = Get.parameters['id'] ?? jadwal['id'];
        //       _showSqlDebugDialog(context, penyaluranId);
        //     },
        //     tooltip: 'Lihat SQL Query',
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi jadwal
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(context, jadwal),
                ],
              ),
            ),

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          jadwal['lokasi'] ?? 'Lokasi Penyaluran',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoItem(
          context,
          icon: Icons.category,
          label: 'Jenis Bantuan',
          value: jadwal['jenis_bantuan'] ?? 'Tidak tersedia',
        ),
        _buildInfoItem(
          context,
          icon: Icons.calendar_today,
          label: 'Tanggal',
          value: jadwal['tanggal'] ?? 'Tidak tersedia',
        ),
        _buildInfoItem(
          context,
          icon: Icons.access_time,
          label: 'Waktu',
          value: jadwal['waktu'] ?? 'Tidak tersedia',
        ),
        _buildInfoItem(
          context,
          icon: Icons.people,
          label: 'Jumlah Penerima',
          value: '${controller.jumlahPenerima} orang',
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isStatus = false,
  }) {
    final bool isActive = isStatus && value.toUpperCase() == 'AKTIF';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDaftarPenerima(
      BuildContext context, Map<String, dynamic> jadwal) {
    // Debug: Periksa validitas ID penyaluran
    final penyaluranId = jadwal['id'];
    if (penyaluranId == null || penyaluranId.toString().isEmpty) {
      print('DEBUG: PERINGATAN! ID penyaluran kosong atau null: $penyaluranId');

      // Tampilkan pesan error jika ID tidak valid
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'ID penyaluran tidak valid: $penyaluranId',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

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
              Obx(() => Text(
                    '${controller.jumlahPenerima.value} orang',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            controller: controller.searchPenerimaController,
            onChanged: (value) => controller.filterPenerima(value),
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
                _buildFilterChip(
                    context, 'Semua', controller.filterStatus.value == 'SEMUA'),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Sudah Diterima',
                    controller.filterStatus.value == 'SUDAHMENERIMA'),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Belum Diterima',
                    controller.filterStatus.value == 'BELUMMENERIMA'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Daftar penerima - gunakan SizedBox dengan height tertentu daripada Expanded
          SizedBox(
            height: 400, // Tinggi tetap, sesuaikan sesuai kebutuhan
            child: Obx(() {
              // Tampilkan loading jika sedang memuat ulang data
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Tampilkan pesan jika tidak ada data
              if (controller.filteredPenerimaPenyaluran.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        color: Colors.grey,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada data penerima untuk penyaluran ini',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          controller.reloadPenerimaPenyaluran();
                        },
                        child: const Text('Refresh Data'),
                      ),
                    ],
                  ),
                );
              }

              // Tampilkan data penerima
              return ListView.builder(
                itemCount: controller.filteredPenerimaPenyaluran.length,
                itemBuilder: (context, index) {
                  final penerima = controller.filteredPenerimaPenyaluran[index];
                  return _buildPenerimaItem(context, penerima);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    String statusValue;
    switch (label) {
      case 'Sudah Diterima':
        statusValue = 'SUDAHMENERIMA';
        break;
      case 'Belum Diterima':
        statusValue = 'BELUMMENERIMA';
        break;
      default:
        statusValue = 'SEMUA';
    }

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.filterStatus.value = statusValue;
          controller.applyFilters();
        }
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

  // Metode untuk menampilkan dialog debug
  void _showDebugDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Data'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Data Struktur:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Keys: ${data.keys.toList().join(', ')}'),
              const Divider(),
              if (data.containsKey('warga')) ...[
                const Text('Warga Data:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (data['warga'] != null)
                  Text(
                      'Warga Keys: ${(data['warga'] as Map<String, dynamic>).keys.toList().join(', ')}')
                else
                  const Text('Warga data is null'),
                const Divider(),
              ],
              const Text('Raw Data:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(data.toString(), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Metode untuk membangun item penerima dengan tombol debug
  Widget _buildPenerimaItem(
      BuildContext context, Map<String, dynamic> penerima) {
    final bool sudahDiterima = penerima['status_penerimaan'] == 'SUDAHMENERIMA';
    final warga = penerima['warga'] as Map<String, dynamic>?;

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
          warga?['nama_lengkap'] ?? 'Nama tidak tersedia',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('NIK: ${warga?['nik'] ?? 'NIK tidak tersedia'}'),
            const SizedBox(height: 2),
            Text('Alamat: ${warga?['alamat'] ?? 'Alamat tidak tersedia'}'),
            if (penerima['jumlah_bantuan'] != null) ...[
              const SizedBox(height: 2),
              Text('Jumlah Bantuan: ${penerima['jumlah_bantuan']}'),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol debug untuk melihat struktur data
            // IconButton(
            //   icon: const Icon(Icons.bug_report, color: Colors.grey),
            //   onPressed: () => _showDebugDialog(context, penerima),
            //   tooltip: 'Lihat struktur data',
            //   iconSize: 20,
            // ),
            Container(
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
          ],
        ),
        onTap: () {
          // Navigasi ke halaman konfirmasi penerima
          Get.toNamed(
            '/konfirmasi-penerima',
            arguments: {
              'penerima_id': penerima['id'],
              'penyaluran_id': penerima['penyaluran_bantuan_id'],
              'warga': warga,
              'status_penerimaan': penerima['status_penerimaan'],
              'jumlah_bantuan': penerima['jumlah_bantuan'],
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons(
      BuildContext context, Map<String, dynamic> jadwal) {
    final String status = (jadwal['status'] ?? '').toUpperCase();

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
          // Tampilkan tombol berdasarkan status
          if (status == 'AKTIF') ...[
            // Tombol Cetak Laporan
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'Informasi',
                    'Mencetak laporan penyaluran...',
                    snackPosition: SnackPosition.TOP,
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
            // Tombol Selesaikan
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showSelesaikanDialog(context, jadwal);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Selesaikan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ] else if (status == 'SELESAI') ...[
            // Hanya tampilkan tombol Cetak Laporan
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'Informasi',
                    'Mencetak laporan penyaluran...',
                    snackPosition: SnackPosition.TOP,
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
          ] else if (status == 'DIBATALKAN') ...[
            // Tampilkan pesan dibatalkan
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Penyaluran Dibatalkan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Status lainnya - tampilkan pesan default
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Status: $status',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
              controller.completeJadwal(jadwal['id']).then((_) {
                Navigator.pop(context);
                Get.back(); // Kembali ke halaman sebelumnya
                Get.snackbar(
                  'Berhasil',
                  'Penyaluran telah diselesaikan',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }).catchError((error) {
                Navigator.pop(context);
                Get.snackbar(
                  'Gagal',
                  'Terjadi kesalahan: $error',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              });
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

  // Metode untuk menampilkan filter dan pencarian
  Widget _buildFilterAndSearch(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter & Pencarian',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // Filter status
          Row(
            children: [
              const Text('Status: '),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() {
                  final currentFilter = controller.filterStatus.value;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Filter Semua
                        InkWell(
                          onTap: () => controller.filterStatus.value = 'SEMUA',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: currentFilter == 'SEMUA'
                                  ? Colors.blue
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Semua',
                              style: TextStyle(
                                color: currentFilter == 'SEMUA'
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: currentFilter == 'SEMUA'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter Sudah Menerima
                        InkWell(
                          onTap: () =>
                              controller.filterStatus.value = 'SUDAHMENERIMA',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: currentFilter == 'SUDAHMENERIMA'
                                  ? Colors.blue
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Sudah Menerima',
                              style: TextStyle(
                                color: currentFilter == 'SUDAHMENERIMA'
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: currentFilter == 'SUDAHMENERIMA'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter Belum Menerima
                        InkWell(
                          onTap: () =>
                              controller.filterStatus.value = 'BELUMMENERIMA',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: currentFilter == 'BELUMMENERIMA'
                                  ? Colors.blue
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Belum Menerima',
                              style: TextStyle(
                                color: currentFilter == 'BELUMMENERIMA'
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: currentFilter == 'BELUMMENERIMA'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pencarian
          TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'Cari berdasarkan nama atau NIK',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Metode untuk menampilkan dialog debug SQL
  void _showSqlDebugDialog(BuildContext context, String penyaluranId) {
    final validId = controller.ensureValidUUID(penyaluranId);
    final sqlQuery = '''
SELECT
  penerima_penyaluran.*,
  warga.*
FROM
  penerima_penyaluran
LEFT JOIN
  warga ON warga.id = penerima_penyaluran.warga_id
WHERE
  penerima_penyaluran.penyaluran_bantuan_id = '$validId';
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SQL Query Debug'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('SQL Query yang digunakan:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  sqlQuery,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Petunjuk:'),
              const SizedBox(height: 8),
              const Text('1. Salin query ini ke SQL Editor di Supabase'),
              const Text('2. Jalankan query untuk melihat hasil'),
              const Text(
                  '3. Bandingkan dengan data yang ditampilkan di aplikasi'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
