-- ============================================================
-- 🛡️ إضافة نفسك كأدمن
-- Add Yourself as Admin
-- ============================================================
-- استخدم هذا الملف إذا لم تكن موجوداً في جدول admin_users
-- ============================================================

-- ============================================================
-- الخطوة 1: التحقق من المستخدم الحالي
-- ============================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🔍 التحقق من المستخدم الحالي:';
  RAISE NOTICE '============================================================';

  IF auth.uid() IS NULL THEN
    RAISE NOTICE '❌ أنت غير مسجل دخول في Supabase SQL Editor!';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️ هذا الملف يحتاج أن تكون مسجل دخول.';
    RAISE NOTICE '   ولكن يمكنك إضافة أي user_id يدوياً أدناه.';
  ELSE
    RAISE NOTICE '✅ أنت مسجل دخول';
    RAISE NOTICE 'auth.uid(): %', auth.uid();
    RAISE NOTICE 'user_id (text): %', auth.uid()::text;
  END IF;

  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
END $$;

-- ============================================================
-- الخطوة 2: عرض جميع المستخدمين الموجودين
-- ============================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '👥 جميع المستخدمين في user_profiles:';
  RAISE NOTICE '============================================================';
END $$;

SELECT
  user_id,
  email,
  full_name,
  created_at,
  CASE
    WHEN EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = user_profiles.user_id)
    THEN '🛡️ ADMIN'
    ELSE '👤 USER'
  END AS role
FROM user_profiles
ORDER BY created_at DESC;

-- ============================================================
-- الخطوة 3: إضافة نفسك كأدمن
-- ============================================================

-- ⚠️ استبدل البيانات التالية بالبيانات الصحيحة:
-- 1. ابحث عن user_id في الجدول أعلاه
-- 2. أو احصل عليه من Firebase Authentication
-- 3. أو استخدم auth.uid() إذا كنت مسجل دخول

-- 🔧 الطريقة 1: إذا كنت مسجل دخول (استخدم auth.uid())
INSERT INTO admin_users (user_id, email, role, permissions)
SELECT
  auth.uid()::text,  -- سيأخذ user_id الحالي تلقائياً
  auth.email(),       -- سيأخذ email الحالي تلقائياً
  'super_admin',
  '{"all": true}'::jsonb
WHERE auth.uid() IS NOT NULL  -- فقط إذا كنت مسجل دخول
ON CONFLICT (user_id) DO NOTHING;

-- 🔧 الطريقة 2: إضافة user_id معين يدوياً
-- أزل التعليق (--) من الأسطر التالية واستبدل البيانات:

/*
INSERT INTO admin_users (user_id, email, role, permissions)
VALUES (
  'ضع_user_id_هنا',           -- user_id من Firebase أو من جدول user_profiles
  'your_email@example.com',    -- إيميلك
  'super_admin',               -- أو 'admin' أو 'moderator'
  '{"all": true}'::jsonb       -- صلاحيات كاملة
)
ON CONFLICT (user_id) DO UPDATE SET
  role = EXCLUDED.role,
  permissions = EXCLUDED.permissions;
*/

-- 🔧 الطريقة 3: إضافة أول مستخدم في user_profiles كأدمن
-- أزل التعليق إذا كنت تريد جعل أول مستخدم أدمن:

/*
INSERT INTO admin_users (user_id, email, role, permissions)
SELECT
  user_id,
  email,
  'super_admin',
  '{"all": true}'::jsonb
FROM user_profiles
ORDER BY created_at ASC
LIMIT 1
ON CONFLICT (user_id) DO NOTHING;
*/

-- ============================================================
-- الخطوة 4: التحقق من النتائج
-- ============================================================

DO $$
DECLARE
  v_admin_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_admin_count FROM admin_users;

  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ تم!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 عدد الأدمن الآن: %', v_admin_count;
  RAISE NOTICE '';

  IF v_admin_count = 0 THEN
    RAISE NOTICE '❌ لم يتم إضافة أي أدمن!';
    RAISE NOTICE '   تحقق من أنك استخدمت إحدى الطرق الثلاثة أعلاه.';
  ELSE
    RAISE NOTICE '✅ يوجد أدمن في النظام!';
    RAISE NOTICE '   يمكنك الآن الوصول إلى /admin/users';
  END IF;
END $$;

-- عرض جميع الأدمن
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🛡️ قائمة الأدمن:';
  RAISE NOTICE '------------------------------------------------------------';
END $$;

SELECT
  user_id,
  email,
  role,
  created_at
FROM admin_users
ORDER BY created_at;

-- ============================================================
-- الخطوات التالية
-- ============================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '📝 الخطوات التالية:';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '1. نفّذ ملف: FIX_RLS_URGENT.sql';
  RAISE NOTICE '2. أعد تشغيل التطبيق: npm run dev';
  RAISE NOTICE '3. افتح: http://localhost:3000/admin/users';
  RAISE NOTICE '4. يجب أن ترى جميع المستخدمين الآن!';
  RAISE NOTICE '============================================================';
END $$;
