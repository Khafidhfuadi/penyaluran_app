import 'dart:convert';

class StokBantuanModel {
  final String? id;
  final String? nama;
  final String? kategoriBantuanId;
  final Map<String, dynamic>? kategoriBantuan;
  final double? totalStok;
  final String? satuan;
  final String? deskripsi;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isUang;

  StokBantuanModel({
    this.id,
    this.nama,
    this.kategoriBantuanId,
    this.kategoriBantuan,
    this.totalStok,
    this.satuan,
    this.deskripsi,
    this.createdAt,
    this.updatedAt,
    this.isUang,
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
        totalStok: json["total_stok"] != null
            ? (json["total_stok"] is int
                ? json["total_stok"].toDouble()
                : json["total_stok"])
            : 0.0,
        satuan: json["satuan"],
        deskripsi: json["deskripsi"],
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        isUang: json["is_uang"] ?? false,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "nama": nama,
      "kategori_bantuan_id": kategoriBantuanId,
      "satuan": satuan,
      "deskripsi": deskripsi,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      "is_uang": isUang ?? false,
    };

    // Tambahkan id hanya jika tidak null
    if (id != null) {
      data["id"] = id;
    }

    // Tambahkan total_stok hanya jika tidak null
    if (totalStok != null) {
      data["total_stok"] = totalStok;
    }

    return data;
  }
}
