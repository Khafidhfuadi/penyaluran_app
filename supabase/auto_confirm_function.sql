-- Fungsi untuk otomatis mengkonfirmasi email pengguna
-- File ini harus dijalankan dengan akses SQL admin di Supabase

-- 1. Buat fungsi untuk update email_confirmed_at
CREATE OR REPLACE FUNCTION public.auto_confirm_user(user_id UUID)
RETURNS VOID AS $$
BEGIN
  -- Update email_confirmed_at menjadi waktu saat ini
  UPDATE auth.users
  SET email_confirmed_at = NOW()
  WHERE id = user_id AND email_confirmed_at IS NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Buat trigger untuk otomatis mengkonfirmasi email saat user baru dibuat
CREATE OR REPLACE FUNCTION public.trigger_auto_confirm_email()
RETURNS TRIGGER AS $$
BEGIN
  -- Jika user baru dibuat dan emailnya belum dikonfirmasi, konfirmasi otomatis
  UPDATE auth.users
  SET email_confirmed_at = NOW()
  WHERE id = NEW.id AND email_confirmed_at IS NULL;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Pasang trigger pada tabel auth.users
DROP TRIGGER IF EXISTS auto_confirm_email_trigger ON auth.users;
CREATE TRIGGER auto_confirm_email_trigger
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.trigger_auto_confirm_email();

-- Catatan penggunaan:
-- 1. Jalankan SQL ini di SQL Editor Supabase sebagai admin
-- 2. Setelah dijalankan, semua pengguna baru akan otomatis dikonfirmasi emailnya
-- 3. Untuk mengkonfirmasi email pengguna yang sudah ada, jalankan:
--    SELECT auto_confirm_user('user-id-disini'); 