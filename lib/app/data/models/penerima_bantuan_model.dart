import 'dart:convert';

class PenerimaBantuanModel {
  final String id;
  final String nama;
  final String? nik;
  final String? alamat;
  final String? desa;
  final String? kecamatan;
  final String? kabupaten;
  final String? provinsi;
  final String? noTelp;
  final String? kategori; // Contoh: 'lansia', 'disabilitas', 'miskin', dll
  final String? status; // Contoh: 'aktif', 'nonaktif'
  final String? lokasiPenyaluranId; // Referensi ke LokasiPenyaluran
  final DateTime createdAt;
  final DateTime? updatedAt;

  PenerimaBantuanModel({
    required this.id,
    required this.nama,
    this.nik,
    this.alamat,
    this.desa,
    this.kecamatan,
    this.kabupaten,
    this.provinsi,
    this.noTelp,
    this.kategori,
    this.status,
    this.lokasiPenyaluranId,
    required this.createdAt,
    this.updatedAt,
  });

  factory PenerimaBantuanModel.fromRawJson(String str) =>
      PenerimaBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PenerimaBantuanModel.fromJson(Map<String, dynamic> json) =>
      PenerimaBantuanModel(
        id: json["id"],
        nama: json["nama"],
        nik: json["nik"],
        alamat: json["alamat"],
        desa: json["desa"],
        kecamatan: json["kecamatan"],
        kabupaten: json["kabupaten"],
        provinsi: json["provinsi"],
        noTelp: json["no_telp"],
        kategori: json["kategori"],
        status: json["status"],
        lokasiPenyaluranId: json["lokasi_penyaluran_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "nik": nik,
        "alamat": alamat,
        "desa": desa,
        "kecamatan": kecamatan,
        "kabupaten": kabupaten,
        "provinsi": provinsi,
        "no_telp": noTelp,
        "kategori": kategori,
        "status": status,
        "lokasi_penyaluran_id": lokasiPenyaluranId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
