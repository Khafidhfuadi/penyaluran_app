import 'dart:convert';
import 'package:penyaluran_app/app/data/models/donatur_model.dart';
import 'package:penyaluran_app/app/data/models/kategori_bantuan_model.dart';

class PenitipanBantuanModel {
  final String? id;
  final String? donaturId;
  final String? stokBantuanId;
  final double? jumlah;
  final String? deskripsi;
  final String? status;
  final String? alasanPenolakan;
  final List<String>? fotoBantuan;
  final DateTime? tanggalPenitipan;
  final DateTime? tanggalVerifikasi;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? petugasDesaId;
  final String? fotoBuktiSerahTerima;
  final String? sumberBantuanId;
  final DonaturModel? donatur;
  final KategoriBantuanModel? kategoriBantuan;
  final bool? isUang;

  PenitipanBantuanModel({
    this.id,
    this.donaturId,
    this.stokBantuanId,
    this.jumlah,
    this.deskripsi,
    this.status,
    this.alasanPenolakan,
    this.fotoBantuan,
    this.tanggalPenitipan,
    this.tanggalVerifikasi,
    this.createdAt,
    this.updatedAt,
    this.petugasDesaId,
    this.fotoBuktiSerahTerima,
    this.sumberBantuanId,
    this.donatur,
    this.kategoriBantuan,
    this.isUang,
  });

  factory PenitipanBantuanModel.fromRawJson(String str) =>
      PenitipanBantuanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PenitipanBantuanModel.fromJson(Map<String, dynamic> json) =>
      PenitipanBantuanModel(
        id: json["id"],
        donaturId: json["donatur_id"],
        stokBantuanId: json["stok_bantuan_id"],
        jumlah: json["jumlah"] != null ? json["jumlah"].toDouble() : 0.0,
        deskripsi: json["deskripsi"],
        status: json["status"],
        alasanPenolakan: json["alasan_penolakan"],
        fotoBantuan: json["foto_bantuan"] == null
            ? null
            : List<String>.from(json["foto_bantuan"].map((x) => x)),
        tanggalPenitipan: json["tanggal_penitipan"] != null
            ? DateTime.parse(json["tanggal_penitipan"])
            : null,
        tanggalVerifikasi: json["tanggal_verifikasi"] != null
            ? DateTime.parse(json["tanggal_verifikasi"])
            : null,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        petugasDesaId: json["petugas_desa_id"],
        fotoBuktiSerahTerima: json["foto_bukti_serah_terima"],
        sumberBantuanId: json["sumber_bantuan_id"],
        donatur: json["donatur"] != null
            ? DonaturModel.fromJson(json["donatur"])
            : null,
        kategoriBantuan: json["kategori_bantuan"] != null
            ? KategoriBantuanModel.fromJson(json["kategori_bantuan"])
            : null,
        isUang: json["is_uang"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "donatur_id": donaturId,
        "stok_bantuan_id": stokBantuanId,
        "jumlah": jumlah,
        "deskripsi": deskripsi,
        "status": status,
        "alasan_penolakan": alasanPenolakan,
        "foto_bantuan": fotoBantuan == null
            ? null
            : List<dynamic>.from(fotoBantuan!.map((x) => x)),
        "tanggal_penitipan": tanggalPenitipan?.toIso8601String(),
        "tanggal_verifikasi": tanggalVerifikasi?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "petugas_desa_id": petugasDesaId,
        "foto_bukti_serah_terima": fotoBuktiSerahTerima,
        "sumber_bantuan_id": sumberBantuanId,
        "is_uang": isUang ?? false,
      };
}
