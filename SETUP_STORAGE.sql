-- 1. Create the 'documents' bucket for notification attachments
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Policy to allow anyone to view files in the 'documents' bucket
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage' 
        AND policyname = 'Public Access for Documents'
    ) THEN
        CREATE POLICY "Public Access for Documents"
        ON storage.objects FOR SELECT
        TO public
        USING (bucket_id = 'documents');
    END IF;
END
$$;

-- 3. Policy to allow authenticated users to upload files to the 'documents' bucket
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage' 
        AND policyname = 'Authenticated Uploads for Documents'
    ) THEN
        CREATE POLICY "Authenticated Uploads for Documents"
        ON storage.objects FOR INSERT
        TO authenticated
        WITH CHECK (bucket_id = 'documents');
    END IF;
END
$$;

-- 4. Policy to allow users to delete their own uploads
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage' 
        AND policyname = 'Authenticated Delete for Documents'
    ) THEN
        CREATE POLICY "Authenticated Delete for Documents"
        ON storage.objects FOR DELETE
        TO authenticated
        USING (bucket_id = 'documents');
    END IF;
END
$$;
