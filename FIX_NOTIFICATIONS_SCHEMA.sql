-- ========================================
-- إصلاح schema جدول الإشعارات
-- Fix notifications table schema
-- ========================================

-- حذف الـ trigger القديم
DROP TRIGGER IF EXISTS booking_notification_trigger ON bookings;

-- حذف الدالة القديمة
DROP FUNCTION IF EXISTS create_booking_notification();

-- تحديث schema الجدول
-- إضافة العمود الجديد إذا لم يكن موجوداً
DO $$
BEGIN
  -- تحقق من وجود العمود is_read
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'notifications'
    AND column_name = 'is_read'
  ) THEN
    -- إذا كان العمود read موجود، قم بإعادة تسميته
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'notifications'
      AND column_name = 'read'
    ) THEN
      ALTER TABLE notifications RENAME COLUMN read TO is_read;
      RAISE NOTICE 'Renamed column "read" to "is_read"';
    ELSE
      -- إضافة العمود الجديد
      ALTER TABLE notifications ADD COLUMN is_read BOOLEAN DEFAULT false;
      RAISE NOTICE 'Added column "is_read"';
    END IF;
  END IF;

  -- إضافة read_at إذا لم يكن موجوداً
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'notifications'
    AND column_name = 'read_at'
  ) THEN
    ALTER TABLE notifications ADD COLUMN read_at TIMESTAMP WITH TIME ZONE;
    RAISE NOTICE 'Added column "read_at"';
  END IF;

  -- تحديث العمود type إذا كان مختلفاً
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'notifications'
    AND column_name = 'type'
  ) THEN
    -- لا نحتاج إلى تغيير، فقط تأكد من القيم الصحيحة
    RAISE NOTICE 'Column "type" exists';
  END IF;
END $$;

-- إضافة الفهارس إذا لم تكن موجودة
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id, is_read) WHERE is_read = false;

-- إنشاء الدالة الجديدة
CREATE OR REPLACE FUNCTION create_booking_notification()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NOT NULL THEN
    INSERT INTO notifications (user_id, title, message, type, link, is_read)
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
      '/profile/bookings',
      false
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إنشاء الـ Trigger
CREATE TRIGGER booking_notification_trigger
AFTER INSERT OR UPDATE OF status ON bookings
FOR EACH ROW
EXECUTE FUNCTION create_booking_notification();

-- ========================================
-- ✅ تم إصلاح جدول الإشعارات!
-- ✅ Notifications table fixed!
-- ========================================

SELECT 'Schema updated successfully!' AS status;
