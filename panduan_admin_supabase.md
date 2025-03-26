# Panduan Admin Supabase: Mengatasi Masalah Konfirmasi Email

## Masalah

Aplikasi Penyaluran mengalami error saat registrasi donatur:

```
Error sending confirmation mail
```

Ini terjadi karena Supabase tidak dapat mengirim email konfirmasi, yang bisa disebabkan oleh:

1. SMTP belum dikonfigurasi dengan benar
2. Email template tidak valid
3. Konfigurasi DNS untuk domain email tidak benar

## Solusi 1: Menonaktifkan Konfirmasi Email (Paling Mudah)

1. Login ke dashboard Supabase project Anda
2. Pilih tab "Authentication" di menu sebelah kiri
3. Pilih "Email Templates"
4. Pada tab "Confirmation" nonaktifkan toggle "Enable email confirmations"
5. Klik "Save"

Dengan menonaktifkan ini, pengguna dapat langsung login setelah registrasi tanpa perlu konfirmasi email.

## Solusi 2: Menggunakan Auto-Confirm SQL Function (Lebih Aman)

Jika Anda ingin tetap menyimpan riwayat kapan email dikonfirmasi, tapi tidak ingin bergantung pada email konfirmasi aktual, ikuti langkah berikut:

1. Login ke dashboard Supabase project Anda
2. Pilih tab "SQL Editor" di menu sebelah kiri
3. Buat SQL query baru
4. Salin dan tempel kode dari file:
   ```
   supabase/migrations/20230601000000_disable_email_verification.sql
   ```
5. Jalankan SQL dengan klik tombol "Run"

Setelah menjalankan SQL ini, semua pengguna baru akan otomatis dikonfirmasi emailnya tanpa perlu mengklik link konfirmasi.

## Solusi 3: Mengkonfigurasi SMTP dengan Benar (Solusi Permanen)

Untuk mengatasi masalah secara permanen dan tetap menggunakan konfirmasi email:

1. Login ke dashboard Supabase project Anda
2. Pilih tab "Settings" di menu sebelah kiri
3. Pilih "Auth" dan scroll ke bagian "SMTP Settings"
4. Isi dengan informasi SMTP yang valid:
   - Host: (mis. smtp.gmail.com)
   - Port: (mis. 587 untuk TLS)
   - Username: email@domain.com
   - Password: [password SMTP Anda]
   - Sender Name: Penyaluran App
   - Sender Email: noreply@yourdomain.com
5. Klik "Save" dan tes konfigurasi

## Bantuan Lebih Lanjut

Jika masih mengalami masalah, silakan hubungi tim pengembang atau lihat dokumentasi Supabase di [supabase.com/docs](https://supabase.com/docs).
