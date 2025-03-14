import 'dart:convert';

enum StatusKelayakan { MENUNGGU, TERVERIFIKASI, DITOLAK }

class PengajuanKelayakanBantuanModel {
  final String? id;
  final String? buktiKelayakan;
  final String? alasanVerifikasi;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? skemaBantuanId;
  final String? wargaId;
  final StatusKelayakan? status;

  PengajuanKelayakanBantuanModel({
    this.id,
    this.buktiKelayakan,
    this.alasanVerifikasi,
    this.createdAt,
    this.updatedAt,
    this.skemaBantuanId,
    this.wargaId,
    this.status,
  });

  factory PengajuanKelayakanBantuanModel.fromRawJson(String str) =>
      PengajuanKelayakanBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PengajuanKelayakanBantuanModel.fromJson(Map<String, dynamic> json) =>
      PengajuanKelayakanBantuanModel(
        id: json["id"],
        buktiKelayakan: json["bukti_kelayakan"],
        alasanVerifikasi: json["alasan_verifikasi"],
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        skemaBantuanId: json["skema_bantuan_id"],
        wargaId: json["warga_id"],
        status: json["status"] != null
            ? StatusKelayakan.values.firstWhere(
                (e) => e.toString() == 'StatusKelayakan.${json["status"]}')
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "bukti_kelayakan": buktiKelayakan,
        "alasan_verifikasi": alasanVerifikasi,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "skema_bantuan_id": skemaBantuanId,
        "warga_id": wargaId,
        "status": status?.toString().split('.').last,
      };
}
