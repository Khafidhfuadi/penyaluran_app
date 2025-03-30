# Fungsi SQL untuk Supabase

File-file SQL di direktori ini berisi fungsi-fungsi yang perlu dijalankan pada database Supabase untuk mendukung fitur-fitur aplikasi.

## Cara Menginstal Fungsi SQL

1. Login ke dashboard Supabase untuk project Anda
2. Buka bagian "SQL Editor"
3. Klik "New Query"
4. Copy dan paste isi file SQL yang ingin diinstal (misalnya `batch_update_jadwal_status.sql`)
5. Jalankan query dengan mengklik tombol "Run"

## Daftar Fungsi SQL

### batch_update_jadwal_status

Fungsi ini digunakan untuk mengupdate status banyak jadwal sekaligus, yang lebih efisien daripada melakukan update satu per satu.

**Sintaks Penggunaan:**

```sql
SELECT batch_update_jadwal_status(
  ARRAY[
    '{"id": "jadwal-id-1", "status": "AKTIF"}',
    '{"id": "jadwal-id-2", "status": "BATALTERLAKSANA"}'
  ]::jsonb[],
  '2023-01-01T00:00:00Z'
);
```

**Parameter:**

- `jadwal_updates`: Array dari objek JSON dengan properti `id` dan `status`
- `updated_timestamp` (opsional): Waktu update dalam format ISO 8601

**Status yang Valid:**
Berikut adalah nilai-nilai yang valid untuk kolom status (enum `StatusPenyaluranBantuan`):

- `DIJADWALKAN` - Jadwal telah dibuat tapi belum aktif
- `AKTIF` - Jadwal sedang berlangsung
- `TERLAKSANA` - Jadwal telah berhasil dilaksanakan
- `BATALTERLAKSANA` - Jadwal tidak terlaksana atau dibatalkan

**Contoh Response:**

```json
{
  "success": true,
  "updated_count": 2,
  "success_ids": ["jadwal-id-1", "jadwal-id-2"],
  "timestamp": "2023-01-01T00:00:00Z",
  "errors": {
    "count": 0,
    "ids": [],
    "messages": []
  }
}
```

## Cara Menguji Fungsi

Setelah fungsi diinstal, Anda dapat mengujinya dengan menjalankan query berikut pada SQL Editor:

```sql
-- Pastikan status yang digunakan sesuai dengan enum StatusPenyaluranBantuan
SELECT batch_update_jadwal_status(
  ARRAY[
    '{"id": "534cb328-1fd9-4945-8642-c99b8e1acb2d", "status": "DIJADWALKAN"}'
  ]::jsonb[]
);
```

Ganti `534cb328-1fd9-4945-8642-c99b8e1acb2d` dengan ID jadwal yang valid dari tabel `penyaluran_bantuan` Anda.

## Membuat Enum di Database (Jika Belum Ada)

Jika enum `StatusPenyaluranBantuan` belum ada di database, Anda dapat membuatnya dengan query berikut:

```sql
CREATE TYPE "StatusPenyaluranBantuan" AS ENUM (
  'DIJADWALKAN',
  'AKTIF',
  'TERLAKSANA',
  'BATALTERLAKSANA'
);
```

## Troubleshooting

Jika muncul error:

- Periksa apakah ID jadwal valid dan ada di tabel `penyaluran_bantuan`
- Pastikan format UUID benar (harus berupa UUID valid, bukan string biasa)
- Periksa apakah nilai status valid dan sesuai dengan tipe enum `StatusPenyaluranBantuan`
- Pastikan tabel `penyaluran_bantuan` memiliki kolom `status` dengan tipe data enum `StatusPenyaluranBantuan` dan kolom `updated_at`

Error umum:

1. `column "status" is of type "StatusPenyaluranBantuan" but expression is of type text` - Ini terjadi karena kolom status memiliki tipe enum, bukan teks biasa. Fungsi sudah menyertakan cast ke enum.
2. `operator does not exist: uuid = text` - Ini terjadi jika ID tidak dikonversi ke UUID. Fungsi sudah menyertakan cast ke UUID.

## Menambahkan Nilai Baru ke Enum

Jika perlu menambahkan nilai enum baru di masa depan, gunakan SQL berikut:

```sql
ALTER TYPE "StatusPenyaluranBantuan" ADD VALUE 'NILAI_BARU';
```
