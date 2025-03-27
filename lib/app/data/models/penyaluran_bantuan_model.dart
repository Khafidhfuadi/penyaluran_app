import 'dart:convert';

class PenyaluranBantuanModel {
  final String? id;
  final String? nama;
  final String? deskripsi;
  final String? lokasiPenyaluranId;
  final String? petugasId;
  final String? status;
  final String? alasanPembatalan;
  final DateTime? tanggalPenyaluran;
  final String? kategoriBantuanId;
  final DateTime? tanggalPembatalan;
  final int? jumlahPenerima;
  final String? skemaId;
  final DateTime? tanggalSelesai;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? lokasiPenyaluran;
  final Map<String, dynamic>? kategori;
  final Map<String, dynamic>? petugas;
  final int? jumlahBantuan;

  PenyaluranBantuanModel({
    this.id,
    this.nama,
    this.deskripsi,
    this.lokasiPenyaluranId,
    this.petugasId,
    this.status,
    this.alasanPembatalan,
    this.tanggalPenyaluran,
    this.kategoriBantuanId,
    this.tanggalPembatalan,
    this.jumlahPenerima,
    this.skemaId,
    this.tanggalSelesai,
    this.createdAt,
    this.updatedAt,
    this.lokasiPenyaluran,
    this.kategori,
    this.petugas,
    this.jumlahBantuan,
  });

  // Mendapatkan nama lokasi dari relasi lokasiPenyaluran
  String? get lokasiNama {
    if (lokasiPenyaluran != null && lokasiPenyaluran!['nama'] != null) {
      return lokasiPenyaluran!['nama'];
    }
    return null;
  }

  // Mendapatkan nama kategori dari relasi kategori
  String? get kategoriNama {
    if (kategori != null && kategori!['nama'] != null) {
      return kategori!['nama'];
    }
    return null;
  }

  // Mendapatkan nama petugas dari relasi petugas
  String? get namaPetugas {
    if (petugas != null) {
      if (petugas!['nama_lengkap'] != null) {
        return petugas!['nama_lengkap'];
      } else if (petugas!['nama'] != null) {
        return petugas!['nama'];
      }
    }
    return null;
  }

  factory PenyaluranBantuanModel.fromRawJson(String str) =>
      PenyaluranBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PenyaluranBantuanModel.fromJson(Map<String, dynamic> json) =>
      PenyaluranBantuanModel(
        id: json["id"],
        nama: json["nama"],
        deskripsi: json["deskripsi"],
        lokasiPenyaluranId: json["lokasi_penyaluran_id"],
        petugasId: json["petugas_id"],
        status: json["status"],
        alasanPembatalan: json["alasan_pembatalan"],
        tanggalPenyaluran: json["tanggal_penyaluran"] != null
            ? DateTime.parse(json["tanggal_penyaluran"]).toUtc()
            : null,
        kategoriBantuanId: json["kategori_bantuan_id"],
        tanggalPembatalan: json["tanggal_pembatalan"] != null
            ? DateTime.parse(json["tanggal_pembatalan"]).toUtc()
            : null,
        jumlahPenerima: json["jumlah_penerima"],
        skemaId: json["skema_id"],
        tanggalSelesai: json["tanggal_selesai"] != null
            ? DateTime.parse(json["tanggal_selesai"]).toUtc()
            : null,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"]).toUtc()
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"]).toUtc()
            : null,
        lokasiPenyaluran: json["lokasi_penyaluran"],
        kategori: json["kategori"],
        petugas: json["petugas"],
        jumlahBantuan: json["jumlah_bantuan"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "deskripsi": deskripsi,
        "lokasi_penyaluran_id": lokasiPenyaluranId,
        "petugas_id": petugasId,
        "status": status,
        "alasan_pembatalan": alasanPembatalan,
        "tanggal_penyaluran": tanggalPenyaluran?.toUtc().toIso8601String(),
        "kategori_bantuan_id": kategoriBantuanId,
        "tanggal_pembatalan": tanggalPembatalan?.toUtc().toIso8601String(),
        "jumlah_penerima": jumlahPenerima,
        "skema_id": skemaId,
        "tanggal_selesai": tanggalSelesai?.toUtc().toIso8601String(),
        "created_at": createdAt?.toUtc().toIso8601String(),
        "updated_at": updatedAt?.toUtc().toIso8601String(),
      };
}
