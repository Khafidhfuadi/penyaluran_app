import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/tindakan_pengaduan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/pengaduan_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/widgets/cards/info_card.dart';
import 'package:penyaluran_app/app/widgets/indicators/status_pill.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class DetailPengaduanView extends GetView<PengaduanController> {
  const DetailPengaduanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String pengaduanId = args['id'] ?? '';

    if (pengaduanId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Pengaduan'),
        ),
        body: const Center(
          child: Text('ID Pengaduan tidak valid'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengaduan'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Panduan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStatusGuide(context),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: controller.getDetailPengaduan(pengaduanId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data;
          if (data == null || data['pengaduan'] == null) {
            return const Center(
              child: Text('Data pengaduan tidak ditemukan'),
            );
          }

          final pengaduan = PengaduanModel.fromJson(data['pengaduan']);
          final List<TindakanPengaduanModel> tindakanList =
              (data['tindakan'] as List)
                  .map((item) => TindakanPengaduanModel.fromJson(item))
                  .toList();

          return _buildDetailContent(context, pengaduan, tindakanList);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTambahTindakanDialog(context, pengaduanId);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    PengaduanModel pengaduan,
    List<TindakanPengaduanModel> tindakanList,
  ) {
    // Tentukan status dan warna
    Color statusColor;
    String statusText;

    switch (pengaduan.status?.toUpperCase()) {
      case 'MENUNGGU':
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      case 'TINDAKAN':
        statusColor = Colors.blue;
        statusText = 'Tindakan';
        break;
      case 'SELESAI':
        statusColor = Colors.green;
        statusText = 'Selesai';
        break;
      default:
        statusColor = Colors.grey;
        statusText = pengaduan.status ?? 'Tidak Diketahui';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan status
          _buildHeaderWithStatus(context, pengaduan, statusColor, statusText),

          const SizedBox(height: 24),

          // Informasi pengaduan
          _buildPengaduanInfo(context, pengaduan),

          const SizedBox(height: 24),

          // Informasi penyaluran yang diadukan
          if (pengaduan.penerimaPenyaluran != null)
            _buildPenyaluranInfo(context, pengaduan),

          const SizedBox(height: 24),

          // Timeline tindakan
          _buildTindakanTimeline(context, tindakanList),
        ],
      ),
    );
  }

  Widget _buildStatusGuide(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Alur Status Pengaduan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildStatusGuideItem(
                'MENUNGGU',
                'Pengaduan baru yang belum ditindaklanjuti',
                Colors.orange,
                Icons.hourglass_empty,
              ),
              const SizedBox(height: 8),
              _buildStatusGuideItem(
                'TINDAKAN',
                'Pengaduan sedang dalam proses penanganan',
                Colors.blue,
                Icons.engineering,
              ),
              const SizedBox(height: 8),
              _buildStatusGuideItem(
                'SELESAI',
                'Pengaduan telah selesai ditangani',
                Colors.green,
                Icons.check_circle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Status Tindakan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildTindakanStatusItem(
              'PROSES',
              'Dalam Proses',
              'Tindakan sedang dilakukan',
              Colors.blue,
              Icons.sync,
            ),
            const SizedBox(height: 8),
            _buildTindakanStatusItem(
              'SELESAI',
              'Selesai',
              'Tindakan telah selesai',
              Colors.green,
              Icons.check_circle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusGuideItem(
    String status,
    String description,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menggunakan StatusPill untuk status
              StatusPill(
                status: status,
                backgroundColor: color,
                textColor: Colors.white,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTindakanStatusItem(
    String status,
    String label,
    String description,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              // Menggunakan StatusPill untuk status tindakan
              StatusPill(
                status: label,
                backgroundColor: color,
                textColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithStatus(
    BuildContext context,
    PengaduanModel pengaduan,
    Color statusColor,
    String statusText,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pengaduan.judul ?? 'Pengaduan',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Menggunakan StatusPill untuk menampilkan status
                _getStatusPill(pengaduan.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              pengaduan.deskripsi ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  pengaduan.tanggalPengaduan != null
                      ? DateFormat('dd MMMM yyyy', 'id_ID')
                          .format(pengaduan.tanggalPengaduan!)
                      : '-',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Panel status pengaduan
            _buildStatusPanel(context, pengaduan),
          ],
        ),
      ),
    );
  }

  // Helper method untuk mendapatkan StatusPill berdasarkan status
  StatusPill _getStatusPill(String? status) {
    switch (status?.toUpperCase()) {
      case 'MENUNGGU':
        return StatusPill(
          status: 'Menunggu',
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
      case 'TINDAKAN':
        return StatusPill(
          status: 'Tindakan',
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
      case 'SELESAI':
        return StatusPill.completed(status: 'Selesai');
      default:
        return StatusPill(
          status: status ?? 'Tidak Diketahui',
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
    }
  }

  Widget _buildStatusPanel(BuildContext context, PengaduanModel pengaduan) {
    final status = pengaduan.status?.toUpperCase() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Pengaduan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              // Tambahkan tombol untuk mengubah status
              if (status != 'SELESAI')
                TextButton.icon(
                  onPressed: () {
                    _showUbahStatusDialog(context, pengaduan);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Ubah Status'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusStep(
                  'MENUNGGU',
                  'Menunggu',
                  status == 'MENUNGGU',
                  status == 'MENUNGGU' ||
                      status == 'TINDAKAN' ||
                      status == 'SELESAI',
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatusStep(
                  'TINDAKAN',
                  'Tindakan',
                  status == 'TINDAKAN',
                  status == 'TINDAKAN' || status == 'SELESAI',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatusStep(
                  'SELESAI',
                  'Selesai',
                  status == 'SELESAI',
                  status == 'SELESAI',
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tombol aksi berdasarkan status
          if (status == 'MENUNGGU')
            ElevatedButton.icon(
              onPressed: () {
                _showTambahTindakanDialog(context, pengaduan.id!);
              },
              icon: const Icon(Icons.engineering),
              label: const Text('Tambah Tindakan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
            )
          else if (status == 'TINDAKAN')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showTambahTindakanDialog(context, pengaduan.id!);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Tindakan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showKonfirmasiSelesai(context, pengaduan.id!);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Selesaikan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else if (status == 'SELESAI')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pengaduan telah selesai ditangani',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(
    String statusValue,
    String label,
    bool isActive,
    bool isCompleted,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive
                ? color
                : (isCompleted ? color.withOpacity(0.3) : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    (statusValue == 'MENUNGGU'
                        ? '1'
                        : (statusValue == 'TINDAKAN' ? '2' : '3')),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? color : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showKonfirmasiSelesai(BuildContext context, String pengaduanId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Apakah Anda yakin ingin menyelesaikan pengaduan ini? Status pengaduan akan berubah menjadi SELESAI.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.selesaikanPengaduan(pengaduanId);
              Navigator.pop(context);
              Get.forceAppUpdate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Ya, Selesaikan'),
          ),
        ],
      ),
    );
  }

  Widget _buildPengaduanInfo(BuildContext context, PengaduanModel pengaduan) {
    final warga = pengaduan.warga;
    final String namaWarga = warga != null
        ? warga['nama_lengkap'] ?? 'Tidak diketahui'
        : 'Tidak diketahui';
    final String nikWarga = warga != null ? warga['nik'] ?? '-' : '-';
    final String alamatWarga = warga != null ? warga['alamat'] ?? '-' : '-';
    final String noHpWarga = warga != null ? warga['no_hp'] ?? '-' : '-';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Informasi Pelapor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            const Divider(height: 24),

            // Informasi pelapor
            _buildInfoRow('Nama', namaWarga),
            _buildInfoRow('NIK', nikWarga),
            _buildInfoRow('Alamat', alamatWarga),
            _buildInfoRow('No. HP', noHpWarga),
          ],
        ),
      ),
    );
  }

  Widget _buildPenyaluranInfo(BuildContext context, PengaduanModel pengaduan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul
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
                Icon(
                  Icons.inventory,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            const Divider(height: 24),

            // Informasi penyaluran
            _buildInfoRow('Nama Penyaluran', pengaduan.namaPenyaluran ?? '-'),
            _buildInfoRow('Jenis Bantuan', pengaduan.jenisBantuan ?? '-'),
            _buildInfoRow('Jumlah Bantuan', pengaduan.jumlahBantuan ?? '-'),
            _buildInfoRow('Deskripsi', pengaduan.deskripsiPenyaluran ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildTindakanTimeline(
    BuildContext context,
    List<TindakanPengaduanModel> tindakanList,
  ) {
    if (tindakanList.isEmpty) {
      return InfoCard(
        title: 'Belum Ada Tindakan',
        description: 'Belum ada tindakan untuk pengaduan ini',
        icon: Icons.info_outline,
        backgroundColor: Colors.grey.shade50,
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menggunakan SectionHeader untuk judul
            SectionHeader(
              title: 'Riwayat Tindakan',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tindakanList.length,
              itemBuilder: (context, index) {
                final tindakan = tindakanList[index];
                final bool isFirst = index == 0;
                final bool isLast = index == tindakanList.length - 1;

                return _buildTimelineTile(
                  context,
                  tindakan,
                  isFirst,
                  isLast,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile(
    BuildContext context,
    TindakanPengaduanModel tindakan,
    bool isFirst,
    bool isLast,
  ) {
    Color dotColor;
    switch (tindakan.statusTindakan) {
      case 'SELESAI':
        dotColor = Colors.green;
        break;
      case 'PROSES':
        dotColor = Colors.blue;
        break;
      default:
        dotColor = Colors.grey;
    }

    return TimelineTile(
      alignment: TimelineAlign.start,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 20,
        color: dotColor,
        iconStyle: IconStyle(
          color: Colors.white,
          iconData:
              tindakan.statusTindakan == 'SELESAI' ? Icons.check : Icons.sync,
        ),
      ),
      endChild: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan kategori dan status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tindakan.kategoriTindakanText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  children: [
                    // Menggunakan StatusPill untuk status tindakan
                    StatusPill(
                      status: tindakan.statusTindakanText,
                      backgroundColor: dotColor,
                      textColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    // Tombol edit
                    InkWell(
                      onTap: () {
                        _showEditTindakanDialog(context, tindakan);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Deskripsi tindakan
            Text(
              tindakan.tindakan ?? '',
              style: const TextStyle(fontSize: 14),
            ),

            // Catatan tindakan (jika ada)
            if (tindakan.catatan != null && tindakan.catatan!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Catatan: ${tindakan.catatan}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Hasil tindakan (jika ada)
            if (tindakan.hasilTindakan != null &&
                tindakan.hasilTindakan!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hasil Tindakan:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tindakan.hasilTindakan!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Bukti tindakan (jika ada)
            if (tindakan.buktiTindakan != null &&
                tindakan.buktiTindakan!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bukti Tindakan:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tindakan.buktiTindakan!.map((bukti) {
                        return Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    tindakan.buktiTindakan!.remove(bukti);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],

            // Feedback warga (jika ada)
            if (tindakan.feedbackWarga != null &&
                tindakan.feedbackWarga!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.comment,
                          size: 16,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Feedback Warga:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        const Spacer(),
                        if (tindakan.ratingWarga != null) ...[
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < (tindakan.ratingWarga ?? 0)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tindakan.feedbackWarga!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Footer dengan info petugas dan tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Oleh: ${tindakan.namaPetugas}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  tindakan.tanggalTindakan != null
                      ? DateFormat('dd MMM yyyy HH:mm', 'id_ID')
                          .format(tindakan.tanggalTindakan!)
                      : '-',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // Prioritas tindakan (jika ada)
            if (tindakan.prioritas != null) ...[
              const SizedBox(height: 8),
              // Menggunakan StatusPill untuk prioritas tindakan
              StatusPill(
                status: tindakan.prioritasText,
                backgroundColor: _getPriorityColor(tindakan.prioritas),
                textColor: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'TINGGI':
        return Colors.red;
      case 'SEDANG':
        return Colors.orange;
      case 'RENDAH':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showTambahTindakanDialog(BuildContext context, String pengaduanId) {
    final formKey = GlobalKey<FormState>();
    final tindakanController = TextEditingController();
    final catatanController = TextEditingController();
    String? selectedKategori;
    String? selectedPrioritas;

    // Gunakan RxList untuk bukti tindakan
    final buktiTindakanList = <String>[].obs;
    final isUploading = false.obs;

    final List<String> kategoriOptions = [
      'VERIFIKASI_DATA',
      'KUNJUNGAN_LAPANGAN',
      'KOORDINASI_LINTAS_INSTANSI',
      'PERBAIKAN_DATA_PENERIMA',
      'PENYALURAN_ULANG',
      'PENGGANTIAN_BANTUAN',
      'MEDIASI',
      'KLARIFIKASI',
      'PENYESUAIAN_JUMLAH_BANTUAN',
      'PEMERIKSAAN_KUALITAS_BANTUAN',
      'PERBAIKAN_PROSES_DISTRIBUSI',
      'EDUKASI_PENERIMA',
      'PENYELESAIAN_ADMINISTRATIF',
      'INVESTIGASI_PENYALAHGUNAAN',
      'PELAPORAN_KE_PIHAK_BERWENANG',
    ];

    final List<String> prioritasOptions = [
      'RENDAH',
      'SEDANG',
      'TINGGI',
    ];

    // Fungsi untuk mengunggah bukti tindakan
    Future<void> uploadBukti() async {
      try {
        isUploading.value = true;

        // Buka image picker untuk memilih file
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );

        if (pickedFile == null) {
          isUploading.value = false;
          return;
        }

        // Upload file ke Supabase Storage
        final String filePath = pickedFile.path;
        final String fileName = filePath.split('/').last;
        final String fileExt = fileName.split('.').last;
        final String fileKey =
            'bukti_tindakan_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        // Upload ke bucket tindakan_pengaduan
        await SupabaseService.to.client.storage
            .from('tindakan_pengaduan')
            .upload(
              fileKey,
              File(filePath),
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );

        // Dapatkan URL publik
        final String fileUrl = SupabaseService.to.client.storage
            .from('tindakan_pengaduan')
            .getPublicUrl(fileKey);

        // Tambahkan URL ke list bukti
        buktiTindakanList.add(fileUrl);

        Get.snackbar(
          'Berhasil',
          'Bukti berhasil diunggah',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print('Error uploading bukti: $e');
        Get.snackbar(
          'Error',
          'Gagal mengunggah bukti: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isUploading.value = false;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tindakan'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori Tindakan',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedKategori,
                  items: kategoriOptions.map((kategori) {
                    return DropdownMenuItem<String>(
                      value: kategori,
                      child: Text(
                        kategori
                            .split('_')
                            .map((word) =>
                                word[0].toUpperCase() +
                                word.substring(1).toLowerCase())
                            .join(' '),
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedKategori = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih kategori tindakan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Prioritas',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedPrioritas,
                  items: prioritasOptions.map((prioritas) {
                    return DropdownMenuItem<String>(
                      value: prioritas,
                      child: Text(
                        prioritas[0].toUpperCase() +
                            prioritas.substring(1).toLowerCase(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedPrioritas = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih prioritas tindakan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: tindakanController,
                  decoration: const InputDecoration(
                    labelText: 'Tindakan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tindakan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: catatanController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Bukti tindakan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bukti Tindakan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            if (buktiTindakanList.isEmpty) {
                              return const Text(
                                'Belum ada bukti tindakan',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              );
                            } else {
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: buktiTindakanList.map((bukti) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Icon(
                                            Icons.insert_drive_file,
                                            color: Colors.blue.shade700,
                                            size: 36,
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: InkWell(
                                            onTap: () {
                                              buktiTindakanList.remove(bukti);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          }),
                          const SizedBox(height: 12),
                          Obx(() => ElevatedButton.icon(
                                onPressed:
                                    isUploading.value ? null : uploadBukti,
                                icon: isUploading.value
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.upload_file),
                                label: Text(isUploading.value
                                    ? 'Mengunggah...'
                                    : 'Tambah Bukti'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 40),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Buat objek tindakan
                  final Map<String, dynamic> tindakanData = {
                    'pengaduan_id': pengaduanId,
                    'tindakan': tindakanController.text,
                    'catatan': catatanController.text,
                    'status_tindakan': 'PROSES',
                    'prioritas': selectedPrioritas,
                    'kategori_tindakan': selectedKategori,
                    'tanggal_tindakan': DateTime.now().toIso8601String(),
                    'petugas_id': controller.user?.id,
                    'bukti_tindakan': buktiTindakanList.toList(),
                    'created_at': DateTime.now().toIso8601String(),
                    'updated_at': DateTime.now().toIso8601String(),
                  };

                  // Simpan tindakan langsung ke Supabase
                  await SupabaseService.to
                      .tambahTindakanPengaduan(tindakanData);

                  // Update status pengaduan
                  await SupabaseService.to
                      .updateStatusPengaduan(pengaduanId, 'TINDAKAN');

                  // Tutup dialog
                  Navigator.pop(context);

                  // Refresh halaman
                  Get.forceAppUpdate();

                  // Tampilkan snackbar
                  Get.snackbar(
                    'Berhasil',
                    'Tindakan berhasil ditambahkan',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  print('Error adding tindakan: $e');
                  Get.snackbar(
                    'Error',
                    'Gagal menambahkan tindakan: ${e.toString()}',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditTindakanDialog(
      BuildContext context, TindakanPengaduanModel tindakan) {
    final formKey = GlobalKey<FormState>();
    final tindakanController = TextEditingController(text: tindakan.tindakan);
    final catatanController = TextEditingController(text: tindakan.catatan);
    final hasilTindakanController =
        TextEditingController(text: tindakan.hasilTindakan);
    String? selectedKategori = tindakan.kategoriTindakan;
    String? selectedPrioritas = tindakan.prioritas;
    String? selectedStatus = tindakan.statusTindakan;

    // Gunakan RxList untuk bukti tindakan
    final buktiTindakanList = (tindakan.buktiTindakan ?? []).obs;
    final isUploading = false.obs;

    final List<String> kategoriOptions = [
      'VERIFIKASI_DATA',
      'KUNJUNGAN_LAPANGAN',
      'KOORDINASI_LINTAS_INSTANSI',
      'PERBAIKAN_DATA_PENERIMA',
      'PENYALURAN_ULANG',
      'PENGGANTIAN_BANTUAN',
      'MEDIASI',
      'KLARIFIKASI',
      'PENYESUAIAN_JUMLAH_BANTUAN',
      'PEMERIKSAAN_KUALITAS_BANTUAN',
      'PERBAIKAN_PROSES_DISTRIBUSI',
      'EDUKASI_PENERIMA',
      'PENYELESAIAN_ADMINISTRATIF',
      'INVESTIGASI_PENYALAHGUNAAN',
      'PELAPORAN_KE_PIHAK_BERWENANG',
    ];

    final List<String> prioritasOptions = [
      'RENDAH',
      'SEDANG',
      'TINGGI',
    ];

    final List<String> statusOptions = [
      'PROSES',
      'SELESAI',
    ];

    // Fungsi untuk mengunggah bukti tindakan
    Future<void> uploadBukti() async {
      try {
        isUploading.value = true;

        // Buka image picker untuk memilih file
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );

        if (pickedFile == null) {
          isUploading.value = false;
          return;
        }

        // Upload file ke Supabase Storage
        final String filePath = pickedFile.path;
        final String fileName = filePath.split('/').last;
        final String fileExt = fileName.split('.').last;
        final String fileKey =
            'bukti_tindakan_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        // Upload ke bucket tindakan_pengaduan
        await SupabaseService.to.client.storage
            .from('tindakan_pengaduan')
            .upload(
              fileKey,
              File(filePath),
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );

        // Dapatkan URL publik
        final String fileUrl = SupabaseService.to.client.storage
            .from('tindakan_pengaduan')
            .getPublicUrl(fileKey);

        // Tambahkan URL ke list bukti
        buktiTindakanList.add(fileUrl);

        Get.snackbar(
          'Berhasil',
          'Bukti berhasil diunggah',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print('Error uploading bukti: $e');
        Get.snackbar(
          'Error',
          'Gagal mengunggah bukti: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isUploading.value = false;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.edit,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Edit Tindakan'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panel informasi status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Tindakan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status tindakan menentukan apakah tindakan ini masih dalam proses atau sudah selesai. Jika semua tindakan selesai, pengaduan dapat diselesaikan.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status tindakan
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Status Tindakan',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: selectedStatus == 'SELESAI'
                        ? Colors.green.shade50
                        : Colors.blue.shade50,
                  ),
                  value: selectedStatus,
                  items: statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Row(
                        children: [
                          Icon(
                            status == 'PROSES'
                                ? Icons.sync
                                : Icons.check_circle,
                            color:
                                status == 'PROSES' ? Colors.blue : Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status == 'PROSES' ? 'Dalam Proses' : 'Selesai',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedStatus = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih status tindakan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kategori tindakan
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori Tindakan',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedKategori,
                  items: kategoriOptions.map((kategori) {
                    return DropdownMenuItem<String>(
                      value: kategori,
                      child: Text(
                        kategori
                            .split('_')
                            .map((word) =>
                                word[0].toUpperCase() +
                                word.substring(1).toLowerCase())
                            .join(' '),
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedKategori = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih kategori tindakan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Prioritas tindakan
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Prioritas',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: selectedPrioritas == 'TINGGI'
                        ? Colors.red.shade50
                        : (selectedPrioritas == 'SEDANG'
                            ? Colors.orange.shade50
                            : Colors.green.shade50),
                  ),
                  value: selectedPrioritas,
                  items: prioritasOptions.map((prioritas) {
                    Color priorityColor = prioritas == 'TINGGI'
                        ? Colors.red
                        : (prioritas == 'SEDANG'
                            ? Colors.orange
                            : Colors.green);

                    return DropdownMenuItem<String>(
                      value: prioritas,
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag,
                            color: priorityColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            prioritas[0].toUpperCase() +
                                prioritas.substring(1).toLowerCase(),
                            style: TextStyle(
                              fontSize: 14,
                              color: priorityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedPrioritas = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih prioritas tindakan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Deskripsi tindakan
                TextFormField(
                  controller: tindakanController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Tindakan',
                    border: OutlineInputBorder(),
                    hintText: 'Jelaskan tindakan yang dilakukan',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tindakan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Catatan tindakan
                TextFormField(
                  controller: catatanController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder(),
                    hintText: 'Tambahkan catatan jika diperlukan',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Hasil tindakan
                TextFormField(
                  controller: hasilTindakanController,
                  decoration: InputDecoration(
                    labelText: 'Hasil Tindakan',
                    border: const OutlineInputBorder(),
                    hintText: 'Jelaskan hasil dari tindakan yang dilakukan',
                    filled: true,
                    fillColor: Colors.blue.shade50,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Bukti tindakan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bukti Tindakan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            if (buktiTindakanList.isEmpty) {
                              return const Text(
                                'Belum ada bukti tindakan',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              );
                            } else {
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: buktiTindakanList.map((bukti) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Icon(
                                            Icons.insert_drive_file,
                                            color: Colors.blue.shade700,
                                            size: 36,
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: InkWell(
                                            onTap: () {
                                              buktiTindakanList.remove(bukti);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          }),
                          const SizedBox(height: 12),
                          Obx(() => ElevatedButton.icon(
                                onPressed:
                                    isUploading.value ? null : uploadBukti,
                                icon: isUploading.value
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.upload_file),
                                label: Text(isUploading.value
                                    ? 'Mengunggah...'
                                    : 'Tambah Bukti'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 40),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),

                // Informasi tentang feedback warga
                if (tindakan.feedbackWarga != null &&
                    tindakan.feedbackWarga!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.comment,
                              color: Colors.amber.shade800,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Feedback dari Warga',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (tindakan.ratingWarga != null) ...[
                          Row(
                            children: [
                              Text(
                                'Rating: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < (tindakan.ratingWarga ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          tindakan.feedbackWarga!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.shade900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Buat data update
                  final Map<String, dynamic> updateData = {
                    'tindakan': tindakanController.text,
                    'catatan': catatanController.text,
                    'hasil_tindakan': hasilTindakanController.text,
                    'status_tindakan': selectedStatus,
                    'prioritas': selectedPrioritas,
                    'kategori_tindakan': selectedKategori,
                    'bukti_tindakan': buktiTindakanList.toList(),
                    'updated_at': DateTime.now().toIso8601String(),
                  };

                  // Jika status berubah menjadi SELESAI, tambahkan tanggal verifikasi
                  if (selectedStatus == 'SELESAI' &&
                      tindakan.statusTindakan != 'SELESAI') {
                    updateData['tanggal_verifikasi'] =
                        DateTime.now().toIso8601String();
                  }

                  // Update tindakan
                  await SupabaseService.to
                      .updateTindakanPengaduan(tindakan.id!, updateData);

                  // Tutup dialog
                  Navigator.pop(context);

                  // Refresh halaman
                  Get.forceAppUpdate();

                  // Tampilkan snackbar
                  Get.snackbar(
                    'Berhasil',
                    'Tindakan berhasil diperbarui',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  print('Error updating tindakan: $e');
                  Get.snackbar(
                    'Error',
                    'Gagal memperbarui tindakan: ${e.toString()}',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }

  void _showUbahStatusDialog(BuildContext context, PengaduanModel pengaduan) {
    final String currentStatus = pengaduan.status?.toUpperCase() ?? '';
    String selectedStatus = currentStatus;

    final List<String> statusOptions = [
      'MENUNGGU',
      'TINDAKAN',
      'SELESAI',
    ];

    // Hapus status yang sama dengan status saat ini dari opsi
    statusOptions.remove(currentStatus);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Status Pengaduan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status saat ini:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _getStatusPill(currentStatus),
            const SizedBox(height: 16),
            const Text(
              'Pilih status baru:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...statusOptions.map((status) => RadioListTile<String>(
                  title: Text(
                    status == 'MENUNGGU'
                        ? 'Menunggu'
                        : (status == 'TINDAKAN' ? 'Tindakan' : 'Selesai'),
                  ),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    selectedStatus = value!;
                    Navigator.pop(context);
                    _showKonfirmasiUbahStatus(
                        context, pengaduan.id!, selectedStatus);
                  },
                  activeColor: status == 'MENUNGGU'
                      ? Colors.orange
                      : (status == 'TINDAKAN' ? Colors.blue : Colors.green),
                  secondary: Icon(
                    status == 'MENUNGGU'
                        ? Icons.hourglass_empty
                        : (status == 'TINDAKAN'
                            ? Icons.engineering
                            : Icons.check_circle),
                    color: status == 'MENUNGGU'
                        ? Colors.orange
                        : (status == 'TINDAKAN' ? Colors.blue : Colors.green),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showKonfirmasiUbahStatus(
      BuildContext context, String pengaduanId, String newStatus) {
    String statusText = newStatus == 'MENUNGGU'
        ? 'Menunggu'
        : (newStatus == 'TINDAKAN' ? 'Tindakan' : 'Selesai');

    Color statusColor = newStatus == 'MENUNGGU'
        ? Colors.orange
        : (newStatus == 'TINDAKAN' ? Colors.blue : Colors.green);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin mengubah status pengaduan menjadi "$statusText"?',
            ),
            const SizedBox(height: 16),
            if (newStatus == 'SELESAI')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.amber.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mengubah status menjadi Selesai akan menandai pengaduan ini telah selesai ditangani.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newStatus == 'SELESAI') {
                await controller.selesaikanPengaduan(pengaduanId);
              } else {
                // Gunakan fungsi prosesPengaduan untuk status TINDAKAN
                // atau fungsi khusus untuk status lainnya
                if (newStatus == 'TINDAKAN') {
                  await controller.prosesPengaduan(pengaduanId);
                } else {
                  // Tambahkan fungsi updateStatusPengaduan di controller
                  await controller.updateStatusPengaduan(
                      pengaduanId, newStatus);
                }
              }

              Navigator.pop(context);
              Get.forceAppUpdate();

              Get.snackbar(
                'Berhasil',
                'Status pengaduan berhasil diubah menjadi $statusText',
                snackPosition: SnackPosition.TOP,
                backgroundColor: statusColor,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: statusColor,
            ),
            child: const Text('Ya, Ubah Status'),
          ),
        ],
      ),
    );
  }
}
