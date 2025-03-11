import 'dart:convert';

class StokBantuanModel {
  final String? id;
  final String? nama;
  final String? bentukBantuanId;
  final String? sumberBantuanId;
  final String? jenisBantuanId;
  final Map<String, dynamic>? jenisBantuan;
  final double? jumlah;
  final String? satuan;
  final String? deskripsi;
  final String? status;
  final DateTime? tanggalMasuk;
  final DateTime? tanggalKadaluarsa;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StokBantuanModel({
    this.id,
    this.nama,
    this.bentukBantuanId,
    this.sumberBantuanId,
    this.jenisBantuanId,
    this.jenisBantuan,
    this.jumlah,
    this.satuan,
    this.deskripsi,
    this.status,
    this.tanggalMasuk,
    this.tanggalKadaluarsa,
    this.createdAt,
    this.updatedAt,
  });

  factory StokBantuanModel.fromRawJson(String str) =>
      StokBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StokBantuanModel.fromJson(Map<String, dynamic> json) =>
      StokBantuanModel(
        id: json["id"],
        nama: json["nama"],
        bentukBantuanId: json["bentuk_bantuan_id"],
        sumberBantuanId: json["sumber_bantuan_id"],
        jenisBantuanId: json["jenis_bantuan_id"],
        jenisBantuan: json["jenis_bantuan"],
        jumlah: json["jumlah"] != null ? json["jumlah"].toDouble() : 0.0,
        satuan: json["satuan"],
        deskripsi: json["deskripsi"],
        status: json["status"],
        tanggalMasuk: json["tanggal_masuk"] != null
            ? DateTime.parse(json["tanggal_masuk"])
            : null,
        tanggalKadaluarsa: json["tanggal_kadaluarsa"] != null
            ? DateTime.parse(json["tanggal_kadaluarsa"])
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
        "nama": nama,
        "bentuk_bantuan_id": bentukBantuanId,
        "sumber_bantuan_id": sumberBantuanId,
        "jenis_bantuan_id": jenisBantuanId,
        "jumlah": jumlah,
        "satuan": satuan,
        "deskripsi": deskripsi,
        "status": status,
        "tanggal_masuk": tanggalMasuk?.toIso8601String(),
        "tanggal_kadaluarsa": tanggalKadaluarsa?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
