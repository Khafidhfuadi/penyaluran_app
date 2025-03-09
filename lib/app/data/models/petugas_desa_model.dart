import 'dart:convert';

class PetugasDesaModel {
  final String id;
  final String nama;
  final String? alamat;
  final String? noTelp;
  final String? email;
  final String? jabatan;
  final String? desa;
  final String? kecamatan;
  final String? kabupaten;
  final String? provinsi;
  final String? userId; // Referensi ke User jika petugas memiliki akun
  final DateTime createdAt;
  final DateTime? updatedAt;

  PetugasDesaModel({
    required this.id,
    required this.nama,
    this.alamat,
    this.noTelp,
    this.email,
    this.jabatan,
    this.desa,
    this.kecamatan,
    this.kabupaten,
    this.provinsi,
    this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory PetugasDesaModel.fromRawJson(String str) =>
      PetugasDesaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PetugasDesaModel.fromJson(Map<String, dynamic> json) =>
      PetugasDesaModel(
        id: json["id"],
        nama: json["nama"],
        alamat: json["alamat"],
        noTelp: json["no_telp"],
        email: json["email"],
        jabatan: json["jabatan"],
        desa: json["desa"],
        kecamatan: json["kecamatan"],
        kabupaten: json["kabupaten"],
        provinsi: json["provinsi"],
        userId: json["user_id"],
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
        "jabatan": jabatan,
        "desa": desa,
        "kecamatan": kecamatan,
        "kabupaten": kabupaten,
        "provinsi": provinsi,
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
