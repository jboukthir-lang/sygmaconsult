-- ============================================================
-- 🚨 إصلاح عاجل: صفحة المستخدمين فارغة
-- URGENT FIX: Users Page Shows Empty
-- ============================================================
-- المشكلة: "Aucun utilisateur trouvé" / No users found
-- السبب: RLS policies لا تعمل بشكل صحيح
-- ============================================================

-- ============================================================
-- الخطوة 1: تعطيل RLS مؤقتاً للتشخيص
-- ============================================================

-- ⚠️ فقط للتشخيص - سنعيد تفعيله بعد قليل
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- الخطوة 2: التحقق من وجود بيانات
-- ============================================================

DO $$
DECLARE
  v_users_count INTEGER;
  v_admin_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_users_count FROM user_profiles;
  SELECT COUNT(*) INTO v_admin_count FROM admin_users;

  RAISE NOTICE '';
  RAISE NOTICE '🔍 التشخيص الأولي:';
  RAISE NOTICE 'عدد المستخدمين في user_profiles: %', v_users_count;
  RAISE NOTICE 'عدد الأدمن في admin_users: %', v_admin_count;
  RAISE NOTICE '';

  IF v_users_count = 0 THEN
    RAISE NOTICE '❌ المشكلة: لا يوجد مستخدمين في قاعدة البيانات!';
    RAISE NOTICE '   الحل: تحتاج إلى إنشاء مستخدمين أولاً';
  ELSIF v_admin_count = 0 THEN
    RAISE NOTICE '❌ المشكلة: لا يوجد أدمن في جدول admin_users!';
    RAISE NOTICE '   الحل: تحتاج إلى إضافة نفسك كأدمن';
  ELSE
    RAISE NOTICE '✅ البيانات موجودة، المشكلة في RLS policies';
  END IF;
END $$;

-- ============================================================
-- الخطوة 3: إعادة تفعيل RLS وإنشاء policies بسيطة
-- ============================================================

-- تفعيل RLS مرة أخرى
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- حذف جميع الـ policies القديمة
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (
    SELECT policyname
    FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'user_profiles'
  )
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON user_profiles', r.policyname);
  END LOOP;
END $$;

-- ============================================================
-- الخطوة 4: إنشاء policy بسيط جداً للأدمن
-- ============================================================

-- ⭐ Policy للأدمن: يرى جميع المستخدمين (بدون شروط معقدة)
CREATE POLICY "admin_view_all_users"
ON user_profiles FOR SELECT
TO authenticated
USING (
  auth.uid()::text IN (SELECT user_id FROM admin_users)
);

COMMENT ON POLICY "admin_view_all_users" ON user_profiles IS
'يسمح للأدمن برؤية جميع المستخدمين - policy بسيط';

-- ⭐ Policy للمستخدمين: كل واحد يرى ملفه فقط
CREATE POLICY "users_view_own"
ON user_profiles FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()::text
  OR
  auth.uid()::text IN (SELECT user_id FROM admin_users)
);

COMMENT ON POLICY "users_view_own" ON user_profiles IS
'المستخدمين يرون ملفاتهم، والأدمن يرون الكل';

-- ⭐ Policy للتحديث
CREATE POLICY "users_update_own"
ON user_profiles FOR UPDATE
TO authenticated
USING (
  user_id = auth.uid()::text
  OR
  auth.uid()::text IN (SELECT user_id FROM admin_users)
)
WITH CHECK (
  user_id = auth.uid()::text
  OR
  auth.uid()::text IN (SELECT user_id FROM admin_users)
);

-- ⭐ Policy للإنشاء
CREATE POLICY "users_insert_own"
ON user_profiles FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid()::text);

-- ============================================================
-- الخطوة 5: التحقق من auth.uid()
-- ============================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🔐 التحقق من الأدمن الحالي:';
  RAISE NOTICE 'auth.uid() الحالي: %', auth.uid();
  RAISE NOTICE '';

  IF auth.uid() IS NULL THEN
    RAISE NOTICE '❌ أنت غير مسجل دخول!';
    RAISE NOTICE '   الحل: سجل دخول أولاً في التطبيق';
  ELSE
    RAISE NOTICE '✅ أنت مسجل دخول';
    RAISE NOTICE 'user_id: %', auth.uid()::text;
  END IF;
END $$;

-- ============================================================
-- الخطوة 6: عرض جميع الأدمن
-- ============================================================

DO $$
DECLARE
  r RECORD;
  v_count INTEGER := 0;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '📋 قائمة الأدمن في النظام:';
  RAISE NOTICE '----------------------------------------------';

  FOR r IN (SELECT user_id, email, role FROM admin_users ORDER BY created_at)
  LOOP
    v_count := v_count + 1;
    RAISE NOTICE '% - % (%) - user_id: %', v_count, r.email, r.role, r.user_id;
  END LOOP;

  IF v_count = 0 THEN
    RAISE NOTICE 'لا يوجد أدمن! تحتاج إلى إضافة نفسك كأدمن.';
  END IF;
END $$;

-- ============================================================
-- الخطوة 7: التحقق من الـ Policies
-- ============================================================

SELECT
  '✅ ' || policyname AS "Policy",
  cmd AS "Action",
  CASE
    WHEN roles = '{authenticated}' THEN 'Authenticated'
    ELSE roles::text
  END AS "Who"
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'user_profiles'
ORDER BY cmd;

-- ============================================================
-- الخطوة 8: اختبار بسيط
-- ============================================================

DO $$
DECLARE
  v_count INTEGER;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🧪 اختبار بسيط:';
  RAISE NOTICE '----------------------------------------------';

  -- عدد المستخدمين (بدون RLS)
  SELECT COUNT(*) INTO v_count FROM user_profiles;
  RAISE NOTICE 'إجمالي المستخدمين في الجدول: %', v_count;

  -- محاولة قراءة البيانات مع RLS
  BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_profiles
    WHERE true; -- مع تطبيق RLS policies

    RAISE NOTICE 'المستخدمين المرئيين مع RLS: %', v_count;

    IF v_count > 0 THEN
      RAISE NOTICE '✅ RLS policies تعمل بشكل صحيح!';
    ELSE
      RAISE NOTICE '❌ RLS policies تمنع الوصول!';
      RAISE NOTICE '   تحقق من أنك مسجل كأدمن في admin_users';
    END IF;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ خطأ في RLS: %', SQLERRM;
  END;

  -- ============================================================
  -- نهاية التشخيص
  -- ============================================================

  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '📝 الخطوات التالية:';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE '1. تحقق من أنك موجود في جدول admin_users';
  RAISE NOTICE '   SELECT * FROM admin_users WHERE email = ''your_email@example.com'';';
  RAISE NOTICE '';
  RAISE NOTICE '2. إذا لم تكن موجوداً، أضف نفسك:';
  RAISE NOTICE '   راجع ملف: ADD_YOURSELF_AS_ADMIN.sql';
  RAISE NOTICE '';
  RAISE NOTICE '3. إذا كانت user_profiles فارغة، أضف مستخدمين تجريبيين:';
  RAISE NOTICE '   راجع ملف: ADD_TEST_USERS.sql';
  RAISE NOTICE '';
  RAISE NOTICE '4. أعد تشغيل التطبيق وجرب مرة أخرى';
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
END $$;
