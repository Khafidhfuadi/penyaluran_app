import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/detail_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:penyaluran_app/app/utils/format_helper.dart';

class KonfirmasiPenerimaPage extends StatefulWidget {
  final String penerimaPenyaluranId;
  final DateTime? tanggalPenyaluran;

  const KonfirmasiPenerimaPage({
    super.key,
    required this.penerimaPenyaluranId,
    this.tanggalPenyaluran,
  });

  @override
  State<KonfirmasiPenerimaPage> createState() => _KonfirmasiPenerimaPageState();
}

class _KonfirmasiPenerimaPageState extends State<KonfirmasiPenerimaPage> {
  PenerimaPenyaluranModel? penerima;
  final controller = Get.find<DetailPenyaluranController>();
  final ImagePicker _picker = ImagePicker();
  File? _buktiPenerimaan;
  bool _setujuPenerimaan = false;
  bool _setujuPenggunaan = false;
  bool _isLoading = false;
  bool _isDataLoading = true; // Loading state untuk data

  // Controller untuk tanda tangan
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: AppTheme.primaryColor,
    exportBackgroundColor: Colors.white,
  );

  // Untuk menyimpan gambar tanda tangan
  Uint8List? _signatureImage;

  @override
  void initState() {
    super.initState();
    // Mengambil data penerima berdasarkan ID
    _loadPenerimaPenyaluranData();
  }

  // Fungsi untuk mengambil data penerima dari database
  Future<void> _loadPenerimaPenyaluranData() async {
    setState(() {
      _isDataLoading = true;
    });

    try {
      // Ambil data penerima beserta relasinya menggunakan ID
      penerima = await controller
          .getPenerimaPenyaluranById(widget.penerimaPenyaluranId);

      if (penerima != null) {
        print('KonfirmasiPenerimaPage - ID Penerima: ${penerima!.id}');
        print(
            'KonfirmasiPenerimaPage - Nama Penerima: ${penerima!.warga?['nama_lengkap']}');

        // Jika penerima memiliki penyaluran_bantuan_id, ambil detail penyaluran
        if (penerima!.penyaluranBantuanId != null) {
          await controller.getDetailPenyaluran(penerima!.penyaluranBantuanId!);
        }
      }
    } catch (e) {
      print('Error saat mengambil data penerima: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data penerima, silakan coba lagi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Pastikan controller signature dibersihkan
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Jika data masih loading atau penerima null, tampilkan loading indicator
    if (_isDataLoading || penerima == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Konfirmasi Penerimaan'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              SizedBox(height: 16),
              Text(
                'Memuat data penerimaan...',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final warga = penerima!.warga;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Penerimaan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Sedang memproses konfirmasi...',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              color: Colors.grey[50],
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Form Konfirmasi Penerimaan Bantuan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Silahkan isi data-data berikut untuk mengkonfirmasi penerimaan bantuan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDetailPenerimaSection(warga),
                      const SizedBox(height: 16),
                      _buildDetailBantuanSection(),
                      const SizedBox(height: 16),
                      _buildFotoBuktiSection(),
                      const SizedBox(height: 16),
                      _buildTandaTanganSection(),
                      const SizedBox(height: 16),
                      _buildFormPersetujuanSection(),
                      const SizedBox(height: 24),
                      _buildKonfirmasiButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDetailPenerimaSection(Map<String, dynamic>? warga) {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Detail Penerima',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Foto & Identitas Utama
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto identitas
                  Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                      image: warga?['foto_profil'] != null
                          ? DecorationImage(
                              image: NetworkImage(warga!['foto_profil']),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: warga?['foto_profil'] == null
                        ? Icon(Icons.person, color: Colors.grey[400], size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Informasi identitas utama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warga?['nama_lengkap'] ?? 'Bajiyadi',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildKeyValueText(
                            'NIK', warga?['nik'] ?? '3201020107030010'),
                        const SizedBox(height: 4),
                        _buildKeyValueText(
                            'No KK', warga?['no_kk'] ?? '3201020107030393'),
                        const SizedBox(height: 4),
                        _buildKeyValueText(
                            'Telepon', warga?['no_telepon'] ?? '089891256532'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Informasi Personal
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Personal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.wc_outlined,
                          title: 'Jenis Kelamin',
                          value: warga?['jenis_kelamin'] ?? 'Pria',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.bookmark_outlined,
                          title: 'Agama',
                          value: warga?['agama'] ?? 'Islam',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    icon: Icons.cake_outlined,
                    title: 'Tempat, Tanggal Lahir',
                    value: warga?['tempat_lahir'] != null &&
                            warga?['tanggal_lahir'] != null
                        ? '${warga!['tempat_lahir']}, ${FormatHelper.formatDateTime(DateTime.parse(warga['tanggal_lahir']), format: 'd MMMM yyyy')}'
                        : 'Bogor, 2 Juni 1990',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Alamat
            _buildDetailItem(
              icon: Icons.home_outlined,
              title: 'Alamat',
              value: warga?['alamat'] ??
                  'Jl. Letda Natsir No. 22 RT 001/003\nKec. Gunung Putri Kab. Bogor',
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            // Pekerjaan & Pendidikan
            _buildDetailItem(
              icon: Icons.work_outline,
              title: 'Pekerjaan',
              value: warga?['pekerjaan'] ?? 'Petani',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.school_outlined,
              title: 'Pendidikan',
              value: warga?['pendidikan_terakhir'] ?? 'Sekolah Dasar (SD)',
              color: Colors.purple,
            ),
            const SizedBox(height: 12),

            // Email
            _buildDetailItem(
              icon: Icons.email_outlined,
              title: 'Email',
              value: warga?['email'] ?? 'bajiyadi@gmail.com',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValueText(String key, String value) {
    return Row(
      children: [
        Text(
          '$key: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blue[700]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBantuanSection() {
    // Tentukan satuan dan apakah bantuan berupa uang
    String satuan = '';
    bool isUang = false;

    // Ambil dari stok_bantuan jika tersedia (prioritas utama)
    if (penerima!.stokBantuan != null &&
        penerima!.stokBantuan!['satuan'] != null) {
      satuan = penerima!.stokBantuan!['satuan'];
      // Cek apakah bantuan berupa uang dari stok_bantuan
      isUang = penerima!.stokBantuan!['is_uang'] ?? false;
    } else if (penerima!.satuan != null) {
      // Ambil dari property satuan di model (sudah diambil dari relasi dalam fromJson)
      satuan = penerima!.satuan!;
      isUang = penerima!.isUang ?? false;
    } else {
      // Default jika tidak ada informasi satuan
      satuan = 'buah';
      isUang = false;
    }

    // Tentukan tanggal dan waktu penyaluran
    String tanggalWaktuPenyaluran = '';
    if (widget.tanggalPenyaluran != null) {
      final tanggal = FormatHelper.formatDateTime(widget.tanggalPenyaluran!);
      tanggalWaktuPenyaluran = tanggal;
    } else if (penerima!.penyaluranBantuan != null &&
        penerima!.penyaluranBantuan!['tanggal_penyaluran'] != null) {
      final tanggalPenyaluran =
          DateTime.parse(penerima!.penyaluranBantuan!['tanggal_penyaluran']);

      final tanggal = FormatHelper.formatDateTime(tanggalPenyaluran);

      tanggalWaktuPenyaluran = tanggal;
    } else {
      tanggalWaktuPenyaluran = 'Belum terjadwal';
    }

    // Ambil nama bantuan dari model jika tersedia
    String namaBantuan = '';
    if (penerima!.stokBantuan != null &&
        penerima!.stokBantuan!['nama'] != null) {
      // Ambil dari stok_bantuan (prioritas utama)
      namaBantuan = penerima!.stokBantuan!['nama'];
    } else if (penerima!.kategoriNama != null &&
        penerima!.kategoriNama!.isNotEmpty) {
      namaBantuan = penerima!.kategoriNama!;
    } else if (penerima!.penyaluranBantuan?['kategori']?['nama'] != null) {
      namaBantuan = penerima!.penyaluranBantuan!['kategori']['nama'];
    } else {
      namaBantuan = '';
    }

    // Ambil jumlah bantuan dari property jumlahBantuan di model
    String jumlahBantuan = '';
    if (penerima!.jumlahBantuan != null) {
      jumlahBantuan = penerima!.jumlahBantuan.toString();
    } else if (penerima!.penyaluranBantuan?['jumlah'] != null) {
      jumlahBantuan = penerima!.penyaluranBantuan!['jumlah'].toString();
    } else {
      jumlahBantuan = '1';
    }

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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isUang
                        ? Icons.payments_outlined
                        : Icons.inventory_2_outlined,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Informasi Penerimaan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Informasi Bantuan dalam Card berwarna
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[50]!,
                    Colors.blue[100]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Bentuk Bantuan
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isUang
                              ? Icons.account_balance_wallet_outlined
                              : Icons.category_outlined,
                          color: Colors.indigo,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUang ? 'Jenis Bantuan Uang' : 'Jenis Bantuan',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              namaBantuan,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Colors.white),
                  const SizedBox(height: 12),

                  // Nilai Bantuan
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isUang ? Icons.attach_money : Icons.scale_outlined,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUang ? 'Nilai Bantuan' : 'Jumlah Bantuan',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                if (isUang)
                                  Text(
                                    'Rp ${FormatHelper.formatNumber(double.tryParse(jumlahBantuan) ?? 0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  )
                                else
                                  Text(
                                    jumlahBantuan,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                if (!isUang) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    satuan,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Colors.white),
                  const SizedBox(height: 12),

                  // Tanggal Penyaluran
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.event_outlined,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal & Waktu Penyaluran',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              tanggalWaktuPenyaluran,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoBuktiSection() {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Foto Bukti Penerimaan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Deskripsi Singkat
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ambil foto penerima bersama bantuan yang diberikan sebagai bukti penerimaan',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Area Foto
            GestureDetector(
              onTap: _ambilFoto,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _buktiPenerimaan != null
                        ? Colors.transparent
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: _buktiPenerimaan != null
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: _buktiPenerimaan != null
                    ? Stack(
                        children: [
                          // Foto yang dipilih
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _buktiPenerimaan!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 180,
                            ),
                          ),

                          // Tombol ganti foto
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Ubah Foto',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.purple[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tambah Foto Bukti',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ketuk untuk mengambil foto',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTandaTanganSection() {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.draw_outlined,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tanda Tangan Digital',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Deskripsi Tanda Tangan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bubuhkan tanda tangan penerima bantuan di area yang disediakan',
                      style: TextStyle(
                        color: Colors.amber[900],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Area tanda tangan dengan badge status
            Stack(
              children: [
                // Area tanda tangan
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _signatureImage != null
                          ? Colors.blue[300]!
                          : Colors.grey[300]!,
                      width: _signatureImage != null ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: _signatureImage != null
                        ? Image.memory(
                            _signatureImage!,
                            fit: BoxFit.contain,
                          )
                        : Signature(
                            controller: _signatureController,
                            backgroundColor: Colors.white,
                            height: 200,
                            width: double.infinity,
                          ),
                  ),
                ),

                // Badge status (jika tanda tangan sudah disimpan)
                if (_signatureImage != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Tersimpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Tombol aksi untuk tanda tangan
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol hapus tanda tangan
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _signatureController.clear();
                        _signatureImage = null;
                      });
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red[800],
                      backgroundColor: Colors.red[50],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Tombol simpan tanda tangan
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveSignature,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPersetujuanSection() {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.gavel_outlined,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Form Persetujuan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Deskripsi Persetujuan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                'Dengan menandatangani dan mencentang pernyataan berikut, penerima menyatakan telah menerima bantuan sesuai dengan jumlah dan kondisi yang tertera.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Checkbox persetujuan 1 dengan card
            Container(
              decoration: BoxDecoration(
                color: _setujuPenerimaan ? Colors.green[50] : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _setujuPenerimaan
                      ? Colors.green[300]!
                      : Colors.grey[300]!,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _setujuPenerimaan = !_setujuPenerimaan;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _setujuPenerimaan,
                          onChanged: (value) {
                            setState(() {
                              _setujuPenerimaan = value ?? false;
                            });
                          },
                          activeColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pernyataan Penerimaan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Saya telah menerima bantuan dengan jumlah dan kondisi yang sesuai.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (_setujuPenerimaan)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Checkbox persetujuan 2 dengan card
            Container(
              decoration: BoxDecoration(
                color: _setujuPenggunaan ? Colors.green[50] : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _setujuPenggunaan
                      ? Colors.green[300]!
                      : Colors.grey[300]!,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _setujuPenggunaan = !_setujuPenggunaan;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _setujuPenggunaan,
                          onChanged: (value) {
                            setState(() {
                              _setujuPenggunaan = value ?? false;
                            });
                          },
                          activeColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pernyataan Penggunaan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Saya akan menggunakan bantuan dengan sebaik-baiknya',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (_setujuPenggunaan)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKonfirmasiButton() {
    final bool isFormValid = _setujuPenerimaan &&
        _setujuPenggunaan &&
        _signatureImage != null &&
        _buktiPenerimaan != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isFormValid
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_setujuPenerimaan ||
              !_setujuPenggunaan ||
              _signatureImage == null ||
              _buktiPenerimaan == null)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange[700],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Harap lengkapi semua data untuk konfirmasi',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ElevatedButton(
            onPressed: isFormValid ? _konfirmasiPenerimaan : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[600],
              elevation: isFormValid ? 0 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isFormValid ? Icons.check_circle_outline : Icons.lock_outline,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Konfirmasi Penerimaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Status indikator
          if (!isFormValid)
            Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusIndicator(
                        _setujuPenerimaan && _setujuPenggunaan, 'Persetujuan'),
                    const SizedBox(width: 12),
                    _buildStatusIndicator(
                        _signatureImage != null, 'Tanda Tangan'),
                    const SizedBox(width: 12),
                    _buildStatusIndicator(
                        _buktiPenerimaan != null, 'Foto Bukti'),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool isComplete, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isComplete ? Colors.green[600] : Colors.grey[400],
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isComplete ? Colors.green[600] : Colors.grey[600],
            fontWeight: isComplete ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Future<void> _ambilFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _buktiPenerimaan = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _saveSignature() async {
    if (_signatureController.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Tanda tangan tidak boleh kosong',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Mendapatkan data tanda tangan
    final signature = await _signatureController.toPngBytes();

    if (signature != null) {
      setState(() {
        _signatureImage = signature;
      });

      Get.snackbar(
        'Sukses',
        'Tanda tangan berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _konfirmasiPenerimaan() async {
    if (!_setujuPenerimaan || !_setujuPenggunaan) {
      Get.snackbar(
        'Perhatian',
        'Anda harus menyetujui semua persyaratan',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_signatureImage == null) {
      Get.snackbar(
        'Perhatian',
        'Tanda tangan digital diperlukan',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_buktiPenerimaan == null) {
      Get.snackbar(
        'Perhatian',
        'Foto bukti penerimaan diperlukan',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Directory? tempDir;
    File? signatureFile;

    try {
      String imageUrl = '';
      String signatureUrl = '';

      // Upload bukti penerimaan
      try {
        imageUrl =
            await controller.uploadBuktiPenerimaan(_buktiPenerimaan!.path);
      } catch (e) {
        throw Exception('Gagal mengupload bukti penerimaan: $e');
      }

      // Simpan tanda tangan ke file sementara dan upload
      try {
        tempDir = await Directory.systemTemp.createTemp('signature');
        signatureFile = File('${tempDir.path}/signature.png');
        await signatureFile.writeAsBytes(_signatureImage!);

        signatureUrl = await controller.uploadBuktiPenerimaan(
          signatureFile.path,
          isTandaTangan: true,
        );
      } catch (e) {
        throw Exception('Gagal mengupload tanda tangan: $e');
      }

      // Konfirmasi penerimaan
      try {
        await controller.konfirmasiPenerimaan(
          penerima!,
          buktiPenerimaan: imageUrl,
          tandaTangan: signatureUrl,
        );
      } catch (e) {
        throw Exception('Gagal melakukan konfirmasi penerimaan: $e');
      }

      // Hapus file sementara sebelum navigasi
      if (signatureFile.existsSync()) {
        await signatureFile.delete();
      }
      if (tempDir.existsSync()) {
        await tempDir.delete();
      }

      // Tutup semua snackbar yang mungkin masih terbuka
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }

      // Kembali ke halaman sebelumnya dengan hasil true (berhasil)
      // Gunakan Get.back(result: true) untuk kembali ke halaman detail penyaluran
      // dengan membawa hasil bahwa konfirmasi berhasil
      Get.back(result: true);

      // Tampilkan snackbar sukses di halaman detail penyaluran
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Sukses',
          'Konfirmasi penerimaan bantuan berhasil',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      });
    } catch (e) {
      // Tampilkan pesan error
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // Hapus file sementara jika belum dihapus
      try {
        if (signatureFile != null && signatureFile.existsSync()) {
          await signatureFile.delete();
        }
        if (tempDir != null && tempDir.existsSync()) {
          await tempDir.delete();
        }
      } catch (e) {
        print('Error saat menghapus file sementara: $e');
      }

      // Pastikan state loading diatur kembali ke false
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
