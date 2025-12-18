-- ============================================================
-- إصلاح صفحة المستخدمين والرسائل
-- Fix Admin Users Page and Contacts
-- ============================================================
-- التاريخ: 18 ديسمبر 2024
-- ============================================================

-- ============================================================
-- 1️⃣ إصلاح صلاحيات جدول contacts للأدمن
-- Fix Contacts Table RLS Policies for Admin
-- ============================================================

-- حذف الـ policies القديمة
DROP POLICY IF EXISTS "Anyone can insert contacts" ON contacts;
DROP POLICY IF EXISTS "Admins can view all contacts" ON contacts;
DROP POLICY IF EXISTS "Admins can update contacts" ON contacts;
DROP POLICY IF EXISTS "Admins can delete contacts" ON contacts;
DROP POLICY IF EXISTS "Service role can do everything on contacts" ON contacts;

-- ⭐ السماح لأي شخص (زائر أو مستخدم) بإرسال رسالة
-- هذا مهم جداً! بدونه لن تعمل صفحة Contact للزوار
CREATE POLICY "Anyone can insert contacts"
ON contacts FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- السماح للأدمن بقراءة جميع الرسائل
CREATE POLICY "Admins can view all contacts"
ON contacts FOR SELECT
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- السماح للأدمن بتحديث حالة الرسائل
CREATE POLICY "Admins can update contacts"
ON contacts FOR UPDATE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- السماح للأدمن بحذف الرسائل
CREATE POLICY "Admins can delete contacts"
ON contacts FOR DELETE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- ============================================================
-- 2️⃣ التأكد من وجود جدول contacts بالشكل الصحيح
-- Ensure contacts table exists with correct structure
-- ============================================================

-- إنشاء الجدول إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  subject TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'read', 'replied')),
  reply TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- إضافة trigger للتحديث التلقائي
CREATE OR REPLACE FUNCTION update_contacts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_contacts_updated_at ON contacts;
CREATE TRIGGER update_contacts_updated_at
BEFORE UPDATE ON contacts
FOR EACH ROW
EXECUTE FUNCTION update_contacts_updated_at();

-- ============================================================
-- 3️⃣ التأكد من صلاحيات user_profiles
-- Ensure user_profiles RLS policies are correct
-- ============================================================

-- حذف الـ policies القديمة
DROP POLICY IF EXISTS "Admins can view all user profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users view own profile" ON user_profiles;

-- ⭐ Policy واحد فقط للقراءة: الأدمن يرى الكل، والمستخدم يرى ملفه فقط
CREATE POLICY "Admins view all, users view own"
ON user_profiles FOR SELECT
TO authenticated
USING (
  -- الأدمن يرى جميع الملفات
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
  OR
  -- المستخدم يرى ملفه فقط
  user_id = auth.uid()::text
);

-- السماح للمستخدمين والأدمن بتحديث ملفاتهم
CREATE POLICY "Users can update own profile"
ON user_profiles FOR UPDATE
TO authenticated
USING (user_id = auth.uid()::text OR EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text))
WITH CHECK (user_id = auth.uid()::text OR EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text));

-- ============================================================
-- 4️⃣ التأكد من صلاحيات notifications
-- Ensure notifications RLS policies are correct
-- ============================================================

-- حذف الـ policies القديمة
DROP POLICY IF EXISTS "Admins can view all notifications" ON notifications;
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Admins can create notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;

-- السماح للأدمن بقراءة جميع الإشعارات
CREATE POLICY "Admins can view all notifications"
ON notifications FOR SELECT
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
  OR user_id = auth.uid()::text
);

-- السماح للمستخدمين بقراءة إشعاراتهم
CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
TO authenticated
USING (user_id = auth.uid()::text);

-- السماح للأدمن بإنشاء إشعارات
CREATE POLICY "Admins can create notifications"
ON notifications FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- السماح للمستخدمين بتحديث حالة القراءة لإشعاراتهم
CREATE POLICY "Users can update own notifications"
ON notifications FOR UPDATE
TO authenticated
USING (user_id = auth.uid()::text)
WITH CHECK (user_id = auth.uid()::text);

-- ============================================================
-- 5️⃣ التأكد من صلاحيات bookings
-- Ensure bookings RLS policies are correct
-- ============================================================

-- حذف الـ policies القديمة
DROP POLICY IF EXISTS "Admins can view all bookings" ON bookings;
DROP POLICY IF EXISTS "Users can view own bookings" ON bookings;
DROP POLICY IF EXISTS "Admins can update bookings" ON bookings;

-- السماح للأدمن بقراءة جميع الحجوزات
CREATE POLICY "Admins can view all bookings"
ON bookings FOR SELECT
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
  OR user_id = auth.uid()::text
);

-- السماح للمستخدمين بقراءة حجوزاتهم
CREATE POLICY "Users can view own bookings"
ON bookings FOR SELECT
TO authenticated
USING (user_id = auth.uid()::text);

-- السماح للأدمن بتحديث الحجوزات
CREATE POLICY "Admins can update bookings"
ON bookings FOR UPDATE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- ============================================================
-- ✅ التحقق من النتائج
-- Verify Results
-- ============================================================

DO $$
DECLARE
  v_contacts_count INTEGER;
  v_users_count INTEGER;
  v_bookings_count INTEGER;
  v_notifications_count INTEGER;
BEGIN
  -- Get counts
  SELECT COUNT(*) INTO v_contacts_count FROM contacts;
  SELECT COUNT(*) INTO v_users_count FROM user_profiles;
  SELECT COUNT(*) INTO v_bookings_count FROM bookings;
  SELECT COUNT(*) INTO v_notifications_count FROM notifications;

  -- Display results
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ تم إصلاح صلاحيات المستخدمين والرسائل!';
  RAISE NOTICE '✅ Admin Users & Contacts Permissions Fixed!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 إحصائيات | Statistics:';
  RAISE NOTICE '------------------------------------------------------------';
  RAISE NOTICE '📧 Contact Messages: %', v_contacts_count;
  RAISE NOTICE '👥 User Profiles: %', v_users_count;
  RAISE NOTICE '📅 Bookings: %', v_bookings_count;
  RAISE NOTICE '🔔 Notifications: %', v_notifications_count;
  RAISE NOTICE '';
  RAISE NOTICE '✅ الآن يمكن للأدمن:';
  RAISE NOTICE '   - عرض جميع المستخدمين وتفاصيلهم';
  RAISE NOTICE '   - عرض جميع رسائل Contact';
  RAISE NOTICE '   - إدارة الحجوزات والإشعارات';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Admin can now:';
  RAISE NOTICE '   - View all users and their details';
  RAISE NOTICE '   - View all contact messages';
  RAISE NOTICE '   - Manage bookings and notifications';
  RAISE NOTICE '============================================================';
END $$;
