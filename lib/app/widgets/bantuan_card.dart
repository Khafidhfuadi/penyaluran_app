import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/data/models/penerima_penyaluran_model.dart';
import 'package:penyaluran_app/app/widgets/status_badge.dart';

class BantuanCard extends StatelessWidget {
  final PenerimaPenyaluranModel item;
  final VoidCallback? onTap;
  final bool isCompact;

  const BantuanCard({
    super.key,
    required this.item,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Format jumlah bantuan berdasarkan tipe (uang atau bukan)
    String formattedJumlah = '';
    if (item.jumlahBantuan != null) {
      if (item.isUang == true) {
        formattedJumlah = currencyFormat.format(item.jumlahBantuan);
      } else {
        formattedJumlah = '${item.jumlahBantuan} ${item.satuan ?? ''}';
      }
    } else {
      formattedJumlah = '-';
    }

    // Tampilan kompak untuk daftar ringkasan
    if (isCompact) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 100),
        child: Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: (item.isUang == true ? Colors.green : Colors.blue)
                  .withOpacity(0.3),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max, // Ensure max width for main Row
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (item.isUang == true ? Colors.green : Colors.blue)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            (item.isUang == true ? Colors.green : Colors.blue)
                                .withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      item.isUang == true
                          ? Icons.attach_money
                          : Icons.inventory_2,
                      color: item.isUang == true ? Colors.green : Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3, // Allocate more space to content
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.namaPenyaluran ?? item.keterangan ?? 'Bantuan',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.kategoriNama ?? 'Bantuan',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.tanggalPenerimaan != null
                                    ? DateFormat('dd MMMM yyyy', 'id_ID')
                                        .format(item.tanggalPenerimaan!)
                                    : '-',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2, // Allocate less space to status/amount
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(
                          status: item.statusPenerimaan ?? 'BELUMMENERIMA',
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        if (item.statusPenyaluran != null &&
                            item.statusPenyaluran!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: StatusBadge(
                              status: item.statusPenyaluran!,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (item.isUang == true
                                    ? Colors.green
                                    : Colors.blue)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (item.isUang == true
                                      ? Colors.green
                                      : Colors.blue)
                                  .withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            formattedJumlah,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item.isUang == true
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
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

    // Tampilan detail untuk halaman daftar lengkap
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: (item.isUang == true ? Colors.green : Colors.blue)
                .withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: 3,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: (item.isUang == true ? Colors.green : Colors.blue)
                      .withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            item.isUang == true
                                ? Icons.attach_money
                                : Icons.inventory_2,
                            color: item.isUang == true
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              item.namaPenyaluran ??
                                  item.keterangan ??
                                  'Bantuan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: item.isUang == true
                                    ? Colors.green.shade800
                                    : Colors.blue.shade800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        formattedJumlah,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: item.isUang == true
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (item.statusPenyaluran != null &&
                            item.statusPenyaluran!.isNotEmpty)
                          StatusBadge(
                            status: item.statusPenyaluran!,
                          ),
                        StatusBadge(
                          status: item.statusPenerimaan ?? 'BELUMMENERIMA',
                        ),
                      ],
                    ),
                    if (item.deskripsiPenyaluran != null &&
                        item.deskripsiPenyaluran!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 16, bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deskripsi:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.deskripsiPenyaluran!,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            Icons.category,
                            'Kategori:',
                            item.kategoriNama ?? 'Bantuan',
                          ),
                          const Divider(height: 16),
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Tanggal:',
                            item.tanggalPenerimaan != null
                                ? DateFormat('dd MMMM yyyy', 'id_ID')
                                    .format(item.tanggalPenerimaan!)
                                : '-',
                          ),
                          const Divider(height: 16),
                          _buildInfoRow(
                            Icons.location_on,
                            'Lokasi:',
                            item.lokasiPenyaluranNama ??
                                'Lokasi tidak tersedia',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.visibility),
                      label: const Text('Lihat Detail'),
                      style: TextButton.styleFrom(
                        foregroundColor: item.isUang == true
                            ? Colors.green.shade600
                            : Colors.blue.shade600,
                      ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}
