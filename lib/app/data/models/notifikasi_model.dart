import 'dart:convert';

class NotifikasiModel {
  final String? id;
  final String? userId;
  final String? judul;
  final String? pesan;
  final String? jenis;
  final String? referensiId;
  final bool? dibaca;
  final DateTime? tanggalNotifikasi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotifikasiModel({
    this.id,
    this.userId,
    this.judul,
    this.pesan,
    this.jenis,
    this.referensiId,
    this.dibaca,
    this.tanggalNotifikasi,
    this.createdAt,
    this.updatedAt,
  });

  factory NotifikasiModel.fromRawJson(String str) =>
      NotifikasiModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) =>
      NotifikasiModel(
        id: json["id"],
        userId: json["user_id"],
        judul: json["judul"],
        pesan: json["pesan"],
        jenis: json["jenis"],
        referensiId: json["referensi_id"],
        dibaca: json["dibaca"],
        tanggalNotifikasi: json["tanggal_notifikasi"] != null
            ? DateTime.parse(json["tanggal_notifikasi"])
            : null,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "judul": judul,
        "pesan": pesan,
        "jenis": jenis,
        "referensi_id": referensiId,
        "dibaca": dibaca,
        "tanggal_notifikasi": tanggalNotifikasi?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
