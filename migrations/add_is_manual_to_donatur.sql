-- Migrasi untuk menambahkan kolom is_manual pada tabel donatur
-- Jalankan melalui SQL Editor di Supabase

-- Tambahkan kolom is_manual jika belum ada
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'donatur'
    AND column_name = 'is_manual'
  ) THEN
    ALTER TABLE donatur ADD COLUMN is_manual BOOLEAN DEFAULT FALSE;
    
    -- Tambahkan indeks untuk mempercepat pencarian donatur manual
    CREATE INDEX idx_donatur_is_manual ON donatur(is_manual);
    
    -- Tambahkan komentar pada kolom
    COMMENT ON COLUMN donatur.is_manual IS 'Flag untuk menandai donatur yang dibuat secara manual oleh petugas desa';
  END IF;
END
$$; 