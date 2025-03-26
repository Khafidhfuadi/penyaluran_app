-- Migration: Disable Email Verification
-- Eksekusi file ini di SQL Editor Supabase untuk mematikan konfirmasi email

-- 1. Tambahkan fungsi untuk auto konfirmasi email
CREATE OR REPLACE FUNCTION public.auto_confirm_user(user_id UUID)
RETURNS VOID AS $$
BEGIN
  -- Update email_confirmed_at menjadi waktu saat ini
  UPDATE auth.users
  SET email_confirmed_at = NOW()
  WHERE id = user_id AND email_confirmed_at IS NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Konfirmasi semua user yang belum dikonfirmasi
DO $$
DECLARE
  user_record RECORD;
BEGIN
  FOR user_record IN SELECT id FROM auth.users WHERE email_confirmed_at IS NULL
  LOOP
    PERFORM auto_confirm_user(user_record.id);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 3. Tambahkan trigger untuk auto konfirmasi user baru
CREATE OR REPLACE FUNCTION public.trigger_auto_confirm_email()
RETURNS TRIGGER AS $$
BEGIN
  -- Auto-konfirmasi email user baru
  UPDATE auth.users
  SET email_confirmed_at = NOW()
  WHERE id = NEW.id AND email_confirmed_at IS NULL;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Pasang trigger pada tabel auth.users
DROP TRIGGER IF EXISTS auto_confirm_email_trigger ON auth.users;
CREATE TRIGGER auto_confirm_email_trigger
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.trigger_auto_confirm_email();

-- Informasi untuk pengguna:
-- Query ini akan:
-- 1. Membuat fungsi untuk auto-konfirmasi user
-- 2. Mengkonfirmasi semua user yang belum dikonfirmasi
-- 3. Membuat trigger untuk auto-konfirmasi semua user baru 