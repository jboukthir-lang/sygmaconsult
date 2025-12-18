-- ============================================================
-- إضافة جدول إعدادات المواعيد
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
COMMENT ON COLUMN appointment_settings.setting_key IS 'مفتاح الإعداد';
COMMENT ON COLUMN appointment_settings.setting_value IS 'قيمة الإعداد';

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

-- حذف الـ policies القديمة
DROP POLICY IF EXISTS "Allow public read appointment settings" ON appointment_settings;
DROP POLICY IF EXISTS "Allow admin manage appointment settings" ON appointment_settings;

-- السماح للجميع بقراءة الإعدادات
CREATE POLICY "Allow public read appointment settings"
ON appointment_settings FOR SELECT
USING (true);

-- السماح للأدمن بإدارة الإعدادات
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
-- ✅ تم إنشاء جدول إعدادات المواعيد!
-- ✅ Appointment settings table created!
-- ============================================================

SELECT
  'Settings table created with ' || COUNT(*) || ' default settings' AS status
FROM appointment_settings;
