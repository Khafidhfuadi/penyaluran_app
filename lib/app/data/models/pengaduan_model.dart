import 'dart:convert';

class PengaduanModel {
  final String? id;
  final String? judul;
  final String? deskripsi;
  final String? status;
  final String? wargaId;
  final List<dynamic>? fotoPengaduan;
  final String? penerimaPenyaluranId;
  final DateTime? tanggalPengaduan;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? penerimaPenyaluran;
  final Map<String, dynamic>? warga;
  final String? feedbackWarga;
  final int? ratingWarga;

  PengaduanModel({
    this.id,
    this.judul,
    this.deskripsi,
    this.status,
    this.wargaId,
    this.fotoPengaduan,
    this.penerimaPenyaluranId,
    this.tanggalPengaduan,
    this.createdAt,
    this.updatedAt,
    this.penerimaPenyaluran,
    this.warga,
    this.feedbackWarga,
    this.ratingWarga,
  });

  factory PengaduanModel.fromRawJson(String str) =>
      PengaduanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PengaduanModel.fromJson(Map<String, dynamic> json) => PengaduanModel(
        id: json["id"],
        judul: json["judul"],
        deskripsi: json["deskripsi"],
        status: json["status"],
        wargaId: json["warga_id"],
        fotoPengaduan: json["foto_pengaduan"],
        penerimaPenyaluranId: json["penerima_penyaluran_id"],
        tanggalPengaduan: json["tanggal_pengaduan"] != null
            ? DateTime.parse(json["tanggal_pengaduan"])
            : null,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        penerimaPenyaluran: json["penerima_penyaluran"],
        warga: json["warga"],
        feedbackWarga: json["feedback_warga"],
        ratingWarga: json["rating_warga"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "judul": judul,
        "deskripsi": deskripsi,
        "status": status,
        "warga_id": wargaId,
        "foto_pengaduan": fotoPengaduan,
        "penerima_penyaluran_id": penerimaPenyaluranId,
        "tanggal_pengaduan": tanggalPengaduan?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "penerima_penyaluran": penerimaPenyaluran,
        "warga": warga,
        "feedback_warga": feedbackWarga,
        "rating_warga": ratingWarga,
      };

  // Getter untuk mendapatkan informasi penyaluran bantuan
  Map<String, dynamic>? get penyaluranBantuan {
    return penerimaPenyaluran?['penyaluran_bantuan'];
  }

  // Getter untuk mendapatkan informasi stok bantuan
  Map<String, dynamic>? get stokBantuan {
    return penerimaPenyaluran?['stok_bantuan'];
  }

  // Getter untuk mendapatkan nama penyaluran
  String get namaPenyaluran {
    return penyaluranBantuan?['nama'] ?? 'Tidak ada data';
  }

  // Getter untuk mendapatkan deskripsi penyaluran
  String get deskripsiPenyaluran {
    return penyaluranBantuan?['deskripsi'] ?? 'Tidak ada deskripsi';
  }

  // Getter untuk mendapatkan jenis bantuan
  String get jenisBantuan {
    return stokBantuan?['kategori_bantuan']?['nama'] ?? 'Tidak diketahui';
  }

  // Getter untuk mendapatkan jumlah bantuan yang diterima
  String get jumlahBantuan {
    final jumlah = penerimaPenyaluran?['jumlah_bantuan'];
    final satuan = penerimaPenyaluran?['satuan'] ?? '';

    if (jumlah == null) return 'Tidak diketahui';
    return '$jumlah $satuan';
  }

  // Getter untuk memeriksa apakah bantuan berupa uang
  bool get isUang {
    return stokBantuan?['is_uang'] == true;
  }
}
