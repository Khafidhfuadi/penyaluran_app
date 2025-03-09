import 'dart:convert';

class PengaduanModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String? userId; // Pengguna yang membuat pengaduan
  final String? penyaluranBantuanId; // Referensi ke PenyaluranBantuan
  final String status; // Contoh: 'pending', 'diproses', 'selesai'
  final List<String>? gambarUrls; // URL gambar bukti pengaduan
  final DateTime createdAt;
  final DateTime? updatedAt;

  PengaduanModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.userId,
    this.penyaluranBantuanId,
    required this.status,
    this.gambarUrls,
    required this.createdAt,
    this.updatedAt,
  });

  factory PengaduanModel.fromRawJson(String str) =>
      PengaduanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PengaduanModel.fromJson(Map<String, dynamic> json) => PengaduanModel(
        id: json["id"],
        judul: json["judul"],
        deskripsi: json["deskripsi"],
        userId: json["user_id"],
        penyaluranBantuanId: json["penyaluran_bantuan_id"],
        status: json["status"],
        gambarUrls: json["gambar_urls"] == null
            ? null
            : List<String>.from(json["gambar_urls"].map((x) => x)),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "judul": judul,
        "deskripsi": deskripsi,
        "user_id": userId,
        "penyaluran_bantuan_id": penyaluranBantuanId,
        "status": status,
        "gambar_urls": gambarUrls == null
            ? null
            : List<dynamic>.from(gambarUrls!.map((x) => x)),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
