import 'dart:convert';

class PenerimaPenyaluranModel {
  final String? id;
  final DateTime? createdAt;
  final String? penyaluranBantuanId;
  final String? wargaId;
  final String? statusPenerimaan;
  final DateTime? tanggalPenerimaan;
  final String? buktiPenerimaan;
  final double? jumlahBantuan;
  final String? stokBantuanId;
  final String? tandaTangan;
  final String? qrCodeHash;

  // Relasi data
  final Map<String, dynamic>? warga; // Data warga yang terkait
  final Map<String, dynamic>? stokBantuan; // Data stok bantuan
  final Map<String, dynamic>? penyaluranBantuan; // Data penyaluran bantuan

  // Properti turunan yang diambil dari relasi
  final String? kategoriNama; // Nama kategori bantuan dari relasi
  final String? namaPenyaluran; // Nama penyaluran dari relasi
  final String? deskripsiPenyaluran; // Deskripsi penyaluran dari relasi
  final String? lokasiPenyaluranNama; // Nama lokasi penyaluran dari relasi
  final String? lokasiPenyaluranAlamat; // Alamat lokasi penyaluran dari relasi
  final String? statusPenyaluran; // Status penyaluran dari relasi
  final String? satuan; // Satuan dari relasi stok bantuan
  final bool? isUang; // Flag is_uang dari relasi stok bantuan

  PenerimaPenyaluranModel({
    this.id,
    this.createdAt,
    this.penyaluranBantuanId,
    this.wargaId,
    this.statusPenerimaan,
    this.tanggalPenerimaan,
    this.buktiPenerimaan,
    this.jumlahBantuan,
    this.stokBantuanId,
    this.tandaTangan,
    this.qrCodeHash,
    // Relasi
    this.warga,
    this.stokBantuan,
    this.penyaluranBantuan,
    // Properti turunan
    this.kategoriNama,
    this.namaPenyaluran,
    this.deskripsiPenyaluran,
    this.lokasiPenyaluranNama,
    this.lokasiPenyaluranAlamat,
    this.statusPenyaluran,
    this.satuan,
    this.isUang,
  });

  factory PenerimaPenyaluranModel.fromRawJson(String str) =>
      PenerimaPenyaluranModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PenerimaPenyaluranModel.fromJson(Map<String, dynamic> json) =>
      PenerimaPenyaluranModel(
        id: json["id"],
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        penyaluranBantuanId: json["penyaluran_bantuan_id"],
        wargaId: json["warga_id"],
        statusPenerimaan: json["status_penerimaan"],
        tanggalPenerimaan: json["tanggal_penerimaan"] != null
            ? DateTime.parse(json["tanggal_penerimaan"])
            : null,
        buktiPenerimaan: json["bukti_penerimaan"],
        jumlahBantuan: json["jumlah_bantuan"]?.toDouble(),
        stokBantuanId: json["stok_bantuan_id"],
        tandaTangan: json["tanda_tangan"],
        qrCodeHash: json["qr_code_hash"],
        // Relasi
        warga: json["warga"],
        stokBantuan: json["stok_bantuan"],
        penyaluranBantuan: json["penyaluran_bantuan"],
        // Properti turunan
        kategoriNama: json["kategori_nama"],
        namaPenyaluran: json["nama_penyaluran"],
        deskripsiPenyaluran: json["deskripsi_penyaluran"],
        lokasiPenyaluranNama: json["lokasi_penyaluran_nama"],
        lokasiPenyaluranAlamat: json["lokasi_penyaluran_alamat"],
        statusPenyaluran: json["status_penyaluran"],
        satuan: json["satuan"] ?? json["stok_bantuan"]?["satuan"],
        isUang: json["is_uang"] ?? json["stok_bantuan"]?["is_uang"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt?.toIso8601String(),
        "penyaluran_bantuan_id": penyaluranBantuanId,
        "warga_id": wargaId,
        "status_penerimaan": statusPenerimaan,
        "tanggal_penerimaan": tanggalPenerimaan?.toIso8601String(),
        "bukti_penerimaan": buktiPenerimaan,
        "jumlah_bantuan": jumlahBantuan,
        "stok_bantuan_id": stokBantuanId,
        "tanda_tangan": tandaTangan,
        "qr_code_hash": qrCodeHash,
        // Relasi tidak perlu disertakan dalam toJson karena
        // biasanya hanya digunakan untuk serialisasi ke database
      };
}
