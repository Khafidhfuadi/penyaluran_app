import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/skema_bantuan_model.dart';
import 'package:penyaluran_app/app/data/models/stok_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/donatur/controllers/donatur_dashboard_controller.dart';
import 'package:penyaluran_app/app/widgets/section_header.dart';
import 'dart:io';

class DonaturPenitipanView extends GetView<DonaturDashboardController> {
  const DonaturPenitipanView({super.key});

  @override
  DonaturDashboardController get controller {
    if (!Get.isRegistered<DonaturDashboardController>(
      tag: 'donatur_dashboard',
    )) {
      return Get.put(
        DonaturDashboardController(),
        tag: 'donatur_dashboard',
        permanent: true,
      );
    }
    return Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return FormPenitipanBantuan();
  }
}

class FormPenitipanBantuan extends StatefulWidget {
  const FormPenitipanBantuan({super.key});

  @override
  _FormPenitipanBantuanState createState() => _FormPenitipanBantuanState();
}

class _FormPenitipanBantuanState extends State<FormPenitipanBantuan> {
  final DonaturDashboardController controller =
      Get.find<DonaturDashboardController>(tag: 'donatur_dashboard');

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedStokBantuanId;
  String? selectedSkemaBantuanId;
  String? selectedLokasiPenyaluranId;
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  bool _isProsedurinfoExpanded = false;

  @override
  void initState() {
    super.initState();
    // Reset foto bantuan saat form dibuka
    controller.resetFotoBantuan();

    // Cek apakah ada skema bantuan yang dipilih dari halaman skema
    if (controller.selectedSkemaBantuanId.isNotEmpty) {
      // Aktifkan tab skema bantuan
      setState(() {
        selectedSkemaBantuanId = controller.selectedSkemaBantuanId.value;
      });

      // Reset ID skema setelah digunakan
      Future.delayed(Duration.zero, () {
        controller.selectedSkemaBantuanId.value = '';
      });
    }
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
              // Bagian Header dengan prosedur singkat
              _buildHeader(),
              const SizedBox(height: 8),

              // Prosedur Penitipan Bantuan
              _buildProsedurPenitipan(),
              const SizedBox(height: 24),

              // Pilih metode penitipan
              _buildMetodePenitipanSection(),
              const SizedBox(height: 24),

              // Form berdasarkan pilihan
              if (selectedSkemaBantuanId != null) ...[
                _buildFormSkemaBantuan(),
              ] else ...[
                _buildFormBantuanManual(),
              ],

              // Jumlah bantuan
              _buildJumlahBantuan(),
              const SizedBox(height: 16),

              // Lokasi Penitipan
              _buildLokasiPenitipan(),
              const SizedBox(height: 16),

              // Deskripsi bantuan
              _buildDeskripsiBantuan(),
              const SizedBox(height: 16),

              // Foto bantuan
              _buildFotoBantuan(),
              const SizedBox(height: 24),

              // Tombol kirim
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.volunteer_activism,
                color: Colors.blue.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Formulir Penitipan Bantuan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Isi formulir untuk mencatat bantuan yang telah Anda titipkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProsedurPenitipan() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      color: Colors.blue.shade50,
      child: Column(
        children: [
          // Header dengan tombol toggle
          InkWell(
            onTap: () {
              setState(() {
                _isProsedurinfoExpanded = !_isProsedurinfoExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade800,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Prosedur Penitipan Bantuan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    _isProsedurinfoExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.blue.shade800,
                  ),
                ],
              ),
            ),
          ),

          // Konten prosedur yang bisa di-expand
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isProsedurinfoExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),

                  // Langkah-langkah prosedur
                  _buildProsedurStep(
                    number: '1',
                    title: 'Penitipan Bantuan',
                    description:
                        'Titipkan bantuan Anda langsung ke lokasi penyaluran yang tersedia',
                    icon: Icons.local_shipping,
                  ),

                  _buildProsedurStep(
                    number: '2',
                    title: 'Ambil Bukti Foto',
                    description:
                        'Ambil foto sebagai bukti bantuan yang telah dititipkan',
                    icon: Icons.camera_alt,
                  ),

                  _buildProsedurStep(
                    number: '3',
                    title: 'Isi Formulir',
                    description:
                        'Lengkapi formulir ini untuk mencatat penitipan bantuan Anda',
                    icon: Icons.edit_document,
                  ),

                  _buildProsedurStep(
                    number: '4',
                    title: 'Verifikasi Petugas',
                    description:
                        'Petugas desa akan memverifikasi penitipan bantuan Anda',
                    icon: Icons.verified_user,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProsedurStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nomor dalam lingkaran
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
              if (!isLast) ...[
                SizedBox(
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 13),
                    child: VerticalDivider(
                      color: Colors.blue.shade300,
                      thickness: 1,
                      width: 1,
                    ),
                  ),
                ),
              ] else
                const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  // Bagian lainnya akan dikembangkan dalam edit selanjutnya

  Widget _buildMetodePenitipanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category_outlined, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              'Metode Penitipan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Tab pilihan metode yang lebih menarik
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      // Reset semua data saat berpindah ke bantuan manual
                      selectedSkemaBantuanId = null;
                      selectedStokBantuanId = null;
                      jumlahController.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selectedSkemaBantuanId == null
                          ? Colors.blue.shade600
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                          color: selectedSkemaBantuanId == null
                              ? Colors.white
                              : Colors.grey.shade800,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bantuan Manual',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedSkemaBantuanId == null
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      // Reset semua data saat berpindah ke skema bantuan
                      selectedStokBantuanId = null;
                      selectedSkemaBantuanId = '';
                      jumlahController.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selectedSkemaBantuanId != null
                          ? Colors.blue.shade600
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schema_outlined,
                          size: 18,
                          color: selectedSkemaBantuanId != null
                              ? Colors.white
                              : Colors.grey.shade800,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dari Skema Bantuan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedSkemaBantuanId != null
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSkemaBantuan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schema, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              'Pilih Skema Bantuan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: 'Pilih skema bantuan',
              prefixIcon: Icon(Icons.category, color: Colors.blue.shade600),
            ),
            value: selectedSkemaBantuanId == '' ? null : selectedSkemaBantuanId,
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
                  final selectedSkema = controller.skemaBantuan.firstWhere(
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
            dropdownColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade600),
            isExpanded: true,
          ),
        ),
        const SizedBox(height: 12),

        // Tampilkan informasi stok bantuan dari skema yang dipilih
        Builder(
          builder: (context) {
            // Hanya tampilkan jika skema dipilih
            if (selectedSkemaBantuanId == null ||
                selectedSkemaBantuanId!.isEmpty) {
              return const SizedBox.shrink();
            }

            // Cari skema bantuan yang dipilih
            SkemaBantuanModel? selectedSkema;
            try {
              selectedSkema = controller.skemaBantuan.firstWhere(
                (skema) => skema.id == selectedSkemaBantuanId,
              );
            } catch (_) {
              return const SizedBox.shrink();
            }

            // Pastikan skema dan stok bantuan ada
            if (selectedSkema == null || selectedSkema.stokBantuanId == null) {
              return const SizedBox.shrink();
            }

            // Menggunakan Obx hanya untuk data yang reaktif
            return Obx(() {
              // Cari stok bantuan yang sesuai
              StokBantuanModel? selectedStok;
              try {
                if (selectedSkema?.stokBantuanId != null) {
                  for (var stok in controller.stokBantuan) {
                    if (stok.id == selectedSkema!.stokBantuanId) {
                      selectedStok = stok;
                      break;
                    }
                  }
                }
              } catch (_) {
                return const SizedBox.shrink();
              }

              if (selectedStok == null) {
                return const SizedBox.shrink();
              }

              final stokNama = selectedStok.nama ?? 'Tidak diketahui';
              final stokTotal = selectedStok.totalStok ?? 0.0;
              final stokSatuan = selectedStok.satuan ?? 'item';
              final stokDeskripsi = selectedStok.deskripsi ?? '';
              final isUang = selectedStok.isUang ?? false;
              String kategoriNama = '';
              if (selectedStok.kategoriBantuan != null) {
                kategoriNama = selectedStok.kategoriBantuan!['nama'] ?? '';
              }

              // Format stok total jika berbentuk uang
              String formattedStokTotal;
              if (isUang) {
                formattedStokTotal = 'Rp ${_formatCurrency(stokTotal)}';
              } else {
                formattedStokTotal = '$stokTotal $stokSatuan';
              }

              // Tampilkan informasi stok bantuan dengan desain yang lebih menarik
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUang ? Colors.green.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isUang
                          ? Colors.green.shade200
                          : Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isUang ? Icons.monetization_on : Icons.inventory_2,
                          color: isUang
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Stok Bantuan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUang
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            icon: isUang ? Icons.attach_money : Icons.category,
                            label: 'Jenis Bantuan',
                            value: stokNama,
                            iconColor: isUang
                                ? Colors.green.shade600
                                : Colors.blue.shade600,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            icon: isUang
                                ? Icons.account_balance_wallet
                                : Icons.inventory,
                            label: 'Stok Tersedia',
                            value: formattedStokTotal,
                            iconColor: isUang
                                ? Colors.green.shade600
                                : Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (kategoriNama.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.category_outlined,
                              label: 'Kategori',
                              value: kategoriNama,
                              iconColor: isUang
                                  ? Colors.green.shade600
                                  : Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (stokDeskripsi.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white70),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.description,
                              size: 16,
                              color: isUang
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deskripsi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  stokDeskripsi,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            });
          },
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoItem(
      {required IconData icon,
      required String label,
      required String value,
      Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor ?? Colors.blue.shade600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormBantuanManual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory_2, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              'Jenis Bantuan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: 'Pilih jenis bantuan',
              prefixIcon: Icon(Icons.category, color: Colors.blue.shade600),
            ),
            value: selectedStokBantuanId,
            items: controller.getAvailableStokBantuan().map((stok) {
              String displayText;
              if (stok.isUang ?? false) {
                displayText =
                    '${stok.nama ?? 'Tidak ada nama'} (Saldo: Rp ${_formatCurrency(stok.totalStok ?? 0)})';
              } else {
                displayText =
                    '${stok.nama ?? 'Tidak ada nama'} (Stok: ${stok.totalStok ?? 0} ${stok.satuan ?? 'item'})';
              }
              return DropdownMenuItem<String>(
                value: stok.id,
                child: Text(displayText),
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
            dropdownColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade600),
            isExpanded: true,
          ),
        ),
        const SizedBox(height: 16),

        // Menampilkan informasi stok bantuan yang dipilih
        Builder(
          builder: (context) {
            if (selectedStokBantuanId == null) {
              return const SizedBox.shrink();
            }

            return Obx(() {
              // Cari stok bantuan yang sesuai
              StokBantuanModel? selectedStok;
              try {
                selectedStok = controller.stokBantuan.firstWhere(
                  (stok) => stok.id == selectedStokBantuanId,
                  orElse: () => StokBantuanModel(),
                );
              } catch (_) {
                return const SizedBox.shrink();
              }

              if (selectedStok.id == null) {
                return const SizedBox.shrink();
              }

              final stokNama = selectedStok.nama ?? 'Tidak diketahui';
              final stokTotal = selectedStok.totalStok ?? 0.0;
              final stokSatuan = selectedStok.satuan ?? 'item';
              final stokDeskripsi = selectedStok.deskripsi ?? '';
              final isUang = selectedStok.isUang ?? false;
              String kategoriNama = '';
              if (selectedStok.kategoriBantuan != null) {
                kategoriNama = selectedStok.kategoriBantuan!['nama'] ?? '';
              }

              // Format stok total jika berbentuk uang
              String formattedStokTotal;
              if (isUang) {
                formattedStokTotal = 'Rp ${_formatCurrency(stokTotal)}';
              } else {
                formattedStokTotal = '$stokTotal $stokSatuan';
              }

              // Tampilkan informasi stok bantuan dengan desain yang lebih menarik
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUang ? Colors.green.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isUang ? Colors.green.shade200 : Colors.blue.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isUang ? Icons.monetization_on : Icons.inventory_2,
                          color: isUang
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Stok Bantuan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUang
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            icon: isUang ? Icons.attach_money : Icons.category,
                            label: 'Jenis Bantuan',
                            value: stokNama,
                            iconColor: isUang
                                ? Colors.green.shade600
                                : Colors.blue.shade600,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            icon: isUang
                                ? Icons.account_balance_wallet
                                : Icons.inventory,
                            label: 'Stok Tersedia',
                            value: formattedStokTotal,
                            iconColor: isUang
                                ? Colors.green.shade600
                                : Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (kategoriNama.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.category_outlined,
                              label: 'Kategori',
                              value: kategoriNama,
                              iconColor: isUang
                                  ? Colors.green.shade600
                                  : Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (stokDeskripsi.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white70),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.description,
                              size: 16,
                              color: isUang
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deskripsi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  stokDeskripsi,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildJumlahBantuan() {
    final isUang = _isSelectedStokUang();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
                // Tampilkan ikon uang jika stok bantuan berbentuk uang
                isUang ? Icons.attach_money : Icons.numbers,
                color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              'Jumlah Bantuan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: jumlahController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  isUang ? 'Masukkan jumlah uang' : 'Masukkan jumlah bantuan',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: Icon(
                  isUang ? Icons.monetization_on : Icons.shopping_bag,
                  color: Colors.blue.shade600),
              // Tambahkan prefix teks "Rp" jika berbentuk uang
              prefixText: isUang ? 'Rp ' : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jumlah harus diisi';
              }

              String numericOnly = value;
              if (isUang) {
                numericOnly = value.replaceAll('.', '');
              }

              if (double.tryParse(numericOnly) == null) {
                return 'Jumlah harus berupa angka';
              }
              if (double.parse(numericOnly) <= 0) {
                return 'Jumlah harus lebih dari 0';
              }
              return null;
            },
            onChanged: (value) {
              if (isUang && value.isNotEmpty) {
                // Format input sebagai currency jika stok berbentuk uang
                final numericValue =
                    value.replaceAll('.', '').replaceAll('Rp ', '');
                if (double.tryParse(numericValue) != null) {
                  final formattedValue =
                      _formatCurrency(double.parse(numericValue));

                  // Hindari infinite loop dengan mengecek apakah nilai sudah berubah
                  if (formattedValue != value) {
                    jumlahController.value = TextEditingValue(
                      text: formattedValue,
                      selection: TextSelection.collapsed(
                          offset: formattedValue.length),
                    );
                  }
                }
              }
            },
          ),
        ),
        if (isUang) ...[
          const SizedBox(height: 8),
          Text(
            'Masukkan jumlah dalam Rupiah tanpa desimal',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  // Helper function untuk mengecek apakah stok bantuan yang dipilih berbentuk uang
  bool _isSelectedStokUang() {
    if (selectedStokBantuanId == null) return false;

    try {
      for (var stok in controller.stokBantuan) {
        if (stok.id == selectedStokBantuanId) {
          return stok.isUang ?? false;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // Helper function untuk memformat angka sebagai currency
  String _formatCurrency(double value) {
    // Format ke currency dengan pemisah ribuan
    final formatted = value.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]}.',
        );
    return formatted;
  }

  Widget _buildLokasiPenitipan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              'Lokasi Penitipan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: 'Pilih lokasi penitipan',
              prefixIcon: Icon(Icons.place, color: Colors.blue.shade600),
            ),
            value: selectedLokasiPenyaluranId,
            items: controller.lokasiPenyaluran.map((lokasi) {
              String alamatLengkap = [
                lokasi.alamat,
                lokasi.desa,
                lokasi.kecamatan,
                lokasi.kabupaten,
              ].where((s) => s != null && s.isNotEmpty).join(', ');

              return DropdownMenuItem<String>(
                value: lokasi.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lokasi.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (alamatLengkap.isNotEmpty)
                      Text(
                        alamatLengkap,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedLokasiPenyaluranId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lokasi penitipan harus dipilih';
              }
              return null;
            },
            dropdownColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade600),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDeskripsiBantuan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              'Deskripsi Bantuan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: deskripsiController,
            maxLines: 3,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Deskripsi bantuan yang dititipkan',
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Deskripsi harus diisi';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFotoBantuan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_camera, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              'Foto Bantuan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Upload minimal 1 foto sebagai bukti bantuan yang dititipkan',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),

        // Widget untuk foto bantuan dengan desain lebih menarik
        Obx(() {
          return controller.fotoBantuanPaths.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tampilkan foto yang sudah dipilih
                    SizedBox(
                      height: 140,
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
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add_a_photo,
                                        size: 28,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tambah Foto',
                                      style: TextStyle(
                                        color: Colors.blue.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Tampilkan foto yang sudah dipilih
                          return Container(
                            width: 120,
                            height: 140,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Foto
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(controller.fotoBantuanPaths[index]),
                                    width: 120,
                                    height: 140,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Tombol hapus
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.removeFotoBantuan(index);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                          ),
                                        ],
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
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: _showPilihSumberFoto,
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_a_photo,
                            size: 36,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tambah Foto Bantuan',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Klik untuk mengambil foto bukti bantuan',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
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
              margin: const EdgeInsets.all(8),
              borderRadius: 8,
              icon:
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
            );
            return;
          }

          // Tampilkan konfirmasi sebelum mengirim
          _showKonfirmasiPenitipan();
        }
      },
      icon: const Icon(Icons.send),
      label: const Text('Kirim Penitipan Bantuan'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi
  void _showKonfirmasiPenitipan() {
    // Dapatkan informasi terkait penitipan untuk ditampilkan di dialog
    String jenisBantuan = '';
    String lokasiPenitipan = '';
    String jumlahBantuan = jumlahController.text;
    bool isUangBantuan = false;
    String tipeBantuan = 'Donasi Langsung';
    String skemaBantuanNama = '';

    // Ambil nama stok bantuan terpilih
    if (selectedStokBantuanId != null) {
      try {
        var stok = controller.stokBantuan
            .firstWhere((s) => s.id == selectedStokBantuanId);
        jenisBantuan = stok.nama ?? 'Tidak diketahui';
        isUangBantuan = stok.isUang ?? false;

        // Format jumlah untuk bantuan uang
        if (isUangBantuan && jumlahBantuan.isNotEmpty) {
          // Pastikan sudah format dengan benar
          if (!jumlahBantuan.startsWith('Rp ')) {
            jumlahBantuan =
                'Rp ${_formatCurrency(double.parse(jumlahBantuan.replaceAll('.', '')))}';
          }
        }
      } catch (_) {
        jenisBantuan = 'Tidak diketahui';
      }
    }

    // Ambil nama skema bantuan jika dipilih
    if (selectedSkemaBantuanId != null && selectedSkemaBantuanId!.isNotEmpty) {
      try {
        var skema = controller.skemaBantuan
            .firstWhere((s) => s.id == selectedSkemaBantuanId);
        skemaBantuanNama = skema.nama ?? 'Tidak diketahui';
        tipeBantuan = 'Bantuan dari Skema: $skemaBantuanNama';
      } catch (_) {
        tipeBantuan = 'Bantuan dari Skema';
      }
    }

    // Ambil nama lokasi penitipan terpilih
    if (selectedLokasiPenyaluranId != null) {
      try {
        var lokasi = controller.lokasiPenyaluran
            .firstWhere((l) => l.id == selectedLokasiPenyaluranId);
        lokasiPenitipan = lokasi.nama;
      } catch (_) {
        lokasiPenitipan = 'Tidak diketahui';
      }
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade700,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Konfirmasi Penitipan Bantuan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Pastikan data yang Anda masukkan sudah benar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Detail info penitipan
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    if (selectedSkemaBantuanId != null &&
                        selectedSkemaBantuanId!.isNotEmpty) ...[
                      _buildDetailRow(
                        icon: Icons.schema,
                        label: 'Metode Penitipan',
                        value: tipeBantuan,
                        iconColor: Colors.purple.shade600,
                      ),
                      const Divider(),
                    ],
                    _buildDetailRow(
                      icon: isUangBantuan
                          ? Icons.monetization_on
                          : Icons.inventory_2,
                      label: 'Jenis Bantuan',
                      value: jenisBantuan,
                      iconColor: isUangBantuan
                          ? Colors.green.shade600
                          : Colors.blue.shade600,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: isUangBantuan
                          ? Icons.attach_money
                          : Icons.shopping_bag,
                      label: 'Jumlah',
                      value: jumlahBantuan + (isUangBantuan ? '' : ' item'),
                      iconColor: isUangBantuan
                          ? Colors.green.shade600
                          : Colors.blue.shade600,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Lokasi Penitipan',
                      value: lokasiPenitipan,
                      iconColor: Colors.orange.shade600,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        // Pastikan jumlah diproses dengan benar
                        double jumlahNumerik = isUangBantuan
                            ? double.parse(jumlahController.text
                                .replaceAll('.', '')
                                .replaceAll('Rp ', ''))
                            : double.parse(jumlahController.text);

                        // Panggil fungsi untuk membuat penitipan bantuan
                        controller.createPenitipanBantuan(
                          selectedStokBantuanId,
                          jumlahNumerik,
                          deskripsiController.text,
                          selectedSkemaBantuanId,
                          selectedLokasiPenyaluranId,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Kirim'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(icon, color: iconColor ?? Colors.blue.shade700, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk memilih foto
  void _showPilihSumberFoto() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5),
              ),
              margin: const EdgeInsets.only(bottom: 16),
            ),
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSumberFotoOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () {
                    Get.back();
                    controller.pickImage(isCamera: true);
                  },
                ),
                _buildSumberFotoOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () {
                    Get.back();
                    controller.pickImage(isCamera: false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSumberFotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.blue.shade700,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
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
          child: Icon(icon, color: Colors.blue, size: 20),
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
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
