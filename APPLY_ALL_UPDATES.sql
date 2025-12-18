-- ========================================
-- تطبيق جميع التحديثات دفعة واحدة
-- Apply All Updates at Once
-- ========================================
-- 📅 التاريخ: 17 يناير 2025
-- 🎯 الهدف: تحديث شامل لنظام Sygma Consult

-- ========================================
-- الجزء 1: تحديث جدول user_profiles
-- Part 1: Update user_profiles table
-- ========================================

-- إضافة حقول جديدة
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS city VARCHAR(200),
ADD COLUMN IF NOT EXISTS address VARCHAR(500),
ADD COLUMN IF NOT EXISTS photo_url VARCHAR(500);

-- ========================================
-- الجزء 2: إنشاء/تحديث Storage Bucket
-- Part 2: Create/Update Storage Bucket
-- ========================================

-- إنشاء bucket للصور
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'public',
  'public',
  true,
  2097152, -- 2MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']::text[]
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 2097152,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']::text[];

-- حذف الـ policies القديمة للـ Storage
DROP POLICY IF EXISTS "Allow public read access" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to update own files" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to delete own files" ON storage.objects;

-- إنشاء policies جديدة للـ Storage
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
USING (bucket_id = 'public' AND owner = auth.uid())
WITH CHECK (bucket_id = 'public' AND owner = auth.uid());

CREATE POLICY "Allow users to delete own files"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'public' AND owner = auth.uid());

-- ========================================
-- الجزء 3: إنشاء جداول التقويم
-- Part 3: Create Calendar Tables
-- ========================================

-- جدول الأوقات المتاحة
CREATE TABLE IF NOT EXISTS time_slots (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_available BOOLEAN DEFAULT true,
  slot_duration INTEGER DEFAULT 30,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  CONSTRAINT valid_time_range CHECK (end_time > start_time)
);

-- جدول التواريخ المحجوبة
CREATE TABLE IF NOT EXISTS blocked_dates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL UNIQUE,
  reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- إضافة فهارس
CREATE INDEX IF NOT EXISTS idx_time_slots_day ON time_slots(day_of_week);
CREATE INDEX IF NOT EXISTS idx_time_slots_available ON time_slots(is_available);
CREATE INDEX IF NOT EXISTS idx_blocked_dates_date ON blocked_dates(date);

-- Triggers لتحديث updated_at
DROP TRIGGER IF EXISTS update_time_slots_updated_at ON time_slots;
CREATE TRIGGER update_time_slots_updated_at
BEFORE UPDATE ON time_slots
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_blocked_dates_updated_at ON blocked_dates;
CREATE TRIGGER update_blocked_dates_updated_at
BEFORE UPDATE ON blocked_dates
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- الجزء 4: RLS Policies للتقويم
-- Part 4: RLS Policies for Calendar
-- ========================================

-- تفعيل RLS
ALTER TABLE time_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_dates ENABLE ROW LEVEL SECURITY;

-- حذف الـ policies القديمة
DROP POLICY IF EXISTS "Allow public read access to time_slots" ON time_slots;
DROP POLICY IF EXISTS "Allow admin full access to time_slots" ON time_slots;
DROP POLICY IF EXISTS "Allow public read access to blocked_dates" ON blocked_dates;
DROP POLICY IF EXISTS "Allow admin full access to blocked_dates" ON blocked_dates;

-- السماح للجميع بقراءة الأوقات المتاحة
CREATE POLICY "Allow public read access to time_slots"
ON time_slots FOR SELECT
USING (true);

-- السماح للأدمن بالتحكم الكامل في الأوقات
CREATE POLICY "Allow admin full access to time_slots"
ON time_slots FOR ALL
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- السماح للجميع بقراءة التواريخ المحجوبة
CREATE POLICY "Allow public read access to blocked_dates"
ON blocked_dates FOR SELECT
USING (true);

-- السماح للأدمن بالتحكم الكامل في التواريخ المحجوبة
CREATE POLICY "Allow admin full access to blocked_dates"
ON blocked_dates FOR ALL
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- ========================================
-- الجزء 5: بيانات تجريبية (اختياري)
-- Part 5: Sample Data (Optional)
-- ========================================

-- إضافة أوقات افتراضية
INSERT INTO time_slots (day_of_week, start_time, end_time, is_available, slot_duration) VALUES
-- الاثنين (Monday)
(1, '09:00', '12:00', true, 30),
(1, '14:00', '17:00', true, 30),
-- الثلاثاء (Tuesday)
(2, '09:00', '12:00', true, 30),
(2, '14:00', '17:00', true, 30),
-- الأربعاء (Wednesday)
(3, '09:00', '12:00', true, 30),
(3, '14:00', '17:00', true, 30),
-- الخميس (Thursday)
(4, '09:00', '12:00', true, 30),
(4, '14:00', '17:00', true, 30),
-- الجمعة (Friday)
(5, '09:00', '12:00', true, 30)
ON CONFLICT DO NOTHING;

-- ========================================
-- الجزء 6: التحقق من التثبيت
-- Part 6: Installation Verification
-- ========================================

-- عرض إحصائيات النظام
DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'تم تطبيق جميع التحديثات بنجاح!';
  RAISE NOTICE 'Installation Completed Successfully!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE 'إحصائيات النظام | System Statistics:';
  RAISE NOTICE '- Time Slots: %', (SELECT COUNT(*) FROM time_slots);
  RAISE NOTICE '- Blocked Dates: %', (SELECT COUNT(*) FROM blocked_dates);
  RAISE NOTICE '- User Profiles: %', (SELECT COUNT(*) FROM user_profiles);
  RAISE NOTICE '- Bookings: %', (SELECT COUNT(*) FROM bookings);
  RAISE NOTICE '- Admin Users: %', (SELECT COUNT(*) FROM admin_users);
  RAISE NOTICE '';
  RAISE NOTICE 'تحقق من:';
  RAISE NOTICE 'Check:';
  RAISE NOTICE '1. Storage bucket "public" exists';
  RAISE NOTICE '2. Can upload images to /profile';
  RAISE NOTICE '3. Admin can access /admin/calendar';
  RAISE NOTICE '4. All translations working';
  RAISE NOTICE '';
  RAISE NOTICE 'للمزيد من المعلومات، راجع COMPLETE_SYSTEM_GUIDE.md';
  RAISE NOTICE 'For more info, see COMPLETE_SYSTEM_GUIDE.md';
  RAISE NOTICE '========================================';
END $$;

-- ========================================
-- ✅ تم! | Done!
-- ========================================
--
-- التالي:
-- Next Steps:
-- 1. تحقق من أن Storage bucket "public" تم إنشاؤه
--    Verify "public" storage bucket was created
--
-- 2. جرّب رفع صورة من /profile
--    Test image upload from /profile
--
-- 3. للأدمن: اذهب إلى /admin/calendar
--    For Admin: Go to /admin/calendar
--
-- 4. تحقق من الترجمات في جميع الصفحات
--    Check translations on all pages
--
-- ========================================
