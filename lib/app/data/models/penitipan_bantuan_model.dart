import 'dart:convert';

class PenitipanBantuanModel {
  final String? id;
  final String? donaturId;
  final String? bentukBantuanId;
  final String? nama;
  final double? jumlah;
  final String? satuan;
  final String? deskripsi;
  final String? status;
  final String? alasanPenolakan;
  final List<String>? gambarUrls;
  final DateTime? tanggalPenitipan;
  final DateTime? tanggalVerifikasi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PenitipanBantuanModel({
    this.id,
    this.donaturId,
    this.bentukBantuanId,
    this.nama,
    this.jumlah,
    this.satuan,
    this.deskripsi,
    this.status,
    this.alasanPenolakan,
    this.gambarUrls,
    this.tanggalPenitipan,
    this.tanggalVerifikasi,
    this.createdAt,
    this.updatedAt,
  });

  factory PenitipanBantuanModel.fromRawJson(String str) =>
      PenitipanBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PenitipanBantuanModel.fromJson(Map<String, dynamic> json) =>
      PenitipanBantuanModel(
        id: json["id"],
        donaturId: json["donatur_id"],
        bentukBantuanId: json["bentuk_bantuan_id"],
        nama: json["nama"],
        jumlah: json["jumlah"] != null ? json["jumlah"].toDouble() : 0.0,
        satuan: json["satuan"],
        deskripsi: json["deskripsi"],
        status: json["status"],
        alasanPenolakan: json["alasan_penolakan"],
        gambarUrls: json["gambar_urls"] == null
            ? null
            : List<String>.from(json["gambar_urls"].map((x) => x)),
        tanggalPenitipan: json["tanggal_penitipan"] != null
            ? DateTime.parse(json["tanggal_penitipan"])
            : null,
        tanggalVerifikasi: json["tanggal_verifikasi"] != null
            ? DateTime.parse(json["tanggal_verifikasi"])
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
        "donatur_id": donaturId,
        "bentuk_bantuan_id": bentukBantuanId,
        "nama": nama,
        "jumlah": jumlah,
        "satuan": satuan,
        "deskripsi": deskripsi,
        "status": status,
        "alasan_penolakan": alasanPenolakan,
        "gambar_urls": gambarUrls == null
            ? null
            : List<dynamic>.from(gambarUrls!.map((x) => x)),
        "tanggal_penitipan": tanggalPenitipan?.toIso8601String(),
        "tanggal_verifikasi": tanggalVerifikasi?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
