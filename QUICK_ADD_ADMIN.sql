-- ============================================================
-- ⚡ إضافة أدمن بسرعة - Quick Add Admin
-- ============================================================
-- نفّذ هذا الملف في Supabase SQL Editor
-- ============================================================

-- الخطوة 1: عرض جميع المستخدمين
SELECT
  user_id,
  email,
  full_name,
  'استخدم user_id هذا في الخطوة 2' as note
FROM user_profiles
ORDER BY created_at;

-- الخطوة 2: انسخ user_id من الأعلى واستبدله هنا:
-- (أزل التعليق /* */ وضع user_id الصحيح)

/*
INSERT INTO admin_users (user_id, email, role, permissions)
VALUES (
  'PASTE_YOUR_USER_ID_HERE',  -- ضع user_id من الخطوة 1
  'your_email@example.com',    -- ضع إيميلك
  'super_admin',
  '{"all": true}'::jsonb
)
ON CONFLICT (user_id) DO UPDATE SET
  role = 'super_admin',
  permissions = '{"all": true}'::jsonb;
*/

-- الخطوة 3: بعد التنفيذ، تحقق:
SELECT
  user_id,
  email,
  role,
  'تم! أنت الآن أدمن' as status
FROM admin_users;
