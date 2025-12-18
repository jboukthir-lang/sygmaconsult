# 🚀 دليل البدء السريع / Guide de démarrage rapide / Quick Start Guide

## Sygma Consult Admin Panel

---

## 📦 التثبيت السريع / Installation rapide / Quick Install

### 1. تثبيت Dependencies:

```bash
cd web
npm install
```

### 2. إعداد قاعدة البيانات:

```bash
# Option A: استخدام Supabase CLI
supabase db push

# Option B: نسخ ولصق SQL يدوياً
# افتح: supabase/migrations/20250117_update_bookings.sql
# الصق في: Supabase Dashboard > SQL Editor
```

### 3. إعداد المتغيرات:

```bash
# إنشاء .env.local
cp .env.example .env.local

# تعديل القيم:
NEXT_PUBLIC_SUPABASE_URL=your_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key
RESEND_API_KEY=your_resend_key
```

### 4. تشغيل التطبيق:

```bash
npm run dev
```

الوصول للأدمن: `http://localhost:3000/admin`

---

## 🔑 إنشاء أول مستخدم أدمن / Créer premier admin / Create First Admin

### الطريقة 1: SQL مباشر

```sql
-- في Supabase SQL Editor
INSERT INTO admin_users (user_id, email, role, permissions)
VALUES (
  'YOUR_USER_ID',  -- من auth.users
  'admin@example.com',
  'super_admin',
  '{"all": true}'::jsonb
);
```

### الطريقة 2: باستخدام Script

```bash
# في مجلد web
node scripts/create-admin.js YOUR_USER_ID admin@example.com
```

---

## 📧 إعداد البريد الإلكتروني / Configuration email / Email Setup

### 1. إنشاء حساب Resend:
- زيارة: https://resend.com
- إنشاء حساب مجاني
- الحصول على API Key

### 2. Deploy Edge Function:

```bash
# تسجيل الدخول لـ Supabase
supabase login

# Deploy function
supabase functions deploy send-booking-email

# إضافة API Key
# Dashboard > Edge Functions > Secrets
RESEND_API_KEY=re_xxxxx
```

### 3. اختبار الإرسال:

```typescript
// في console المتصفح
const { data, error } = await supabase.functions.invoke('send-booking-email', {
  body: { bookingId: 'test-id' }
});
console.log(data, error);
```

---

## 🖼️ إعداد رفع الملفات / Configuration upload / File Upload Setup

### 1. إنشاء Storage Bucket:

```sql
-- في SQL Editor
INSERT INTO storage.buckets (id, name, public)
VALUES ('public', 'public', true);
```

### 2. إضافة Policies:

```sql
-- القراءة للجميع
CREATE POLICY "Allow public read"
ON storage.objects FOR SELECT
USING (bucket_id = 'public');

-- الكتابة للأدمن فقط
CREATE POLICY "Allow admin upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'public' AND
  EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid())
);
```

### 3. اختبار الرفع:
- انتقل إلى: `/admin/settings`
- رفع لوجو أو صورة
- تحقق من النجاح

---

## 🌐 تفعيل Real-time / Activer temps réel / Enable Real-time

### في Supabase Dashboard:

1. **Database > Replication**
2. تفعيل Replication للجداول:
   - ✅ `bookings`
   - ✅ `contacts`
   - ✅ `user_profiles`
   - ✅ `admin_users`
   - ✅ `documents`
   - ✅ `notifications`

### اختبار التزامن:

```typescript
// افتح صفحتي admin في تبويبين
// في التبويب 1: أضف حجز جديد
// في التبويب 2: يجب أن يظهر تلقائياً!
```

---

## 🎨 تخصيص الألوان / Personnaliser couleurs / Customize Colors

### في `tailwind.config.ts`:

```typescript
theme: {
  extend: {
    colors: {
      primary: '#001F3F',    // غيّر هنا / Change here
      secondary: '#D4AF37',
      accent: '#003366',
    }
  }
}
```

---

## 🌍 إضافة لغة جديدة / Ajouter langue / Add New Language

### 1. تحديث Type:

```typescript
// lib/translations.ts
export type Language = 'fr' | 'ar' | 'en' | 'es';  // إضافة 'es'
```

### 2. إضافة الترجمات:

```typescript
common: {
  welcome: {
    fr: 'Bienvenue',
    ar: 'مرحباً',
    en: 'Welcome',
    es: 'Bienvenido',  // جديد
  },
  // ... باقي الترجمات
}
```

### 3. تحديث Language Context:

```typescript
// context/LanguageContext.tsx
type Language = 'en' | 'fr' | 'ar' | 'es';
```

---

## 🔍 تصحيح الأخطاء / Débogage / Debugging

### مشاكل شائعة:

#### ❌ "Cannot find module..."
```bash
# حل: إعادة تثبيت
rm -rf node_modules package-lock.json
npm install
```

#### ❌ "Supabase connection failed"
```typescript
// تحقق من .env.local
console.log(process.env.NEXT_PUBLIC_SUPABASE_URL);

// تأكد من صحة الـ URL
```

#### ❌ "Admin access denied"
```sql
-- تحقق من وجود المستخدم في admin_users
SELECT * FROM admin_users WHERE email = 'your@email.com';
```

#### ❌ "Real-time not working"
```typescript
// افتح DevTools > Network
// ابحث عن WebSocket connection
// يجب أن ترى: wss://...supabase.co/realtime/v1
```

---

## 📱 اختبار على الموبايل / Test mobile / Mobile Testing

```bash
# معرفة IP المحلي
# Windows:
ipconfig

# Mac/Linux:
ifconfig

# الوصول من الموبايل:
http://192.168.x.x:3000/admin
```

---

## 🚀 النشر Production / Déploiement / Production Deployment

### Vercel (موصى به):

```bash
# 1. تثبيت Vercel CLI
npm i -g vercel

# 2. تسجيل الدخول
vercel login

# 3. Deploy
cd web
vercel

# 4. إضافة Environment Variables
# في Vercel Dashboard > Settings > Environment Variables
```

### Netlify:

```bash
# 1. تثبيت CLI
npm i -g netlify-cli

# 2. Login
netlify login

# 3. Deploy
cd web
netlify deploy --prod
```

---

## 🔒 الأمان / Sécurité / Security Checklist

قبل Production:

- [ ] تغيير `SUPABASE_SERVICE_ROLE_KEY` (لا تشارك!)
- [ ] تفعيل RLS على جميع الجداول
- [ ] تحديث Allowed Origins في Supabase
- [ ] إضافة Rate Limiting
- [ ] تفعيل HTTPS
- [ ] مراجعة Policies
- [ ] إزالة console.log في production

---

## 📊 المراقبة / Surveillance / Monitoring

### إضافة Sentry (اختياري):

```bash
npm install @sentry/nextjs

# إعداد
npx @sentry/wizard -i nextjs
```

### Supabase Logs:

```bash
# عرض logs Edge Functions
supabase functions logs send-booking-email
```

---

## 🆘 الحصول على المساعدة / Obtenir aide / Get Help

### الموارد:

1. **التوثيق الكامل**: `ADMIN_SYSTEM_DOCUMENTATION.md`
2. **Supabase Docs**: https://supabase.com/docs
3. **Next.js Docs**: https://nextjs.org/docs
4. **Community Discord**: https://discord.gg/supabase

### الإبلاغ عن Bug:

```markdown
## Bug Report Template

**الوصف / Description:**
[وصف المشكلة]

**الخطوات / Steps to reproduce:**
1. انتقل إلى...
2. انقر على...
3. لاحظ الخطأ...

**المتوقع / Expected:**
[ما كان يجب أن يحدث]

**الفعلي / Actual:**
[ما حدث بالفعل]

**Screenshots:**
[إرفاق صور إن أمكن]

**البيئة / Environment:**
- OS: [Windows/Mac/Linux]
- Browser: [Chrome/Firefox/Safari]
- Node Version: [16.x/18.x/20.x]
```

---

## ✅ Checklist البدء / Liste de départ / Launch Checklist

قبل الاستخدام:

- [ ] `npm install` نجح
- [ ] قاعدة البيانات جاهزة
- [ ] أول مستخدم أدمن تم إنشاؤه
- [ ] `.env.local` مُعد بشكل صحيح
- [ ] Storage bucket جاهز
- [ ] Edge Function deployed
- [ ] Real-time مفعّل
- [ ] اختبار رفع الملفات
- [ ] اختبار إرسال البريد
- [ ] اختبار التزامن الفوري

---

## 🎓 نصائح للمطورين / Conseils dev / Developer Tips

### 1. استخدام VS Code Extensions:
- **ES7+ React/Redux/React-Native snippets**
- **Tailwind CSS IntelliSense**
- **Prettier - Code formatter**
- **ESLint**

### 2. Hot Keys مفيدة:
- `Ctrl/Cmd + P`: فتح ملف سريع
- `Ctrl/Cmd + Shift + F`: بحث في المشروع
- `Ctrl/Cmd + D`: تحديد التالي
- `Alt + Up/Down`: نقل السطر

### 3. البنية الموصى بها:
```
web/
├── app/
│   ├── admin/          # صفحات الأدمن
│   ├── profile/        # صفحات المستخدم
│   └── (public)/       # صفحات عامة
├── components/
│   ├── admin/          # مكونات الأدمن
│   └── ui/             # مكونات UI عامة
├── lib/
│   ├── supabase.ts     # Supabase client
│   └── translations.ts # الترجمات
└── context/
    └── LanguageContext.tsx
```

---

## 🎉 أنت جاهز! / Vous êtes prêt! / You're Ready!

الآن يمكنك:
- ✅ تسجيل الدخول إلى `/admin`
- ✅ إدارة الحجوزات
- ✅ إرسال الإشعارات
- ✅ رفع الملفات والصور
- ✅ عرض الإحصائيات
- ✅ تغيير اللغة

**استمتع بالتطوير! 🚀**

---

**آخر تحديث / Dernière mise à jour / Last Updated:** 17/01/2025
