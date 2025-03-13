import 'dart:convert';

class PenyaluranBantuanModel {
  final String? id;
  final String? nama;
  final String? deskripsi;
  final String? lokasiPenyaluranId;
  final String? petugasId;
  final String? status;
  final String? alasanPenolakan;
  final DateTime? tanggalPenjadwalan;
  final DateTime? tanggalPenyaluran;
  final String? kategoriBantuanId;
  final DateTime? tanggalPermintaan;
  final int? jumlahPenerima;
  final String? skemaId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PenyaluranBantuanModel({
    this.id,
    this.nama,
    this.deskripsi,
    this.lokasiPenyaluranId,
    this.petugasId,
    this.status,
    this.alasanPenolakan,
    this.tanggalPenjadwalan,
    this.tanggalPenyaluran,
    this.kategoriBantuanId,
    this.tanggalPermintaan,
    this.jumlahPenerima,
    this.skemaId,
    this.createdAt,
    this.updatedAt,
  });

  factory PenyaluranBantuanModel.fromRawJson(String str) =>
      PenyaluranBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PenyaluranBantuanModel.fromJson(Map<String, dynamic> json) =>
      PenyaluranBantuanModel(
        id: json["id"],
        nama: json["nama"],
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
        kategoriBantuanId: json["kategori_bantuan_id"],
        tanggalPermintaan: json["tanggal_permintaan"] != null
            ? DateTime.parse(json["tanggal_permintaan"])
            : null,
        jumlahPenerima: json["jumlah_penerima"],
        skemaId: json["skema_id"],
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
        "lokasi_penyaluran_id": lokasiPenyaluranId,
        "petugas_id": petugasId,
        "status": status,
        "alasan_penolakan": alasanPenolakan,
        "tanggal_penjadwalan": tanggalPenjadwalan?.toIso8601String(),
        "tanggal_penyaluran": tanggalPenyaluran?.toIso8601String(),
        "kategori_bantuan_id": kategoriBantuanId,
        "tanggal_permintaan": tanggalPermintaan?.toIso8601String(),
        "jumlah_penerima": jumlahPenerima,
        "skema_id": skemaId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
