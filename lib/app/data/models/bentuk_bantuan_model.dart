import 'dart:convert';

class BentukBantuanModel {
  final String? id;
  final String? nama;
  final String? deskripsi;
  final String? kategori;
  final String? satuan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BentukBantuanModel({
    this.id,
    this.nama,
    this.deskripsi,
    this.kategori,
    this.satuan,
    this.createdAt,
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
        "kategori": kategori,
        "satuan": satuan,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
