import 'dart:convert';

class LaporanPenyaluranModel {
  final String? id;
  final String penyaluranBantuanId;
  final String judul;
  final String? dokumentasiUrl;
  final String? beritaAcaraUrl;
  final DateTime? tanggalLaporan;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LaporanPenyaluranModel({
    this.id,
    required this.penyaluranBantuanId,
    required this.judul,
    this.dokumentasiUrl,
    this.beritaAcaraUrl,
    this.tanggalLaporan,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory LaporanPenyaluranModel.fromRawJson(String str) =>
      LaporanPenyaluranModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LaporanPenyaluranModel.fromJson(Map<String, dynamic> json) =>
      LaporanPenyaluranModel(
        id: json["id"],
        penyaluranBantuanId: json["penyaluran_bantuan_id"],
        judul: json["judul"],
        dokumentasiUrl: json["dokumentasi_url"],
        beritaAcaraUrl: json["berita_acara_url"],
        tanggalLaporan: json["tanggal_laporan"] != null
            ? DateTime.parse(json["tanggal_laporan"]).toUtc()
            : null,
        status: json["status"],
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"]).toUtc()
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"]).toUtc()
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "penyaluran_bantuan_id": penyaluranBantuanId,
        "judul": judul,
        "dokumentasi_url": dokumentasiUrl,
        "berita_acara_url": beritaAcaraUrl,
        "tanggal_laporan": tanggalLaporan?.toUtc().toIso8601String(),
        "status": status,
        "created_at": createdAt?.toUtc().toIso8601String(),
        "updated_at": updatedAt?.toUtc().toIso8601String(),
      };
}
