import 'dart:convert';

class KategoriBantuanModel {
  final String? id;
  final String? nama;
  final String? deskripsi;
  final String? satuan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KategoriBantuanModel({
    this.id,
    this.nama,
    this.deskripsi,
    this.satuan,
    this.createdAt,
    this.updatedAt,
  });

  factory KategoriBantuanModel.fromRawJson(String str) =>
      KategoriBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory KategoriBantuanModel.fromJson(Map<String, dynamic> json) =>
      KategoriBantuanModel(
        id: json["id"],
        nama: json["nama"],
        deskripsi: json["deskripsi"],
        satuan: json["satuan"],
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
        "satuan": satuan,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
