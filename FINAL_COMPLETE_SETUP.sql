-- ============================================================
-- 🎯 التحديث الكامل والنهائي - Sygma Consult System
-- Final Complete Setup - All Features
-- ============================================================
-- 📅 التاريخ: 17 يناير 2025
-- 🎯 الهدف: نظام كامل متكامل بجميع المميزات
--
-- المميزات:
-- ✅ Profile System with Image Upload
-- ✅ Calendar & Time Management
-- ✅ Enhanced Booking System
-- ✅ Notifications System with Real-time
-- ============================================================

-- ============================================================
-- الجزء 1: تحديث جدول user_profiles
-- Part 1: Update user_profiles Table
-- ============================================================

ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS city VARCHAR(200),
ADD COLUMN IF NOT EXISTS address VARCHAR(500),
ADD COLUMN IF NOT EXISTS photo_url VARCHAR(500);

COMMENT ON COLUMN user_profiles.city IS 'City of the user';
COMMENT ON COLUMN user_profiles.address IS 'Full address';
COMMENT ON COLUMN user_profiles.photo_url IS 'Profile picture URL from Supabase Storage';

-- ============================================================
-- الجزء 2: إعداد Supabase Storage
-- Part 2: Supabase Storage Setup
-- ============================================================

-- إنشاء/تحديث bucket للصور
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

-- حذف policies القديمة
DROP POLICY IF EXISTS "Allow public read access" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to update own files" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to delete own files" ON storage.objects;

-- Policies للـ Storage
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

-- ============================================================
-- الجزء 3: جداول التقويم والأوقات
-- Part 3: Calendar & Time Slots Tables
-- ============================================================

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

COMMENT ON TABLE time_slots IS 'Available time slots for booking';
COMMENT ON COLUMN time_slots.day_of_week IS 'Day of week (0=Sunday, 6=Saturday)';
COMMENT ON COLUMN time_slots.slot_duration IS 'Duration of each slot in minutes';

-- جدول التواريخ المحجوبة
CREATE TABLE IF NOT EXISTS blocked_dates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL UNIQUE,
  reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

COMMENT ON TABLE blocked_dates IS 'Dates when bookings are blocked';

-- فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_time_slots_day ON time_slots(day_of_week);
CREATE INDEX IF NOT EXISTS idx_time_slots_available ON time_slots(is_available);
CREATE INDEX IF NOT EXISTS idx_blocked_dates_date ON blocked_dates(date);

-- Triggers للتحديث التلقائي
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

-- RLS للتقويم
ALTER TABLE time_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_dates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to time_slots" ON time_slots;
DROP POLICY IF EXISTS "Allow admin full access to time_slots" ON time_slots;
DROP POLICY IF EXISTS "Allow public read access to blocked_dates" ON blocked_dates;
DROP POLICY IF EXISTS "Allow admin full access to blocked_dates" ON blocked_dates;

CREATE POLICY "Allow public read access to time_slots"
ON time_slots FOR SELECT
USING (true);

CREATE POLICY "Allow admin full access to time_slots"
ON time_slots FOR ALL
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

CREATE POLICY "Allow public read access to blocked_dates"
ON blocked_dates FOR SELECT
USING (true);

CREATE POLICY "Allow admin full access to blocked_dates"
ON blocked_dates FOR ALL
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- ============================================================
-- الجزء 4: نظام الإشعارات
-- Part 4: Notifications System
-- ============================================================

-- جدول الإشعارات
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50) DEFAULT 'info', -- info, success, warning, error
  is_read BOOLEAN DEFAULT false,
  link VARCHAR(500),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  read_at TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE notifications IS 'User notifications system';
COMMENT ON COLUMN notifications.type IS 'Notification type: info, success, warning, error';

-- فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id, is_read) WHERE is_read = false;

-- RLS للإشعارات
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications;
DROP POLICY IF EXISTS "System can create notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can view all notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can create notifications" ON notifications;

CREATE POLICY "Users can view their own notifications"
ON notifications FOR SELECT
USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update their own notifications"
ON notifications FOR UPDATE
USING (auth.uid()::text = user_id::text)
WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "System can create notifications"
ON notifications FOR INSERT
WITH CHECK (true);

CREATE POLICY "Admin can view all notifications"
ON notifications FOR SELECT
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

CREATE POLICY "Admin can create notifications"
ON notifications FOR INSERT
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- دالة لإنشاء إشعار تلقائياً عند حجز
CREATE OR REPLACE FUNCTION create_booking_notification()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NOT NULL THEN
    INSERT INTO notifications (user_id, title, message, type, link)
    VALUES (
      NEW.user_id,
      CASE
        WHEN TG_OP = 'INSERT' THEN 'حجز جديد | New Booking'
        ELSE 'تحديث الحجز | Booking Update'
      END,
      CASE
        WHEN TG_OP = 'INSERT' THEN
          'تم إنشاء حجزك بنجاح. سيتم مراجعته قريباً. | Your booking has been created successfully.'
        WHEN NEW.status = 'confirmed' THEN
          'تم تأكيد حجزك! | Your booking has been confirmed!'
        WHEN NEW.status = 'cancelled' THEN
          'تم إلغاء حجزك. | Your booking has been cancelled.'
        ELSE
          'تم تحديث حالة حجزك. | Your booking status has been updated.'
      END,
      CASE
        WHEN NEW.status = 'confirmed' THEN 'success'
        WHEN NEW.status = 'cancelled' THEN 'error'
        ELSE 'info'
      END,
      '/profile/bookings'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger للإشعارات التلقائية
DROP TRIGGER IF EXISTS booking_notification_trigger ON bookings;
CREATE TRIGGER booking_notification_trigger
AFTER INSERT OR UPDATE OF status ON bookings
FOR EACH ROW
EXECUTE FUNCTION create_booking_notification();

-- دالة لحذف الإشعارات القديمة
CREATE OR REPLACE FUNCTION cleanup_old_notifications()
RETURNS void AS $$
BEGIN
  DELETE FROM notifications
  WHERE created_at < NOW() - INTERVAL '30 days'
  AND is_read = true;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- الجزء 5: بيانات تجريبية (اختياري)
-- Part 5: Sample Data (Optional)
-- ============================================================

-- إضافة أوقات افتراضية للتقويم
INSERT INTO time_slots (day_of_week, start_time, end_time, is_available, slot_duration) VALUES
-- الاثنين
(1, '09:00', '12:00', true, 30),
(1, '14:00', '17:00', true, 30),
-- الثلاثاء
(2, '09:00', '12:00', true, 30),
(2, '14:00', '17:00', true, 30),
-- الأربعاء
(3, '09:00', '12:00', true, 30),
(3, '14:00', '17:00', true, 30),
-- الخميس
(4, '09:00', '12:00', true, 30),
(4, '14:00', '17:00', true, 30),
-- الجمعة
(5, '09:00', '12:00', true, 30)
ON CONFLICT DO NOTHING;

-- ============================================================
-- الجزء 6: التحقق من التثبيت
-- Part 6: Installation Verification
-- ============================================================

DO $$
DECLARE
  v_time_slots_count INTEGER;
  v_blocked_dates_count INTEGER;
  v_notifications_count INTEGER;
  v_user_profiles_count INTEGER;
  v_bookings_count INTEGER;
  v_admin_users_count INTEGER;
BEGIN
  -- Get counts
  SELECT COUNT(*) INTO v_time_slots_count FROM time_slots;
  SELECT COUNT(*) INTO v_blocked_dates_count FROM blocked_dates;
  SELECT COUNT(*) INTO v_notifications_count FROM notifications;
  SELECT COUNT(*) INTO v_user_profiles_count FROM user_profiles;
  SELECT COUNT(*) INTO v_bookings_count FROM bookings;
  SELECT COUNT(*) INTO v_admin_users_count FROM admin_users;

  -- Display results
  RAISE NOTICE '============================================================';
  RAISE NOTICE '🎉 تم تطبيق جميع التحديثات بنجاح!';
  RAISE NOTICE '🎉 Installation Completed Successfully!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 إحصائيات النظام | System Statistics:';
  RAISE NOTICE '------------------------------------------------------------';
  RAISE NOTICE '✅ Time Slots: %', v_time_slots_count;
  RAISE NOTICE '✅ Blocked Dates: %', v_blocked_dates_count;
  RAISE NOTICE '✅ Notifications: %', v_notifications_count;
  RAISE NOTICE '✅ User Profiles: %', v_user_profiles_count;
  RAISE NOTICE '✅ Bookings: %', v_bookings_count;
  RAISE NOTICE '✅ Admin Users: %', v_admin_users_count;
  RAISE NOTICE '';
  RAISE NOTICE '📋 الخطوات التالية | Next Steps:';
  RAISE NOTICE '------------------------------------------------------------';
  RAISE NOTICE '1. ✅ تحقق من Storage bucket "public" في Supabase Dashboard';
  RAISE NOTICE '   Verify "public" storage bucket in Supabase Dashboard';
  RAISE NOTICE '';
  RAISE NOTICE '2. 🖼️  جرّب رفع صورة من /profile';
  RAISE NOTICE '   Test image upload from /profile';
  RAISE NOTICE '';
  RAISE NOTICE '3. 📅 للأدمن: اذهب إلى /admin/calendar';
  RAISE NOTICE '   For Admin: Go to /admin/calendar';
  RAISE NOTICE '';
  RAISE NOTICE '4. 🔔 تحقق من زر الإشعارات في الـ Header';
  RAISE NOTICE '   Check notifications bell in Header';
  RAISE NOTICE '';
  RAISE NOTICE '5. 🌐 تأكد من الترجمات في جميع الصفحات';
  RAISE NOTICE '   Verify translations on all pages';
  RAISE NOTICE '';
  RAISE NOTICE '📚 للمزيد من المعلومات | For More Information:';
  RAISE NOTICE '------------------------------------------------------------';
  RAISE NOTICE '📖 COMPLETE_SYSTEM_GUIDE.md - الدليل الكامل';
  RAISE NOTICE '⚡ START_HERE_AR.md - البداية السريعة';
  RAISE NOTICE '📝 WHAT_WAS_DONE.md - ملخص الإنجازات';
  RAISE NOTICE '============================================================';
END $$;

-- ============================================================
-- ✅ تم! | Done!
-- ============================================================
