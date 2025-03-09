import 'dart:convert';

class BentukBantuanModel {
  final String id;
  final String nama;
  final String? deskripsi;
  final String? kategori;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BentukBantuanModel({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.kategori,
    required this.createdAt,
    this.updatedAt,
  });

  factory BentukBantuanModel.fromRawJson(String str) =>
      BentukBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BentukBantuanModel.fromJson(Map<String, dynamic> json) =>
      BentukBantuanModel(
        id: json["id"],
        nama: json["nama"],
        deskripsi: json["deskripsi"],
        kategori: json["kategori"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "deskripsi": deskripsi,
        "kategori": kategori,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
