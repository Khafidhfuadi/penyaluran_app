import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/detail_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/views/konfirmasi_penerima_page.dart';

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
        title: const Text('Detail Penyaluran'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
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
                const SizedBox(height: 16),
                _buildPenerimaPenyaluranSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: Obx(() => showScrollToTop.value
          ? FloatingActionButton(
              mini: true,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.arrow_upward),
              onPressed: () {
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            )
          : const SizedBox.shrink()),
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
                    ? DateTimeHelper.formatDateTime(
                        penyaluran.tanggalPenyaluran!)
                    : 'Belum dijadwalkan'),
            // Tampilkan tanggal selesai jika status TERLAKSANA atau BATALTERLAKSANA
            if (penyaluran.status == 'TERLAKSANA' ||
                penyaluran.status == 'BATALTERLAKSANA')
              _buildInfoRow(
                  'Tanggal Selesai',
                  penyaluran.tanggalSelesai != null
                      ? DateTimeHelper.formatDateTime(
                          penyaluran.tanggalSelesai!)
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
          ],
        ),
      ),
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
                      child: Text(
                        '${_getFilteredPenerima().length} Orang',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    )),
              ],
            ),
          ),

          // Statistik penerima
          Obx(() => _buildStatistikPenerima(context)),

          // Search field dengan filter status
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                // Search field dengan icon dan tombol hapus
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama, NIK, atau alamat...',
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
                          vertical: 12, horizontal: 16),
                    ),
                    onChanged: (value) {
                      searchQuery.value = value.toLowerCase();
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Filter status dengan label
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', true),
                      const SizedBox(width: 8),
                      _buildFilterChip('Sudah Menerima', false),
                      const SizedBox(width: 8),
                      _buildFilterChip('Belum Menerima', false),
                    ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insert_chart_outlined,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Progres Penyaluran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: progressColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${persentaseSudah.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

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
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '$sudahMenerima dari $totalPenerima',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  // Background progress bar
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Foreground progress bar
                  FractionallySizedBox(
                    widthFactor: persentaseSudah / 100,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: progressColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

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
              )),
              const SizedBox(width: 6),
              Expanded(
                  child: _buildStatistikItem(
                'Belum Menerima',
                belumMenerima,
                AppTheme.warningColor,
                Icons.pending,
              )),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatistikItem(
      String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
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

    // Tentukan icon berdasarkan jenis filter
    IconData filterIcon;
    if (label == 'Semua') {
      filterIcon = Icons.list_alt;
    } else if (label == 'Sudah Menerima') {
      filterIcon = Icons.check_circle;
    } else {
      filterIcon = Icons.pending;
    }

    return FilterChip(
      avatar: Icon(
        filterIcon,
        size: 16,
        color: isSelected ? Colors.white : AppTheme.primaryColor,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.3)
                  : AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      // checkmarkColor: Colors.white,
      showCheckmark: false,
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      elevation: isSelected ? 0 : 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
          width: 1,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          statusFilter.value = filterValue;
        }
      },
    );
  }

  Widget _buildPenerimaItem(
      BuildContext context, PenerimaPenyaluranModel item) {
    final warga = item.warga;
    final bool sudahMenerima =
        item.statusPenerimaan?.toUpperCase() == 'DITERIMA';
    final Color cardColor = Colors.white;
    final Color borderColor = Colors.grey.shade300;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      color: cardColor,
      child: InkWell(
        onTap: () => _showDetailPenerima(context, item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: sudahMenerima
                    ? AppTheme.successColor.withOpacity(0.2)
                    : AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  warga != null && warga['nama_lengkap'] != null
                      ? warga['nama_lengkap']
                          .toString()
                          .substring(0, 1)
                          .toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: sudahMenerima
                        ? AppTheme.successColor
                        : AppTheme.primaryColor,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Informasi penerima
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nama dan NIK
                    Text(
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
                    const SizedBox(height: 2),
                    Text(
                      'NIK: ${warga != null ? warga['nik'] ?? '-' : '-'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),
                    _buildStatusChipNew(item.statusPenerimaan ?? '-'),
                  ],
                ),
              ),

              // Status dan icon
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_forward_ios,
                      size: 14,
                      color:
                          sudahMenerima ? AppTheme.successColor : Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChipNew(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String statusText = _getStatusPenerimaanText(status);
    IconData iconData;

    // Konversi status ke format yang diinginkan
    if (status.toUpperCase() == 'DITERIMA') {
      backgroundColor = AppTheme.successColor;
      statusText = 'Sudah Menerima';
      iconData = Icons.check_circle;
    } else {
      // Semua status selain DITERIMA dianggap sebagai BELUMMENERIMA
      backgroundColor = AppTheme.warningColor;
      statusText = 'Belum Menerima';
      iconData = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: textColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
    final bool sudahMenerima =
        penerima.statusPenerimaan?.toUpperCase() == 'DITERIMA';
    final Color statusColor =
        sudahMenerima ? AppTheme.successColor : AppTheme.warningColor;

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
                const SizedBox(height: 20),

                // Header dengan avatar dan nama
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: statusColor.withOpacity(0.2),
                      child: Text(
                        warga != null && warga['nama_lengkap'] != null
                            ? warga['nama_lengkap']
                                .toString()
                                .substring(0, 1)
                                .toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            warga != null
                                ? warga['nama_lengkap'] ?? 'Nama tidak tersedia'
                                : 'Nama tidak tersedia',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusChipNew(penerima.statusPenerimaan ?? '-'),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Informasi biodata
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Biodata Singkat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const Divider(height: 24),
                      if (warga != null) ...[
                        _buildInfoRow('NIK', warga['nik'] ?? '-'),
                        _buildInfoRow('Alamat Lengkap',
                            '${warga['alamat'] ?? '-'} Desa ${warga['desa'] ?? '-'} Kecamatan ${warga['kecamatan'] ?? '-'} Kabupaten ${warga['kabupaten'] ?? '-'} Provinsi ${warga['provinsi'] ?? '-'}'),
                        _buildInfoRow(
                            'Jenis Kelamin', warga['jenis_kelamin'] ?? '-'),
                        _buildInfoRow('No. Telepon', warga['no_hp'] ?? '-'),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Informasi penerimaan
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            sudahMenerima ? Icons.check_circle : Icons.pending,
                            color: statusColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi Penerimaan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                          'Status Penerimaan',
                          _getStatusPenerimaanText(
                              penerima.statusPenerimaan ?? '-')),
                      if (penerima.tanggalPenerimaan != null)
                        _buildInfoRow(
                            'Tanggal Penerimaan',
                            DateTimeHelper.formatDate(
                                penerima.tanggalPenerimaan!)),
                      if (penerima.jumlahBantuan != null)
                        _buildInfoRow('Jumlah Bantuan',
                            penerima.jumlahBantuan.toString()),
                      if (penerima.keterangan != null &&
                          penerima.keterangan!.isNotEmpty)
                        _buildInfoRow('Keterangan', penerima.keterangan!),
                    ],
                  ),
                ),

                // Bukti penerimaan
                if (penerima.buktiPenerimaan != null &&
                    penerima.buktiPenerimaan!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bukti Penerimaan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // Tombol konfirmasi penerimaan
                if (controller.penyaluran.value?.status?.toUpperCase() ==
                        'AKTIF' &&
                    penerima.statusPenerimaan?.toUpperCase() != 'DITERIMA') ...[
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showKonfirmasiPenerimaan(context, penerima);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Tombol tutup
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
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
                  DateTimeHelper.formatDateTime(penyaluran.tanggalSelesai!)),
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
          // Filter untuk yang belum menerima
          return item.statusPenerimaan?.toUpperCase() != 'DITERIMA';
        }
      }).toList();
    }

    return filteredList;
  }
}
