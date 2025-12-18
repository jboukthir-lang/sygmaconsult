-- ============================================================
-- 👥 إضافة مستخدمين تجريبيين
-- Add Test Users
-- ============================================================
-- استخدم هذا الملف إذا كان جدول user_profiles فارغاً
-- ============================================================

-- التحقق من عدد المستخدمين الحاليين
DO $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM user_profiles;

  RAISE NOTICE '';
  RAISE NOTICE '🔍 عدد المستخدمين الحاليين: %', v_count;
  RAISE NOTICE '';

  IF v_count > 0 THEN
    RAISE NOTICE 'يوجد % مستخدمين في النظام.', v_count;
    RAISE NOTICE 'سنضيف مستخدمين تجريبيين إضافيين.';
  ELSE
    RAISE NOTICE 'الجدول فارغ. سنضيف مستخدمين تجريبيين.';
  END IF;
END $$;

-- ============================================================
-- إضافة 10 مستخدمين تجريبيين
-- ============================================================

INSERT INTO user_profiles (
  user_id,
  email,
  full_name,
  phone,
  company,
  country,
  city,
  address,
  created_at
)
VALUES
  -- مستخدم 1: فرنسي من باريس
  (
    gen_random_uuid()::text,
    'jean.dupont@example.com',
    'Jean Dupont',
    '+33612345678',
    'Tech Solutions SAS',
    'France',
    'Paris',
    '15 Avenue des Champs-Élysées, 75008 Paris',
    NOW() - INTERVAL '30 days'
  ),
  -- مستخدم 2: فرنسية من ليون
  (
    gen_random_uuid()::text,
    'marie.martin@example.com',
    'Marie Martin',
    '+33698765432',
    'Innovation Labs',
    'France',
    'Lyon',
    '25 Rue de la République, 69002 Lyon',
    NOW() - INTERVAL '25 days'
  ),
  -- مستخدم 3: تونسي من تونس
  (
    gen_random_uuid()::text,
    'ahmed.ben.ali@example.com',
    'Ahmed Ben Ali',
    '+21650123456',
    'Digital Tunisia',
    'Tunisia',
    'Tunis',
    'Les Berges du Lac II, 1053 Tunis',
    NOW() - INTERVAL '20 days'
  ),
  -- مستخدم 4: تونسية من صفاقس
  (
    gen_random_uuid()::text,
    'fatma.trabelsi@example.com',
    'Fatma Trabelsi',
    '+21698765432',
    'Sfax Business Hub',
    'Tunisia',
    'Sfax',
    'Avenue Habib Bourguiba, 3000 Sfax',
    NOW() - INTERVAL '18 days'
  ),
  -- مستخدم 5: فرنسي من مرسيليا
  (
    gen_random_uuid()::text,
    'pierre.dubois@example.com',
    'Pierre Dubois',
    '+33687654321',
    'Marseille Consulting',
    'France',
    'Marseille',
    '10 La Canebière, 13001 Marseille',
    NOW() - INTERVAL '15 days'
  ),
  -- مستخدم 6: تونسي من سوسة
  (
    gen_random_uuid()::text,
    'mohamed.sassi@example.com',
    'Mohamed Sassi',
    '+21652987654',
    'Sousse Tech',
    'Tunisia',
    'Sousse',
    'Avenue Léopold Sédar Senghor, 4000 Sousse',
    NOW() - INTERVAL '12 days'
  ),
  -- مستخدم 7: فرنسية من نيس
  (
    gen_random_uuid()::text,
    'sophie.bernard@example.com',
    'Sophie Bernard',
    '+33645678912',
    'Côte d''Azur Solutions',
    'France',
    'Nice',
    '5 Promenade des Anglais, 06000 Nice',
    NOW() - INTERVAL '10 days'
  ),
  -- مستخدم 8: تونسية من المنستير
  (
    gen_random_uuid()::text,
    'leila.gharbi@example.com',
    'Leila Gharbi',
    '+21699876543',
    'Monastir Innovations',
    'Tunisia',
    'Monastir',
    'Route de la Corniche, 5000 Monastir',
    NOW() - INTERVAL '7 days'
  ),
  -- مستخدم 9: فرنسي من تولوز
  (
    gen_random_uuid()::text,
    'luc.petit@example.com',
    'Luc Petit',
    '+33656789123',
    'Aerospace Toulouse',
    'France',
    'Toulouse',
    '12 Allées Jean Jaurès, 31000 Toulouse',
    NOW() - INTERVAL '5 days'
  ),
  -- مستخدم 10: تونسي من نابل
  (
    gen_random_uuid()::text,
    'karim.ben.salem@example.com',
    'Karim Ben Salem',
    '+21651234567',
    'Nabeul Digital',
    'Tunisia',
    'Nabeul',
    'Avenue Farhat Hached, 8000 Nabeul',
    NOW() - INTERVAL '2 days'
  )
ON CONFLICT (user_id) DO NOTHING;

-- ============================================================
-- التحقق من النتائج
-- ============================================================

DO $$
DECLARE
  v_total INTEGER;
  v_french INTEGER;
  v_tunisian INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total FROM user_profiles;
  SELECT COUNT(*) INTO v_french FROM user_profiles WHERE country = 'France';
  SELECT COUNT(*) INTO v_tunisian FROM user_profiles WHERE country = 'Tunisia';

  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ تم إضافة المستخدمين التجريبيين!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 الإحصائيات:';
  RAISE NOTICE '------------------------------------------------------------';
  RAISE NOTICE 'إجمالي المستخدمين: %', v_total;
  RAISE NOTICE 'مستخدمين فرنسيين: %', v_french;
  RAISE NOTICE 'مستخدمين تونسيين: %', v_tunisian;
  RAISE NOTICE '';
END $$;

-- عرض جميع المستخدمين
RAISE NOTICE '👥 قائمة المستخدمين:';
RAISE NOTICE '============================================================';

SELECT
  full_name AS "Name",
  email AS "Email",
  city AS "City",
  country AS "Country",
  company AS "Company",
  TO_CHAR(created_at, 'YYYY-MM-DD') AS "Created"
FROM user_profiles
ORDER BY created_at DESC;

-- ============================================================
-- إضافة حجوزات تجريبية (اختياري)
-- ============================================================

-- أزل التعليق لإضافة حجوزات تجريبية:
/*
INSERT INTO bookings (
  user_id,
  name,
  email,
  phone,
  date,
  time,
  service_type,
  status,
  created_at
)
SELECT
  user_id,
  full_name,
  email,
  phone,
  CURRENT_DATE + (random() * 30)::int,
  (ARRAY['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'])[floor(random() * 6 + 1)],
  (ARRAY['consultation', 'audit', 'training'])[floor(random() * 3 + 1)],
  (ARRAY['pending', 'confirmed', 'completed'])[floor(random() * 3 + 1)],
  created_at
FROM user_profiles
LIMIT 5;
*/

-- ============================================================
-- إضافة إشعارات تجريبية (اختياري)
-- ============================================================

-- أزل التعليق لإضافة إشعارات تجريبية:
/*
INSERT INTO notifications (
  user_id,
  title,
  message,
  type,
  is_read,
  created_at
)
SELECT
  user_id,
  'Welcome to Sygma Consult!',
  'Thank you for joining our platform. We are here to help you grow your business.',
  'info',
  random() > 0.5,  -- 50% مقروءة، 50% غير مقروءة
  created_at + INTERVAL '1 hour'
FROM user_profiles;
*/

-- ============================================================
-- الخطوات التالية
-- ============================================================

RAISE NOTICE '';
RAISE NOTICE '📝 الخطوات التالية:';
RAISE NOTICE '============================================================';
RAISE NOTICE '1. تأكد من أنك مضاف كأدمن (نفّذ ADD_YOURSELF_AS_ADMIN.sql)';
RAISE NOTICE '2. نفّذ ملف FIX_RLS_URGENT.sql لإصلاح الصلاحيات';
RAISE NOTICE '3. أعد تشغيل التطبيق: npm run dev';
RAISE NOTICE '4. افتح: http://localhost:3000/admin/users';
RAISE NOTICE '5. يجب أن ترى جميع المستخدمين الـ% الآن!', (SELECT COUNT(*) FROM user_profiles);
RAISE NOTICE '============================================================';
