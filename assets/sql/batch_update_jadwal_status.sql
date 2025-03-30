-- Fungsi untuk memperbarui status banyak jadwal sekaligus
-- Penggunaan:
-- SELECT batch_update_jadwal_status(
--   ARRAY[
--     '{"id": "jadwal-id-1", "status": "AKTIF"}',
--     '{"id": "jadwal-id-2", "status": "BATALTERLAKSANA"}'
--   ]::jsonb[],
--   '2023-01-01T00:00:00Z'
-- );

CREATE OR REPLACE FUNCTION public.batch_update_jadwal_status(
  jadwal_updates jsonb[],
  updated_timestamp text DEFAULT NOW()
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  jadwal_item jsonb;
  jadwal_id text;
  new_status text;
  updated_count int := 0;
  success_ids text[] := '{}';
  result jsonb;
  error_ids text[] := '{}';
  error_messages text[] := '{}';
BEGIN
  -- Loop melalui setiap item dalam array
  FOREACH jadwal_item IN ARRAY jadwal_updates
  LOOP
    -- Ekstrak ID dan status dari item JSON
    jadwal_id := jadwal_item->>'id';
    new_status := jadwal_item->>'status';
    
    -- Konversi ID string ke UUID secara eksplisit dan status ke enum
    BEGIN
      -- Update jadwal penyaluran dengan cast eksplisit ke UUID dan StatusPenyaluranBantuan
      UPDATE public.penyaluran_bantuan
      SET 
        status = new_status::public."StatusPenyaluranBantuan",
        updated_at = updated_timestamp
      WHERE id = jadwal_id::uuid;
      
      -- Jika berhasil diperbarui
      IF FOUND THEN
        updated_count := updated_count + 1;
        success_ids := array_append(success_ids, jadwal_id);
      END IF;
      
    EXCEPTION 
      WHEN invalid_text_representation THEN
        -- Log error jika konversi UUID gagal
        RAISE NOTICE 'Invalid UUID format: %', jadwal_id;
        error_ids := array_append(error_ids, jadwal_id);
        error_messages := array_append(error_messages, 'Invalid UUID format');
      WHEN others THEN
        -- Tangkap error lainnya
        RAISE NOTICE 'Error updating status for jadwal ID %: %', jadwal_id, SQLERRM;
        error_ids := array_append(error_ids, jadwal_id);
        error_messages := array_append(error_messages, SQLERRM);
    END;
  END LOOP;
  
  -- Buat hasil dalam format JSON
  result := jsonb_build_object(
    'success', updated_count > 0,
    'updated_count', updated_count,
    'success_ids', success_ids,
    'timestamp', updated_timestamp,
    'errors', jsonb_build_object(
      'count', array_length(error_ids, 1),
      'ids', error_ids,
      'messages', error_messages
    )
  );
  
  RETURN result;
END;
$$; 