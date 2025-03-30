import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/detail_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/konfirmasi_penerima_page.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/qr_scanner_page.dart';

class DetailPenyaluranPage extends StatelessWidget {
  final controller = Get.put(DetailPenyaluranController());
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'SEMUA'.obs;
  final RxBool showAllItems = false.obs;
  final int initialItemCount = 4;
  final ScrollController scrollController = ScrollController();
  final RxBool showScrollToTop = false.obs;

  DetailPenyaluranPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tambahkan listener untuk scroll controller
    scrollController.addListener(() {
      if (scrollController.offset > 300) {
        showScrollToTop.value = true;
      } else {
        showScrollToTop.value = false;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Penyaluran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.grey.withOpacity(0.3),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back,
                color: AppTheme.primaryColor, size: 20),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: controller.refreshData,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.refresh,
                    color: AppTheme.primaryColor, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.penyaluran.value == null) {
          return const Center(
            child: Text('Data penyaluran tidak ditemukan'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshData();
          },
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context),
                const SizedBox(height: 16),
                if (controller.penyaluran.value?.status?.toUpperCase() ==
                        'BATALTERLAKSANA' &&
                    controller.penyaluran.value?.alasanPembatalan != null &&
                    controller.penyaluran.value!.alasanPembatalan!.isNotEmpty)
                  _buildPembatalanSection(context),
                if (controller.penyaluran.value?.status?.toUpperCase() ==
                    'TERLAKSANA')
                  _buildLaporanSection(context),
                const SizedBox(height: 16),
                _buildPenerimaPenyaluranSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: Obx(() {
        final status = controller.penyaluran.value?.status?.toUpperCase() ?? '';
        if (status == 'AKTIF') {
          return FloatingActionButton(
            backgroundColor: AppTheme.primaryColor,
            elevation: 4,
            onPressed: () => _showQrCodeScanner(context),
            tooltip: 'Scan QR Code',
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.qr_code_scanner, color: Colors.white),
            ),
          );
        }
        return showScrollToTop.value
            ? FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                elevation: 4,
                onPressed: () {
                  scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.grey.shade100],
                    ),
                  ),
                  child: const Icon(Icons.arrow_upward,
                      color: AppTheme.primaryColor),
                ),
              )
            : const SizedBox.shrink();
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Memuat data penyaluran...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final penyaluran = controller.penyaluran.value!;
    final skema = controller.skemaBantuan.value;

    return Card(
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan status
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Informasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(penyaluran.status ?? '-'),
              ],
            ),
          ),

          // Informasi penyaluran
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama dan tanggal dalam baris yang sama
                _buildInfoItem(Icons.description_outlined, 'Nama Penyaluran',
                    penyaluran.nama ?? '-', AppTheme.secondaryColor),
                const SizedBox(height: 16),
                _buildInfoItem(
                    Icons.event,
                    'Tanggal Penyaluran',
                    penyaluran.tanggalPenyaluran != null
                        ? FormatHelper.formatDateTime(
                            penyaluran.tanggalPenyaluran!)
                        : 'Belum dijadwalkan',
                    AppTheme.secondaryColor),
                const SizedBox(height: 16),

                // Tampilkan tanggal selesai jika status TERLAKSANA atau BATALTERLAKSANA
                if (penyaluran.status == 'TERLAKSANA' ||
                    penyaluran.status == 'BATALTERLAKSANA')
                  _buildInfoItem(
                      Icons.event_available,
                      'Tanggal Selesai',
                      penyaluran.tanggalSelesai != null
                          ? FormatHelper.formatDateTime(
                              penyaluran.tanggalSelesai!)
                          : '-',
                      AppTheme.secondaryColor),

                const SizedBox(height: 16),
                _buildInfoItem(
                    Icons.people,
                    'Jumlah Penerima',
                    '${penyaluran.jumlahPenerima ?? 0} orang',
                    AppTheme.secondaryColor),

                // Informasi skema bantuan
                if (skema != null) ...[
                  const Divider(height: 32, thickness: 1),
                  _buildInfoItem(Icons.category, 'Skema Bantuan',
                      skema.nama ?? '-', AppTheme.accentColor),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk info item dengan icon
  Widget _buildInfoItem(IconData icon, String label, String value,
      [Color? statusColor]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: statusColor ?? AppTheme.secondaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPenerimaPenyaluranSection(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan judul dan jumlah penerima
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Daftar Penerima',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_getFilteredPenerima().length} Orang',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          // Statistik penerima
          Obx(() => _buildStatistikPenerima(context)),

          // Search field dengan filter status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field dengan icon dan tombol hapus
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama, NIK, atau alamat...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.primaryColor),
                      suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                searchQuery.value = '';
                              },
                            )
                          : const SizedBox.shrink()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryColor, width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                    onChanged: (value) {
                      searchQuery.value = value.toLowerCase();
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Filter status dengan label
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        _buildFilterChip('Semua', true),
                        const SizedBox(width: 12),
                        _buildFilterChip('Sudah Menerima', false),
                        const SizedBox(width: 12),
                        _buildFilterChip('Belum Menerima', false),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar penerima
          Obx(() {
            final filteredList = _getFilteredPenerima();

            if (filteredList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
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
                      const SizedBox(height: 8),
                      Text(
                        'Coba ubah filter pencarian',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Tentukan jumlah item yang akan ditampilkan
            final itemsToShow =
                showAllItems.value || filteredList.length <= initialItemCount
                    ? filteredList
                    : filteredList.sublist(0, initialItemCount);

            // Tentukan jumlah kolom berdasarkan lebar layar
            final screenWidth = MediaQuery.of(context).size.width;
            final crossAxisCount = screenWidth > 600 ? 2 : 1;
            final childAspectRatio = screenWidth > 600 ? 2.5 : 2.2;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimationLimiter(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: itemsToShow.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          columnCount: crossAxisCount,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: _buildPenerimaItem(
                                  context, itemsToShow[index]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Tombol untuk menampilkan lebih banyak atau lebih sedikit item
                if (filteredList.length > initialItemCount)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextButton.icon(
                      onPressed: () {
                        showAllItems.value = !showAllItems.value;
                      },
                      icon: Icon(
                        showAllItems.value
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppTheme.primaryColor,
                      ),
                      label: Text(
                        showAllItems.value
                            ? 'Tampilkan Lebih Sedikit'
                            : 'Lihat Semua (${filteredList.length})',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatistikPenerima(BuildContext context) {
    // Hitung jumlah yang sudah dan belum menerima
    int totalPenerima = controller.penerimaPenyaluran.length;
    int sudahMenerima = controller.penerimaPenyaluran
        .where((item) => item.statusPenerimaan?.toUpperCase() == 'DITERIMA')
        .length;
    int belumMenerima = totalPenerima - sudahMenerima;

    // Hitung persentase
    double persentaseSudah =
        totalPenerima > 0 ? (sudahMenerima / totalPenerima) * 100 : 0;

    // Tentukan warna berdasarkan persentase
    Color progressColor = persentaseSudah > 75
        ? AppTheme.successColor
        : persentaseSudah > 50
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan judul dan persentase
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.insert_chart_outlined,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progres Penyaluran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total $totalPenerima penerima',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: progressColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      persentaseSudah > 75
                          ? Icons.emoji_events
                          : persentaseSudah > 50
                              ? Icons.trending_up
                              : Icons.trending_down,
                      size: 16,
                      color: progressColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${persentaseSudah.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar dengan label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sudah Menerima',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$sudahMenerima dari $totalPenerima',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  // Background progress bar
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Foreground progress bar
                  FractionallySizedBox(
                    widthFactor: persentaseSudah / 100,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: progressColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: persentaseSudah > 15
                            ? Text(
                                '${persentaseSudah.toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Statistik detail
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildStatistikItem(
                  'Sudah Menerima',
                  sudahMenerima,
                  AppTheme.successColor,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatistikItem(
                  'Belum Menerima',
                  belumMenerima,
                  AppTheme.warningColor,
                  Icons.pending,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatistikItem(
      String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    String filterValue;
    int count = 0;

    // Konversi label ke nilai filter dan hitung jumlah
    if (label == 'Semua') {
      filterValue = 'SEMUA';
      count = controller.penerimaPenyaluran.length;
    } else if (label == 'Sudah Menerima') {
      filterValue = 'DITERIMA';
      count = controller.penerimaPenyaluran
          .where((item) => item.statusPenerimaan?.toUpperCase() == 'DITERIMA')
          .length;
    } else {
      filterValue = 'BELUM';
      count = controller.penerimaPenyaluran
          .where((item) => item.statusPenerimaan?.toUpperCase() != 'DITERIMA')
          .length;
    }

    // Cek apakah filter ini yang aktif
    isSelected = statusFilter.value == filterValue;

    // Tentukan icon dan warna berdasarkan jenis filter
    IconData filterIcon;
    Color chipColor;

    if (label == 'Semua') {
      filterIcon = Icons.list_alt;
      chipColor = AppTheme.primaryColor;
    } else if (label == 'Sudah Menerima') {
      filterIcon = Icons.check_circle;
      chipColor = AppTheme.successColor;
    } else {
      filterIcon = Icons.pending;
      chipColor = AppTheme.warningColor;
    }

    return InkWell(
      onTap: () {
        statusFilter.value = filterValue;
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: chipColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
          ],
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filterIcon,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : chipColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : chipColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method untuk mendapatkan warna status
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DITERIMA':
        return AppTheme.successColor;
      case 'BELUMMENERIMA':
        return AppTheme.warningColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPenerimaItem(
      BuildContext context, PenerimaPenyaluranModel item) {
    final warga = item.warga;
    final bool sudahMenerima =
        item.statusPenerimaan?.toUpperCase() == 'DITERIMA';
    final Color statusColor =
        sudahMenerima ? AppTheme.successColor : AppTheme.warningColor;

    return Card(
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: sudahMenerima
              ? statusColor.withOpacity(0.3)
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showDetailPenerima(context, item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar dengan border berwarna
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: sudahMenerima
                      ? statusColor.withOpacity(0.15)
                      : Colors.grey.shade50,
                  backgroundImage: warga != null &&
                          warga['foto_profil'] != null &&
                          warga['foto_profil'].toString().isNotEmpty
                      ? NetworkImage(warga['foto_profil'])
                      : null,
                  child: (warga == null ||
                          warga['foto_profil'] == null ||
                          warga['foto_profil'].toString().isEmpty)
                      ? Text(
                          warga != null && warga['nama_lengkap'] != null
                              ? warga['nama_lengkap']
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: sudahMenerima
                                ? statusColor
                                : Colors.grey.shade700,
                            fontSize: 22,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),

              // Informasi penerima
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nama
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            warga != null
                                ? warga['nama_lengkap'] ?? 'Nama tidak tersedia'
                                : 'Nama tidak tersedia',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Icon indicator (arrow or check)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: sudahMenerima
                                ? statusColor.withOpacity(0.1)
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            sudahMenerima
                                ? Icons.check_circle
                                : Icons.arrow_forward,
                            size: 18,
                            color: sudahMenerima
                                ? statusColor
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // NIK dengan icon
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'NIK: ${warga != null ? warga['nik'] ?? '-' : '-'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Status penerimaan
                    _buildStatusChipNew(item.statusPenerimaan ?? '-'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData statusIcon;
    String statusText = _getStatusText(status);

    switch (status.toUpperCase()) {
      case 'DIJADWALKAN':
        backgroundColor = AppTheme.processedColor;
        statusIcon = Icons.calendar_today;
        break;
      case 'AKTIF':
        backgroundColor = AppTheme.scheduledColor;
        statusIcon = Icons.play_circle_outline;
        break;
      case 'TERLAKSANA':
        backgroundColor = AppTheme.completedColor;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'BATALTERLAKSANA':
        backgroundColor = AppTheme.errorColor;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        backgroundColor = AppTheme.infoColor;
        statusIcon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: backgroundColor,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: backgroundColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final status = controller.penyaluran.value?.status?.toUpperCase() ?? '';

    if (controller.isProcessing.value) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(
                'Memproses...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
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
        label: const Text(
          'Batalkan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorColor,
          side: const BorderSide(color: AppTheme.errorColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _showBatalkanDialog(context),
      ),
    );

    if (status == 'AKTIF') {
      final bool allReceived = controller.penerimaPenyaluran.every(
          (penerima) => penerima.statusPenerimaan?.toUpperCase() == 'DITERIMA');

      return buildButtonContainer([
        Expanded(
          child: ElevatedButton.icon(
            icon: allReceived
                ? const Icon(Icons.check_circle)
                : const Icon(Icons.info_outline),
            label: Text(
              'Selesaikan',
              style: TextStyle(
                fontSize: allReceived ? 16 : 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  allReceived ? AppTheme.successColor : Colors.grey.shade300,
              foregroundColor:
                  allReceived ? Colors.white : Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: allReceived ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: allReceived
                ? controller.selesaikanPenyaluran
                : () => Get.snackbar(
                      'Perhatian',
                      'Masih ada penerima yang belum menerima bantuan',
                      backgroundColor: Colors.orange.shade100,
                      colorText: Colors.orange.shade800,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 10,
                      icon: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                    ),
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
    // Navigasi ke halaman konfirmasi penerima dengan hanya mengirimkan ID
    Get.to(
      () => KonfirmasiPenerimaPage(
        penerimaPenyaluranId: penerima.id!,
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
    final isAlasanEmpty = false.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.errorColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Batalkan Penyaluran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.errorColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tindakan ini tidak dapat dibatalkan',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Form alasan
              const Text(
                'Masukkan alasan pembatalan:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => TextField(
                    controller: alasanController,
                    decoration: InputDecoration(
                      hintText: 'Misalnya: Terjadi kesalahan data penerima...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      errorText: isAlasanEmpty.value
                          ? 'Alasan tidak boleh kosong'
                          : null,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppTheme.errorColor),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      if (isAlasanEmpty.value && value.trim().isNotEmpty) {
                        isAlasanEmpty.value = false;
                      }
                    },
                  )),

              const SizedBox(height: 24),

              // Tombol aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                        foregroundColor: Colors.grey.shade700,
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (alasanController.text.trim().isEmpty) {
                          isAlasanEmpty.value = true;
                          return;
                        }

                        controller
                            .batalkanPenyaluran(alasanController.text.trim());
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batalkan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  void _showDetailPenerimaan(
      BuildContext context, PenerimaPenyaluranModel penerima) {
    // Tampilkan detail penerimaan menggunakan bottom sheet
    final warga = penerima.warga;
    final bool sudahMenerima =
        penerima.statusPenerimaan?.toUpperCase() == 'DITERIMA';
    final Color statusColor =
        sudahMenerima ? AppTheme.successColor : AppTheme.warningColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle untuk drag
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
              const SizedBox(height: 16),

              // Konten utama dengan scrolling
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Header dengan avatar dan informasi utama
                      _buildDetailHeader(warga, sudahMenerima, statusColor),

                      const SizedBox(height: 24),

                      // Section 2: Biodata lengkap
                      _buildDetailBiodata(warga),

                      const SizedBox(height: 16),

                      // Section 3: Informasi penerimaan bantuan
                      _buildDetailInfoPenerimaan(penerima, statusColor),

                      // Section 4: Bukti penerimaan (jika ada)
                      if (penerima.buktiPenerimaan != null &&
                          penerima.buktiPenerimaan!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailBuktiPenerimaan(penerima.buktiPenerimaan!),
                      ],
                    ],
                  ),
                ),
              ),

              // Tombol aksi
              _buildDetailActionButtons(context, penerima, sudahMenerima),
            ],
          ),
        );
      },
    );
  }

  // Widget untuk header detail penerima
  Widget _buildDetailHeader(
      Map<String, dynamic>? warga, bool sudahMenerima, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar dan nama
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: statusColor.withOpacity(0.15),
                    backgroundImage: warga != null &&
                            warga['foto_profil'] != null &&
                            warga['foto_profil'].toString().isNotEmpty
                        ? NetworkImage(warga['foto_profil'])
                        : null,
                    child: (warga == null ||
                            warga['foto_profil'] == null ||
                            warga['foto_profil'].toString().isEmpty)
                        ? Text(
                            warga != null && warga['nama_lengkap'] != null
                                ? warga['nama_lengkap']
                                    .toString()
                                    .substring(0, 1)
                                    .toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              fontSize: 28,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        sudahMenerima ? Icons.check_circle : Icons.pending,
                        color: statusColor,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama dengan overflow ellipsis
                    Text(
                      warga != null && warga['nama_lengkap'] != null
                          ? warga['nama_lengkap']
                          : 'Nama tidak tersedia',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // NIK dengan icon
                    Row(
                      children: [
                        Icon(Icons.credit_card_outlined,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            warga != null && warga['nik'] != null
                                ? 'NIK: ${warga['nik']}'
                                : 'NIK: -',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  sudahMenerima ? Icons.check_circle : Icons.pending_outlined,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  sudahMenerima
                      ? 'Sudah Menerima Bantuan'
                      : 'Belum Menerima Bantuan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk biodata
  Widget _buildDetailBiodata(Map<String, dynamic>? warga) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
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
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Biodata Penerima',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            if (warga != null) ...[
              // Data alamat lengkap
              _buildInfoGroup(
                'Alamat Lengkap',
                [
                  _buildInfoItemGroup('Alamat', warga['alamat'] ?? '-'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInfoItemGroup(
                            'Desa',
                            warga['desa'] != null && warga['desa'] is Map
                                ? warga['desa']['nama'] ?? '-'
                                : warga['nama_desa'] ?? warga['desa'] ?? '-'),
                      ),
                      Expanded(
                        child: _buildInfoItemGroup(
                            'Kecamatan',
                            warga['desa'] != null && warga['desa'] is Map
                                ? warga['desa']['kecamatan'] ?? '-'
                                : warga['kecamatan'] ?? '-'),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInfoItemGroup(
                            'Kabupaten',
                            warga['desa'] != null && warga['desa'] is Map
                                ? warga['desa']['kabupaten'] ?? '-'
                                : warga['kabupaten'] ?? '-'),
                      ),
                      Expanded(
                        child: _buildInfoItemGroup(
                            'Provinsi',
                            warga['desa'] != null && warga['desa'] is Map
                                ? warga['desa']['provinsi'] ?? '-'
                                : warga['provinsi'] ?? '-'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Data personal
              _buildInfoGroup(
                'Data Personal',
                [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInfoItemGroup(
                            'Jenis Kelamin', warga['jenis_kelamin'] ?? '-'),
                      ),
                      Expanded(
                        child: _buildInfoItemGroup(
                            'No. Telepon', warga['no_hp'] ?? '-'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget untuk informasi penerimaan
  Widget _buildDetailInfoPenerimaan(
      PenerimaPenyaluranModel penerima, Color statusColor) {
    final bool sudahMenerima =
        penerima.statusPenerimaan?.toUpperCase() == 'DITERIMA';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.3)),
      ),
      color: statusColor.withOpacity(0.03),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    sudahMenerima
                        ? Icons.verified_outlined
                        : Icons.pending_actions_outlined,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Detail Penerimaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Status penerimaan dengan chip
            Row(
              children: [
                Text(
                  'Status:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    sudahMenerima ? 'Sudah Menerima' : 'Belum Menerima',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tanggal penerimaan
            if (penerima.tanggalPenerimaan != null) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Penerimaan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        FormatHelper.formatDateTime(
                            penerima.tanggalPenerimaan!),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Jenis bantuan
            if (penerima.stokBantuan != null &&
                penerima.stokBantuan!['nama'] != null) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      size: 14,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jenis Bantuan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            penerima.stokBantuan!['nama'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (_getBantuanIsUang(penerima))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Uang',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Jumlah bantuan
            if (penerima.jumlahBantuan != null) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Icon(
                      _getBantuanIsUang(penerima)
                          ? Icons.monetization_on_outlined
                          : Icons.inventory_2_outlined,
                      size: 14,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah Bantuan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _formatJumlahBantuan(penerima),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper untuk mengecek apakah bantuan berupa uang
  bool _getBantuanIsUang(PenerimaPenyaluranModel penerima) {
    // Cek dari relasi stok_bantuan
    if (penerima.stokBantuan != null) {
      return penerima.stokBantuan!['is_uang'] ?? false;
    }
    // Fallback jika stok_bantuan tidak tersedia
    return penerima.isUang ?? false;
  }

  // Helper untuk memformat jumlah bantuan dengan satuan dan cek apakah uang
  String _formatJumlahBantuan(PenerimaPenyaluranModel penerima) {
    // Cek apakah berupa uang dan ambil satuan dari stok_bantuan
    bool isUang = false;
    String satuan = '';

    // Ambil data dari relasi stok_bantuan
    if (penerima.stokBantuan != null) {
      isUang = penerima.stokBantuan!['is_uang'] ?? false;
      satuan = penerima.stokBantuan!['satuan'] ?? '';
    } else {
      // Fallback jika stok_bantuan tidak tersedia
      isUang = penerima.isUang ?? false;
      satuan = penerima.satuan ?? '';
    }

    // Format jumlah bantuan
    if (isUang) {
      return FormatHelper.formatRupiah(penerima.jumlahBantuan ?? 0);
    } else {
      return '${penerima.jumlahBantuan} ${satuan.isNotEmpty ? satuan : 'item'}';
    }
  }

  // Widget untuk bukti penerimaan
  Widget _buildDetailBuktiPenerimaan(String buktiUrl) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Bukti Penerimaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Foto bukti
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      buktiUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gambar tidak dapat dimuat',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 20,
                        ),
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

  // Widget untuk tombol aksi
  Widget _buildDetailActionButtons(BuildContext context,
      PenerimaPenyaluranModel penerima, bool sudahMenerima) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Tombol konfirmasi penerimaan (jika status adalah AKTIF dan belum menerima)
        if (controller.penyaluran.value?.status?.toUpperCase() == 'AKTIF' &&
            !sudahMenerima) ...[
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () {
                Navigator.pop(context);
                _showKonfirmasiPenerimaan(context, penerima);
              },
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Tombol tutup
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text(
              'Tutup',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade400),
              foregroundColor: Colors.grey.shade700,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  // Widget untuk grup informasi
  Widget _buildInfoGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  // Widget untuk item informasi dalam grup
  Widget _buildInfoItemGroup(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  List<PenerimaPenyaluranModel> _getFilteredPenerima() {
    final query = searchQuery.value;
    final status = statusFilter.value;

    // Filter dasar berdasarkan query pencarian
    List<PenerimaPenyaluranModel> filteredList = controller.penerimaPenyaluran;

    if (query.isNotEmpty) {
      filteredList = filteredList.where((item) {
        final warga = item.warga;
        if (warga == null) return false;

        final nama = warga['nama_lengkap']?.toString().toLowerCase() ?? '';
        final nik = warga['nik']?.toString().toLowerCase() ?? '';
        final alamat = warga['alamat']?.toString().toLowerCase() ?? '';
        final statusPenerimaan = item.statusPenerimaan?.toLowerCase() ?? '';

        return nama.contains(query) ||
            nik.contains(query) ||
            alamat.contains(query) ||
            statusPenerimaan.contains(query);
      }).toList();
    }

    // Filter tambahan berdasarkan status
    if (status != 'SEMUA') {
      filteredList = filteredList.where((item) {
        if (status == 'DITERIMA') {
          return item.statusPenerimaan?.toUpperCase() == 'DITERIMA';
        } else {
          // Semua status selain DITERIMA dianggap sebagai BELUMMENERIMA
          return item.statusPenerimaan?.toUpperCase() == 'BELUMMENERIMA';
        }
      }).toList();
    }

    return filteredList;
  }

  // Fungsi untuk membuka scanner QR code
  void _showQrCodeScanner(BuildContext context) async {
    if (controller.penyaluran.value?.id == null) return;

    final result = await Get.to(
      () => QrScannerPage(
        penyaluranId: controller.penyaluran.value!.id!,
      ),
    );

    if (result == true) {
      // Refresh data setelah kembali dari scanner jika berhasil
      await controller.refreshData();
      Get.snackbar(
        'Berhasil',
        'Penerima berhasil diverifikasi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // Widget untuk menampilkan QR Code (dikosongkan untuk petugas desa)
  Widget _buildQrCodeSection(PenerimaPenyaluranModel penerima) {
    // Widget QR Code tetap dibuat tapi tidak digunakan di petugas desa
    return const SizedBox.shrink();
  }

  // Widget untuk status chip baru
  Widget _buildStatusChipNew(String status) {
    final bool isDiterima = status.toUpperCase() == 'DITERIMA';
    final Color statusColor =
        isDiterima ? AppTheme.successColor : AppTheme.warningColor;
    final String statusText = isDiterima ? 'Sudah Menerima' : 'Belum Menerima';
    final IconData statusIcon = isDiterima ? Icons.check_circle : Icons.pending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 5),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailPenerima(
      BuildContext context, PenerimaPenyaluranModel penerima) {
    _showDetailPenerimaan(context, penerima);
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
                  FormatHelper.formatDateTime(penyaluran.tanggalSelesai!)),
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

  Widget _buildLaporanSection(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingLaporan.value) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Memuat data laporan...'),
                ],
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: AppTheme.successColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Laporan Penyaluran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  if (controller.laporan.value != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.successColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tersedia',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Divider(height: 24),
              if (controller.laporan.value == null)
                Column(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_late_outlined,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada laporan penyaluran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Buat laporan untuk mendokumentasikan hasil penyaluran bantuan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: controller.navigateToLaporanCreate,
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Buat Laporan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Judul', controller.laporan.value!.judul),
                    _buildInfoRow(
                      'Tanggal Laporan',
                      controller.laporan.value?.tanggalLaporan != null
                          ? FormatHelper.formatDateTime(
                              controller.laporan.value!.tanggalLaporan!)
                          : '-',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                controller.navigateToLaporanDetail(),
                            icon: const Icon(Icons.visibility),
                            label: const Text('Lihat Detail'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: const BorderSide(
                                  color: AppTheme.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (controller.laporan.value?.beritaAcaraUrl != null &&
                            controller
                                .laporan.value!.beritaAcaraUrl!.isNotEmpty)
                          Expanded(
                            child: Obx(() => ElevatedButton.icon(
                                  onPressed: controller.isExporting.value
                                      ? null
                                      : () => controller.exportToPdf(),
                                  icon: controller.isExporting.value
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.download),
                                  label: Text(controller.isExporting.value
                                      ? 'Mengekspor...'
                                      : 'Unduh PDF'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.successColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    disabledBackgroundColor:
                                        AppTheme.successColor.withOpacity(0.7),
                                  ),
                                )),
                          ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }
}
