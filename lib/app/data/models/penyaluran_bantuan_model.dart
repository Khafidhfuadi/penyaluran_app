import 'dart:convert';

class PenyaluranBantuanModel {
  final String? id;
  final String? judul;
  final String? deskripsi;
  final String? lokasiPenyaluranId;
  final String? petugasId;
  final String? status;
  final String? alasanPenolakan;
  final DateTime? tanggalPenjadwalan;
  final DateTime? tanggalPenyaluran;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PenyaluranBantuanModel({
    this.id,
    this.judul,
    this.deskripsi,
    this.lokasiPenyaluranId,
    this.petugasId,
    this.status,
    this.alasanPenolakan,
    this.tanggalPenjadwalan,
    this.tanggalPenyaluran,
    this.createdAt,
    this.updatedAt,
  });

  factory PenyaluranBantuanModel.fromRawJson(String str) =>
      PenyaluranBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PenyaluranBantuanModel.fromJson(Map<String, dynamic> json) =>
      PenyaluranBantuanModel(
        id: json["id"],
        judul: json["judul"],
        deskripsi: json["deskripsi"],
        lokasiPenyaluranId: json["lokasi_penyaluran_id"],
        petugasId: json["petugas_id"],
        status: json["status"],
        alasanPenolakan: json["alasan_penolakan"],
        tanggalPenjadwalan: json["tanggal_penjadwalan"] != null
            ? DateTime.parse(json["tanggal_penjadwalan"])
            : null,
        tanggalPenyaluran: json["tanggal_penyaluran"] != null
            ? DateTime.parse(json["tanggal_penyaluran"])
            : null,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "judul": judul,
        "deskripsi": deskripsi,
        "lokasi_penyaluran_id": lokasiPenyaluranId,
        "petugas_id": petugasId,
        "status": status,
        "alasan_penolakan": alasanPenolakan,
        "tanggal_penjadwalan": tanggalPenjadwalan?.toIso8601String(),
        "tanggal_penyaluran": tanggalPenyaluran?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
