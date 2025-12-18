-- ============================================================
-- 📅 نظام التقويم الكامل - Complete Calendar System
-- ============================================================
-- يتضمن: إعدادات التقويم، أنواع المواعيد، الأوقات المتاحة، الحجوزات
-- ============================================================

-- ============================================================
-- 1️⃣ جدول أنواع المواعيد (Appointment Types)
-- ============================================================
CREATE TABLE IF NOT EXISTS appointment_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_ar TEXT NOT NULL,
  name_fr TEXT NOT NULL,
  name_en TEXT NOT NULL,
  description_ar TEXT,
  description_fr TEXT,
  description_en TEXT,
  duration INTEGER NOT NULL DEFAULT 60, -- بالدقائق
  color TEXT DEFAULT '#3B82F6', -- لون في التقويم
  price DECIMAL(10, 2) DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 2️⃣ جدول إعدادات التقويم (Calendar Settings)
-- ============================================================
CREATE TABLE IF NOT EXISTS calendar_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- أيام العمل
  monday_enabled BOOLEAN DEFAULT true,
  tuesday_enabled BOOLEAN DEFAULT true,
  wednesday_enabled BOOLEAN DEFAULT true,
  thursday_enabled BOOLEAN DEFAULT true,
  friday_enabled BOOLEAN DEFAULT true,
  saturday_enabled BOOLEAN DEFAULT false,
  sunday_enabled BOOLEAN DEFAULT false,

  -- ساعات العمل (تنسيق 24 ساعة)
  monday_start TIME DEFAULT '09:00',
  monday_end TIME DEFAULT '18:00',
  tuesday_start TIME DEFAULT '09:00',
  tuesday_end TIME DEFAULT '18:00',
  wednesday_start TIME DEFAULT '09:00',
  wednesday_end TIME DEFAULT '18:00',
  thursday_start TIME DEFAULT '09:00',
  thursday_end TIME DEFAULT '18:00',
  friday_start TIME DEFAULT '09:00',
  friday_end TIME DEFAULT '18:00',
  saturday_start TIME DEFAULT '09:00',
  saturday_end TIME DEFAULT '18:00',
  sunday_start TIME DEFAULT '09:00',
  sunday_end TIME DEFAULT '18:00',

  -- استراحة الغداء
  lunch_break_enabled BOOLEAN DEFAULT true,
  lunch_break_start TIME DEFAULT '12:00',
  lunch_break_end TIME DEFAULT '13:00',

  -- إعدادات عامة
  slot_duration INTEGER DEFAULT 30, -- مدة كل فترة زمنية بالدقائق
  max_advance_booking_days INTEGER DEFAULT 90, -- أقصى عدد أيام للحجز المسبق
  min_advance_booking_hours INTEGER DEFAULT 24, -- الحد الأدنى للحجز المسبق بالساعات
  allow_weekend_booking BOOLEAN DEFAULT false,
  require_admin_approval BOOLEAN DEFAULT false,

  -- رسائل التأكيد
  send_confirmation_email BOOLEAN DEFAULT true,
  send_reminder_email BOOLEAN DEFAULT true,
  reminder_hours_before INTEGER DEFAULT 24,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 3️⃣ جدول العطلات والأيام الخاصة (Holidays)
-- ============================================================
CREATE TABLE IF NOT EXISTS calendar_holidays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_ar TEXT NOT NULL,
  name_fr TEXT NOT NULL,
  name_en TEXT NOT NULL,
  date DATE NOT NULL,
  is_recurring BOOLEAN DEFAULT false, -- هل تتكرر كل سنة؟
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 4️⃣ جدول المواعيد (Appointments)
-- ============================================================
CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- معلومات الموعد
  appointment_type_id UUID REFERENCES appointment_types(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,

  -- التاريخ والوقت
  appointment_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,

  -- معلومات العميل
  user_id TEXT, -- من Firebase أو NULL إذا كان ضيف
  client_name TEXT NOT NULL,
  client_email TEXT NOT NULL,
  client_phone TEXT NOT NULL,
  client_notes TEXT,

  -- الحالة
  status TEXT DEFAULT 'pending', -- pending, confirmed, cancelled, completed, no_show

  -- ملاحظات إدارية
  admin_notes TEXT,
  cancellation_reason TEXT,

  -- التذكيرات
  reminder_sent BOOLEAN DEFAULT false,
  reminder_sent_at TIMESTAMP WITH TIME ZONE,

  -- التواريخ
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  confirmed_at TIMESTAMP WITH TIME ZONE,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,

  -- قيود
  CONSTRAINT valid_time_range CHECK (end_time > start_time),
  CONSTRAINT valid_status CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed', 'no_show'))
);

-- ============================================================
-- 5️⃣ جدول الأوقات المحظورة (Blocked Times)
-- ============================================================
CREATE TABLE IF NOT EXISTS blocked_times (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  title TEXT NOT NULL,
  description TEXT,

  -- التاريخ والوقت
  blocked_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,

  -- نوع الحظر
  block_type TEXT DEFAULT 'other', -- meeting, vacation, maintenance, other
  is_recurring BOOLEAN DEFAULT false,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  CONSTRAINT valid_blocked_time CHECK (end_time > start_time)
);

-- ============================================================
-- إضافة Indexes للأداء
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_appointments_user_id ON appointments(user_id);
CREATE INDEX IF NOT EXISTS idx_appointments_email ON appointments(client_email);
CREATE INDEX IF NOT EXISTS idx_blocked_times_date ON blocked_times(blocked_date);
CREATE INDEX IF NOT EXISTS idx_holidays_date ON calendar_holidays(date);

-- ============================================================
-- تعطيل RLS مؤقتاً للجداول الجديدة
-- ============================================================
ALTER TABLE appointment_types DISABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_holidays DISABLE ROW LEVEL SECURITY;
ALTER TABLE appointments DISABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_times DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- إدراج بيانات افتراضية - أنواع المواعيد
-- ============================================================
INSERT INTO appointment_types (name_ar, name_fr, name_en, description_ar, description_fr, description_en, duration, color, price)
VALUES
  ('استشارة عامة', 'Consultation générale', 'General Consultation', 'استشارة عامة حول الخدمات', 'Consultation générale sur les services', 'General consultation about services', 30, '#3B82F6', 0),
  ('استشارة متخصصة', 'Consultation spécialisée', 'Specialized Consultation', 'استشارة متخصصة مع خبير', 'Consultation spécialisée avec un expert', 'Specialized consultation with an expert', 60, '#8B5CF6', 50),
  ('اجتماع متابعة', 'Réunion de suivi', 'Follow-up Meeting', 'اجتماع متابعة للمشاريع القائمة', 'Réunion de suivi pour les projets en cours', 'Follow-up meeting for ongoing projects', 45, '#10B981', 0),
  ('عرض تقديمي', 'Présentation', 'Presentation', 'عرض تقديمي للخدمات والمنتجات', 'Présentation des services et produits', 'Presentation of services and products', 90, '#F59E0B', 0),
  ('ورشة عمل', 'Atelier', 'Workshop', 'ورشة عمل تدريبية', 'Atelier de formation', 'Training workshop', 120, '#EF4444', 100);

-- ============================================================
-- إدراج إعدادات افتراضية للتقويم
-- ============================================================
INSERT INTO calendar_settings (
  monday_enabled, tuesday_enabled, wednesday_enabled, thursday_enabled, friday_enabled,
  saturday_enabled, sunday_enabled,
  monday_start, monday_end,
  tuesday_start, tuesday_end,
  wednesday_start, wednesday_end,
  thursday_start, thursday_end,
  friday_start, friday_end,
  saturday_start, saturday_end,
  sunday_start, sunday_end,
  lunch_break_enabled, lunch_break_start, lunch_break_end,
  slot_duration, max_advance_booking_days, min_advance_booking_hours,
  send_confirmation_email, send_reminder_email, reminder_hours_before
)
VALUES (
  true, true, true, true, true, false, false,
  '09:00', '18:00',
  '09:00', '18:00',
  '09:00', '18:00',
  '09:00', '18:00',
  '09:00', '18:00',
  '09:00', '17:00',
  '09:00', '17:00',
  true, '12:30', '13:30',
  30, 90, 24,
  true, true, 24
)
ON CONFLICT DO NOTHING;

-- ============================================================
-- إدراج عطلات افتراضية (أمثلة)
-- ============================================================
INSERT INTO calendar_holidays (name_ar, name_fr, name_en, date, is_recurring)
VALUES
  ('رأس السنة الميلادية', 'Nouvel An', 'New Year''s Day', '2025-01-01', true),
  ('عيد العمال', 'Fête du Travail', 'Labour Day', '2025-05-01', true),
  ('عيد الاستقلال', 'Fête de l''Indépendance', 'Independence Day', '2025-03-20', true),
  ('عيد الفطر', 'Aïd al-Fitr', 'Eid al-Fitr', '2025-03-30', false),
  ('عيد الأضحى', 'Aïd al-Adha', 'Eid al-Adha', '2025-06-06', false),
  ('عيد الميلاد', 'Noël', 'Christmas', '2025-12-25', true)
ON CONFLICT DO NOTHING;

-- ============================================================
-- إدراج مواعيد تجريبية
-- ============================================================
INSERT INTO appointments (
  appointment_type_id, title, description,
  appointment_date, start_time, end_time,
  client_name, client_email, client_phone,
  status
)
SELECT
  (SELECT id FROM appointment_types WHERE name_en = 'General Consultation' LIMIT 1),
  'استشارة مع السيد أحمد',
  'استشارة حول خدمات الشركة',
  CURRENT_DATE + INTERVAL '2 days',
  '10:00',
  '10:30',
  'أحمد محمد',
  'ahmed@example.com',
  '+216 50 123 456',
  'confirmed'
WHERE NOT EXISTS (SELECT 1 FROM appointments LIMIT 1);

INSERT INTO appointments (
  appointment_type_id, title, description,
  appointment_date, start_time, end_time,
  client_name, client_email, client_phone,
  status
)
SELECT
  (SELECT id FROM appointment_types WHERE name_en = 'Specialized Consultation' LIMIT 1),
  'Consultation avec Mme. Marie',
  'Consultation spécialisée',
  CURRENT_DATE + INTERVAL '3 days',
  '14:00',
  '15:00',
  'Marie Laurent',
  'marie@example.com',
  '+33 6 12 34 56 78',
  'pending';

-- ============================================================
-- التحقق من النتائج
-- ============================================================
DO $$
DECLARE
  v_types INTEGER;
  v_settings INTEGER;
  v_holidays INTEGER;
  v_appointments INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_types FROM appointment_types;
  SELECT COUNT(*) INTO v_settings FROM calendar_settings;
  SELECT COUNT(*) INTO v_holidays FROM calendar_holidays;
  SELECT COUNT(*) INTO v_appointments FROM appointments;

  RAISE NOTICE '';
  RAISE NOTICE '====================================';
  RAISE NOTICE '✅ تم إنشاء نظام التقويم بنجاح!';
  RAISE NOTICE '====================================';
  RAISE NOTICE 'أنواع المواعيد: %', v_types;
  RAISE NOTICE 'الإعدادات: %', v_settings;
  RAISE NOTICE 'العطلات: %', v_holidays;
  RAISE NOTICE 'المواعيد: %', v_appointments;
  RAISE NOTICE '';
  RAISE NOTICE '📝 الخطوات التالية:';
  RAISE NOTICE '1. تحديث صفحة الأدمن للتقويم';
  RAISE NOTICE '2. إنشاء واجهة الحجز للمستخدمين';
  RAISE NOTICE '3. إضافة نظام التذكيرات';
  RAISE NOTICE '====================================';
END $$;

-- عرض أنواع المواعيد
SELECT
  name_ar,
  name_fr,
  duration || ' دقيقة' as المدة,
  price || ' €' as السعر,
  color
FROM appointment_types
ORDER BY duration;

-- عرض المواعيد القادمة
SELECT
  appointment_date as التاريخ,
  start_time || ' - ' || end_time as الوقت,
  client_name as العميل,
  status as الحالة
FROM appointments
WHERE appointment_date >= CURRENT_DATE
ORDER BY appointment_date, start_time;
