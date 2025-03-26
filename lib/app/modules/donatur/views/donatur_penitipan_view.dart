import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/skema_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'dart:io';

class DonaturPenitipanView extends GetView<DonaturDashboardController> {
  const DonaturPenitipanView({super.key});

  @override
  DonaturDashboardController get controller {
    if (!Get.isRegistered<DonaturDashboardController>(
        tag: 'donatur_dashboard')) {
      return Get.put(DonaturDashboardController(),
          tag: 'donatur_dashboard', permanent: true);
    }
    return Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return FormPenitipanBantuan();
  }
}

class DonaturRiwayatPenitipanView extends GetView<DonaturDashboardController> {
  DonaturRiwayatPenitipanView({Key? key}) : super(key: key);

  @override
  DonaturDashboardController get controller {
    return Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
  }

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Penitipan'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Menunggu'),
              Tab(text: 'Diterima'),
              Tab(text: 'Ditolak'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Menunggu
            _buildPenitipanList(context, 'MENUNGGU'),
            // Tab Diterima
            _buildPenitipanList(context, 'DITERIMA'),
            // Tab Ditolak
            _buildPenitipanList(context, 'DITOLAK'),
          ],
        ),
      ),
    );
  }

  Widget _buildPenitipanList(BuildContext context, String status) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Filter penitipan berdasarkan status
      var filteredList = controller.penitipanBantuan
          .where((item) => item.status == status)
          .toList();

      // Filter berdasarkan pencarian
      final searchText = searchController.text.toLowerCase();
      if (searchText.isNotEmpty) {
        filteredList = filteredList.where((item) {
          final kategoriNama = item.kategoriBantuan?.nama?.toLowerCase() ?? '';
          final deskripsi = item.deskripsi?.toLowerCase() ?? '';
          final tanggal = item.tanggalPenitipan != null
              ? DateFormat('dd MMMM yyyy', 'id_ID')
                  .format(item.tanggalPenitipan!)
                  .toLowerCase()
              : '';

          return kategoriNama.contains(searchText) ||
              deskripsi.contains(searchText) ||
              tanggal.contains(searchText);
        }).toList();
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchPenitipanBantuan();
        },
        child: filteredList.isEmpty
            ? _buildEmptyState(status)
            : _buildContentList(context, filteredList, status),
      );
    });
  }

  Widget _buildEmptyState(String status) {
    String statusText = '';
    switch (status) {
      case 'MENUNGGU':
        statusText = 'menunggu verifikasi';
        break;
      case 'DITERIMA':
        statusText = 'diterima';
        break;
      case 'DITOLAK':
        statusText = 'ditolak';
        break;
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada penitipan $statusText',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Anda belum memiliki riwayat penitipan yang $statusText',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList(
      BuildContext context, List<dynamic> filteredList, String status) {
    Color statusColor;
    switch (status) {
      case 'DITERIMA':
        statusColor = Colors.green;
        break;
      case 'DITOLAK':
        statusColor = Colors.red;
        break;
      case 'MENUNGGU':
      default:
        statusColor = Colors.orange;
        break;
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari riwayat penitipan...',
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
                // Trigger update dengan GetX
                controller.update();
              },
            ),
            const SizedBox(height: 16),
            // Info jumlah item
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Penitipan ${status.toLowerCase()}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${filteredList.length} item',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Daftar penitipan
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return _buildPenitipanCard(
                    context, filteredList[index], statusColor);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenitipanCard(
      BuildContext context, dynamic penitipan, Color statusColor) {
    final formattedDate = penitipan.tanggalPenitipan != null
        ? DateFormat('dd MMMM yyyy', 'id_ID')
            .format(penitipan.tanggalPenitipan!)
        : 'Tanggal tidak tersedia';

    IconData statusIcon;

    switch (penitipan.status) {
      case 'DITERIMA':
        statusIcon = Icons.check_circle;
        break;
      case 'DITOLAK':
        statusIcon = Icons.cancel;
        break;
      case 'MENUNGGU':
      default:
        statusIcon = Icons.hourglass_empty;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                penitipan.kategoriBantuan?.nama ?? 'Bantuan',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                penitipan.status ?? 'MENUNGGU',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Jumlah: ${penitipan.jumlah ?? 0}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (penitipan.deskripsi != null &&
                  penitipan.deskripsi!.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  penitipan.deskripsi!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (penitipan.status == 'DITOLAK' &&
                  penitipan.alasanPenolakan != null &&
                  penitipan.alasanPenolakan!.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  'Alasan Penolakan:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  penitipan.alasanPenolakan!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FormPenitipanBantuan extends StatefulWidget {
  @override
  _FormPenitipanBantuanState createState() => _FormPenitipanBantuanState();
}

class _FormPenitipanBantuanState extends State<FormPenitipanBantuan> {
  final DonaturDashboardController controller =
      Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedStokBantuanId;
  String? selectedSkemaBantuanId;
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset foto bantuan saat form dibuka
    controller.resetFotoBantuan();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Formulir Penitipan Bantuan'),
              Text(
                'Isi formulir berikut untuk melakukan penitipan bantuan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Pilih metode penitipan
              Text(
                'Metode Penitipan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),

              // Tab pilihan metode
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedSkemaBantuanId = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedSkemaBantuanId == null
                                ? Colors.blue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Bantuan Manual',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedSkemaBantuanId == null
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            // Reset stok bantuan saat memilih skema
                            selectedStokBantuanId = null;
                            selectedSkemaBantuanId = '';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedSkemaBantuanId != null
                                ? Colors.blue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Dari Skema Bantuan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedSkemaBantuanId != null
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form berdasarkan pilihan
              if (selectedSkemaBantuanId != null) ...[
                // Form untuk skema bantuan
                Text(
                  'Pilih Skema Bantuan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    hintText: 'Pilih skema bantuan',
                  ),
                  value: selectedSkemaBantuanId == ''
                      ? null
                      : selectedSkemaBantuanId,
                  items: controller.skemaBantuan.map((skema) {
                    return DropdownMenuItem<String>(
                      value: skema.id,
                      child: Text(skema.nama ?? 'Tidak ada nama'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSkemaBantuanId = value;
                      // Jika skema dipilih, isi otomatis stok bantuan sesuai dengan skema
                      if (value != null) {
                        final selectedSkema =
                            controller.skemaBantuan.firstWhere(
                          (skema) => skema.id == value,
                          orElse: () => SkemaBantuanModel(),
                        );
                        selectedStokBantuanId = selectedSkema.stokBantuanId;

                        // Isi otomatis jumlah jika ada
                        if (selectedSkema.jumlahDiterimaPerOrang != null) {
                          jumlahController.text =
                              selectedSkema.jumlahDiterimaPerOrang.toString();
                        }
                      }
                    });
                  },
                  validator: (value) {
                    if (selectedSkemaBantuanId != null &&
                        (value == null || value.isEmpty)) {
                      return 'Skema bantuan harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Form untuk bantuan manual
                Text(
                  'Jenis Bantuan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    hintText: 'Pilih jenis bantuan',
                  ),
                  value: selectedStokBantuanId,
                  items: controller.getAvailableStokBantuan().map((stok) {
                    return DropdownMenuItem<String>(
                      value: stok.id,
                      child: Text(
                          '${stok.nama ?? 'Tidak ada nama'} (Stok: ${stok.totalStok ?? 0} ${stok.satuan ?? 'item'})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStokBantuanId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis bantuan harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Jumlah bantuan
              Text(
                'Jumlah Bantuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Masukkan jumlah bantuan',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Jumlah harus berupa angka';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi bantuan
              Text(
                'Deskripsi Bantuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: deskripsiController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Deskripsi bantuan yang dititipkan',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Foto bantuan
              Text(
                'Foto Bantuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),

              // Widget untuk foto bantuan
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tampilkan foto yang sudah dipilih
                      if (controller.fotoBantuanPaths.isNotEmpty) ...[
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.fotoBantuanPaths.length +
                                1, // +1 untuk tombol tambah
                            itemBuilder: (context, index) {
                              if (index == controller.fotoBantuanPaths.length) {
                                // Tombol tambah foto
                                return GestureDetector(
                                  onTap: _showPilihSumberFoto,
                                  child: Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 32,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tambah Foto',
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

                              // Tampilkan foto yang sudah dipilih
                              return Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                      image: DecorationImage(
                                        image: FileImage(File(controller
                                            .fotoBantuanPaths[index])),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.removeFotoBantuan(index);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        // Tampilkan placeholder untuk upload foto
                        GestureDetector(
                          onTap: _showPilihSumberFoto,
                          child: Container(
                            height: 120,
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
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tambah Foto Bantuan',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Upload minimal 1 foto bantuan',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  )),

              const SizedBox(height: 24),

              // Tombol kirim
              ElevatedButton.icon(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Validasi foto bantuan
                    if (controller.fotoBantuanPaths.isEmpty) {
                      Get.snackbar(
                        'Peringatan',
                        'Harap upload setidaknya 1 foto bantuan',
                        backgroundColor: Colors.amber,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 3),
                      );
                      return;
                    }

                    // Tampilkan konfirmasi sebelum mengirim
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Konfirmasi Penitipan Bantuan'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                'Apakah data yang Anda masukkan sudah benar?'),
                            const SizedBox(height: 12),
                            const Text(
                                'Penitipan bantuan akan diproses oleh petugas desa.'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              // Panggil fungsi untuk membuat penitipan bantuan
                              controller.createPenitipanBantuan(
                                selectedStokBantuanId,
                                double.parse(jumlahController.text),
                                deskripsiController.text,
                                selectedSkemaBantuanId,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Kirim'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('Kirim Penitipan Bantuan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Informasi kontak petugas
              Text(
                'Hubungi Petugas Desa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Untuk penitipan bantuan secara langsung, silahkan hubungi petugas desa terdekat atau kunjungi kantor desa terdekat.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Implementasi untuk membuka kontak petugas desa
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Informasi Kontak Petugas Desa'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContactInfo(
                            icon: Icons.phone,
                            title: 'Telepon',
                            content: '0812-3456-7890',
                          ),
                          const SizedBox(height: 16),
                          _buildContactInfo(
                            icon: Icons.email,
                            title: 'Email',
                            content: 'petugas@desa.id',
                          ),
                          const SizedBox(height: 16),
                          _buildContactInfo(
                            icon: Icons.location_on,
                            title: 'Alamat',
                            content:
                                'Jl. Desa Sejahtera No. 123, Kecamatan Makmur',
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.contact_phone),
                label: const Text('Lihat Kontak Petugas Desa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: BorderSide(color: Colors.blue.shade300),
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Fungsi untuk memilih foto
  void _showPilihSumberFoto() {
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
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                controller.pickImage(isCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                controller.pickImage(isCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
