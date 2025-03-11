import 'dart:convert';

class StokBantuanModel {
  final String? id;
  final String? nama;
  final String? kategoriBantuanId;
  final Map<String, dynamic>? kategoriBantuan;
  final double? jumlah;
  final String? satuan;
  final String? deskripsi;
  final DateTime? tanggalMasuk;
  final DateTime? tanggalKadaluarsa;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StokBantuanModel({
    this.id,
    this.nama,
    this.kategoriBantuanId,
    this.kategoriBantuan,
    this.jumlah,
    this.satuan,
    this.deskripsi,
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
        kategoriBantuanId: json["kategori_bantuan_id"],
        kategoriBantuan: json["kategori_bantuan"],
        jumlah: json["jumlah"] != null ? json["jumlah"].toDouble() : 0.0,
        satuan: json["satuan"],
        deskripsi: json["deskripsi"],
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "nama": nama,
      "kategori_bantuan_id": kategoriBantuanId,
      "jumlah": jumlah,
      "satuan": satuan,
      "deskripsi": deskripsi,
      "tanggal_masuk": tanggalMasuk?.toIso8601String(),
      "tanggal_kadaluarsa": tanggalKadaluarsa?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };

    // Tambahkan id hanya jika tidak null
    if (id != null) {
      data["id"] = id;
    }

    return data;
  }
}
