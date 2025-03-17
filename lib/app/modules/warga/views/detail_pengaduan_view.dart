import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/pengaduan_model.dart';
import 'package:penyaluran_app/app/data/models/tindakan_pengaduan_model.dart';
import 'package:penyaluran_app/app/modules/warga/controllers/warga_dashboard_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class WargaDetailPengaduanView extends GetView<WargaDashboardController> {
  const WargaDetailPengaduanView({Key? key}) : super(key: key);

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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
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
            const Text(
              'Informasi Penyaluran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Nama Penyaluran', pengaduan.namaPenyaluran),
            _buildInfoRow('Jenis Bantuan', pengaduan.jenisBantuan),
            _buildInfoRow('Jumlah Bantuan', pengaduan.jumlahBantuan),
            _buildInfoRow('Deskripsi', pengaduan.deskripsiPenyaluran),
          ],
        ),
      ),
    );
  }

  Widget _buildTindakanTimeline(
    BuildContext context,
    List<TindakanPengaduanModel> tindakanList,
  ) {
    if (tindakanList.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Pengaduan Anda sedang menunggu tindakan dari petugas',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        ),
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
            const Text(
              'Riwayat Tindakan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tindakan.kategoriTindakanText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: dotColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tindakan.statusTindakanText,
                    style: TextStyle(
                      color: dotColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tindakan.tindakan ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            if (tindakan.hasilTindakan != null &&
                tindakan.hasilTindakan!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Hasil: ${tindakan.hasilTindakan}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            const SizedBox(height: 8),
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
                      ? DateFormat('dd MMM yyyy', 'id_ID')
                          .format(tindakan.tanggalTindakan!)
                      : '-',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TambahTindakanPengaduanView extends StatefulWidget {
  final String pengaduanId;

  const TambahTindakanPengaduanView({Key? key, required this.pengaduanId})
      : super(key: key);

  @override
  State<TambahTindakanPengaduanView> createState() =>
      _TambahTindakanPengaduanViewState();
}

class _TambahTindakanPengaduanViewState
    extends State<TambahTindakanPengaduanView> {
  final formKey = GlobalKey<FormState>();
  final tindakanController = TextEditingController();
  final catatanController = TextEditingController();
  String? selectedKategori;
  String? selectedPrioritas;

  // List untuk menyimpan path file lokal
  final List<String> buktiTindakanPaths = [];
  bool isUploading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tindakan Pengaduan'),
        elevation: 0,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategori Tindakan
              Text(
                'Kategori Tindakan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Pilih kategori tindakan'),
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
                  setState(() {
                    selectedKategori = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih kategori tindakan';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Prioritas
              Text(
                'Prioritas',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Pilih prioritas'),
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
                  setState(() {
                    selectedPrioritas = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih prioritas tindakan';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Deskripsi Tindakan
              Text(
                'Deskripsi Tindakan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: tindakanController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Jelaskan tindakan yang dilakukan',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tindakan tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Catatan (opsional)
              Text(
                'Catatan (opsional)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: catatanController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Tambahkan catatan jika diperlukan',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Bukti Tindakan
              Text(
                'Bukti Tindakan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),

              // Area upload bukti tindakan
              if (buktiTindakanPaths.isEmpty)
                InkWell(
                  onTap: () => _showPilihSumberFoto(context),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 48,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tambah Bukti Tindakan',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: buktiTindakanPaths.length +
                            1, // +1 untuk tombol tambah
                        itemBuilder: (context, index) {
                          if (index == buktiTindakanPaths.length) {
                            // Tombol tambah foto
                            return InkWell(
                              onTap: () => _showPilihSumberFoto(context),
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 32,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tambah',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Tampilkan foto yang sudah diambil
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () => _showFullScreenImage(
                                    context, buktiTindakanPaths[index]),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(
                                          File(buktiTindakanPaths[index])),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      buktiTindakanPaths.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isUploading ? null : _simpanTindakan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPilihSumberFoto(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Foto',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                _pickBuktiTindakan(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                _pickBuktiTindakan(false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBuktiTindakan(bool fromCamera) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedFile != null) {
        setState(() {
          buktiTindakanPaths.add(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil gambar: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        size: 50,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simpanTindakan() async {
    if (formKey.currentState!.validate()) {
      if (buktiTindakanPaths.isEmpty) {
        Get.snackbar(
          'Error',
          'Bukti tindakan harus diupload',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      setState(() {
        isUploading = true;
      });

      try {
        // Di sini kita baru melakukan upload file ke server
        // Contoh implementasi:

        // 1. Upload semua file bukti tindakan
        // final List<String> buktiTindakanUrls = await uploadMultipleFiles(buktiTindakanPaths);

        // 2. Simpan data tindakan ke database
        // await saveTindakanPengaduan(
        //   pengaduanId: widget.pengaduanId,
        //   kategoriTindakan: selectedKategori!,
        //   prioritas: selectedPrioritas!,
        //   tindakan: tindakanController.text,
        //   catatan: catatanController.text,
        //   buktiTindakanUrls: buktiTindakanUrls,
        // );

        // Tampilkan pesan sukses
        Get.back(); // Kembali ke halaman sebelumnya
        Get.snackbar(
          'Sukses',
          'Tindakan berhasil disimpan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print('Error saving tindakan: $e');
        Get.snackbar(
          'Error',
          'Gagal menyimpan tindakan: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          isUploading = false;
        });
      }
    }
  }
}
