import 'dart:convert';

// warga == penerima bantuan
class WargaModel {
  final String? id;
  final String? nama;
  final String? nik;
  final String? alamat;
  final String? desa;
  final String? kecamatan;
  final String? kabupaten;
  final String? provinsi;
  final String? telepon;
  final String? email;
  final String? catatan;
  final String? kategori; // Contoh: 'lansia', 'disabilitas', 'miskin', dll
  final String? status; // Contoh: 'AKTIF', 'NONAKTIF'
  final String? lokasiPenyaluranId; // Referensi ke LokasiPenyaluran
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WargaModel({
    this.id,
    this.nama,
    this.nik,
    this.alamat,
    this.desa,
    this.kecamatan,
    this.kabupaten,
    this.provinsi,
    this.telepon,
    this.email,
    this.catatan,
    this.kategori,
    this.status,
    this.lokasiPenyaluranId,
    this.createdAt,
    this.updatedAt,
  });

  factory WargaModel.fromRawJson(String str) =>
      WargaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WargaModel.fromJson(Map<String, dynamic> json) => WargaModel(
        id: json["id"],
        nama: json["nama"],
        nik: json["nik"],
        alamat: json["alamat"],
        desa: json["desa"],
        kecamatan: json["kecamatan"],
        kabupaten: json["kabupaten"],
        provinsi: json["provinsi"],
        telepon: json["telepon"] ?? json["no_telp"],
        email: json["email"],
        catatan: json["catatan"],
        kategori: json["kategori"],
        status: json["status"],
        lokasiPenyaluranId: json["lokasi_penyaluran_id"],
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
        "nik": nik,
        "alamat": alamat,
        "desa": desa,
        "kecamatan": kecamatan,
        "kabupaten": kabupaten,
        "provinsi": provinsi,
        "telepon": telepon,
        "email": email,
        "catatan": catatan,
        "kategori": kategori,
        "status": status,
        "lokasi_penyaluran_id": lokasiPenyaluranId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
