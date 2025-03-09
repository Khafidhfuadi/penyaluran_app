import 'dart:convert';

class PenitipanBantuanModel {
  final String id;
  final String? donaturId; // Referensi ke Donatur
  final String? bentukBantuanId; // Referensi ke BentukBantuan
  final String? sumberBantuanId; // Referensi ke SumberBantuan
  final double jumlah;
  final String? satuan; // Contoh: kg, buah, paket, dll
  final String? deskripsi;
  final String status; // Contoh: 'diterima', 'disalurkan', 'ditolak'
  final List<String>? gambarUrls; // URL gambar bukti penitipan
  final DateTime tanggalPenitipan;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PenitipanBantuanModel({
    required this.id,
    this.donaturId,
    this.bentukBantuanId,
    this.sumberBantuanId,
    required this.jumlah,
    this.satuan,
    this.deskripsi,
    required this.status,
    this.gambarUrls,
    required this.tanggalPenitipan,
    required this.createdAt,
    this.updatedAt,
  });

  factory PenitipanBantuanModel.fromRawJson(String str) =>
      PenitipanBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PenitipanBantuanModel.fromJson(Map<String, dynamic> json) =>
      PenitipanBantuanModel(
        id: json["id"],
        donaturId: json["donatur_id"],
        bentukBantuanId: json["bentuk_bantuan_id"],
        sumberBantuanId: json["sumber_bantuan_id"],
        jumlah: json["jumlah"].toDouble(),
        satuan: json["satuan"],
        deskripsi: json["deskripsi"],
        status: json["status"],
        gambarUrls: json["gambar_urls"] == null
            ? null
            : List<String>.from(json["gambar_urls"].map((x) => x)),
        tanggalPenitipan: DateTime.parse(json["tanggal_penitipan"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "donatur_id": donaturId,
        "bentuk_bantuan_id": bentukBantuanId,
        "sumber_bantuan_id": sumberBantuanId,
        "jumlah": jumlah,
        "satuan": satuan,
        "deskripsi": deskripsi,
        "status": status,
        "gambar_urls": gambarUrls == null
            ? null
            : List<dynamic>.from(gambarUrls!.map((x) => x)),
        "tanggal_penitipan": tanggalPenitipan.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
