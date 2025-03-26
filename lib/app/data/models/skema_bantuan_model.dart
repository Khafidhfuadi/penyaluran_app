import 'dart:convert';

class SkemaBantuanModel {
  final String? id;
  final int? petugasVerifikasiId;
  final String? nama;
  final String? deskripsi;
  final int? kuota;
  final String? kriteria;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? stokBantuanId;
  final String? kategoriBantuanId;
  final double? jumlahDiterimaPerOrang;

  SkemaBantuanModel({
    this.id,
    this.petugasVerifikasiId,
    this.nama,
    this.deskripsi,
    this.kuota,
    this.kriteria,
    this.createdAt,
    this.updatedAt,
    this.stokBantuanId,
    this.kategoriBantuanId,
    this.jumlahDiterimaPerOrang,
  });

  factory SkemaBantuanModel.fromRawJson(String str) =>
      SkemaBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SkemaBantuanModel.fromJson(Map<String, dynamic> json) =>
      SkemaBantuanModel(
        id: json["id"],
        petugasVerifikasiId: json["petugas_verifikasi_id"],
        nama: json["nama"],
        deskripsi: json["deskripsi"],
        kuota: json["kuota"],
        kriteria: json["kriteria"],
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        stokBantuanId: json["stok_bantuan_id"],
        kategoriBantuanId: json["kategori_bantuan_id"],
        jumlahDiterimaPerOrang: json["jumlah_diterima_per_orang"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "petugas_verifikasi_id": petugasVerifikasiId,
        "nama": nama,
        "deskripsi": deskripsi,
        "kuota": kuota,
        "kriteria": kriteria,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "stok_bantuan_id": stokBantuanId,
        "kategori_bantuan_id": kategoriBantuanId,
        "jumlah_diterima_per_orang": jumlahDiterimaPerOrang,
      };
}
