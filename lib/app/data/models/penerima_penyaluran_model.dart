import 'dart:convert';

class PenerimaPenyaluranModel {
  final int? id;
  final DateTime? createdAt;
  final String? penyaluranBantuanId;
  final String? wargaId;
  final String? statusPenerimaan;
  final DateTime? tanggalPenerimaan;
  final String? buktiPenerimaan;
  final String? keterangan;
  final double? jumlahBantuan;
  final String? stokBantuanId;
  final Map<String, dynamic>? warga; // Data warga yang terkait

  PenerimaPenyaluranModel({
    this.id,
    this.createdAt,
    this.penyaluranBantuanId,
    this.wargaId,
    this.statusPenerimaan,
    this.tanggalPenerimaan,
    this.buktiPenerimaan,
    this.keterangan,
    this.jumlahBantuan,
    this.stokBantuanId,
    this.warga,
  });

  factory PenerimaPenyaluranModel.fromRawJson(String str) =>
      PenerimaPenyaluranModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PenerimaPenyaluranModel.fromJson(Map<String, dynamic> json) =>
      PenerimaPenyaluranModel(
        id: json["id"],
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        penyaluranBantuanId: json["penyaluran_bantuan_id"],
        wargaId: json["warga_id"],
        statusPenerimaan: json["status_penerimaan"],
        tanggalPenerimaan: json["tanggal_penerimaan"] != null
            ? DateTime.parse(json["tanggal_penerimaan"])
            : null,
        buktiPenerimaan: json["bukti_penerimaan"],
        keterangan: json["keterangan"],
        jumlahBantuan: json["jumlah_bantuan"]?.toDouble(),
        stokBantuanId: json["stok_bantuan_id"],
        warga: json["warga"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt?.toIso8601String(),
        "penyaluran_bantuan_id": penyaluranBantuanId,
        "warga_id": wargaId,
        "status_penerimaan": statusPenerimaan,
        "tanggal_penerimaan": tanggalPenerimaan?.toIso8601String(),
        "bukti_penerimaan": buktiPenerimaan,
        "keterangan": keterangan,
        "jumlah_bantuan": jumlahBantuan,
        "stok_bantuan_id": stokBantuanId,
        "warga": warga,
      };
}
