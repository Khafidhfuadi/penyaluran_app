import 'dart:convert';

class DesaModel {
  final String id;
  final String nama;
  final String? kecamatan;
  final String? kabupaten;
  final String? provinsi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DesaModel({
    required this.id,
    required this.nama,
    this.kecamatan,
    this.kabupaten,
    this.provinsi,
    this.createdAt,
    this.updatedAt,
  });

  factory DesaModel.fromRawJson(String str) =>
      DesaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DesaModel.fromJson(Map<String, dynamic> json) => DesaModel(
        id: json["id"],
        nama: json["nama"],
        kecamatan: json["kecamatan"],
        kabupaten: json["kabupaten"],
        provinsi: json["provinsi"],
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
        "kecamatan": kecamatan,
        "kabupaten": kabupaten,
        "provinsi": provinsi,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
