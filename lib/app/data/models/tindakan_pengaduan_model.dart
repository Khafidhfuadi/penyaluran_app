import 'dart:convert';

class TindakanPengaduanModel {
  final String? id;
  final String? pengaduanId;
  final String? tindakan;
  final String? catatan;
  final String? status;
  final String? petugasId;
  final DateTime? tanggalTindakan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TindakanPengaduanModel({
    this.id,
    this.pengaduanId,
    this.tindakan,
    this.catatan,
    this.status,
    this.petugasId,
    this.tanggalTindakan,
    this.createdAt,
    this.updatedAt,
  });

  factory TindakanPengaduanModel.fromRawJson(String str) =>
      TindakanPengaduanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TindakanPengaduanModel.fromJson(Map<String, dynamic> json) =>
      TindakanPengaduanModel(
        id: json["id"],
        pengaduanId: json["pengaduan_id"],
        tindakan: json["tindakan"],
        catatan: json["catatan"],
        status: json["status"],
        petugasId: json["petugas_id"],
        tanggalTindakan: json["tanggal_tindakan"] != null
            ? DateTime.parse(json["tanggal_tindakan"])
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
        "pengaduan_id": pengaduanId,
        "tindakan": tindakan,
        "catatan": catatan,
        "status": status,
        "petugas_id": petugasId,
        "tanggal_tindakan": tanggalTindakan?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
