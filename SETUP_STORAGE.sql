-- 1. Create the 'documents' bucket for notification attachments
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Enable RLS for the objects table (if not already enabled)
-- Note: This is usually enabled by default in Supabase

-- 3. Policy to allow anyone to view files in the 'documents' bucket
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'documents');

-- 4. Policy to allow authenticated users to upload files to the 'documents' bucket
-- This ensures only you (as an admin/logged-in user) can upload
CREATE POLICY "Authenticated Uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'documents');

-- 5. Policy to allow users to delete their own uploads
CREATE POLICY "Authenticated Delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'documents');
