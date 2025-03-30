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
    final statusActive = penerima['status'] == 'AKTIF';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            // Navigasi ke halaman detail penerima
            Get.toNamed('/daftar-penerima/detail', arguments: penerima['id']);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppTheme.primaryColor.withOpacity(0.03),
                ],
              ),
            ),
            child: Row(
              children: [
                // Foto profil dengan animasi hero
                Hero(
                  tag: 'penerima-${penerima['id']}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      backgroundImage: penerima['foto_profil'] != null &&
                              penerima['foto_profil'].toString().isNotEmpty
                          ? NetworkImage(penerima['foto_profil'])
                          : null,
                      child: (penerima['foto_profil'] == null ||
                              penerima['foto_profil'].toString().isEmpty)
                          ? Text(
                              penerima['nama_lengkap'] != null
                                  ? penerima['nama_lengkap']
                                      .toString()
                                      .substring(0, 1)
                                      .toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
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
                              penerima['nama_lengkap'] ?? 'Tanpa Nama',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (penerima['terverifikasi'] == true)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'NIK: ${penerima['nik'] ?? 'Belum Ada'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusActive
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusActive
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 12,
                                  color:
                                      statusActive ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusActive ? 'Aktif' : 'Tidak Aktif',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: statusActive
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: AppTheme.primaryColor,
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
      final nama = penerima['nama_lengkap']?.toString().toLowerCase() ?? '';
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
              backgroundImage: penerima['foto_profil'] != null &&
                      penerima['foto_profil'].toString().isNotEmpty
                  ? NetworkImage(penerima['foto_profil'])
                  : null,
              child: (penerima['foto_profil'] == null ||
                      penerima['foto_profil'].toString().isEmpty)
                  ? Text(
                      penerima['nama_lengkap'] != null
                          ? penerima['nama_lengkap']
                              .toString()
                              .substring(0, 1)
                              .toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: 24,
                      ),
                    )
                  : null,
            ),
            title: Text(
              penerima['nama_lengkap'] ?? '',
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
