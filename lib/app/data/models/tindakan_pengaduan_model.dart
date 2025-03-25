import 'dart:convert';

class TindakanPengaduanModel {
  final String? id;
  final String? pengaduanId;
  final String? tindakan;
  final String? catatan;
  final String? statusTindakan; // PROSES, SELESAI
  final String? kategoriTindakan; // Kategori tindakan enum
  final String? petugasId;
  final String? verifikatorId;
  final String? hasilTindakan;
  final List<dynamic>? buktiTindakan;
  final DateTime? estimasiSelesai;
  final DateTime? tanggalTindakan;
  final DateTime? tanggalVerifikasi;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? biayaTindakan;
  final Map<String, dynamic>? petugas; // Data petugas yang melakukan tindakan
  final Map<String, dynamic>? verifikator; // Data petugas yang memverifikasi

  TindakanPengaduanModel({
    this.id,
    this.pengaduanId,
    this.tindakan,
    this.catatan,
    this.statusTindakan,
    this.kategoriTindakan,
    this.petugasId,
    this.verifikatorId,
    this.hasilTindakan,
    this.buktiTindakan,
    this.estimasiSelesai,
    this.tanggalTindakan,
    this.tanggalVerifikasi,
    this.createdAt,
    this.updatedAt,
    this.biayaTindakan,
    this.petugas,
    this.verifikator,
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
        statusTindakan: json["status_tindakan"],
        kategoriTindakan: json["kategori_tindakan"],
        petugasId: json["petugas_id"],
        verifikatorId: json["verifikator_id"],
        hasilTindakan: json["hasil_tindakan"],
        buktiTindakan: json["bukti_tindakan"],
        estimasiSelesai: json["estimasi_selesai"] != null
            ? DateTime.parse(json["estimasi_selesai"])
            : null,
        tanggalTindakan: json["tanggal_tindakan"] != null
            ? DateTime.parse(json["tanggal_tindakan"])
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
        biayaTindakan: json["biaya_tindakan"]?.toDouble(),
        petugas: json["petugas"],
        verifikator: json["verifikator"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pengaduan_id": pengaduanId,
        "tindakan": tindakan,
        "catatan": catatan,
        "status_tindakan": statusTindakan,
        "kategori_tindakan": kategoriTindakan,
        "petugas_id": petugasId,
        "verifikator_id": verifikatorId,
        "hasil_tindakan": hasilTindakan,
        "bukti_tindakan": buktiTindakan,
        "estimasi_selesai": estimasiSelesai?.toIso8601String(),
        "tanggal_tindakan": tanggalTindakan?.toIso8601String(),
        "tanggal_verifikasi": tanggalVerifikasi?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "biaya_tindakan": biayaTindakan,
        "petugas": petugas,
        "verifikator": verifikator,
      };

  // Getter untuk mendapatkan nama petugas
  String get namaPetugas {
    if (petugas != null && petugas!['nama_lengkap'] != null) {
      return petugas!['nama_lengkap'];
    }
    return 'Petugas';
  }

  // Getter untuk mendapatkan nama verifikator
  String get namaVerifikator {
    if (verifikator != null && verifikator!['nama_lengkap'] != null) {
      return verifikator!['nama_lengkap'];
    }
    return 'Belum diverifikasi';
  }

  // Getter untuk mendapatkan status tindakan yang lebih user-friendly
  String get statusTindakanText {
    switch (statusTindakan) {
      case 'PROSES':
        return 'Dalam Proses';
      case 'SELESAI':
        return 'Selesai';
      default:
        return statusTindakan ?? 'Tidak Diketahui';
    }
  }

  // Getter untuk mendapatkan kategori tindakan yang lebih user-friendly
  String get kategoriTindakanText {
    if (kategoriTindakan == null) return 'Tidak Diketahui';

    // Mengubah format SNAKE_CASE menjadi Title Case
    return kategoriTindakan!
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
