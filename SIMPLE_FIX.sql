-- ============================================================
-- 🚀 الحل الأبسط والأسرع
-- SIMPLEST & FASTEST FIX
-- ============================================================
-- نفّذ هذا الملف فقط في Supabase SQL Editor
-- ============================================================

-- 1️⃣ إزالة جميع الـ RLS policies القديمة
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

  RAISE NOTICE '✅ تم حذف جميع الـ policies القديمة';
END $$;

-- 2️⃣ إنشاء policy بسيط: الأدمن يرى الكل
CREATE POLICY "admin_full_access"
ON user_profiles FOR ALL
TO authenticated
USING (
  auth.uid()::text IN (SELECT user_id FROM admin_users)
);

-- 3️⃣ إنشاء policy: المستخدمين يرون ملفاتهم
CREATE POLICY "users_own_access"
ON user_profiles FOR ALL
TO authenticated
USING (user_id = auth.uid()::text)
WITH CHECK (user_id = auth.uid()::text);

-- 4️⃣ التحقق
DO $$
DECLARE
  v_users INTEGER;
  v_admins INTEGER;
  v_policies INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_users FROM user_profiles;
  SELECT COUNT(*) INTO v_admins FROM admin_users;
  SELECT COUNT(*) INTO v_policies FROM pg_policies WHERE tablename = 'user_profiles';

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ تم الإصلاح!';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'المستخدمين: %', v_users;
  RAISE NOTICE 'الأدمن: %', v_admins;
  RAISE NOTICE 'Policies: %', v_policies;
  RAISE NOTICE '';

  IF v_users = 0 THEN
    RAISE NOTICE '❌ لا يوجد مستخدمين! نفّذ: ADD_TEST_USERS.sql';
  ELSIF v_admins = 0 THEN
    RAISE NOTICE '❌ لست أدمن! نفّذ: ADD_YOURSELF_AS_ADMIN.sql';
  ELSE
    RAISE NOTICE '✅ كل شيء جاهز!';
    RAISE NOTICE '   افتح: http://localhost:3000/admin/users';
  END IF;
  RAISE NOTICE '========================================';
END $$;
