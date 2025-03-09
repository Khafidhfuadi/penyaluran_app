import 'dart:convert';

class StokBantuanModel {
  final String id;
  final String bentukBantuanId; // Referensi ke BentukBantuan
  final double jumlahMasuk;
  final double jumlahKeluar;
  final double stokSisa;
  final String? satuan;
  final String? catatan;
  final DateTime tanggalUpdate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StokBantuanModel({
    required this.id,
    required this.bentukBantuanId,
    required this.jumlahMasuk,
    required this.jumlahKeluar,
    required this.stokSisa,
    this.satuan,
    this.catatan,
    required this.tanggalUpdate,
    required this.createdAt,
    this.updatedAt,
  });

  factory StokBantuanModel.fromRawJson(String str) =>
      StokBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StokBantuanModel.fromJson(Map<String, dynamic> json) =>
      StokBantuanModel(
        id: json["id"],
        bentukBantuanId: json["bentuk_bantuan_id"],
        jumlahMasuk: json["jumlah_masuk"].toDouble(),
        jumlahKeluar: json["jumlah_keluar"].toDouble(),
        stokSisa: json["stok_sisa"].toDouble(),
        satuan: json["satuan"],
        catatan: json["catatan"],
        tanggalUpdate: DateTime.parse(json["tanggal_update"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "bentuk_bantuan_id": bentukBantuanId,
        "jumlah_masuk": jumlahMasuk,
        "jumlah_keluar": jumlahKeluar,
        "stok_sisa": stokSisa,
        "satuan": satuan,
        "catatan": catatan,
        "tanggal_update": tanggalUpdate.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
