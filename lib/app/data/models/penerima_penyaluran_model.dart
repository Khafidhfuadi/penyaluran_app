import 'dart:convert';

class PenerimaPenyaluranModel {
  final String? id;
  final DateTime? createdAt;
  final String? penyaluranBantuanId;
  final String? wargaId;
  final String? statusPenerimaan;
  final DateTime? tanggalPenerimaan;
  final String? buktiPenerimaan;
  final String? keterangan;
  final double? jumlahBantuan;
  final String? stokBantuanId;
  final Map<String, dynamic>? warga; // Data warga yang terkait
  final String? tandaTangan;
  final bool? isUang; // Apakah bantuan berupa uang
  final String? satuan; // Satuan bantuan
  final Map<String, dynamic>? stokBantuan; // Data stok bantuan
  final Map<String, dynamic>? penyaluranBantuan; // Data penyaluran bantuan
  final String? kategoriNama; // Nama kategori bantuan
  final String? namaPenyaluran; // Nama penyaluran
  final String? deskripsiPenyaluran; // Deskripsi penyaluran
  final String? lokasiPenyaluranNama; // Nama lokasi penyaluran
  final String? lokasiPenyaluranAlamat; // Alamat lokasi penyaluran
  final String? qrCodeHash; // Hash untuk QR code

  PenerimaPenyaluranModel({
    this.id,
    this.createdAt,
    this.penyaluranBantuanId,
    this.wargaId,
    this.statusPenerimaan,
    this.tanggalPenerimaan,
    this.buktiPenerimaan,
    this.keterangan,
    this.jumlahBantuan,
    this.stokBantuanId,
    this.warga,
    this.tandaTangan,
    this.isUang,
    this.satuan,
    this.stokBantuan,
    this.penyaluranBantuan,
    this.kategoriNama,
    this.namaPenyaluran,
    this.deskripsiPenyaluran,
    this.lokasiPenyaluranNama,
    this.lokasiPenyaluranAlamat,
    this.qrCodeHash,
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
        keterangan: json["keterangan"],
        jumlahBantuan: json["jumlah_bantuan"]?.toDouble(),
        stokBantuanId: json["stok_bantuan_id"],
        warga: json["warga"],
        tandaTangan: json["tanda_tangan"],
        isUang: json["is_uang"],
        satuan: json["satuan"],
        stokBantuan: json["stok_bantuan"],
        penyaluranBantuan: json["penyaluran_bantuan"],
        kategoriNama: json["kategori_nama"],
        namaPenyaluran: json["nama_penyaluran"],
        deskripsiPenyaluran: json["deskripsi_penyaluran"],
        lokasiPenyaluranNama: json["lokasi_penyaluran_nama"],
        lokasiPenyaluranAlamat: json["lokasi_penyaluran_alamat"],
        qrCodeHash: json["qr_code_hash"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt?.toIso8601String(),
        "penyaluran_bantuan_id": penyaluranBantuanId,
        "warga_id": wargaId,
        "status_penerimaan": statusPenerimaan,
        "tanggal_penerimaan": tanggalPenerimaan?.toIso8601String(),
        "bukti_penerimaan": buktiPenerimaan,
        "keterangan": keterangan,
        "jumlah_bantuan": jumlahBantuan,
        "stok_bantuan_id": stokBantuanId,
        "warga": warga,
        "tanda_tangan": tandaTangan,
        "is_uang": isUang,
        "satuan": satuan,
        "stok_bantuan": stokBantuan,
        "penyaluran_bantuan": penyaluranBantuan,
        "kategori_nama": kategoriNama,
        "nama_penyaluran": namaPenyaluran,
        "deskripsi_penyaluran": deskripsiPenyaluran,
        "lokasi_penyaluran_nama": lokasiPenyaluranNama,
        "lokasi_penyaluran_alamat": lokasiPenyaluranAlamat,
        "qr_code_hash": qrCodeHash,
      };
}
