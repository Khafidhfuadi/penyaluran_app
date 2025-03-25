import 'dart:convert';

class DonaturModel {
  final String id; // Primary key yang juga foreign key ke auth.users(id)
  final String? namaLengkap;
  final String? alamat;
  final String? noHp;
  final String? email;
  final String? jenis;
  final String? deskripsi;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DonaturModel({
    required this.id,
    this.namaLengkap,
    this.alamat,
    this.noHp,
    this.email,
    this.jenis,
    this.deskripsi,
    this.status = 'AKTIF',
    this.createdAt,
    this.updatedAt,
  });

  factory DonaturModel.fromRawJson(String str) =>
      DonaturModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DonaturModel.fromJson(Map<String, dynamic> json) => DonaturModel(
        id: json["id"],
        namaLengkap: json["nama_lengkap"],
        alamat: json["alamat"],
        noHp: json["no_hp"],
        email: json["email"],
        jenis: json["jenis"],
        deskripsi: json["deskripsi"],
        status: json["status"] ?? 'AKTIF',
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama_lengkap": namaLengkap,
        "alamat": alamat,
        "no_hp": noHp,
        "email": email,
        "jenis": jenis,
        "deskripsi": deskripsi,
        "status": status ?? 'AKTIF',
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };

  // Helper method untuk mendapatkan nama yang ditampilkan
  String get displayName => namaLengkap ?? 'Donatur';

  // Getter untuk kompatibilitas dengan kode yang masih menggunakan nama
  String? get nama => namaLengkap;
}
