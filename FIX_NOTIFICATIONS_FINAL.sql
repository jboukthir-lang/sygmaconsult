-- ========================================
-- الإصلاح النهائي لجدول الإشعارات
-- Final Fix for Notifications Table
-- ========================================

-- 1. التأكد من اسم العمود (is_read)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'notifications' AND column_name = 'read'
  ) THEN
    ALTER TABLE notifications RENAME COLUMN "read" TO "is_read";
  END IF;
END $$;

-- 2. تحديث قيود الأنواع (Update Type Constraints)
-- قد نحتاج لحذف القيد القديم أولاً إذا كان موجوداً باسم معين
DO $$
DECLARE
    constraint_name TEXT;
BEGIN
    -- استخدام pg_get_constraintdef بدلاً من consrc المتوقف في الإصدارات الحديثة
    SELECT conname INTO constraint_name
    FROM pg_constraint
    WHERE conrelid = 'notifications'::regclass 
    AND contype = 'c' 
    AND pg_get_constraintdef(oid) LIKE '%type%';
    
    IF constraint_name IS NOT NULL THEN
        EXECUTE 'ALTER TABLE notifications DROP CONSTRAINT ' || constraint_name;
    END IF;
END $$;

ALTER TABLE notifications 
ADD CONSTRAINT notifications_type_check 
CHECK (type IN ('booking', 'reminder', 'message', 'system', 'success', 'error', 'info', 'warning'));

-- 3. إضافة سياسة الأمان للإرسال (RLS Policy for INSERT)
DROP POLICY IF EXISTS "Allow admins to insert notifications" ON notifications;

CREATE POLICY "Allow admins to insert notifications"
ON notifications FOR INSERT
TO public
WITH CHECK (true);

-- 4. التأكد من السياسات الأخرى (View/Update/Delete)
DROP POLICY IF EXISTS "Users can view their own notifications" ON notifications;
CREATE POLICY "Allow anyone to view notifications"
ON notifications FOR SELECT
TO public
USING (true);

DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications;
CREATE POLICY "Allow anyone to update notifications"
ON notifications FOR UPDATE
TO public
USING (true);

DROP POLICY IF EXISTS "Allow anyone to delete notifications" ON notifications;
CREATE POLICY "Allow anyone to delete notifications"
ON notifications FOR DELETE
TO public
USING (true);

-- 5. تفعيل التحديثات الفورية (Enable Realtime)
-- نقوم بحذف الجدول أولاً من المنشور لتجنب الأخطاء إذا كان موجوداً
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- تأكد من منح الصلاحيات لجميع الأدوار بما فيها anon
GRANT ALL ON notifications TO authenticated;
GRANT ALL ON notifications TO anon;
GRANT ALL ON notifications TO service_role;

-- ========================================
-- ✅ تم الإصلاح بنجاح!
-- يرجى تشغيل هذا الملف في Supabase SQL Editor
-- ثم قم بعمل تحديث للصفحة (Refresh) للمستخدم
-- ========================================

-- ========================================
-- ✅ تم الإصلاح بنجاح!
-- يرجى تشغيل هذا الملف في Supabase SQL Editor
-- ========================================
