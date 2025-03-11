import 'dart:convert';

class PengaduanModel {
  final String? id;
  final String? judul;
  final String? deskripsi;
  final String? status;
  final String? kategori;
  final String? pelapor;
  final String? kontakPelapor;
  final List<String>? gambarUrls;
  final DateTime? tanggalPengaduan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PengaduanModel({
    this.id,
    this.judul,
    this.deskripsi,
    this.status,
    this.kategori,
    this.pelapor,
    this.kontakPelapor,
    this.gambarUrls,
    this.tanggalPengaduan,
    this.createdAt,
    this.updatedAt,
  });

  factory PengaduanModel.fromRawJson(String str) =>
      PengaduanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PengaduanModel.fromJson(Map<String, dynamic> json) => PengaduanModel(
        id: json["id"],
        judul: json["judul"],
        deskripsi: json["deskripsi"],
        status: json["status"],
        kategori: json["kategori"],
        pelapor: json["pelapor"],
        kontakPelapor: json["kontak_pelapor"],
        gambarUrls: json["gambar_urls"] == null
            ? null
            : List<String>.from(json["gambar_urls"].map((x) => x)),
        tanggalPengaduan: json["tanggal_pengaduan"] != null
            ? DateTime.parse(json["tanggal_pengaduan"])
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
        "status": status,
        "kategori": kategori,
        "pelapor": pelapor,
        "kontak_pelapor": kontakPelapor,
        "gambar_urls": gambarUrls == null
            ? null
            : List<dynamic>.from(gambarUrls!.map((x) => x)),
        "tanggal_pengaduan": tanggalPengaduan?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
