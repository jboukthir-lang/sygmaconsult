-- ============================================================
-- 🔧 إصلاح صفحة المستخدمين فقط
-- Fix Users Page Only - Show All Users to Admin
-- ============================================================
-- التاريخ: 18 ديسمبر 2024
-- المشكلة: صفحة /admin/users تعرض الأدمن فقط ولا تعرض المستخدمين
-- الحل: إصلاح RLS policies لجدول user_profiles
-- ============================================================

-- ============================================================
-- 1️⃣ تفعيل Row Level Security على جدول user_profiles
-- ============================================================

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 2️⃣ حذف جميع الـ policies القديمة المتضاربة
-- ============================================================

-- حذف كل الـ policies القديمة لتجنب التضارب
DROP POLICY IF EXISTS "Admins can view all user profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Admins view all, users view own" ON user_profiles;
DROP POLICY IF EXISTS "Allow users to view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Allow users to update own profile" ON user_profiles;

-- ============================================================
-- 3️⃣ إنشاء policies جديدة صحيحة
-- ============================================================

-- ⭐ Policy للقراءة (SELECT):
-- - الأدمن يرى جميع المستخدمين
-- - المستخدم العادي يرى ملفه فقط
CREATE POLICY "Admins view all users, users view own"
ON user_profiles FOR SELECT
TO authenticated
USING (
  -- إذا كان المستخدم أدمن، يرى الكل
  EXISTS (
    SELECT 1
    FROM admin_users
    WHERE user_id::text = auth.uid()::text
  )
  OR
  -- إذا كان مستخدم عادي، يرى ملفه فقط
  user_id = auth.uid()::text
);

COMMENT ON POLICY "Admins view all users, users view own" ON user_profiles IS
'يسمح للأدمن برؤية جميع المستخدمين، والمستخدم العادي يرى ملفه فقط';

-- ⭐ Policy للتحديث (UPDATE):
-- - الأدمن يحدث أي ملف
-- - المستخدم يحدث ملفه فقط
CREATE POLICY "Admins update any, users update own"
ON user_profiles FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM admin_users
    WHERE user_id::text = auth.uid()::text
  )
  OR
  user_id = auth.uid()::text
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM admin_users
    WHERE user_id::text = auth.uid()::text
  )
  OR
  user_id = auth.uid()::text
);

COMMENT ON POLICY "Admins update any, users update own" ON user_profiles IS
'يسمح للأدمن بتحديث أي ملف، والمستخدم يحدث ملفه فقط';

-- ⭐ Policy للإنشاء (INSERT):
-- أي مستخدم مسجل يمكنه إنشاء ملفه
CREATE POLICY "Users can insert own profile"
ON user_profiles FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid()::text);

COMMENT ON POLICY "Users can insert own profile" ON user_profiles IS
'يسمح للمستخدمين بإنشاء ملفاتهم الشخصية';

-- ============================================================
-- 4️⃣ التحقق من النتائج
-- ============================================================

DO $$
DECLARE
  v_total_users INTEGER;
  v_admin_users INTEGER;
  v_regular_users INTEGER;
  v_policies_count INTEGER;
BEGIN
  -- إحصائيات المستخدمين
  SELECT COUNT(*) INTO v_total_users FROM user_profiles;

  SELECT COUNT(*) INTO v_admin_users
  FROM user_profiles up
  WHERE EXISTS (SELECT 1 FROM admin_users au WHERE au.user_id = up.user_id);

  v_regular_users := v_total_users - v_admin_users;

  -- عدد الـ policies
  SELECT COUNT(*) INTO v_policies_count
  FROM pg_policies
  WHERE schemaname = 'public' AND tablename = 'user_profiles';

  -- عرض النتائج
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ تم إصلاح صفحة المستخدمين بنجاح!';
  RAISE NOTICE '✅ Users Page Fixed Successfully!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 إحصائيات المستخدمين | User Statistics:';
  RAISE NOTICE '------------------------------------------------------------';
  RAISE NOTICE '👥 إجمالي المستخدمين | Total Users: %', v_total_users;
  RAISE NOTICE '🛡️  مستخدمين أدمن | Admin Users: %', v_admin_users;
  RAISE NOTICE '👤 مستخدمين عاديين | Regular Users: %', v_regular_users;
  RAISE NOTICE '';
  RAISE NOTICE '🔐 الصلاحيات | Policies:';
  RAISE NOTICE '------------------------------------------------------------';
  RAISE NOTICE 'عدد الـ policies النشطة | Active Policies: %', v_policies_count;
  RAISE NOTICE '';
  RAISE NOTICE '✅ الآن يمكن:';
  RAISE NOTICE '   1. الأدمن: رؤية جميع المستخدمين (% مستخدم)', v_total_users;
  RAISE NOTICE '   2. الأدمن: تحديث أي ملف مستخدم';
  RAISE NOTICE '   3. المستخدم: رؤية وتحديث ملفه الشخصي فقط';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Now available:';
  RAISE NOTICE '   1. Admin: View all users (% users)', v_total_users;
  RAISE NOTICE '   2. Admin: Update any user profile';
  RAISE NOTICE '   3. User: View and update own profile only';
  RAISE NOTICE '';
  RAISE NOTICE '🔍 للتحقق من الـ policies:';
  RAISE NOTICE '   SELECT policyname, cmd, roles FROM pg_policies';
  RAISE NOTICE '   WHERE tablename = ''user_profiles'';';
  RAISE NOTICE '============================================================';
END $$;

-- ============================================================
-- 5️⃣ عرض جميع الـ policies الحالية
-- ============================================================

SELECT
  policyname AS "Policy Name",
  cmd AS "Command",
  CASE
    WHEN roles = '{authenticated}' THEN 'Authenticated Users'
    WHEN roles = '{anon}' THEN 'Anonymous'
    ELSE roles::text
  END AS "Applies To"
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'user_profiles'
ORDER BY cmd, policyname;

-- ============================================================
-- 🧪 اختبار: عرض المستخدمين حسب النوع
-- ============================================================

-- عرض الأدمن
SELECT
  '🛡️ ADMIN' AS type,
  up.full_name,
  up.email,
  au.role
FROM user_profiles up
JOIN admin_users au ON au.user_id = up.user_id
ORDER BY up.created_at DESC;

-- عرض المستخدمين العاديين
SELECT
  '👤 USER' AS type,
  up.full_name,
  up.email,
  up.created_at
FROM user_profiles up
WHERE NOT EXISTS (
  SELECT 1 FROM admin_users au WHERE au.user_id = up.user_id
)
ORDER BY up.created_at DESC;

-- ============================================================
-- ✅ تم! | Done!
-- ============================================================

RAISE NOTICE '';
RAISE NOTICE '🎉 يمكنك الآن الذهاب إلى /admin/users وستجد جميع المستخدمين!';
RAISE NOTICE '🎉 Go to /admin/users and you will see all users now!';
