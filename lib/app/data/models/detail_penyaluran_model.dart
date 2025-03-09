import 'dart:convert';

class DetailPenyaluranModel {
  final String id;
  final String penyaluranBantuanId; // Referensi ke PenyaluranBantuan
  final String? penerimaBantuanId; // Referensi ke PenerimaBantuan
  final double jumlah;
  final String? satuan;
  final String? catatan;
  final String status; // Contoh: 'diterima', 'ditolak'
  final List<String>? gambarUrls; // URL gambar bukti penerimaan
  final DateTime tanggalDiterima;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DetailPenyaluranModel({
    required this.id,
    required this.penyaluranBantuanId,
    this.penerimaBantuanId,
    required this.jumlah,
    this.satuan,
    this.catatan,
    required this.status,
    this.gambarUrls,
    required this.tanggalDiterima,
    required this.createdAt,
    this.updatedAt,
  });

  factory DetailPenyaluranModel.fromRawJson(String str) =>
      DetailPenyaluranModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DetailPenyaluranModel.fromJson(Map<String, dynamic> json) =>
      DetailPenyaluranModel(
        id: json["id"],
        penyaluranBantuanId: json["penyaluran_bantuan_id"],
        penerimaBantuanId: json["penerima_bantuan_id"],
        jumlah: json["jumlah"].toDouble(),
        satuan: json["satuan"],
        catatan: json["catatan"],
        status: json["status"],
        gambarUrls: json["gambar_urls"] == null
            ? null
            : List<String>.from(json["gambar_urls"].map((x) => x)),
        tanggalDiterima: DateTime.parse(json["tanggal_diterima"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "penyaluran_bantuan_id": penyaluranBantuanId,
        "penerima_bantuan_id": penerimaBantuanId,
        "jumlah": jumlah,
        "satuan": satuan,
        "catatan": catatan,
        "status": status,
        "gambar_urls": gambarUrls == null
            ? null
            : List<dynamic>.from(gambarUrls!.map((x) => x)),
        "tanggal_diterima": tanggalDiterima.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
