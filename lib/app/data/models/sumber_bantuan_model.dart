import 'dart:convert';

class SumberBantuanModel {
  final String? id;
  final String? nama;
  final String? deskripsi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SumberBantuanModel({
    this.id,
    this.nama,
    this.deskripsi,
    this.createdAt,
    this.updatedAt,
  });

  factory SumberBantuanModel.fromRawJson(String str) =>
      SumberBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SumberBantuanModel.fromJson(Map<String, dynamic> json) =>
      SumberBantuanModel(
        id: json["id"],
        nama: json["nama"],
        deskripsi: json["deskripsi"],
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "deskripsi": deskripsi,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
