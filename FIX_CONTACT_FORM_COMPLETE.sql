-- ============================================================
-- 📧 إصلاح نموذج الاتصال بالكامل
-- Complete Contact Form Fix
-- ============================================================
-- التاريخ: 18 ديسمبر 2024
-- الهدف: السماح للزوار بإرسال رسائل + السماح للأدمن برؤيتها
-- ============================================================

-- ============================================================
-- 1️⃣ إنشاء جدول contacts (إذا لم يكن موجوداً)
-- Create contacts table (if not exists)
-- ============================================================

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

COMMENT ON TABLE contacts IS 'رسائل نموذج الاتصال من صفحة Contact';

-- ============================================================
-- 2️⃣ إضافة trigger للتحديث التلقائي
-- Add auto-update trigger
-- ============================================================

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
-- 3️⃣ تفعيل Row Level Security
-- Enable RLS
-- ============================================================

ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 4️⃣ حذف جميع الـ policies القديمة
-- Drop all old policies
-- ============================================================

DROP POLICY IF EXISTS "Anyone can insert contacts" ON contacts;
DROP POLICY IF EXISTS "Admins can view all contacts" ON contacts;
DROP POLICY IF EXISTS "Admins can update contacts" ON contacts;
DROP POLICY IF EXISTS "Admins can delete contacts" ON contacts;
DROP POLICY IF EXISTS "Service role can do everything on contacts" ON contacts;
DROP POLICY IF EXISTS "Allow public to insert contacts" ON contacts;
DROP POLICY IF EXISTS "Allow anon insert contacts" ON contacts;

-- ============================================================
-- 5️⃣ إنشاء policies جديدة صحيحة
-- Create correct new policies
-- ============================================================

-- ⭐ Policy 1: السماح لأي شخص (زائر أو مستخدم) بإرسال رسالة
-- Allow anyone (visitor or authenticated user) to send contact messages
-- هذا CRITICAL! بدونه لن يستطيع الزوار إرسال رسائل
CREATE POLICY "Anyone can insert contacts"
ON contacts FOR INSERT
TO anon, authenticated
WITH CHECK (true);

COMMENT ON POLICY "Anyone can insert contacts" ON contacts IS
'يسمح للزوار والمستخدمين بإرسال رسائل اتصال';

-- ⭐ Policy 2: السماح للأدمن فقط بقراءة جميع الرسائل
-- Allow only admins to view all contact messages
CREATE POLICY "Admins can view all contacts"
ON contacts FOR SELECT
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

COMMENT ON POLICY "Admins can view all contacts" ON contacts IS
'يسمح للأدمن فقط بقراءة جميع رسائل الاتصال';

-- ⭐ Policy 3: السماح للأدمن بتحديث حالة الرسائل
-- Allow admins to update contact status
CREATE POLICY "Admins can update contacts"
ON contacts FOR UPDATE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

COMMENT ON POLICY "Admins can update contacts" ON contacts IS
'يسمح للأدمن بتحديث حالة الرسائل (new → read → replied)';

-- ⭐ Policy 4: السماح للأدمن بحذف الرسائل
-- Allow admins to delete contacts
CREATE POLICY "Admins can delete contacts"
ON contacts FOR DELETE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

COMMENT ON POLICY "Admins can delete contacts" ON contacts IS
'يسمح للأدمن بحذف الرسائل غير المرغوبة';

-- ============================================================
-- 6️⃣ التحقق من النتائج
-- Verify Results
-- ============================================================

DO $$
DECLARE
  v_contacts_count INTEGER;
  v_policies_count INTEGER;
  v_admin_count INTEGER;
BEGIN
  -- Get counts
  SELECT COUNT(*) INTO v_contacts_count FROM contacts;
  SELECT COUNT(*) INTO v_policies_count
  FROM pg_policies
  WHERE schemaname = 'public' AND tablename = 'contacts';
  SELECT COUNT(*) INTO v_admin_count FROM admin_users;

  -- Display results
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ تم إصلاح نموذج الاتصال بنجاح!';
  RAISE NOTICE '✅ Contact Form Fixed Successfully!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 إحصائيات | Statistics:';
  RAISE NOTICE '------------------------------------------------------------';
  RAISE NOTICE '📧 Contact Messages: %', v_contacts_count;
  RAISE NOTICE '🔐 Security Policies: %', v_policies_count;
  RAISE NOTICE '👤 Admin Users: %', v_admin_count;
  RAISE NOTICE '';
  RAISE NOTICE '✅ الآن يمكن:';
  RAISE NOTICE '   1. للزوار: إرسال رسائل من صفحة /contact';
  RAISE NOTICE '   2. للأدمن: رؤية جميع الرسائل في /admin/contacts';
  RAISE NOTICE '   3. للأدمن: تحديث حالة الرسائل (new → read → replied)';
  RAISE NOTICE '   4. للأدمن: حذف الرسائل';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Now available:';
  RAISE NOTICE '   1. Visitors: Send messages from /contact page';
  RAISE NOTICE '   2. Admins: View all messages in /admin/contacts';
  RAISE NOTICE '   3. Admins: Update message status (new → read → replied)';
  RAISE NOTICE '   4. Admins: Delete messages';
  RAISE NOTICE '';
  RAISE NOTICE '🔍 للتحقق من الـ policies:';
  RAISE NOTICE '   SELECT * FROM pg_policies';
  RAISE NOTICE '   WHERE tablename = ''contacts'';';
  RAISE NOTICE '============================================================';
END $$;

-- ============================================================
-- 7️⃣ عرض جميع الـ policies الحالية
-- Show all current policies
-- ============================================================

SELECT
  policyname AS "Policy Name",
  cmd AS "Command",
  CASE
    WHEN roles = '{anon,authenticated}' THEN 'anon + authenticated'
    WHEN roles = '{authenticated}' THEN 'authenticated only'
    ELSE roles::text
  END AS "Applies To",
  CASE
    WHEN qual IS NOT NULL THEN 'Has USING clause'
    ELSE 'No restrictions'
  END AS "USING",
  CASE
    WHEN with_check IS NOT NULL THEN 'Has WITH CHECK clause'
    ELSE 'No restrictions'
  END AS "WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'contacts'
ORDER BY cmd, policyname;

-- ============================================================
-- ✅ تم! | Done!
-- ============================================================
