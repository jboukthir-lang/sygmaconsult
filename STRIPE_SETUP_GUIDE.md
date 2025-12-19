# دليل إعداد Stripe للدفع الإلكتروني
## Stripe Payment Integration Guide

> **التاريخ:** 19 ديسمبر 2024
> **الإصدار:** 1.0
> **الحالة:** جاهز للتطبيق

---

## 📋 جدول المحتويات

1. [نظرة عامة](#نظرة-عامة)
2. [الخطوات المطلوبة](#الخطوات-المطلوبة)
3. [إعداد قاعدة البيانات](#إعداد-قاعدة-البيانات)
4. [تكوين المتغيرات](#تكوين-المتغيرات)
5. [إعداد Webhooks](#إعداد-webhooks)
6. [الاختبار](#الاختبار)
7. [النشر](#النشر)

---

## نظرة عامة

### ✅ ما تم إنجازه

1. **تثبيت المكتبات:**
   ```bash
   npm install stripe @stripe/stripe-js
   ```

2. **إنشاء الملفات:**
   - ✅ `/lib/stripe.ts` - إعدادات Stripe الأساسية
   - ✅ `/app/api/stripe/create-checkout/route.ts` - إنشاء جلسة الدفع
   - ✅ `/app/api/stripe/webhook/route.ts` - معالجة أحداث Stripe
   - ✅ `/scripts/setup-stripe-settings.mjs` - سكريبت إعداد الإعدادات
   - ✅ `/supabase/migrations/setup_stripe_settings.sql` - ملف SQL للإعدادات

3. **المفاتيح المتاحة:**
   - ✅ Live Secret Key: `sk_live_51Sg16j...`
   - ✅ Live Publishable Key: `pk_live_51Sg16j...`

---

## الخطوات المطلوبة

### الخطوة 1: إعداد قاعدة البيانات

قم بتنفيذ ملف SQL في Supabase Dashboard:

1. افتح [Supabase Dashboard](https://supabase.com/dashboard)
2. اذهب إلى **SQL Editor**
3. افتح الملف: `web/supabase/migrations/setup_stripe_settings.sql`
4. انسخ المحتوى والصقه في SQL Editor
5. اضغط **Run**

سيقوم هذا بـ:
- ✅ حفظ مفاتيح Stripe في `site_settings`
- ✅ إضافة أعمدة `stripe_session_id` و `stripe_payment_intent_id` إلى جدول `bookings`
- ✅ إنشاء indexes للبحث السريع

---

### الخطوة 2: تكوين المتغيرات البيئية

أضف المفاتيح التالية إلى ملف `.env.local`:

```env
# Stripe Payment Gateway
# Get your keys from: https://dashboard.stripe.com/apikeys
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_YOUR_PUBLISHABLE_KEY_HERE
STRIPE_SECRET_KEY=sk_live_YOUR_SECRET_KEY_HERE
STRIPE_WEBHOOK_SECRET=whsec_YOUR_WEBHOOK_SECRET_HERE

# Site URL
NEXT_PUBLIC_URL=https://your-production-domain.com  # أو http://localhost:3000 للتطوير
```

⚠️ **ملاحظات أمان مهمة:**
1. **NEVER** commit `.env.local` to Git
2. Store these keys securely
3. Use different keys for development/production
4. The secret key should ONLY be used server-side

---

### الخطوة 3: إعداد Webhooks

الـ Webhooks ضرورية لتحديث حالة الحجز تلقائياً بعد الدفع.

#### أ. إنشاء Webhook في Stripe:

1. اذهب إلى [Stripe Dashboard > Webhooks](https://dashboard.stripe.com/webhooks)
2. اضغط **+ Add endpoint**
3. أدخل URL:
   ```
   https://your-domain.com/api/stripe/webhook
   ```
   للتطوير المحلي، استخدم [Stripe CLI](https://stripe.com/docs/stripe-cli):
   ```bash
   stripe listen --forward-to localhost:3000/api/stripe/webhook
   ```

4. اختر الأحداث التالية:
   - ✅ `checkout.session.completed`
   - ✅ `payment_intent.succeeded`
   - ✅ `payment_intent.payment_failed`
   - ✅ `charge.refunded`

5. احفظ **Signing secret** (يبدأ بـ `whsec_`)

#### ب. تحديث Webhook Secret:

1. افتح `.env.local` وأضف:
   ```env
   STRIPE_WEBHOOK_SECRET=whsec_your_secret_here
   ```

2. قم بتحديثه في قاعدة البيانات أيضاً:
   ```sql
   UPDATE public.site_settings
   SET value_text = 'whsec_your_secret_here'
   WHERE key = 'stripe_webhook_secret';
   ```

---

### الخطوة 4: تعديل صفحة الحجز

الآن نحتاج لتفعيل زر الدفع في صفحة الحجز.

#### الملف: `web/components/BookingCalendar.tsx`

أضف التالي في بداية الملف:

```tsx
import { loadStripe } from '@stripe/stripe-js';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!);
```

ثم أضف دالة `redirectToCheckout`:

```tsx
const redirectToCheckout = async (bookingId: string) => {
  try {
    setLoading(true);

    const response = await fetch('/api/stripe/create-checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ bookingId })
    });

    const { url, error } = await response.json();

    if (error) {
      toast.error('Failed to initialize payment');
      console.error('Payment error:', error);
      return;
    }

    // Redirect to Stripe Checkout
    window.location.href = url;
  } catch (error) {
    console.error('Checkout error:', error);
    toast.error('An error occurred. Please try again.');
  } finally {
    setLoading(false);
  }
};
```

وعدّل دالة `handleSubmit`:

```tsx
const handleSubmit = async (e) => {
  e.preventDefault();

  // إنشاء الحجز أولاً
  const { data: booking, error } = await supabase
    .from('bookings')
    .insert({
      // ... existing booking data
      payment_status: 'pending'
    })
    .select()
    .single();

  if (error) {
    toast.error('Failed to create booking');
    return;
  }

  // إذا كان السعر > 0، اذهب للدفع
  const consultationType = consultationTypes.find(t => t.id === selectedConsultationType);

  if (consultationType && consultationType.price > 0) {
    await redirectToCheckout(booking.id);
  } else {
    // حجز مجاني
    toast.success('Booking created successfully!');
    router.push('/profile/bookings');
  }
};
```

---

### الخطوة 5: إنشاء صفحات Success و Cancel

#### أ. صفحة النجاح: `app/booking/success/page.tsx`

```tsx
'use client';

import { useEffect, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { CheckCircle } from 'lucide-react';
import Link from 'next/link';

export default function SuccessPage() {
  const searchParams = useSearchParams();
  const bookingId = searchParams.get('booking_id');

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="container mx-auto px-4 max-w-2xl">
        <div className="bg-white rounded-2xl shadow-lg p-8 text-center">
          <CheckCircle className="w-20 h-20 text-green-600 mx-auto mb-4" />
          <h1 className="text-3xl font-bold mb-2">Payment Successful!</h1>
          <p className="text-gray-600 mb-8">Your consultation has been confirmed</p>

          <div className="flex gap-4">
            <Link
              href="/profile/bookings"
              className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              View My Bookings
            </Link>
            <Link
              href="/"
              className="flex-1 px-6 py-3 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300"
            >
              Back to Home
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
```

#### ب. صفحة الإلغاء: `app/booking/cancel/page.tsx`

```tsx
'use client';

import { XCircle } from 'lucide-react';
import Link from 'next/link';

export default function CancelPage() {
  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="container mx-auto px-4 max-w-2xl">
        <div className="bg-white rounded-2xl shadow-lg p-8 text-center">
          <XCircle className="w-20 h-20 text-red-600 mx-auto mb-4" />
          <h1 className="text-3xl font-bold mb-2">Payment Cancelled</h1>
          <p className="text-gray-600 mb-8">Your payment was not completed</p>

          <div className="flex gap-4">
            <Link
              href="/book"
              className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              Try Again
            </Link>
            <Link
              href="/"
              className="flex-1 px-6 py-3 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300"
            >
              Back to Home
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
```

---

## الاختبار

### 1. الاختبار المحلي

```bash
# 1. Start the development server
npm run dev

# 2. In another terminal, start Stripe CLI listener
stripe listen --forward-to localhost:3000/api/stripe/webhook

# 3. Use test card numbers
# Success: 4242 4242 4242 4242
# Decline: 4000 0000 0000 0002
# Any future expiry date and any 3-digit CVC
```

### 2. بطاقات الاختبار

| السيناريو | رقم البطاقة |
|-----------|-------------|
| ✅ نجاح | 4242 4242 4242 4242 |
| ❌ رفض | 4000 0000 0000 0002 |
| ⚠️ يتطلب تأكيد إضافي | 4000 0025 0000 3155 |
| 💳 Insufficient funds | 4000 0000 0000 9995 |

- تاريخ الانتهاء: أي تاريخ مستقبلي (مثل 12/25)
- CVC: أي 3 أرقام (مثل 123)
- Postal Code: أي رمز بريدي

### 3. التحقق من العمليات

1. ✅ إنشاء حجز جديد
2. ✅ إعادة التوجيه إلى Stripe Checkout
3. ✅ إتمام الدفع
4. ✅ تحديث حالة الحجز إلى "confirmed" و "paid"
5. ✅ إرسال إشعار للمستخدم
6. ✅ إرسال إشعار للإدارة
7. ✅ إعادة التوجيه إلى صفحة النجاح

---

## النشر

### 1. على Vercel

```bash
# 1. Add environment variables in Vercel Dashboard
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_URL=https://your-domain.com

# 2. Deploy
vercel --prod

# 3. Update webhook URL in Stripe Dashboard
https://your-domain.com/api/stripe/webhook
```

### 2. التحقق من الإنتاج

1. ✅ اختبر حجز تجريبي بمبلغ صغير (€1)
2. ✅ تحقق من Stripe Dashboard لرؤية الدفعة
3. ✅ تحقق من تحديث قاعدة البيانات
4. ✅ تحقق من استلام الإشعارات

---

## 🔒 الأمان

### قواعد مهمة:

1. ⛔ **NEVER** expose secret key in client code
2. ✅ Always use HTTPS in production
3. ✅ Validate webhook signatures
4. ✅ Log all payment events
5. ✅ Monitor for suspicious activity
6. ✅ Use Stripe's fraud prevention tools

### التشفير:

```typescript
// ❌ WRONG - Don't do this
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
// client-side code

// ✅ CORRECT - Server-side only
// app/api/payment/route.ts
import { stripe } from '@/lib/stripe';  // Only in API routes
```

---

## 📊 المراقبة

### في Stripe Dashboard:

1. **Payments** - عرض جميع الدفعات
2. **Customers** - إدارة العملاء
3. **Disputes** - معالجة الخلافات
4. **Events** - سجل الأحداث
5. **Webhooks** - حالة الـ webhooks

### في التطبيق:

```sql
-- عرض إحصائيات الدفع
SELECT
  payment_status,
  COUNT(*) as count,
  SUM(price) as total_revenue
FROM bookings
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY payment_status;
```

---

## 🆘 استكشاف الأخطاء

### مشكلة: Webhook لا يعمل

**الحل:**
```bash
# تحقق من logs
stripe logs tail

# تحقق من signature
# في webhook/route.ts, أضف:
console.log('Signature:', signature);
console.log('Body:', body.substring(0, 100));
```

### مشكلة: Payment fails silently

**الحل:**
1. تحقق من Stripe Dashboard > Events
2. تحقق من browser console
3. تحقق من server logs
4. تحقق من webhook endpoint في Stripe

### مشكلة: Booking not updating

**الحل:**
```sql
-- تحقق من RLS policies
SELECT * FROM pg_policies WHERE tablename = 'bookings';

-- تحقق من webhook secret
SELECT value_text FROM site_settings WHERE key = 'stripe_webhook_secret';
```

---

## 📝 الخطوات التالية

بعد إكمال إعداد Stripe، يمكنك:

1. ✅ إضافة نظام الفواتير (invoices)
2. ✅ إضافة المبالغ المستردة (refunds)
3. ✅ إضافة الاشتراكات (subscriptions)
4. ✅ إضافة الخصومات (coupons/discounts)
5. ✅ تكامل مع accounting software

---

## 📞 الدعم

### روابط مفيدة:

- [Stripe Documentation](https://stripe.com/docs)
- [Stripe API Reference](https://stripe.com/docs/api)
- [Stripe Testing](https://stripe.com/docs/testing)
- [Stripe Security](https://stripe.com/docs/security/stripe)
- [Stripe Dashboard](https://dashboard.stripe.com)

### التواصل:

- **Stripe Support:** https://support.stripe.com
- **Technical Issues:** Check Stripe logs and webhook events
- **Billing Questions:** Contact Stripe billing team

---

## ✅ Checklist نهائي

قبل الانتقال إلى الإنتاج، تأكد من:

- [ ] تنفيذ ملف SQL في Supabase
- [ ] إضافة متغيرات البيئة
- [ ] إعداد Webhooks في Stripe
- [ ] اختبار الدفع بنجاح
- [ ] اختبار webhook events
- [ ] اختبار صفحات success/cancel
- [ ] التحقق من تحديث قاعدة البيانات
- [ ] التحقق من الإشعارات
- [ ] اختبار على Production
- [ ] مراقبة أول دفعة حقيقية

---

**آخر تحديث:** 19 ديسمبر 2024
**الإصدار:** 1.0
**الحالة:** ✅ جاهز للتطبيق

**ملاحظة:** هذا الدليل يغطي الإعداد الأساسي. للميزات المتقدمة (subscriptions, invoicing, refunds)، راجع الوثائق الرسمية لـ Stripe.
