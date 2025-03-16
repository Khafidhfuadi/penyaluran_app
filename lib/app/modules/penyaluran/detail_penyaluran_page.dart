import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/modules/penyaluran/detail_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:penyaluran_app/app/modules/penyaluran/konfirmasi_penerima_page.dart';
import 'package:penyaluran_app/app/utils/date_formatter.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';

class DetailPenyaluranPage extends StatelessWidget {
  final controller = Get.put(DetailPenyaluranController());
  final ImagePicker _picker = ImagePicker();
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  DetailPenyaluranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penyaluran'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.penyaluran.value == null) {
          return const Center(
            child: Text('Data penyaluran tidak ditemukan'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context),
                const SizedBox(height: 16),
                _buildPenerimaPenyaluranSection(context),
                const SizedBox(height: 24),
                // Menampilkan section alasan pembatalan jika status BATALTERLAKSANA
                if (controller.penyaluran.value?.status?.toUpperCase() ==
                        'BATALTERLAKSANA' &&
                    controller.penyaluran.value?.alasanPembatalan != null &&
                    controller.penyaluran.value!.alasanPembatalan!.isNotEmpty)
                  _buildPembatalanSection(context),
                const SizedBox(height: 24),
                // Tombol aksi akan ditampilkan di bottomNavigationBar
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final status = controller.penyaluran.value?.status?.toUpperCase() ?? '';
        if (status == 'AKTIF' ||
            status == 'DISETUJUI' ||
            status == 'DIJADWALKAN') {
          return _buildActionButtons(context);
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final penyaluran = controller.penyaluran.value!;
    final skema = controller.skemaBantuan.value;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Informasi Penyaluran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                _buildStatusBadge(penyaluran.status ?? '-'),
              ],
            ),
            const Divider(height: 24),

            // Informasi penyaluran
            _buildInfoRow('Nama', penyaluran.nama ?? '-'),
            _buildInfoRow(
                'Tanggal',
                penyaluran.tanggalPenyaluran != null
                    ? DateFormatter.formatDateTime(
                        penyaluran.tanggalPenyaluran!)
                    : 'Belum dijadwalkan'),
            // Tampilkan tanggal selesai jika status TERLAKSANA atau BATALTERLAKSANA
            if (penyaluran.status == 'TERLAKSANA' ||
                penyaluran.status == 'BATALTERLAKSANA')
              _buildInfoRow(
                  'Tanggal Selesai',
                  penyaluran.tanggalSelesai != null
                      ? DateFormatter.formatDateTime(penyaluran.tanggalSelesai!)
                      : '-'),
            _buildInfoRow(
                'Jumlah Penerima', '${penyaluran.jumlahPenerima ?? 0} orang'),

            // Informasi skema bantuan
            if (skema != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.category,
                      size: 16, color: AppTheme.secondaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Skema: ${skema.nama ?? '-'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                skema.deskripsi ?? 'Tidak ada deskripsi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],

            // Alasan penolakan jika ada
            if (penyaluran.alasanPembatalan != null &&
                penyaluran.alasanPembatalan!.isNotEmpty) ...[
              const Divider(height: 24),
              if (penyaluran.status?.toUpperCase() == 'BATALTERLAKSANA') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.errorColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Alasan Pembatalan:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.errorColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        penyaluran.alasanPembatalan!,
                        style: TextStyle(
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Alasan Pembatalan:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  penyaluran.alasanPembatalan!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPenerimaPenyaluranSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Penerima',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Obx(() => Text(
                      '${_getFilteredPenerima().length} Orang',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari penerima...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                searchQuery.value = value.toLowerCase();
              },
            ),

            const SizedBox(height: 16),

            // Daftar penerima
            Obx(() {
              final filteredList = _getFilteredPenerima();

              if (filteredList.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada data penerima',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _buildPenerimaItem(context, filteredList[index]);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  List<PenerimaPenyaluranModel> _getFilteredPenerima() {
    final query = searchQuery.value;
    if (query.isEmpty) {
      return controller.penerimaPenyaluran;
    }

    return controller.penerimaPenyaluran.where((item) {
      final warga = item.warga;
      if (warga == null) return false;

      final nama = warga['nama_lengkap']?.toString().toLowerCase() ?? '';
      final nik = warga['nik']?.toString().toLowerCase() ?? '';
      final alamat = warga['alamat']?.toString().toLowerCase() ?? '';
      final status = item.statusPenerimaan?.toLowerCase() ?? '';

      return nama.contains(query) ||
          nik.contains(query) ||
          alamat.contains(query) ||
          status.contains(query);
    }).toList();
  }

  Widget _buildPenerimaItem(
      BuildContext context, PenerimaPenyaluranModel item) {
    final warga = item.warga;

    return InkWell(
      onTap: () => _showDetailPenerima(context, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                warga != null && warga['nama_lengkap'] != null
                    ? warga['nama_lengkap']
                        .toString()
                        .substring(0, 1)
                        .toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info penerima
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    warga != null
                        ? warga['nama_lengkap'] ?? 'Nama tidak tersedia'
                        : 'Nama tidak tersedia',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIK: ${warga != null ? warga['nik'] ?? '-' : '-'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Status chip
            _buildStatusChip(item.statusPenerimaan ?? '-'),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String statusText = _getStatusText(status);

    switch (status.toUpperCase()) {
      case 'DIJADWALKAN':
        backgroundColor = AppTheme.processedColor;
        break;
      case 'AKTIF':
        backgroundColor = AppTheme.scheduledColor;
        break;
      case 'TERLAKSANA':
        backgroundColor = AppTheme.completedColor;
        break;
      case 'BATALTERLAKSANA':
        backgroundColor = AppTheme.errorColor;
        break;
      default:
        backgroundColor = AppTheme.infoColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String statusText = _getStatusPenerimaanText(status);

    // Konversi status ke format yang diinginkan
    if (status.toUpperCase() == 'DITERIMA') {
      backgroundColor = AppTheme.successColor;
      statusText = 'Sudah Menerima';
    } else {
      // Semua status selain DITERIMA dianggap sebagai BELUMMENERIMA
      backgroundColor = AppTheme.warningColor;
      statusText = 'Belum Menerima';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final status = controller.penyaluran.value?.status?.toUpperCase() ?? '';

    if (controller.isProcessing.value) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Container untuk tombol-tombol
    Widget buildButtonContainer(List<Widget> children) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: children,
        ),
      );
    }

    // Tombol Batalkan yang digunakan berulang
    Widget cancelButton = Expanded(
      child: OutlinedButton.icon(
        icon: const Icon(Icons.cancel),
        label: const Text('Batalkan'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorColor,
          side: const BorderSide(color: AppTheme.errorColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () => _showBatalkanDialog(context),
      ),
    );

    if (status == 'AKTIF') {
      return buildButtonContainer([
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Selesaikan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: controller.selesaikanPenyaluran,
          ),
        ),
        const SizedBox(width: 12),
        cancelButton,
      ]);
    } else if (status == 'DIJADWALKAN') {
      return buildButtonContainer([cancelButton]);
    }

    // Untuk status lainnya tidak menampilkan tombol
    return const SizedBox.shrink();
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showKonfirmasiPenerimaan(
      BuildContext context, PenerimaPenyaluranModel penerima) {
    // Dapatkan data jumlah bantuan dari penerima
    final jumlahBantuan = penerima.jumlahBantuan?.toString() ?? '5';

    // Navigasi ke halaman konfirmasi penerima
    Get.to(
      () => KonfirmasiPenerimaPage(
        penerima: penerima,
        bentukBantuan:
            null, // Tidak ada data bentuk bantuan yang tersedia langsung
        jumlahBantuan: jumlahBantuan,
        tanggalPenyaluran: controller.penyaluran.value?.tanggalPenyaluran,
      ),
    )?.then((result) {
      if (result == true) {
        // Refresh data jika konfirmasi berhasil
        controller.refreshData();
      }
    });
  }

  void _showBatalkanDialog(BuildContext context) {
    final TextEditingController alasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Penyaluran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan alasan pembatalan penyaluran:'),
            const SizedBox(height: 16),
            TextField(
              controller: alasanController,
              decoration: const InputDecoration(
                hintText: 'Alasan pembatalan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (alasanController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Alasan pembatalan tidak boleh kosong',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              controller.batalkanPenyaluran(alasanController.text.trim());
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  void _showDetailPenerima(
      BuildContext context, PenerimaPenyaluranModel penerima) {
    final warga = penerima.warga;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Biodata Singkat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Divider(height: 30),
                if (warga != null) ...[
                  _buildInfoRow('Nama', warga['nama_lengkap'] ?? '-'),
                  _buildInfoRow('NIK', warga['nik'] ?? '-'),
                  _buildInfoRow('Alamat Lengkap',
                      '${warga['alamat'] ?? '-'} Desa ${warga['desa'] ?? '-'} Kecamatan ${warga['kecamatan'] ?? '-'} Kabupaten ${warga['kabupaten'] ?? '-'} Provinsi ${warga['provinsi'] ?? '-'}'),
                  _buildInfoRow('Jenis Kelamin', warga['jenis_kelamin'] ?? '-'),
                  _buildInfoRow('No. Telepon', warga['no_hp'] ?? '-'),
                ],
                const Divider(height: 30),
                _buildInfoRow('Status Penerimaan',
                    _getStatusPenerimaanText(penerima.statusPenerimaan ?? '-')),
                if (penerima.tanggalPenerimaan != null)
                  _buildInfoRow('Tanggal Penerimaan',
                      DateFormatter.formatDate(penerima.tanggalPenerimaan!)),
                if (penerima.jumlahBantuan != null)
                  _buildInfoRow(
                      'Jumlah Bantuan', penerima.jumlahBantuan.toString()),
                if (penerima.keterangan != null &&
                    penerima.keterangan!.isNotEmpty)
                  _buildInfoRow('Keterangan', penerima.keterangan!),
                if (penerima.buktiPenerimaan != null &&
                    penerima.buktiPenerimaan!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Bukti Penerimaan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      penerima.buktiPenerimaan!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text('Gagal memuat gambar'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                if (controller.penyaluran.value?.status?.toUpperCase() ==
                        'AKTIF' &&
                    penerima.statusPenerimaan?.toUpperCase() != 'DITERIMA') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        'Konfirmasi Penerimaan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showKonfirmasiPenerimaan(context, penerima);
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'DIJADWALKAN':
        return 'Terjadwal';
      case 'AKTIF':
        return 'Aktif';
      case 'TERLAKSANA':
        return 'Terlaksana';
      case 'BATALTERLAKSANA':
        return 'Batal Terlaksana';
      default:
        return status;
    }
  }

  String _getStatusPenerimaanText(String status) {
    // Konversi status ke format yang diinginkan
    if (status.toUpperCase() == 'DITERIMA') {
      return 'Sudah Menerima';
    } else {
      // Semua status selain DITERIMA dianggap sebagai BELUMMENERIMA
      return 'Belum Menerima';
    }
  }

  Widget _buildPembatalanSection(BuildContext context) {
    final penyaluran = controller.penyaluran.value!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.errorColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.cancel_outlined,
                  color: AppTheme.errorColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Informasi Pembatalan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Status', 'Batal Terlaksana'),
            if (penyaluran.tanggalSelesai != null)
              _buildInfoRow('Tanggal Pembatalan',
                  DateFormatter.formatDateTime(penyaluran.tanggalSelesai!)),
            const SizedBox(height: 8),
            const Text(
              'Alasan Pembatalan:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                penyaluran.alasanPembatalan!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
