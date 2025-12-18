-- ========================================
-- الحل النهائي لمشكلة RLS في جدول الحجوزات
-- Final solution for bookings RLS issue
-- ========================================

-- الخطوة 1: حذف جميع الـ policies من جدول bookings
DO $$
DECLARE
    pol_name TEXT;
BEGIN
    FOR pol_name IN
        SELECT policyname
        FROM pg_policies
        WHERE tablename = 'bookings' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON bookings', pol_name);
    END LOOP;
END $$;

-- الخطوة 2: إضافة policy بسيط جداً يسمح بكل شيء مؤقتاً للاختبار
CREATE POLICY "Allow all operations on bookings"
ON bookings
FOR ALL
USING (true)
WITH CHECK (true);

-- ========================================
-- ✅ هذا سيسمح بكل العمليات على جدول bookings
-- ✅ This will allow all operations on bookings table
--
-- ملاحظة: بعد التأكد من أن الحجز يعمل، يمكنك
-- تطبيق policies أكثر أماناً
-- ========================================
