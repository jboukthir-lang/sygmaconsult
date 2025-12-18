# 📘 دليل النظام الكامل - Sygma Consult
# Complete System Guide - Sygma Consult

## 🎯 ملخص التحديثات الأخيرة | Recent Updates Summary

تم تحديث وتطوير النظام الكامل ليشمل:

### 1. ✅ نظام Profile المستخدم مع رفع الصور
**User Profile System with Image Upload**

#### المميزات | Features:
- رفع صور الملف الشخصي إلى Supabase Storage
- مزامنة فورية للبيانات باستخدام Real-time subscriptions
- حقول جديدة: City, Address, Photo URL
- عداد الحجوزات الحقيقي
- رسائل النجاح/الخطأ
- دعم متعدد اللغات (FR, AR, EN)

#### الملفات المحدثة | Updated Files:
- `/app/profile/page.tsx` - صفحة Profile كاملة
- `/supabase/migrations/20250117_update_user_profiles.sql` - SQL للحقول الجديدة
- `/lib/translations.ts` - 40+ ترجمة جديدة

---

### 2. ✅ نظام إدارة التقويم للأدمن
**Admin Calendar Management System**

#### المميزات | Features:
- إدارة الأوقات المتاحة حسب اليوم
- إضافة/حذف/تعطيل الأوقات
- حجب تواريخ محددة مع السبب
- Real-time synchronization
- واجهة سهلة الاستخدام

#### الملفات الجديدة | New Files:
- `/app/admin/calendar/page.tsx` - صفحة Calendar للأدمن
- `/supabase/migrations/20250117_calendar_tables.sql` - جداول time_slots & blocked_dates
- Translation keys في `/lib/translations.ts`

---

### 3. ✅ نظام الحجوزات المحسّن
**Enhanced Booking System**

#### المميزات | Features:
- أنواع الاستشارات من قاعدة البيانات
- اختيار Online/On-site
- التقويم الديناميكي
- صفحة حجوزات المستخدم مع التفاصيل الكاملة
- Real-time updates

---

## 📋 خطوات التثبيت | Installation Steps

### الخطوة 1: تطبيق SQL Files

قم بتطبيق ملفات SQL التالية **بالترتيب** في Supabase SQL Editor:

```bash
# 1. تحديث جدول user_profiles
supabase/migrations/20250117_update_user_profiles.sql

# 2. إنشاء جداول التقويم
supabase/migrations/20250117_calendar_tables.sql

# 3. تحديث جدول الحجوزات (إذا لم يتم من قبل)
supabase/migrations/20250117_update_bookings.sql
```

### الخطوة 2: إنشاء Storage Bucket

في Supabase Dashboard:
1. اذهب إلى **Storage**
2. أنشئ bucket جديد اسمه `public`
3. اجعله **Public** (حتى يمكن الوصول للصور)
4. أو دع SQL يقوم بذلك تلقائياً

### الخطوة 3: تحديث Environment Variables

في ملف `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Firebase (if using)
NEXT_PUBLIC_FIREBASE_API_KEY=your_firebase_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_firebase_auth_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_firebase_project_id
```

### الخطوة 4: تشغيل المشروع

```bash
cd web
npm install
npm run dev
```

---

## 🗄️ هيكل قاعدة البيانات | Database Schema

### جدول `user_profiles`
```sql
- user_id (UUID, FK to auth.users)
- full_name (VARCHAR)
- email (VARCHAR)
- phone (VARCHAR)
- company (VARCHAR)
- country (VARCHAR)
- city (VARCHAR) ← جديد
- address (VARCHAR) ← جديد
- photo_url (VARCHAR) ← جديد
- language (VARCHAR)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### جدول `time_slots`
```sql
- id (UUID, PK)
- day_of_week (INTEGER 0-6)
- start_time (TIME)
- end_time (TIME)
- is_available (BOOLEAN)
- slot_duration (INTEGER)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### جدول `blocked_dates`
```sql
- id (UUID, PK)
- date (DATE, UNIQUE)
- reason (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### جدول `bookings` (المحسّن)
```sql
... الحقول السابقة +
- duration (INTEGER)
- appointment_type (VARCHAR)
- specialization (VARCHAR)
- is_online (BOOLEAN)
- meeting_link (VARCHAR)
- location (VARCHAR)
- consultant_name (VARCHAR)
- price (DECIMAL)
- payment_status (VARCHAR)
- notes_admin (TEXT)
```

---

## 🔐 Row Level Security (RLS) Policies

### user_profiles
```sql
- Users can view their own profile
- Users can update their own profile
- Admin can view all profiles
```

### time_slots
```sql
- Public read access (for booking calendar)
- Admin full access (CRUD)
```

### blocked_dates
```sql
- Public read access (to check availability)
- Admin full access (CRUD)
```

### Storage (public bucket)
```sql
- Public read access
- Authenticated users can upload
- Users can update/delete own files
```

---

## 📱 واجهات المستخدم | User Interfaces

### للمستخدم العادي | For Regular Users:

1. **Profile Page** (`/profile`)
   - تحديث المعلومات الشخصية
   - رفع صورة الملف الشخصي
   - عرض إحصائيات الحساب

2. **Bookings Page** (`/profile/bookings`)
   - عرض جميع الحجوزات
   - تصفية: الكل / القادمة / السابقة
   - الانضمام للاجتماعات Online
   - عرض ملاحظات الأدمن

3. **Settings Page** (`/profile/settings`)
   - تغيير كلمة المرور
   - إعدادات الإشعارات
   - تغيير اللغة

### للأدمن | For Admins:

1. **Calendar Management** (`/admin/calendar`)
   - إدارة الأوقات المتاحة
   - حجب التواريخ
   - تفعيل/تعطيل الأوقات

2. **Bookings Management** (`/admin/bookings`)
   - عرض جميع الحجوزات
   - تحديث الحالة
   - إضافة ملاحظات للمستخدمين

3. **Users Management** (`/admin/users`)
   - عرض جميع المستخدمين
   - إدارة الصلاحيات

---

## 🎨 الترجمات | Translations

تم إضافة أكثر من **100 ترجمة جديدة** في ثلاث لغات:
- 🇫🇷 Français (French)
- 🇸🇦 العربية (Arabic) - مع دعم RTL
- 🇬🇧 English

المفاتيح الجديدة:
- `profile.*` - 40+ مفتاح للملف الشخصي
- `calendar.*` - 30+ مفتاح لإدارة التقويم
- `bookings.*` - 30+ مفتاح للحجوزات

---

## 🔄 Real-time Synchronization

جميع الصفحات تستخدم Supabase Real-time:

```typescript
// مثال
const channel = supabase
  .channel('channel_name')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'table_name',
    filter: 'column=eq.value'
  }, () => {
    fetchData(); // تحديث البيانات تلقائياً
  })
  .subscribe();

return () => supabase.removeChannel(channel);
```

---

## 🚀 المميزات القادمة | Upcoming Features

### 4. 🔔 نظام الإشعارات (قيد التطوير)
**Notifications System (In Progress)**
- زر الإشعارات في الـ Header
- عداد الإشعارات الجديدة
- إشعارات فورية للحجوزات

### 5. 🎨 إدارة الصور والإعدادات
**Project Settings Management**
- رفع لوجو المشروع
- تخصيص الألوان
- إعدادات عامة للموقع

### 6. 🔗 ربط الخدمات
**Services Integration**
- ربط جميع الخدمات مع لوحة المستخدم
- صفحة موحدة لجميع الخدمات

---

## 🐛 استكشاف الأخطاء | Troubleshooting

### مشكلة: لا يمكن رفع الصور
**Problem: Cannot upload images**

```sql
-- تأكد من وجود bucket
SELECT * FROM storage.buckets WHERE id = 'public';

-- إذا لم يكن موجود، قم بإنشائه
INSERT INTO storage.buckets (id, name, public)
VALUES ('public', 'public', true);
```

### مشكلة: RLS تمنع الإدراج
**Problem: RLS blocking inserts**

```sql
-- تحقق من الـ policies
SELECT * FROM pg_policies WHERE tablename = 'table_name';

-- طبّق السكريبتات المرفقة
```

### مشكلة: الترجمات لا تعمل
**Problem: Translations not working**

```typescript
// تأكد من استيراد الدالة
import { t } from '@/lib/translations';

// استخدم مع اللغة
const text = t('key.subkey', language);
```

---

## 📞 الدعم | Support

إذا واجهت أي مشكلة:
1. تحقق من console logs في المتصفح
2. تحقق من Supabase logs
3. تأكد من تطبيق جميع SQL files
4. تحقق من Environment Variables

---

## ✅ Checklist للتحقق من التثبيت

- [ ] تم تطبيق جميع SQL files
- [ ] تم إنشاء Storage bucket (public)
- [ ] يمكن رفع صورة في Profile
- [ ] يمكن تحديث معلومات Profile
- [ ] صفحة Calendar تعمل للأدمن
- [ ] يمكن إضافة/حذف time slots
- [ ] يمكن حجب التواريخ
- [ ] الترجمات تعمل في جميع الصفحات
- [ ] Real-time sync يعمل

---

## 📝 Notes

- جميع الصفحات تستخدم `'use client'` لأنها interactive
- جميع الأوقات UTC في قاعدة البيانات
- الصور محدودة بـ 2MB
- RLS مفعّل على جميع الجداول

---

**آخر تحديث:** 17 يناير 2025
**Last Updated:** January 17, 2025

**الإصدار:** 2.0
**Version:** 2.0
