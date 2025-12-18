# 📚 نظام الإدارة - Sygma Consult Admin System Documentation

## 🌟 نظرة عامة / Vue d'ensemble / Overview

نظام إدارة متكامل متعدد اللغات (FR, AR, EN) لإدارة الاستشارات والحجوزات والمستخدمين مع تزامن فوري ونظام إشعارات متطور.

A comprehensive multilingual admin system (FR, AR, EN) for managing consultations, bookings, and users with real-time synchronization and advanced notification system.

---

## 🎯 الميزات الرئيسية / Fonctionnalités principales / Key Features

### 1. نظام متعدد اللغات / Système multilingue / Multi-language System
- ✅ **3 لغات**: الفرنسية (افتراضي)، العربية، الإنجليزية
- ✅ **RTL Support**: دعم كامل للغة العربية
- ✅ **تبديل فوري**: تغيير اللغة بنقرة واحدة
- ✅ **ترجمات شاملة**: جميع واجهات الأدمن مترجمة

### 2. نظام الحجوزات المتطور / Système de réservation avancé / Advanced Booking System

#### 📋 حقول الحجز / Champs de réservation / Booking Fields:
```typescript
interface Booking {
  // المعلومات الأساسية / Informations de base
  id: string;
  name: string;
  email: string;
  phone: string;

  // تفاصيل الموعد / Détails du rendez-vous
  date: string;                    // التاريخ / Date
  time: string;                    // الوقت / Time
  duration: number;                // المدة بالدقائق / Duration (minutes)

  // نوع الاستشارة / Type de consultation
  topic: string;                   // الموضوع / Topic
  appointment_type: string;        // نوع الموعد / Appointment type
  specialization: string;          // التخصص / Specialization

  // أونلاين أو حضوري / En ligne ou sur place
  is_online: boolean;              // أونلاين؟ / Online?
  meeting_link: string;            // رابط الاجتماع / Meeting link
  location: string;                // الموقع / Location

  // المستشار والتسعير / Consultant et tarification
  consultant_name: string;         // اسم المستشار / Consultant name
  price: number;                   // السعر / Price
  payment_status: string;          // حالة الدفع / Payment status

  // الحالة والملاحظات / Statut et notes
  status: string;                  // pending, confirmed, cancelled
  notes: string;                   // ملاحظات العميل / Client notes
  notes_admin: string;             // ملاحظات الأدمن / Admin notes
}
```

#### 🔔 نظام الإشعارات بالبريد / Système de notifications par email

**عند إنشاء حجز جديد:**
1. ✉️ إرسال تلقائي للأدمن بجميع التفاصيل
2. ✉️ إرسال تأكيد للعميل بتفاصيل الموعد
3. 🌐 الإيميلات متعددة اللغات (FR, AR, EN)
4. 📱 تصميم responsive للموبايل

**Edge Function**: `/supabase/functions/send-booking-email/index.ts`

```typescript
// استدعاء بعد إنشاء الحجز / Appeler après création
const { data, error } = await supabase.functions.invoke('send-booking-email', {
  body: { bookingId: newBooking.id }
});
```

### 3. صفحات الإدارة / Pages d'administration / Admin Pages

#### 📊 Dashboard / لوحة التحكم
- نظرة عامة على الإحصائيات
- الحجوزات الأخيرة
- الرسائل الجديدة
- نمو المستخدمين

#### 👥 Users / المستخدمون
- **Real-time sync**: تزامن فوري مع قاعدة البيانات
- إدارة الصلاحيات (Admin, Super Admin)
- بحث وتصفية متقدم
- عرض معلومات مفصلة

**Real-time Subscriptions**:
```typescript
// قناتان للتزامن الفوري
usersChannel: 'user_profiles' table
adminChannel: 'admin_users' table
```

#### 📅 Bookings / الحجوزات
- **Real-time sync**: تحديث تلقائي
- تأكيد/رفض الحجوزات
- فلترة حسب الحالة (pending, confirmed, cancelled)
- عرض تفاصيل كاملة

#### 💬 Messages / الرسائل (Contacts)
- **Real-time sync**: إشعارات فورية
- تعليم كمقروء
- الرد عبر البريد الإلكتروني
- إحصائيات الرسائل

#### 📄 Documents / المستندات
- **Real-time sync**: تحديث تلقائي
- معاينة الملفات (PDF, Images)
- تحميل الملفات
- حذف آمن

#### 🔔 Send Notifications / إرسال الإشعارات
- إرسال للجميع أو مستخدمين محددين
- 4 أنواع: Booking, Reminder, Message, System
- إضافة روابط للإشعارات
- تتبع حالة الإرسال

#### 📊 Analytics / التحليلات
- إحصائيات المستخدمين
- معدلات التحويل
- الإيرادات
- معدل الاستجابة
- فلترة حسب الفترة (7, 30, 90 يوم)

#### 🎨 Settings / الإعدادات
- **رفع اللوجو**: تعديل لوجو الموقع
- **رفع Favicon**: تعديل أيقونة الموقع
- **معلومات الشركة**: الاسم، البريد، الهاتف، العنوان
- **إعدادات الحجوزات**: المدة الافتراضية، السعر

**مميزات رفع الملفات**:
- ✅ رفع إلى Supabase Storage
- ✅ معاينة فورية
- ✅ تحقق من نوع الملف
- ✅ حد أقصى للحجم (2MB)

### 4. التزامن الفوري / Synchronisation en temps réel / Real-time Sync

جميع الصفحات تستخدم **Supabase Real-time**:

```typescript
// مثال: تزامن الحجوزات
const channel = supabase
  .channel('admin_bookings')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'bookings',
  }, () => {
    fetchBookings(); // تحديث البيانات تلقائياً
  })
  .subscribe();

// تنظيف عند إلغاء التحميل
return () => {
  supabase.removeChannel(channel);
};
```

---

## 🗄️ قاعدة البيانات / Base de données / Database Schema

### Tables الجداول الرئيسية:

#### 1. `bookings` - الحجوزات
```sql
- id: UUID (Primary Key)
- name, email, phone: VARCHAR
- date, time: VARCHAR
- duration: INTEGER (default 30)
- topic: TEXT
- appointment_type: VARCHAR(50)
- specialization: VARCHAR(100)
- is_online: BOOLEAN (default true)
- meeting_link: VARCHAR(500)
- location: VARCHAR(500)
- consultant_name: VARCHAR(200)
- price: DECIMAL(10, 2)
- payment_status: VARCHAR(50)
- status: VARCHAR (pending/confirmed/cancelled)
- notes: TEXT
- notes_admin: TEXT
- created_at: TIMESTAMP
```

#### 2. `consultation_types` - أنواع الاستشارات
```sql
- id: UUID
- name_fr, name_ar, name_en: VARCHAR(200)
- description_fr, description_ar, description_en: TEXT
- duration: INTEGER
- price: DECIMAL(10, 2)
- is_active: BOOLEAN
- is_online_available: BOOLEAN
- is_onsite_available: BOOLEAN
```

#### 3. `consultants` - المستشارون
```sql
- id: UUID
- user_id: UUID (FK to auth.users)
- full_name: VARCHAR(200)
- email: VARCHAR(255)
- phone: VARCHAR(50)
- specializations: TEXT[]
- bio_fr, bio_ar, bio_en: TEXT
- photo_url: VARCHAR(500)
- is_active: BOOLEAN
- hourly_rate: DECIMAL(10, 2)
```

#### 4. `site_settings` - إعدادات الموقع
```sql
- id: UUID
- key: VARCHAR(100) UNIQUE
- value_text: TEXT
- value_json: JSONB
- description: TEXT
```

**إعدادات افتراضية**:
- `logo_url`: رابط اللوجو
- `favicon_url`: رابط الأيقونة
- `company_name`: اسم الشركة
- `admin_email`: البريد الإداري
- `company_phone`: رقم الهاتف
- `company_address`: العنوان
- `default_appointment_duration`: 30
- `default_consultation_price`: 0

### Row Level Security (RLS):

```sql
-- الجميع يمكنه القراءة
CREATE POLICY "Allow read access" ON consultation_types
FOR SELECT USING (is_active = true);

-- الأدمن لديه صلاحيات كاملة
CREATE POLICY "Allow admin full access" ON consultation_types
FOR ALL USING (
  EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid())
);
```

---

## 🚀 التثبيت والإعداد / Installation et configuration / Installation & Setup

### 1. تطبيق Migration:

```bash
# من مجلد المشروع
cd web

# تطبيق migration قاعدة البيانات
supabase db push
```

أو يدوياً:
```bash
# تنفيذ ملف SQL في Supabase Dashboard
# SQL Editor > New Query
# نسخ محتوى: supabase/migrations/20250117_update_bookings.sql
```

### 2. إعداد Edge Function للبريد:

```bash
# deploy Edge Function
supabase functions deploy send-booking-email

# إضافة API Key (في Supabase Dashboard > Edge Functions > Secrets)
RESEND_API_KEY=re_xxxxxxxxxxxxx
```

### 3. متغيرات البيئة:

```env
# .env.local
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
RESEND_API_KEY=your_resend_api_key
```

### 4. Supabase Storage Bucket:

```sql
-- إنشاء bucket للصور
INSERT INTO storage.buckets (id, name, public)
VALUES ('public', 'public', true);

-- إضافة policies
CREATE POLICY "Allow public read" ON storage.objects
FOR SELECT USING (bucket_id = 'public');

CREATE POLICY "Allow admin upload" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'public' AND
  EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid())
);
```

---

## 📱 واجهة المستخدم / Interface utilisateur / User Interface

### الألوان الرئيسية / Couleurs principales:
```css
--primary: #001F3F (Navy Blue)
--secondary: #D4AF37 (Gold)
--accent: #003366 (Dark Blue)
```

### الأيقونات / Icônes:
- **Lucide React**: مكتبة أيقونات حديثة
- أيقونات متجاوبة ومتسقة في كل الصفحات

### التصميم / Design:
- **Responsive**: متجاوب مع جميع الأجهزة
- **RTL Support**: دعم كامل للعربية
- **Dark Mode Ready**: جاهز لوضع الليل (قريباً)

---

## 🔐 الأمان / Sécurité / Security

### حماية الصفحات:
```typescript
// في layout.tsx
- التحقق من تسجيل الدخول
- التحقق من صلاحيات الأدمن
- إعادة توجيه تلقائية للمستخدمين غير المصرح لهم
```

### Row Level Security:
- ✅ جميع الجداول محمية بـ RLS
- ✅ الأدمن فقط لديهم صلاحيات التعديل
- ✅ القراءة العامة للبيانات النشطة فقط

### تحميل الملفات:
- ✅ التحقق من نوع الملف
- ✅ حد أقصى للحجم (2MB)
- ✅ التخزين الآمن في Supabase Storage

---

## 📊 الإحصائيات والتقارير / Statistiques et rapports / Analytics & Reports

### Dashboard Metrics:
- إجمالي الحجوزات / Total bookings
- الحجوزات المعلقة / Pending bookings
- الرسائل الجديدة / New messages
- المستخدمون المسجلون / Registered users
- معدل التحويل / Conversion rate

### Analytics Page:
- نمو المستخدمين / User growth
- إحصائيات الحجوزات / Booking statistics
- الإيرادات / Revenue
- معدل الاستجابة / Response rate
- فلترة حسب الفترة / Filter by period

---

## 🛠️ الصيانة والدعم / Maintenance et support / Maintenance & Support

### Logs والمراقبة:
```typescript
// جميع الأخطاء مسجلة في console
console.error('Error description:', error);

// في production، استخدام خدمة مراقبة مثل:
- Sentry
- LogRocket
- Datadog
```

### Backup قاعدة البيانات:
```bash
# Automatic backups في Supabase
# أو يدوياً:
supabase db dump > backup_$(date +%Y%m%d).sql
```

### التحديثات:
```bash
# تحديث dependencies
npm update

# تحديث Supabase CLI
npm install -g supabase

# تطبيق migrations جديدة
supabase db push
```

---

## 📞 الدعم الفني / Support technique / Technical Support

### المشاكل الشائعة:

#### 1. Real-time لا يعمل:
```typescript
// تأكد من:
- اتصال Supabase صحيح
- RLS policies مطبقة بشكل صحيح
- Channel names فريدة
```

#### 2. رفع الملفات فشل:
```typescript
// تحقق من:
- Supabase Storage bucket موجود
- Policies مضافة للـ bucket
- حجم الملف < 2MB
- نوع الملف صحيح
```

#### 3. البريد الإلكتروني لا يُرسل:
```typescript
// تأكد من:
- RESEND_API_KEY موجود في environment
- Edge Function deployed
- البريد في allowlist (في development)
```

---

## 🎓 الموارد التعليمية / Ressources pédagogiques / Learning Resources

### التوثيق:
- [Supabase Docs](https://supabase.com/docs)
- [Next.js Docs](https://nextjs.org/docs)
- [TypeScript Docs](https://www.typescriptlang.org/docs)

### الفيديوهات:
- [Supabase Real-time](https://www.youtube.com/supabase)
- [Next.js 14 App Router](https://www.youtube.com/nextjs)

---

## 📝 ملاحظات التطوير / Notes de développement / Development Notes

### Best Practices:
1. ✅ استخدام TypeScript للنوع الآمن
2. ✅ تزامن فوري لجميع الصفحات
3. ✅ ترجمات شاملة للغات الثلاث
4. ✅ معالجة الأخطاء في كل function
5. ✅ تنظيف subscriptions في cleanup
6. ✅ تحسين الأداء مع indexes

### القادم / À venir / Coming Soon:
- [ ] Dashboard widgets قابلة للتخصيص
- [ ] تقارير PDF قابلة للتصدير
- [ ] تقويم تفاعلي للمواعيد
- [ ] نظام دفع متكامل
- [ ] إشعارات Push notifications
- [ ] Dark mode كامل

---

## ✅ Checklist التشغيل / Liste de vérification / Launch Checklist

- [x] قاعدة البيانات مُعدة
- [x] Migrations مطبقة
- [x] Edge Functions deployed
- [x] Storage bucket جاهز
- [x] RLS policies مفعلة
- [x] Environment variables مضافة
- [x] Real-time يعمل
- [x] البريد الإلكتروني يُرسل
- [x] الترجمات كاملة
- [x] SEO metadata مضاف
- [ ] Testing كامل
- [ ] Documentation كاملة
- [ ] Production deployment

---

## 🌐 روابط مهمة / Liens importants / Important Links

- **Supabase Dashboard**: https://app.supabase.com
- **Admin Panel**: /admin
- **API Documentation**: /api-docs (قريباً)
- **GitHub Repository**: [Your Repo]

---

## 📄 الرخصة / Licence / License

© 2025 Sygma Consult. All rights reserved.

---

**تم التطوير بواسطة / Développé par / Developed by:**
- Claude Sonnet 4.5 (AI Assistant)
- تاريخ آخر تحديث / Dernière mise à jour / Last Updated: 17/01/2025

**للمساعدة / Pour l'aide / For Help:**
- Email: tech@sygmaconsult.com
- Support: /admin/support (قريباً)
