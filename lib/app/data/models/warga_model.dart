import 'dart:convert';
import 'package:penyaluran_app/app/data/models/desa_model.dart';

// warga == penerima bantuan
class WargaModel {
  final String id; // Primary key yang juga foreign key ke auth.users(id)
  final String? desaId;
  final String? namaLengkap;
  final String? alamat;
  final String? noHp;
  final String? email;
  final String? nik;
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final String? jenisKelamin;
  final String? agama;
  final String? kategoriEkonomi;
  final String? status;
  final String? catatan;
  final String? fotoProfil;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DesaModel? desa;

  WargaModel({
    required this.id,
    this.desaId,
    this.namaLengkap,
    this.alamat,
    this.noHp,
    this.email,
    this.nik,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.agama,
    this.kategoriEkonomi,
    this.status = 'AKTIF',
    this.catatan,
    this.fotoProfil,
    this.createdAt,
    this.updatedAt,
    this.desa,
  });

  factory WargaModel.fromRawJson(String str) =>
      WargaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WargaModel.fromJson(Map<String, dynamic> json) {
    DesaModel? desa;
    if (json["desa"] != null && json["desa"] is Map<String, dynamic>) {
      desa = DesaModel.fromJson(json["desa"]);
    }

    return WargaModel(
      id: json["id"],
      desaId: json["desa_id"],
      namaLengkap: json["nama_lengkap"],
      alamat: json["alamat"],
      noHp: json["no_hp"],
      email: json["email"],
      nik: json["nik"],
      tempatLahir: json["tempat_lahir"],
      tanggalLahir: json["tanggal_lahir"] != null
          ? DateTime.parse(json["tanggal_lahir"])
          : null,
      jenisKelamin: json["jenis_kelamin"],
      agama: json["agama"],
      kategoriEkonomi: json["kategori_ekonomi"],
      status: json["status"] ?? 'AKTIF',
      catatan: json["catatan"],
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
        "nik": nik,
        "tempat_lahir": tempatLahir,
        "tanggal_lahir": tanggalLahir?.toIso8601String(),
        "jenis_kelamin": jenisKelamin,
        "agama": agama,
        "kategori_ekonomi": kategoriEkonomi,
        "status": status,
        "catatan": catatan,
        "foto_profil": fotoProfil,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };

  // Helper method untuk mendapatkan nama yang ditampilkan
  String get displayName => namaLengkap ?? 'Warga';
}
