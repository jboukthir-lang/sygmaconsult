-- Create storage bucket for public files if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('public', 'public', true)
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies for the public bucket
-- Allow anyone to read files
CREATE POLICY IF NOT EXISTS "Public files are accessible to everyone"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'public');

-- Allow authenticated users to upload files
CREATE POLICY IF NOT EXISTS "Authenticated users can upload files"
  ON storage.objects
  FOR INSERT
  WITH CHECK (bucket_id = 'public' AND auth.role() = 'authenticated');

-- Allow admins to delete files
CREATE POLICY IF NOT EXISTS "Admins can delete files"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'public' AND
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE admin_users.user_id = auth.uid()
    )
  );

-- Allow users to update their own files
CREATE POLICY IF NOT EXISTS "Users can update their own files"
  ON storage.objects
  FOR UPDATE
  USING (bucket_id = 'public' AND auth.uid()::text = owner)
  WITH CHECK (bucket_id = 'public' AND auth.uid()::text = owner);
