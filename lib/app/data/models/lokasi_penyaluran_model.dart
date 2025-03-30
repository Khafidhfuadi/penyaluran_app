import 'dart:convert';

class LokasiPenyaluranModel {
  final String id;
  final String nama;
  final String? alamatLengkap;
  final String? desa;
  final String? kecamatan;
  final String? kabupaten;
  final String? provinsi;
  final String? kodePos;
  final double? latitude;
  final double? longitude;
  final String? petugasDesaId; // Referensi ke PetugasDesa
  final bool isLokasiTitip; // Field baru untuk menentukan lokasi penitipan
  final DateTime createdAt;
  final DateTime? updatedAt;

  LokasiPenyaluranModel({
    required this.id,
    required this.nama,
    this.alamatLengkap,
    this.desa,
    this.kecamatan,
    this.kabupaten,
    this.provinsi,
    this.kodePos,
    this.latitude,
    this.longitude,
    this.petugasDesaId,
    this.isLokasiTitip = false, // Nilai default false
    required this.createdAt,
    this.updatedAt,
  });

  factory LokasiPenyaluranModel.fromRawJson(String str) =>
      LokasiPenyaluranModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LokasiPenyaluranModel.fromJson(Map<String, dynamic> json) =>
      LokasiPenyaluranModel(
        id: json["id"],
        nama: json["nama"],
        alamatLengkap: json["alamat_lengkap"],
        desa: json["desa"],
        kecamatan: json["kecamatan"],
        kabupaten: json["kabupaten"],
        provinsi: json["provinsi"],
        kodePos: json["kode_pos"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        petugasDesaId: json["petugas_desa_id"],
        isLokasiTitip: json["is_lokasi_titip"] ?? false,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "alamat_lengkap": alamatLengkap,
        "desa": desa,
        "kecamatan": kecamatan,
        "kabupaten": kabupaten,
        "provinsi": provinsi,
        "kode_pos": kodePos,
        "latitude": latitude,
        "longitude": longitude,
        "petugas_desa_id": petugasDesaId,
        "is_lokasi_titip": isLokasiTitip,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
