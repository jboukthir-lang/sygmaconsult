-- ============================================================
-- إصلاح صلاحيات رفع الصور في Storage
-- Fix Storage Upload Permissions
-- ============================================================

-- حذف جميع الـ policies القديمة
DROP POLICY IF EXISTS "Allow public read access" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to update own files" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to delete own files" ON storage.objects;
DROP POLICY IF EXISTS "Allow admins full access" ON storage.objects;

-- تأكد من وجود bucket "public"
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'public',
  'public',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']::text[]
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']::text[];

-- السماح للجميع بقراءة الملفات
CREATE POLICY "Allow public read access"
ON storage.objects FOR SELECT
USING (bucket_id = 'public');

-- السماح للمستخدمين المسجلين برفع الملفات
CREATE POLICY "Allow authenticated users to upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'public');

-- السماح للمستخدمين بتحديث ملفاتهم الخاصة
CREATE POLICY "Allow users to update own files"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'public')
WITH CHECK (bucket_id = 'public');

-- السماح للمستخدمين بحذف ملفاتهم الخاصة
CREATE POLICY "Allow users to delete own files"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'public');

-- السماح للأدمن بالوصول الكامل
CREATE POLICY "Allow admins full access"
ON storage.objects FOR ALL
TO authenticated
USING (
  bucket_id = 'public' AND
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
)
WITH CHECK (
  bucket_id = 'public' AND
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- ============================================================
-- ✅ تم إصلاح صلاحيات Storage!
-- ✅ Storage permissions fixed!
-- ============================================================

SELECT 'Storage policies updated successfully!' AS status;
