import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/petugas_desa_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class PenitipanView extends GetView<PetugasDesaController> {
  const PenitipanView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan penitipan
            _buildPenitipanSummary(context),

            const SizedBox(height: 24),

            // Filter dan pencarian
            _buildFilterSearch(context),

            const SizedBox(height: 20),

            // Daftar penitipan
            _buildPenitipanList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPenitipanSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Penitipan',
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
                  icon: Icons.pending_actions,
                  title: 'Menunggu',
                  value: '5',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.check_circle,
                  title: 'Terverifikasi',
                  value: '12',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  icon: Icons.cancel,
                  title: 'Ditolak',
                  value: '2',
                  color: Colors.red,
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

  Widget _buildFilterSearch(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari penitipan...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              // Tampilkan dialog filter
            },
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
        ),
      ],
    );
  }

  Widget _buildPenitipanList(BuildContext context) {
    final List<Map<String, dynamic>> penitipanList = [
      {
        'id': '1',
        'donatur': 'PT Sejahtera Abadi',
        'jenis_bantuan': 'Sembako',
        'jumlah': '500 kg',
        'tanggal_pengajuan': '15 April 2023',
        'status': 'Menunggu',
      },
      {
        'id': '2',
        'donatur': 'Yayasan Peduli Sesama',
        'jenis_bantuan': 'Pakaian',
        'jumlah': '200 pcs',
        'tanggal_pengajuan': '14 April 2023',
        'status': 'Terverifikasi',
      },
      {
        'id': '3',
        'donatur': 'Bank BRI',
        'jenis_bantuan': 'Beras',
        'jumlah': '300 kg',
        'tanggal_pengajuan': '13 April 2023',
        'status': 'Terverifikasi',
      },
      {
        'id': '4',
        'donatur': 'Komunitas Peduli',
        'jenis_bantuan': 'Alat Tulis',
        'jumlah': '100 set',
        'tanggal_pengajuan': '12 April 2023',
        'status': 'Ditolak',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Penitipan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...penitipanList.map((item) => _buildPenitipanItem(context, item)),
      ],
    );
  }

  Widget _buildPenitipanItem(BuildContext context, Map<String, dynamic> item) {
    Color statusColor;
    IconData statusIcon;

    switch (item['status']) {
      case 'Menunggu':
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        break;
      case 'Terverifikasi':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Ditolak':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['donatur'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['status'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon: Icons.category,
                    label: 'Jenis Bantuan',
                    value: item['jenis_bantuan'] ?? '',
                  ),
                ),
                Expanded(
                  child: _buildItemDetail(
                    context,
                    icon: Icons.inventory,
                    label: 'Jumlah',
                    value: item['jumlah'] ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildItemDetail(
              context,
              icon: Icons.calendar_today,
              label: 'Tanggal Pengajuan',
              value: item['tanggal_pengajuan'] ?? '',
            ),
            const SizedBox(height: 12),
            if (item['status'] == 'Menunggu')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Implementasi untuk menerima penitipan
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Terima'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Implementasi untuk menolak penitipan
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Tolak'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Implementasi untuk melihat detail penitipan
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Detail'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Implementasi untuk melihat detail penitipan
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Detail'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetail(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
