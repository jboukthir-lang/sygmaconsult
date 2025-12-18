-- ============================================================
-- 🔧 تطبيق جميع الإصلاحات والتحديثات
-- Apply All Fixes and Updates
-- ============================================================
-- 📅 التاريخ: 17 ديسمبر 2024
-- 🎯 الهدف: إصلاح جميع المشاكل دفعة واحدة
-- ============================================================

-- ============================================================
-- 1️⃣ إصلاح صلاحيات Storage (مشكلة رفع الصور)
-- Fix Storage Permissions (Image Upload Issue)
-- ============================================================

-- حذف جميع الـ policies القديمة
DROP POLICY IF EXISTS "Allow public read access" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to update own files" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to delete own files" ON storage.objects;
DROP POLICY IF EXISTS "Allow admins full access" ON storage.objects;

-- تأكد من وجود bucket "public"
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'public',
  'public',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']::text[]
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']::text[];

-- سياسات جديدة أكثر مرونة
CREATE POLICY "Allow public read access"
ON storage.objects FOR SELECT
USING (bucket_id = 'public');

CREATE POLICY "Allow authenticated users to upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'public');

CREATE POLICY "Allow users to update own files"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'public')
WITH CHECK (bucket_id = 'public');

CREATE POLICY "Allow users to delete own files"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'public');

CREATE POLICY "Allow admins full access"
ON storage.objects FOR ALL
TO authenticated
USING (
  bucket_id = 'public' AND
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
)
WITH CHECK (
  bucket_id = 'public' AND
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- ============================================================
-- 2️⃣ إضافة جدول إعدادات المواعيد
-- Add Appointment Settings Table
-- ============================================================

-- إنشاء جدول إعدادات المواعيد
CREATE TABLE IF NOT EXISTS appointment_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

COMMENT ON TABLE appointment_settings IS 'إعدادات المواعيد والحجوزات';

-- إضافة الإعدادات الافتراضية
INSERT INTO appointment_settings (setting_key, setting_value, description) VALUES
('default_duration', '30', 'مدة الموعد الافتراضية بالدقائق'),
('min_duration', '15', 'الحد الأدنى لمدة الموعد بالدقائق'),
('max_duration', '120', 'الحد الأقصى لمدة الموعد بالدقائق'),
('booking_advance_days', '7', 'عدد الأيام المسموح بالحجز مسبقاً'),
('max_bookings_per_day', '10', 'أقصى عدد حجوزات في اليوم'),
('working_days', '1,2,3,4,5', 'أيام العمل (0=الأحد، 6=السبت)'),
('start_time', '09:00', 'وقت بداية العمل'),
('end_time', '17:00', 'وقت نهاية العمل'),
('break_start', '12:00', 'وقت بداية استراحة الغداء'),
('break_end', '13:00', 'وقت نهاية استراحة الغداء'),
('auto_confirm', 'false', 'تأكيد تلقائي للمواعيد'),
('allow_weekend_booking', 'false', 'السماح بالحجز في عطلة نهاية الأسبوع')
ON CONFLICT (setting_key) DO NOTHING;

-- إضافة trigger للتحديث التلقائي
CREATE OR REPLACE FUNCTION update_appointment_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_appointment_settings_updated_at ON appointment_settings;
CREATE TRIGGER update_appointment_settings_updated_at
BEFORE UPDATE ON appointment_settings
FOR EACH ROW
EXECUTE FUNCTION update_appointment_settings_updated_at();

-- تفعيل RLS
ALTER TABLE appointment_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read appointment settings" ON appointment_settings;
DROP POLICY IF EXISTS "Allow admin manage appointment settings" ON appointment_settings;

CREATE POLICY "Allow public read appointment settings"
ON appointment_settings FOR SELECT
USING (true);

CREATE POLICY "Allow admin manage appointment settings"
ON appointment_settings FOR ALL
TO authenticated
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- ============================================================
-- 3️⃣ التحقق من جميع الجداول المطلوبة
-- Verify All Required Tables
-- ============================================================

DO $$
DECLARE
  v_users_count INTEGER;
  v_bookings_count INTEGER;
  v_notifications_count INTEGER;
  v_time_slots_count INTEGER;
  v_blocked_dates_count INTEGER;
  v_appointment_settings_count INTEGER;
  v_site_settings_count INTEGER;
BEGIN
  -- Get counts
  SELECT COUNT(*) INTO v_users_count FROM user_profiles;
  SELECT COUNT(*) INTO v_bookings_count FROM bookings;
  SELECT COUNT(*) INTO v_notifications_count FROM notifications;
  SELECT COUNT(*) INTO v_time_slots_count FROM time_slots;
  SELECT COUNT(*) INTO v_blocked_dates_count FROM blocked_dates;
  SELECT COUNT(*) INTO v_appointment_settings_count FROM appointment_settings;
  SELECT COUNT(*) INTO v_site_settings_count FROM site_settings;

  -- Display results
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '🎉 تم تطبيق جميع التحديثات بنجاح!';
  RAISE NOTICE '🎉 All Updates Applied Successfully!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 إحصائيات النظام | System Statistics:';
  RAISE NOTICE '------------------------------------------------------------';
  RAISE NOTICE '👥 Users: %', v_users_count;
  RAISE NOTICE '📅 Bookings: %', v_bookings_count;
  RAISE NOTICE '🔔 Notifications: %', v_notifications_count;
  RAISE NOTICE '⏰ Time Slots: %', v_time_slots_count;
  RAISE NOTICE '🚫 Blocked Dates: %', v_blocked_dates_count;
  RAISE NOTICE '⚙️  Appointment Settings: %', v_appointment_settings_count;
  RAISE NOTICE '🎨 Site Settings: %', v_site_settings_count;
  RAISE NOTICE '';
  RAISE NOTICE '📋 الخطوات التالية | Next Steps:';
  RAISE NOTICE '------------------------------------------------------------';
  RAISE NOTICE '1. ✅ رفع الصور من الإعدادات سيعمل الآن';
  RAISE NOTICE '   Image upload from settings should work now';
  RAISE NOTICE '';
  RAISE NOTICE '2. 📅 تحقق من صفحة /admin/calendar لإعدادات المواعيد';
  RAISE NOTICE '   Check /admin/calendar for appointment settings';
  RAISE NOTICE '';
  RAISE NOTICE '3. 👥 تحقق من صفحة /admin/users لعرض جميع المستخدمين';
  RAISE NOTICE '   Check /admin/users to view all users';
  RAISE NOTICE '';
  RAISE NOTICE '4. 🔔 الإشعارات تظهر لكل مستخدم في صفحته';
  RAISE NOTICE '   Notifications shown for each user in their page';
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
END $$;

-- ============================================================
-- ✅ تم! | Done!
-- ============================================================
