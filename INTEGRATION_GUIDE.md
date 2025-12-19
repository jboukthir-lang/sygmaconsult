# 🔗 دليل الربط الشامل - Sygma Consult Integration Guide

## 📋 نظرة عامة | Overview

هذا الدليل يشرح كيفية ربط جميع أنظمة الموقع مع بعضها البعض بشكل كامل.

---

## 1️⃣ نظام الحجوزات والدفع | Booking & Payment System

### البنية الموحدة | Unified Structure

تم دمج `consultation_types` و `appointment_types` في جدول واحد موحد:

```
appointment_types
├── id (UUID)
├── name_fr, name_ar, name_en
├── description_fr, description_ar, description_en
├── duration (minutes)
├── price (EUR)
├── color (hex)
├── is_active
├── is_online_available
└── is_onsite_available
```

### التدفق الكامل | Complete Flow

```
User selects date/time → Chooses appointment type → Fills form →
→ IF price > 0: Redirect to Stripe Checkout → Payment → Confirmation
→ IF price = 0: Direct confirmation
```

---

## 2️⃣ ربط Calendar مع Bookings | Calendar-Booking Integration

### الجداول المرتبطة | Related Tables

1. **bookings** - الحجوزات الأساسية
2. **appointments** - المواعيد في الكالندر
3. **appointment_types** - أنواع المواعيد مع الأسعار
4. **calendar_settings** - إعدادات ساعات العمل

### العلاقات | Relationships

```sql
appointments.appointment_type_id → appointment_types.id
appointments.booking_id → bookings.id
bookings.appointment_type_id → appointment_types.id
```

---

## 3️⃣ نظام التسعير الموحد | Unified Pricing System

### مصدر الأسعار | Price Source

جميع الأسعار تأتي من `appointment_types`:

```typescript
// في BookingCalendar.tsx
const selectedAppointment = appointmentTypes.find(
  apt => apt.id === formData.appointmentTypeId
);
const price = selectedAppointment?.price || 0;
```

### تحديث السعر | Price Updates

```sql
-- تحديث سعر نوع معين
UPDATE appointment_types
SET price = 200.00
WHERE id = 'uuid-here';
```

---

## 4️⃣ تكامل Stripe | Stripe Integration

### التدفق | Flow

```
1. User completes booking form
2. POST /api/booking (saves to DB with price)
3. IF price > 0:
   → POST /api/stripe/create-checkout
   → Redirects to Stripe
   → User pays
   → Webhook updates booking status
4. User sees success page
```

### الحقول المطلوبة في bookings | Required Fields

```sql
bookings {
  appointment_type_id UUID,
  price DECIMAL(10,2),
  payment_status VARCHAR(50), -- 'pending', 'paid', 'refunded', 'free'
  stripe_session_id VARCHAR(255),
  stripe_payment_intent_id VARCHAR(255)
}
```

---

## 5️⃣ خطوات الإعداد | Setup Steps

### الخطوة 1: تنفيذ Migration

```bash
# في Supabase SQL Editor
# نفذ الملف:
web/supabase/migrations/unify_appointment_consultation_types.sql
```

هذا الملف سيقوم بـ:
- ✅ إنشاء/تحديث جدول `appointment_types`
- ✅ دمج البيانات من `consultation_types`
- ✅ إضافة حقول Stripe لـ `bookings`
- ✅ إنشاء جدول `appointments`
- ✅ إنشاء جدول `calendar_settings`
- ✅ إعداد RLS policies
- ✅ إضافة indexes للأداء

### الخطوة 2: إضافة مفاتيح Stripe

في `.env.local`:

```env
# Stripe Keys (احصل عليها من dashboard.stripe.com/apikeys)
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_YOUR_PUBLISHABLE_KEY_HERE
STRIPE_SECRET_KEY=sk_live_YOUR_SECRET_KEY_HERE
STRIPE_WEBHOOK_SECRET=whsec_YOUR_WEBHOOK_SECRET_HERE

# Site URL
NEXT_PUBLIC_URL=https://sygmaconsult.com
```

### الخطوة 3: إعداد Stripe Webhook

1. اذهب إلى https://dashboard.stripe.com/webhooks
2. أضف endpoint: `https://sygmaconsult.com/api/stripe/webhook`
3. اختر الأحداث:
   - ✅ `checkout.session.completed`
   - ✅ `payment_intent.succeeded`
   - ✅ `payment_intent.payment_failed`
   - ✅ `charge.refunded`
4. انسخ `Signing secret` → أضفه إلى `.env.local`

### الخطوة 4: تكوين Calendar Settings

في لوحة الأدمن `/admin/calendar`:

1. **Working Hours** - حدد ساعات العمل لكل يوم
2. **Lunch Break** - فعّل وقت الاستراحة
3. **Slot Duration** - مدة كل موعد (افتراضي 30 دقيقة)
4. **Booking Rules**:
   - Max advance booking days: 60
   - Min advance booking hours: 24
   - Require admin approval: true/false

### الخطوة 5: إضافة أنواع المواعيد

في `/admin/calendar` → Appointment Types:

```sql
INSERT INTO appointment_types (
  name_fr, name_ar, name_en,
  description_fr, description_ar, description_en,
  duration, price, color, is_active
) VALUES (
  'Consultation Premium',
  'استشارة متميزة',
  'Premium Consultation',
  'Consultation approfondie avec expert senior',
  'استشارة معمقة مع خبير كبير',
  'In-depth consultation with senior expert',
  90,
  250.00,
  '#6366F1',
  true
);
```

---

## 6️⃣ واجهات الإدارة | Admin Interfaces

### إدارة المواعيد | Appointments Management

**المسار:** `/admin/calendar`

**الوظائف:**
- 📅 عرض جميع المواعيد القادمة
- ✅ تأكيد/إلغاء المواعيد
- 📝 تعديل التفاصيل
- 👁️ معاينة معلومات العميل

### إدارة الأنواع | Types Management

**المسار:** `/admin/calendar` → Appointment Types

**الوظائف:**
- ➕ إضافة نوع جديد
- ✏️ تعديل السعر والمدة
- 🎨 تغيير اللون
- 🔄 تفعيل/تعطيل النوع

### إعدادات الكالندر | Calendar Settings

**المسار:** `/admin/calendar` → Settings

**الوظائف:**
- ⏰ ضبط ساعات العمل
- 🍽️ تحديد وقت الاستراحة
- ⚙️ قواعد الحجز
- 📧 إعدادات الإشعارات

---

## 7️⃣ اختبار النظام | System Testing

### اختبار الحجز المجاني | Free Booking Test

```
1. انتقل إلى /book
2. اختر موعداً مجانياً (price = 0)
3. املأ النموذج
4. تأكيد → يجب أن تظهر صفحة النجاح مباشرة
5. تحقق من قاعدة البيانات:
   - payment_status = 'free'
   - status = 'pending'
```

### اختبار الحجز المدفوع | Paid Booking Test

```
1. انتقل إلى /book
2. اختر موعداً مدفوعاً (price > 0)
3. املأ النموذج
4. تأكيد → يجب إعادة التوجيه إلى Stripe
5. استخدم بطاقة اختبار: 4242 4242 4242 4242
6. أكمل الدفع
7. تحقق من:
   - صفحة النجاح /booking/success
   - قاعدة البيانات: payment_status = 'paid'
   - إشعار في لوحة الأدمن
```

### اختبار Calendar

```
1. انتقل إلى /admin/calendar
2. تحقق من ظهور جميع المواعيد
3. جرب تأكيد موعد
4. تحقق من تحديث الحالة في قاعدة البيانات
5. جرب إضافة نوع موعد جديد
6. تحقق من ظهوره في /book
```

---

## 8️⃣ استكشاف الأخطاء | Troubleshooting

### خطأ: "Failed to create checkout session"

**الأسباب المحتملة:**
1. مفاتيح Stripe غير صحيحة
2. حقل `price` غير موجود في booking
3. `NEXT_PUBLIC_URL` غير مضبوط

**الحل:**
```bash
# تحقق من المفاتيح
echo $STRIPE_SECRET_KEY

# تحقق من وجود السعر
SELECT id, price, payment_status FROM bookings WHERE id = 'booking-id';

# تحقق من URL
echo $NEXT_PUBLIC_URL
```

### خطأ: Appointment types لا تظهر

**الأسباب:**
1. الجدول فارغ
2. جميع الأنواع `is_active = false`
3. مشكلة في RLS policy

**الحل:**
```sql
-- تحقق من البيانات
SELECT * FROM appointment_types WHERE is_active = true;

-- أضف نوعاً تجريبياً
INSERT INTO appointment_types (
  name_fr, name_ar, name_en,
  duration, price, is_active
) VALUES (
  'Test', 'اختبار', 'Test',
  30, 50.00, true
);
```

### خطأ: Calendar settings لا تحفظ

**الحل:**
```sql
-- تحقق من وجود السطر
SELECT * FROM calendar_settings;

-- إذا لم يكن موجوداً
INSERT INTO calendar_settings DEFAULT VALUES;

-- تحقق من RLS policy
SELECT * FROM pg_policies WHERE tablename = 'calendar_settings';
```

---

## 9️⃣ الأمان | Security

### RLS Policies

```sql
-- appointment_types: الجميع يمكنهم القراءة، الأدمن فقط للتعديل
-- appointments: الجميع للقراءة، الأدمن للتعديل
-- bookings: المستخدم يرى حجوزاته فقط، الأدمن يرى الكل
-- calendar_settings: الجميع للقراءة، الأدمن للتعديل
```

### حماية المفاتيح

- ✅ جميع مفاتيح Stripe في `.env.local`
- ✅ `.env.local` في `.gitignore`
- ✅ استخدام `NEXT_PUBLIC_` فقط للمفاتيح العامة
- ✅ Secret keys على السيرفر فقط

---

## 🔟 الصيانة | Maintenance

### تحديثات الأسعار

```sql
-- تحديث سعر نوع معين
UPDATE appointment_types
SET price = 180.00,
    updated_at = NOW()
WHERE name_en = 'Legal Consultation';
```

### إضافة أيام عطلة

```sql
-- تعطيل حجوزات في تاريخ معين
-- يمكن إضافة جدول holidays منفصل
CREATE TABLE holidays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  reason TEXT,
  is_active BOOLEAN DEFAULT true
);
```

### تقارير الحجوزات

```sql
-- حجوزات الشهر الحالي
SELECT
  COUNT(*) as total_bookings,
  SUM(price) as total_revenue,
  AVG(price) as average_price
FROM bookings
WHERE date >= DATE_TRUNC('month', CURRENT_DATE)
  AND payment_status = 'paid';

-- أكثر أنواع المواعيد طلباً
SELECT
  at.name_en,
  COUNT(b.id) as booking_count,
  SUM(b.price) as revenue
FROM bookings b
JOIN appointment_types at ON b.appointment_type_id = at.id
WHERE b.payment_status = 'paid'
GROUP BY at.name_en
ORDER BY booking_count DESC;
```

---

## ✅ Checklist نهائي | Final Checklist

قبل الإطلاق، تأكد من:

- [ ] تنفيذ migration الموحد
- [ ] إضافة مفاتيح Stripe
- [ ] إعداد Stripe webhook
- [ ] تكوين calendar settings
- [ ] إضافة 4-6 أنواع مواعيد على الأقل
- [ ] اختبار حجز مجاني
- [ ] اختبار حجز مدفوع
- [ ] اختبار webhook (استخدم Stripe CLI)
- [ ] مراجعة RLS policies
- [ ] اختبار صفحات النجاح/الإلغاء
- [ ] اختبار إشعارات الأدمن
- [ ] اختبار على mobile
- [ ] مراجعة ترجمات EN/FR/AR
- [ ] backup قاعدة البيانات

---

## 📞 الدعم | Support

إذا واجهت أي مشاكل:
1. تحقق من console logs في المتصفح
2. تحقق من Supabase logs
3. تحقق من Stripe Dashboard > Developers > Logs
4. راجع هذا الدليل
5. راجع STRIPE_SETUP_GUIDE.md

---

**تم التحديث:** 2025-12-19
**الإصدار:** 1.0.0
