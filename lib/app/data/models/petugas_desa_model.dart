import 'dart:convert';
import 'package:penyaluran_app/app/data/models/desa_model.dart';

class PetugasDesaModel {
  final String id; // Primary key yang juga foreign key ke auth.users(id)
  final String? desaId;
  final String? namaLengkap;
  final String? alamat;
  final String? noHp;
  final String? email;
  final String? jabatan;
  final String? nip;
  final String? fotoProfil;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DesaModel? desa;

  PetugasDesaModel({
    required this.id,
    this.desaId,
    this.namaLengkap,
    this.alamat,
    this.noHp,
    this.email,
    this.jabatan,
    this.nip,
    this.fotoProfil,
    this.createdAt,
    this.updatedAt,
    this.desa,
  });

  factory PetugasDesaModel.fromRawJson(String str) =>
      PetugasDesaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PetugasDesaModel.fromJson(Map<String, dynamic> json) {
    DesaModel? desa;
    if (json["desa"] != null && json["desa"] is Map<String, dynamic>) {
      desa = DesaModel.fromJson(json["desa"]);
    }

    return PetugasDesaModel(
      id: json["id"],
      desaId: json["desa_id"],
      namaLengkap: json["nama_lengkap"],
      alamat: json["alamat"],
      noHp: json["no_hp"],
      email: json["email"],
      jabatan: json["jabatan"],
      nip: json["nip"],
      fotoProfil: json["foto_profil"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
      desa: desa,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "desa_id": desaId,
        "nama_lengkap": namaLengkap,
        "alamat": alamat,
        "no_hp": noHp,
        "email": email,
        "jabatan": jabatan,
        "nip": nip,
        "foto_profil": fotoProfil,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };

  // Helper method untuk mendapatkan nama yang ditampilkan
  String get displayName => namaLengkap ?? 'Petugas Desa';
}
