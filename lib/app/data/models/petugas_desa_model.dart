import 'dart:convert';

class PetugasDesaModel {
  final String? id;
  final String? nama;
  final String? alamatLengkap;
  final String? noTelp;
  final String? email;
  final String? jabatan;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PetugasDesaModel({
    this.id,
    this.nama,
    this.alamatLengkap,
    this.noTelp,
    this.email,
    this.jabatan,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory PetugasDesaModel.fromRawJson(String str) =>
      PetugasDesaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PetugasDesaModel.fromJson(Map<String, dynamic> json) =>
      PetugasDesaModel(
        id: json["id"],
        nama: json["nama"],
        alamatLengkap: json["alamat_lengkap"],
        noTelp: json["no_telp"],
        email: json["email"],
        jabatan: json["jabatan"],
        userId: json["user_id"],
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
        "alamat_lengkap": alamatLengkap,
        "no_telp": noTelp,
        "email": email,
        "jabatan": jabatan,
        "user_id": userId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
