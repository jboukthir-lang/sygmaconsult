-- ========================================
-- إصلاح RLS لجدول الحجوزات (النسخة المحدثة)
-- Fix RLS for bookings table (Updated version)
-- ========================================

-- حذف جميع الـ policies القديمة من جدول bookings
DROP POLICY IF EXISTS "Allow public to create bookings" ON bookings;
DROP POLICY IF EXISTS "Allow anyone to create bookings" ON bookings;
DROP POLICY IF EXISTS "Allow users to view their own bookings" ON bookings;
DROP POLICY IF EXISTS "Allow admin to view all bookings" ON bookings;
DROP POLICY IF EXISTS "Allow admin to update bookings" ON bookings;
DROP POLICY IF EXISTS "Allow admin to delete bookings" ON bookings;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON bookings;
DROP POLICY IF EXISTS "Enable read access for all users" ON bookings;

-- السماح للجميع بإنشاء حجوزات (مهم!)
CREATE POLICY "Allow anyone to create bookings"
ON bookings
FOR INSERT
WITH CHECK (true);

-- السماح للمستخدمين برؤية حجوزاتهم الخاصة (بدون الوصول لجدول auth.users)
CREATE POLICY "Allow users to view their own bookings"
ON bookings
FOR SELECT
USING (
  auth.uid()::text = user_id::text
  OR user_id IS NULL
);

-- السماح للأدمن برؤية جميع الحجوزات
CREATE POLICY "Allow admin to view all bookings"
ON bookings
FOR SELECT
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- السماح للأدمن بتحديث الحجوزات
CREATE POLICY "Allow admin to update bookings"
ON bookings
FOR UPDATE
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
)
WITH CHECK (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- السماح للأدمن بحذف الحجوزات
CREATE POLICY "Allow admin to delete bookings"
ON bookings
FOR DELETE
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id::text = auth.uid()::text)
);

-- ========================================
-- ✅ تم! الآن يمكنك إنشاء حجوزات بدون مشاكل
-- ✅ Done! Now you can create bookings without issues
-- ========================================
