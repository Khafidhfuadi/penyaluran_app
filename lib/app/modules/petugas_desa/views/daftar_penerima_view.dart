import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/penerima_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class DaftarPenerimaView extends GetView<PenerimaController> {
  const DaftarPenerimaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Penerima'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementasi pencarian
              showSearch(
                context: context,
                delegate: PenerimaSearchDelegate(controller.daftarPenerima),
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

        if (controller.daftarPenerima.isEmpty) {
          return const Center(
            child: Text('Tidak ada data penerima'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildPenerimaSummary(context),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: controller.daftarPenerima.length,
                itemBuilder: (context, index) {
                  final penerima = controller.daftarPenerima[index];
                  return _buildPenerimaCard(context, penerima);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  // Ringkasan daftar penerima
  Widget _buildPenerimaSummary(BuildContext context) {
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
            'Ringkasan Penerima Bantuan',
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
                  icon: Icons.people_alt_outlined,
                  title: 'Total',
                  value: '${controller.daftarPenerima.length}',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.check_circle_outline,
                  title: 'Tersalurkan',
                  value:
                      '${controller.daftarPenerima.where((p) => p['status'] == 'Selesai').length}',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.pending_outlined,
                  title: 'Menunggu',
                  value:
                      '${controller.daftarPenerima.where((p) => p['status'] != 'Selesai').length}',
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

  Widget _buildPenerimaCard(
      BuildContext context, Map<String, dynamic> penerima) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman detail penerima
          Get.toNamed('/daftar-penerima/detail', arguments: penerima['id']);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Foto profil
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: penerima['foto'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          penerima['foto'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 30,
                              color: AppTheme.primaryColor,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 30,
                        color: AppTheme.primaryColor,
                      ),
              ),
              const SizedBox(width: 16),
              // Informasi penerima
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            penerima['nama'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (penerima['terverifikasi'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Terverifikasi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIK: ${penerima['nik'] ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),

                    _buildStatusBadge(penerima['status']),
                    // const SizedBox(height: 8),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       penerima['alamatLengkap'] ?? '',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: Colors.grey[600],
                    //       ),
                    //       maxLines: 1,
                    //       overflow: TextOverflow.ellipsis,
                    //     ),
                    //     _buildStatusBadge(penerima['status']),
                    //   ],
                    // ),
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

    switch (status) {
      case 'Selesai':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'Terjadwal':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case 'Belum disalurkan':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status ?? 'Tidak diketahui',
        style: TextStyle(
          fontSize: 12,
          color: textColor,
        ),
      ),
    );
  }
}

class PenerimaSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> daftarPenerima;

  PenerimaSearchDelegate(this.daftarPenerima);

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
    final filteredList = daftarPenerima.where((penerima) {
      final nama = penerima['nama']?.toString().toLowerCase() ?? '';
      final nik = penerima['nik']?.toString().toLowerCase() ?? '';
      final alamat = penerima['alamatLengkap']?.toString().toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return nama.contains(searchLower) ||
          nik.contains(searchLower) ||
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
        final penerima = filteredList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () {
              close(context, null);
              Get.toNamed('/daftar-penerima/detail', arguments: penerima['id']);
            },
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(
              penerima['nama'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('NIK: ${penerima['nik'] ?? ''}'),
            trailing: penerima['terverifikasi'] == true
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
