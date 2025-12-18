-- ============================================================
-- 🔧 إصلاح مشكلة التكرار وإضافة مستخدمين
-- Fix Duplicate Error and Add Users
-- ============================================================
-- هذا الملف يحل مشكلة "duplicate key" ويضيف مستخدمين للاختبار
-- ============================================================

-- ============================================================
-- الخطوة 1: تعطيل RLS مؤقتاً للتشخيص
-- ============================================================
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- الخطوة 2: التحقق من البيانات الحالية
-- ============================================================
DO $$
DECLARE
  v_users INTEGER;
  v_admins INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_users FROM user_profiles;
  SELECT COUNT(*) INTO v_admins FROM admin_users;

  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE '📊 الوضع الحالي:';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'المستخدمين في user_profiles: %', v_users;
  RAISE NOTICE 'الأدمن في admin_users: %', v_admins;
  RAISE NOTICE '';
END $$;

-- ============================================================
-- الخطوة 3: إضافة مستخدمين إلى user_profiles (تجاهل إذا موجودين)
-- ============================================================

-- إضافة Super Admin
INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
SELECT
  gen_random_uuid()::text,
  'admin@sygma-consult.com',
  'Super Admin',
  '+33752034786',
  'Paris',
  'France'
WHERE NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'admin@sygma-consult.com');

-- إضافة مستخدمين تجريبيين فرنسيين
INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
SELECT
  gen_random_uuid()::text,
  'user1@example.com',
  'Pierre Dubois',
  '+33612345678',
  'Lyon',
  'France'
WHERE NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user1@example.com');

INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
SELECT
  gen_random_uuid()::text,
  'user2@example.com',
  'Marie Laurent',
  '+33623456789',
  'Marseille',
  'France'
WHERE NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user2@example.com');

INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
SELECT
  gen_random_uuid()::text,
  'user3@example.com',
  'Jean Martin',
  '+33634567890',
  'Nice',
  'France'
WHERE NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user3@example.com');

-- إضافة مستخدمين تجريبيين تونسيين
INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
SELECT
  gen_random_uuid()::text,
  'user4@example.com',
  'أحمد بن علي',
  '+21650123456',
  'Tunis',
  'Tunisia'
WHERE NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user4@example.com');

INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
SELECT
  gen_random_uuid()::text,
  'user5@example.com',
  'فاطمة الزهراء',
  '+21651234567',
  'Sfax',
  'Tunisia'
WHERE NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user5@example.com');

INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
SELECT
  gen_random_uuid()::text,
  'user6@example.com',
  'محمد الطرابلسي',
  '+21652345678',
  'Sousse',
  'Tunisia'
WHERE NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user6@example.com');

-- ============================================================
-- الخطوة 4: التأكد من أن admin@sygma-consult.com في جدول admin_users
-- ============================================================
-- استخدام ON CONFLICT لتحديث البيانات إذا كانت موجودة
INSERT INTO admin_users (user_id, email, role, permissions)
SELECT
  user_id,
  email,
  'super_admin',
  '{"all": true}'::jsonb
FROM user_profiles
WHERE email = 'admin@sygma-consult.com'
ON CONFLICT (email) DO UPDATE SET
  role = 'super_admin',
  permissions = '{"all": true}'::jsonb,
  updated_at = NOW();

-- ============================================================
-- الخطوة 5: حذف جميع الـ policies القديمة
-- ============================================================
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

  RAISE NOTICE '✅ تم حذف الـ policies القديمة';
END $$;

-- ============================================================
-- الخطوة 6: إنشاء policy بسيط جداً: كل مستخدم مُسجل دخول يرى كل شيء
-- ============================================================
CREATE POLICY "authenticated_full_access"
ON user_profiles FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================================
-- الخطوة 7: إعادة تفعيل RLS
-- ============================================================
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- الخطوة 8: التحقق النهائي
-- ============================================================
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
  RAISE NOTICE '====================================';
  RAISE NOTICE '✅ تم الإصلاح!';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'المستخدمين في user_profiles: %', v_users;
  RAISE NOTICE 'الأدمن في admin_users: %', v_admins;
  RAISE NOTICE 'RLS Policies: %', v_policies;
  RAISE NOTICE '';

  IF v_users > 0 THEN
    RAISE NOTICE '✅✅✅ نجح! يوجد % مستخدمين في قاعدة البيانات', v_users;
    RAISE NOTICE '';
    RAISE NOTICE '📝 الخطوات التالية:';
    RAISE NOTICE '1. افتح: http://localhost:3000/admin/users';
    RAISE NOTICE '2. افتح Console (F12)';
    RAISE NOTICE '3. ابحث عن الرسائل:';
    RAISE NOTICE '   - 📊 User profiles data: [...]';
    RAISE NOTICE '   - ✅ Found X users';
    RAISE NOTICE '';
  ELSE
    RAISE NOTICE '❌ لا يزال لا يوجد مستخدمين!';
  END IF;
  RAISE NOTICE '====================================';
END $$;

-- ============================================================
-- الخطوة 9: عرض النتائج
-- ============================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '📋 المستخدمين الموجودين الآن:';
  RAISE NOTICE '====================================';
END $$;

SELECT
  email,
  full_name,
  city,
  country,
  CASE
    WHEN EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = user_profiles.user_id)
    THEN '🛡️ ADMIN'
    ELSE '👤 USER'
  END as type
FROM user_profiles
ORDER BY created_at DESC;

-- ============================================================
-- رسالة نهائية
-- ============================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🎉 انتهى! الآن:';
  RAISE NOTICE '1. اذهب إلى المتصفح';
  RAISE NOTICE '2. افتح: http://localhost:3000/admin/users';
  RAISE NOTICE '3. اضغط F12 لفتح Console';
  RAISE NOTICE '4. يجب أن ترى: ✅ Found X users';
  RAISE NOTICE '5. يجب أن ترى قائمة المستخدمين في الصفحة';
  RAISE NOTICE '';
END $$;
