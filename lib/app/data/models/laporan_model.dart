import 'dart:convert';

class LaporanModel {
  final String id;
  final String judul;
  final String? deskripsi;
  final String jenis; // Contoh: 'penyaluran', 'penitipan', 'pengaduan'
  final String?
      referensiId; // ID dari entitas yang dilaporkan (penyaluran, penitipan, dll)
  final String status; // Contoh: 'draft', 'final', 'disetujui'
  final String? userId; // Pengguna yang membuat laporan
  final List<String>? fileUrls; // URL file laporan (PDF, Excel, dll)
  final DateTime periodeAwal;
  final DateTime periodeAkhir;
  final DateTime tanggalLaporan;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LaporanModel({
    required this.id,
    required this.judul,
    this.deskripsi,
    required this.jenis,
    this.referensiId,
    required this.status,
    this.userId,
    this.fileUrls,
    required this.periodeAwal,
    required this.periodeAkhir,
    required this.tanggalLaporan,
    required this.createdAt,
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
        userId: json["user_id"],
        fileUrls: json["file_urls"] == null
            ? null
            : List<String>.from(json["file_urls"].map((x) => x)),
        periodeAwal: DateTime.parse(json["periode_awal"]),
        periodeAkhir: DateTime.parse(json["periode_akhir"]),
        tanggalLaporan: DateTime.parse(json["tanggal_laporan"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "judul": judul,
        "deskripsi": deskripsi,
        "jenis": jenis,
        "referensi_id": referensiId,
        "status": status,
        "user_id": userId,
        "file_urls": fileUrls == null
            ? null
            : List<dynamic>.from(fileUrls!.map((x) => x)),
        "periode_awal": periodeAwal.toIso8601String(),
        "periode_akhir": periodeAkhir.toIso8601String(),
        "tanggal_laporan": tanggalLaporan.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
