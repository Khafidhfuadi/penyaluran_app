import 'dart:convert';

class DonaturModel {
  final String? id;
  final String? nama;
  final String? alamat;
  final String? telepon;
  final String? email;
  final String? jenis;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DonaturModel({
    this.id,
    this.nama,
    this.alamat,
    this.telepon,
    this.email,
    this.jenis,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory DonaturModel.fromRawJson(String str) =>
      DonaturModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DonaturModel.fromJson(Map<String, dynamic> json) => DonaturModel(
        id: json["id"],
        nama: json["nama"],
        alamat: json["alamat"],
        telepon: json["telepon"],
        email: json["email"],
        jenis: json["jenis"],
        status: json["status"] ?? 'AKTIF',
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
        "alamat": alamat,
        "telepon": telepon,
        "email": email,
        "jenis": jenis,
        "status": status ?? 'AKTIF',
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
