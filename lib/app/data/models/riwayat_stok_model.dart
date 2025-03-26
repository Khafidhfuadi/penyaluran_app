import 'dart:convert';

class RiwayatStokModel {
  final String? id;
  final String? stokBantuanId;
  final Map<String, dynamic>? stokBantuan;
  final String? jenisPerubahan; // 'penambahan' atau 'pengurangan'
  final double? jumlah;
  final String? sumber; // 'penitipan', 'penyaluran', atau 'manual'
  final String? idReferensi; // ID penitipan atau penyaluran jika bukan manual
  final String? alasan;
  final String? fotoBukti;
  final String? createdById; // ID petugas yang membuat perubahan
  final Map<String, dynamic>? createdBy;
  final DateTime? createdAt;

  RiwayatStokModel({
    this.id,
    this.stokBantuanId,
    this.stokBantuan,
    this.jenisPerubahan,
    this.jumlah,
    this.sumber,
    this.idReferensi,
    this.alasan,
    this.fotoBukti,
    this.createdById,
    this.createdBy,
    this.createdAt,
  });

  factory RiwayatStokModel.fromRawJson(String str) =>
      RiwayatStokModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RiwayatStokModel.fromJson(Map<String, dynamic> json) =>
      RiwayatStokModel(
        id: json["id"],
        stokBantuanId: json["stok_bantuan_id"],
        stokBantuan: json["stok_bantuan"],
        jenisPerubahan: json["jenis_perubahan"],
        jumlah: json["jumlah"] != null
            ? (json["jumlah"] is int
                ? json["jumlah"].toDouble()
                : json["jumlah"])
            : 0.0,
        sumber: json["sumber"],
        idReferensi: json["id_referensi"],
        alasan: json["alasan"],
        fotoBukti: json["foto_bukti"],
        createdById: json["created_by_id"],
        createdBy: json["created_by"],
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "stok_bantuan_id": stokBantuanId,
      "jenis_perubahan": jenisPerubahan,
      "jumlah": jumlah,
      "sumber": sumber,
      "created_at": createdAt?.toIso8601String(),
    };

    // Tambahkan id hanya jika tidak null
    if (id != null) {
      data["id"] = id;
    }

    // Tambahkan id_referensi jika tidak null
    if (idReferensi != null) {
      data["id_referensi"] = idReferensi;
    }

    // Tambahkan alasan jika tidak null
    if (alasan != null) {
      data["alasan"] = alasan;
    }

    // Tambahkan foto_bukti jika tidak null
    if (fotoBukti != null) {
      data["foto_bukti"] = fotoBukti;
    }

    // Tambahkan created_by_id jika tidak null
    if (createdById != null) {
      data["created_by_id"] = createdById;
    }

    return data;
  }
}
