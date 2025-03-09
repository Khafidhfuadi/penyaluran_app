import 'dart:convert';

class PenyaluranBantuanModel {
  final String id;
  final String? penitipanBantuanId; // Referensi ke PenitipanBantuan
  final String? lokasiPenyaluranId; // Referensi ke LokasiPenyaluran
  final String? petugasDesaId; // Referensi ke PetugasDesa
  final double jumlah;
  final String? satuan; // Contoh: kg, buah, paket, dll
  final String? deskripsi;
  final String status; // Contoh: 'diproses', 'disalurkan', 'dibatalkan'
  final List<String>? gambarUrls; // URL gambar bukti penyaluran
  final DateTime tanggalPenyaluran;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PenyaluranBantuanModel({
    required this.id,
    this.penitipanBantuanId,
    this.lokasiPenyaluranId,
    this.petugasDesaId,
    required this.jumlah,
    this.satuan,
    this.deskripsi,
    required this.status,
    this.gambarUrls,
    required this.tanggalPenyaluran,
    required this.createdAt,
    this.updatedAt,
  });

  factory PenyaluranBantuanModel.fromRawJson(String str) =>
      PenyaluranBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PenyaluranBantuanModel.fromJson(Map<String, dynamic> json) =>
      PenyaluranBantuanModel(
        id: json["id"],
        penitipanBantuanId: json["penitipan_bantuan_id"],
        lokasiPenyaluranId: json["lokasi_penyaluran_id"],
        petugasDesaId: json["petugas_desa_id"],
        jumlah: json["jumlah"].toDouble(),
        satuan: json["satuan"],
        deskripsi: json["deskripsi"],
        status: json["status"],
        gambarUrls: json["gambar_urls"] == null
            ? null
            : List<String>.from(json["gambar_urls"].map((x) => x)),
        tanggalPenyaluran: DateTime.parse(json["tanggal_penyaluran"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "penitipan_bantuan_id": penitipanBantuanId,
        "lokasi_penyaluran_id": lokasiPenyaluranId,
        "petugas_desa_id": petugasDesaId,
        "jumlah": jumlah,
        "satuan": satuan,
        "deskripsi": deskripsi,
        "status": status,
        "gambar_urls": gambarUrls == null
            ? null
            : List<dynamic>.from(gambarUrls!.map((x) => x)),
        "tanggal_penyaluran": tanggalPenyaluran.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
