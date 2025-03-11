import 'dart:convert';

class LaporanModel {
  final String? id;
  final String? judul;
  final String? deskripsi;
  final String? jenis; // Contoh: 'PENYALURAN', 'STOK_BANTUAN', 'PENERIMA'
  final String?
      referensiId; // ID dari entitas yang dilaporkan (penyaluran, penitipan, dll)
  final String? status; // Contoh: 'draft', 'final', 'disetujui'
  final String? petugasId; // Pengguna yang membuat laporan
  final List<String>? fileUrls; // URL file laporan (PDF, Excel, dll)
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final DateTime? tanggalLaporan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LaporanModel({
    this.id,
    this.judul,
    this.deskripsi,
    this.jenis,
    this.referensiId,
    this.status,
    this.petugasId,
    this.fileUrls,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.tanggalLaporan,
    this.createdAt,
    this.updatedAt,
  });

  factory LaporanModel.fromRawJson(String str) =>
      LaporanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LaporanModel.fromJson(Map<String, dynamic> json) => LaporanModel(
        id: json["id"],
        judul: json["judul"],
        deskripsi: json["deskripsi"],
        jenis: json["jenis"],
        referensiId: json["referensi_id"],
        status: json["status"],
        petugasId: json["petugas_id"] ?? json["user_id"],
        fileUrls: json["file_urls"] == null
            ? null
            : List<String>.from(json["file_urls"].map((x) => x)),
        tanggalMulai: json["tanggal_mulai"] != null
            ? DateTime.parse(json["tanggal_mulai"])
            : json["periode_awal"] != null
                ? DateTime.parse(json["periode_awal"])
                : null,
        tanggalSelesai: json["tanggal_selesai"] != null
            ? DateTime.parse(json["tanggal_selesai"])
            : json["periode_akhir"] != null
                ? DateTime.parse(json["periode_akhir"])
                : null,
        tanggalLaporan: json["tanggal_laporan"] != null
            ? DateTime.parse(json["tanggal_laporan"])
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
        "judul": judul,
        "deskripsi": deskripsi,
        "jenis": jenis,
        "referensi_id": referensiId,
        "status": status,
        "petugas_id": petugasId,
        "file_urls": fileUrls == null
            ? null
            : List<dynamic>.from(fileUrls!.map((x) => x)),
        "tanggal_mulai": tanggalMulai?.toIso8601String(),
        "tanggal_selesai": tanggalSelesai?.toIso8601String(),
        "tanggal_laporan": tanggalLaporan?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
