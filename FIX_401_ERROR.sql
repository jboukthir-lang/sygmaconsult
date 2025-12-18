-- ============================================================
-- 🔥 إصلاح خطأ 401 Unauthorized
-- Fix 401 Unauthorized Error
-- ============================================================
-- هذا الحل يعطل RLS تماماً للاختبار
-- ============================================================

-- ============================================================
-- الخطوة 1: تعطيل RLS على جميع الجداول
-- ============================================================
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- تعطيل RLS على الجداول الأخرى إذا كانت موجودة
DO $$
BEGIN
  -- notifications
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications') THEN
    ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
  END IF;

  -- bookings
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bookings') THEN
    ALTER TABLE bookings DISABLE ROW LEVEL SECURITY;
  END IF;

  -- contact_messages
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contact_messages') THEN
    ALTER TABLE contact_messages DISABLE ROW LEVEL SECURITY;
  END IF;

  -- contacts
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contacts') THEN
    ALTER TABLE contacts DISABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- ============================================================
-- الخطوة 2: إضافة مستخدمين تجريبيين (فقط إذا لم يكونوا موجودين)
-- ============================================================
DO $$
BEGIN
  -- إضافة admin@sygma-consult.com
  IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'admin@sygma-consult.com') THEN
    INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
    VALUES (gen_random_uuid()::text, 'admin@sygma-consult.com', 'Super Admin', '+33752034786', 'Paris', 'France');
  END IF;

  -- إضافة user1@example.com
  IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user1@example.com') THEN
    INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
    VALUES (gen_random_uuid()::text, 'user1@example.com', 'Pierre Dubois', '+33612345678', 'Lyon', 'France');
  END IF;

  -- إضافة user2@example.com
  IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user2@example.com') THEN
    INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
    VALUES (gen_random_uuid()::text, 'user2@example.com', 'Marie Laurent', '+33623456789', 'Marseille', 'France');
  END IF;

  -- إضافة user3@example.com
  IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user3@example.com') THEN
    INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
    VALUES (gen_random_uuid()::text, 'user3@example.com', 'Jean Martin', '+33634567890', 'Nice', 'France');
  END IF;

  -- إضافة user4@example.com
  IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user4@example.com') THEN
    INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
    VALUES (gen_random_uuid()::text, 'user4@example.com', 'أحمد بن علي', '+21650123456', 'Tunis', 'Tunisia');
  END IF;

  -- إضافة user5@example.com
  IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user5@example.com') THEN
    INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
    VALUES (gen_random_uuid()::text, 'user5@example.com', 'فاطمة الزهراء', '+21651234567', 'Sfax', 'Tunisia');
  END IF;

  -- إضافة user6@example.com
  IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE email = 'user6@example.com') THEN
    INSERT INTO user_profiles (user_id, email, full_name, phone, city, country)
    VALUES (gen_random_uuid()::text, 'user6@example.com', 'محمد الطرابلسي', '+21652345678', 'Sousse', 'Tunisia');
  END IF;
END $$;

-- ============================================================
-- الخطوة 3: التأكد من وجود admin
-- ============================================================
DO $$
DECLARE
  v_user_id TEXT;
BEGIN
  -- الحصول على user_id من user_profiles
  SELECT user_id INTO v_user_id
  FROM user_profiles
  WHERE email = 'admin@sygma-consult.com'
  LIMIT 1;

  -- إذا وجدنا المستخدم، أضفه إلى admin_users (أو حدّث بياناته)
  IF v_user_id IS NOT NULL THEN
    -- محاولة الإضافة
    BEGIN
      INSERT INTO admin_users (user_id, email, role, permissions)
      VALUES (v_user_id, 'admin@sygma-consult.com', 'super_admin', '{"all": true}'::jsonb);
    EXCEPTION WHEN unique_violation THEN
      -- إذا كان موجوداً، قم بالتحديث
      UPDATE admin_users
      SET role = 'super_admin',
          permissions = '{"all": true}'::jsonb
      WHERE email = 'admin@sygma-consult.com' OR user_id = v_user_id;
    END;
  END IF;
END $$;

-- ============================================================
-- الخطوة 4: التحقق
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
  RAISE NOTICE '✅ تم تعطيل RLS تماماً!';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'المستخدمين: %', v_users;
  RAISE NOTICE 'الأدمن: %', v_admins;
  RAISE NOTICE '';
  RAISE NOTICE '🔥 الآن refresh الصفحة!';
  RAISE NOTICE '   http://localhost:3000/admin/users';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️ RLS معطل للاختبار فقط';
  RAISE NOTICE '====================================';
END $$;

-- عرض المستخدمين
SELECT
  email,
  full_name,
  city,
  country
FROM user_profiles
ORDER BY created_at DESC;
