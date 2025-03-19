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
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (item.isUang == true ? Colors.green : Colors.blue)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.isUang == true
                        ? Icons.attach_money
                        : Icons.inventory_2,
                    color: item.isUang == true ? Colors.green : Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.namaPenyaluran ?? item.keterangan ?? 'Bantuan',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.kategoriNama ?? 'Bantuan',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.tanggalPenerimaan != null
                            ? DateFormat('dd MMMM yyyy', 'id_ID')
                                .format(item.tanggalPenerimaan!)
                            : '-',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(
                      status: item.statusPenerimaan ?? 'MENUNGGU',
                      fontSize: 10,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedJumlah,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: item.isUang == true ? Colors.green : Colors.blue,
                        fontSize: 14,
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

    // Tampilan detail untuk halaman daftar lengkap
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.namaPenyaluran ?? item.keterangan ?? 'Bantuan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(
                    status: item.statusPenerimaan ?? 'MENUNGGU',
                  ),
                ],
              ),
              if (item.deskripsiPenyaluran != null &&
                  item.deskripsiPenyaluran!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    item.deskripsiPenyaluran!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.kategoriNama ?? 'Bantuan',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.tanggalPenerimaan != null
                        ? DateFormat('dd MMMM yyyy', 'id_ID')
                            .format(item.tanggalPenerimaan!)
                        : '-',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.lokasiPenyaluranNama ?? 'Lokasi tidak tersedia',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    item.isUang == true
                        ? Icons.attach_money
                        : Icons.inventory_2,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedJumlah,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item.isUang == true ? Colors.green : Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility),
                    label: const Text('Lihat Detail'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
