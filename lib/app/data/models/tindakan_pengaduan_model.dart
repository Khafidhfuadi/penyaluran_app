import 'dart:convert';

class TindakanPengaduanModel {
  final String id;
  final String pengaduanId; // Referensi ke Pengaduan
  final String? userId; // Pengguna yang melakukan tindakan
  final String tindakan; // Deskripsi tindakan yang dilakukan
  final String status; // Contoh: 'diproses', 'selesai'
  final String? catatan;
  final List<String>? gambarUrls; // URL gambar bukti tindakan
  final DateTime tanggalTindakan;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TindakanPengaduanModel({
    required this.id,
    required this.pengaduanId,
    this.userId,
    required this.tindakan,
    required this.status,
    this.catatan,
    this.gambarUrls,
    required this.tanggalTindakan,
    required this.createdAt,
    this.updatedAt,
  });

  factory TindakanPengaduanModel.fromRawJson(String str) =>
      TindakanPengaduanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TindakanPengaduanModel.fromJson(Map<String, dynamic> json) =>
      TindakanPengaduanModel(
        id: json["id"],
        pengaduanId: json["pengaduan_id"],
        userId: json["user_id"],
        tindakan: json["tindakan"],
        status: json["status"],
        catatan: json["catatan"],
        gambarUrls: json["gambar_urls"] == null
            ? null
            : List<String>.from(json["gambar_urls"].map((x) => x)),
        tanggalTindakan: DateTime.parse(json["tanggal_tindakan"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pengaduan_id": pengaduanId,
        "user_id": userId,
        "tindakan": tindakan,
        "status": status,
        "catatan": catatan,
        "gambar_urls": gambarUrls == null
            ? null
            : List<dynamic>.from(gambarUrls!.map((x) => x)),
        "tanggal_tindakan": tanggalTindakan.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
