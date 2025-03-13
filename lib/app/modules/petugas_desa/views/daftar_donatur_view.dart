import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/donatur_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';

class DaftarDonaturView extends GetView<DonaturController> {
  const DaftarDonaturView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Donatur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementasi pencarian
              showSearch(
                context: context,
                delegate: DonaturSearchDelegate(controller),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.daftarDonatur.isEmpty) {
          return const Center(
            child: Text('Tidak ada data donatur'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildDonaturSummary(context),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: controller.daftarDonatur.length,
                itemBuilder: (context, index) {
                  final donatur = controller.daftarDonatur[index];
                  return _buildDonaturCard(context, donatur);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  // Ringkasan daftar donatur
  Widget _buildDonaturSummary(BuildContext context) {
    // Hitung jumlah donatur berdasarkan jenis
    final jumlahPerusahaan =
        controller.daftarDonatur.where((d) => d.jenis == 'Perusahaan').length;
    final jumlahOrganisasi =
        controller.daftarDonatur.where((d) => d.jenis == 'Organisasi').length;
    final jumlahIndividu =
        controller.daftarDonatur.where((d) => d.jenis == 'Individu').length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Donatur',
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
                  icon: Icons.business,
                  title: 'Perusahaan',
                  value: '$jumlahPerusahaan',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.groups,
                  title: 'Organisasi',
                  value: '$jumlahOrganisasi',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.person,
                  title: 'Individu',
                  value: '$jumlahIndividu',
                  color: Colors.orange,
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

  Widget _buildDonaturCard(BuildContext context, DonaturModel donatur) {
    // Pilih ikon berdasarkan jenis donatur
    IconData jenisIcon;
    switch (donatur.jenis) {
      case 'Perusahaan':
        jenisIcon = Icons.business;
        break;
      case 'Organisasi':
        jenisIcon = Icons.groups;
        break;
      case 'Individu':
        jenisIcon = Icons.person;
        break;
      default:
        jenisIcon = Icons.help_outline;
    }

    // Hitung jumlah donasi dan total nilai donasi
    final jumlahDonasi = controller.getJumlahDonasi(donatur.id);
    final jumlahDonasiUang = controller.getJumlahDonasiUang(donatur.id);
    final jumlahDonasiBarang = controller.getJumlahDonasiBarang(donatur.id);
    final totalNilaiDonasiUang = controller.getTotalNilaiDonasiUang(donatur.id);
    final totalNilaiDonasiUangFormatted =
        controller.formatRupiah(totalNilaiDonasiUang);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman detail donatur
          Get.toNamed(Routes.detailDonatur, arguments: donatur.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Foto profil atau ikon
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Icon(
                  jenisIcon,
                  size: 30,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              // Informasi donatur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            donatur.nama ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(donatur.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          jenisIcon,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          donatur.jenis ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    // Informasi donasi
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                size: 14,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${jumlahDonasiUang}x Donasi Uang',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.inventory_2,
                                size: 14,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${jumlahDonasiBarang}x Donasi Barang',
                                style: const TextStyle(
                                  fontSize: 12,
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
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'AKTIF':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        label = 'Aktif';
        break;
      case 'NONAKTIF':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        label = 'Non Aktif';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        label = 'Tidak diketahui';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
        ),
      ),
    );
  }
}

class DonaturSearchDelegate extends SearchDelegate {
  final DonaturController controller;

  DonaturSearchDelegate(this.controller);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredList = controller.daftarDonatur.where((donatur) {
      final nama = donatur.nama?.toLowerCase() ?? '';
      final jenis = donatur.jenis?.toLowerCase() ?? '';
      final alamat = donatur.alamat?.toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return nama.contains(searchLower) ||
          jenis.contains(searchLower) ||
          alamat.contains(searchLower);
    }).toList();

    if (filteredList.isEmpty) {
      return const Center(
        child: Text('Tidak ada hasil yang ditemukan'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final donatur = filteredList[index];

        // Pilih ikon berdasarkan jenis donatur
        IconData jenisIcon;
        switch (donatur.jenis) {
          case 'Perusahaan':
            jenisIcon = Icons.business;
            break;
          case 'Organisasi':
            jenisIcon = Icons.groups;
            break;
          case 'Individu':
            jenisIcon = Icons.person;
            break;
          default:
            jenisIcon = Icons.help_outline;
        }

        // Hitung jumlah donasi dan total nilai donasi
        final jumlahDonasi = controller.getJumlahDonasi(donatur.id);
        final jumlahDonasiUang = controller.getJumlahDonasiUang(donatur.id);
        final jumlahDonasiBarang = controller.getJumlahDonasiBarang(donatur.id);
        final totalNilaiDonasiUang =
            controller.getTotalNilaiDonasiUang(donatur.id);
        final totalNilaiDonasiUangFormatted =
            controller.formatRupiah(totalNilaiDonasiUang);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () {
              close(context, null);
              Get.toNamed(Routes.detailDonatur, arguments: donatur.id);
            },
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(
                jenisIcon,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(
              donatur.nama ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donatur.jenis ?? ''),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 12,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      totalNilaiDonasiUangFormatted,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.volunteer_activism,
                      size: 12,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$jumlahDonasi Donasi',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            trailing: donatur.status == 'AKTIF'
                ? const Icon(
                    Icons.verified,
                    color: Colors.green,
                  )
                : null,
          ),
        );
      },
    );
  }
}
