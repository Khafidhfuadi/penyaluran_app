import 'dart:convert';

class NotifikasiModel {
  final String id;
  final String judul;
  final String pesan;
  final String? jenis; // Contoh: 'penyaluran', 'penitipan', 'pengaduan'
  final String? referensiId; // ID dari entitas yang terkait notifikasi
  final String? userId; // Pengguna yang menerima notifikasi
  final bool dibaca;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NotifikasiModel({
    required this.id,
    required this.judul,
    required this.pesan,
    this.jenis,
    this.referensiId,
    this.userId,
    this.dibaca = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory NotifikasiModel.fromRawJson(String str) =>
      NotifikasiModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) =>
      NotifikasiModel(
        id: json["id"],
        judul: json["judul"],
        pesan: json["pesan"],
        jenis: json["jenis"],
        referensiId: json["referensi_id"],
        userId: json["user_id"],
        dibaca: json["dibaca"] ?? false,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "judul": judul,
        "pesan": pesan,
        "jenis": jenis,
        "referensi_id": referensiId,
        "user_id": userId,
        "dibaca": dibaca,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
