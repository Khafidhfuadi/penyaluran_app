import 'dart:convert';

class DonaturModel {
  final String id;
  final String nama;
  final String? alamat;
  final String? noTelp;
  final String? email;
  final String? jenisDonatur; // Individu, Organisasi, Perusahaan, dll
  final DateTime createdAt;
  final DateTime? updatedAt;

  DonaturModel({
    required this.id,
    required this.nama,
    this.alamat,
    this.noTelp,
    this.email,
    this.jenisDonatur,
    required this.createdAt,
    this.updatedAt,
  });

  factory DonaturModel.fromRawJson(String str) =>
      DonaturModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DonaturModel.fromJson(Map<String, dynamic> json) => DonaturModel(
        id: json["id"],
        nama: json["nama"],
        alamat: json["alamat"],
        noTelp: json["no_telp"],
        email: json["email"],
        jenisDonatur: json["jenis_donatur"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "alamat": alamat,
        "no_telp": noTelp,
        "email": email,
        "jenis_donatur": jenisDonatur,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
