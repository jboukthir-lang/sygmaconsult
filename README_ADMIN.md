# 🔐 دليل تسجيل الدخول للأدمن - Sygma Consult

## ✅ حالة النظام

✅ السيرفر يعمل: **http://localhost:3000**
✅ جدول admin_users موجود في Supabase
✅ يوجد حساب admin تجريبي واحد (يحتاج تحديث)

---

## 📋 الوضع الحالي

يوجد حساب admin تجريبي في قاعدة البيانات:
- **البريد**: `your-email@example.com`
- **User ID**: `YOUR_FIREBASE_UID`
- **الصلاحية**: `super_admin`

⚠️ **هذا حساب تجريبي** - يجب إنشاء حساب حقيقي

---

## 🚀 خطوات إنشاء حساب Admin جديد

### الخطوة 1: إنشاء حساب في Firebase

1. افتح المتصفح واذهب إلى:
   ```
   http://localhost:3000/signup
   ```

2. أدخل البيانات التالية:
   ```
   الاسم الكامل: Sygma Admin
   البريد الإلكتروني: admin@sygma-consult.com
   كلمة المرور: Admin@2025!
   تأكيد كلمة المرور: Admin@2025!
   ```
   ✅ وافق على الشروط والأحكام

3. اضغط "Create Account"

4. بعد التسجيل، ستذهب إلى صفحة Profile تلقائياً

---

### الخطوة 2: الحصول على Firebase User ID

**الطريقة 1: من Console المتصفح**
1. اضغط `F12` لفتح Developer Tools
2. اذهب إلى تبويب **Console**
3. اكتب الأمر التالي واضغط Enter:
   ```javascript
   localStorage.getItem('authUser')
   ```
4. سيظهر User ID (uid)، انسخه

**الطريقة 2: من Firebase Console**
1. اذهب إلى Firebase Console
2. اختر مشروعك
3. اذهب إلى **Authentication** → **Users**
4. انسخ UID للمستخدم الجديد

---

### الخطوة 3: إضافة المستخدم إلى admin_users

1. افتح Supabase Dashboard:
   ```
   https://ldbsacdpkinbpcguvgai.supabase.co
   ```

2. اذهب إلى **SQL Editor**

3. الصق هذا الكود (بعد استبدال `YOUR_FIREBASE_UID`):
   ```sql
   -- استبدل YOUR_FIREBASE_UID بالـ UID الذي نسخته
   INSERT INTO admin_users (user_id, email, role, permissions)
   VALUES (
     'YOUR_FIREBASE_UID',
     'admin@sygma-consult.com',
     'super_admin',
     '{"all": true}'::jsonb
   )
   ON CONFLICT (user_id)
   DO UPDATE SET
     email = EXCLUDED.email,
     role = EXCLUDED.role,
     permissions = EXCLUDED.permissions,
     updated_at = NOW();
   ```

4. اضغط **Run** أو `Ctrl + Enter`

5. يجب أن تظهر رسالة نجاح

---

### الخطوة 4: تسجيل الدخول

1. اذهب إلى:
   ```
   http://localhost:3000/login
   ```

2. أدخل البيانات:
   ```
   البريد الإلكتروني: admin@sygma-consult.com
   كلمة المرور: Admin@2025!
   ```

3. اضغط **Sign In**

4. سيتم توجيهك تلقائياً إلى:
   ```
   http://localhost:3000/admin
   ```

✅ **الآن أنت في لوحة التحكم!**

---

## 🎯 صفحات Admin المتاحة

بعد تسجيل الدخول، ستتمكن من الوصول إلى:

### 📊 Dashboard
```
http://localhost:3000/admin
```
- إحصائيات عامة
- الحجوزات الأخيرة
- الرسائل الجديدة
- عدد المستخدمين

### 💼 Consultations
```
http://localhost:3000/admin/consultations
```
- إدارة جميع الاستشارات
- إحصائيات (الإجمالي، المجدولة، قيد التنفيذ، المكتملة، الإيرادات)
- بحث وتصفية
- عرض/تعديل/حذف الاستشارات

### 📅 Bookings
```
http://localhost:3000/admin/bookings
```
- إدارة الحجوزات
- تأكيد/إلغاء الحجوزات

### 💬 Messages
```
http://localhost:3000/admin/contacts
```
- عرض جميع رسائل التواصل
- الرد على الرسائل

### 👥 Users
```
http://localhost:3000/admin/users
```
- إدارة المستخدمين المسجلين

### 📈 Analytics
```
http://localhost:3000/admin/analytics
```
- تحليلات وإحصائيات متقدمة

---

## 🔍 التحقق من حساب Admin

للتحقق من جميع حسابات Admin الموجودة:

```bash
cd web
node scripts/check-admin.mjs
```

سيعرض:
- عدد حسابات Admin
- بيانات كل حساب (Email, User ID, Role, Permissions)
- تعليمات تسجيل الدخول

---

## 🛠️ استكشاف الأخطاء

### ❌ مشكلة: "Access Denied" بعد تسجيل الدخول

**السبب**: User ID غير موجود في جدول admin_users

**الحل**:
1. تأكد من إضافة User ID الصحيح في جدول admin_users
2. تحقق باستخدام هذا SQL في Supabase:
   ```sql
   SELECT * FROM admin_users WHERE email = 'admin@sygma-consult.com';
   ```
3. تأكد من أن `user_id` يطابق Firebase UID

---

### ❌ مشكلة: "Invalid email or password"

**الأسباب المحتملة**:
- البريد الإلكتروني خاطئ
- كلمة المرور خاطئة
- الحساب غير موجود في Firebase

**الحل**:
1. تأكد من البريد وكلمة المرور
2. جرب إعادة تعيين كلمة المرور:
   ```
   http://localhost:3000/reset-password
   ```
3. تحقق من Firebase Console → Authentication → Users

---

### ❌ مشكلة: السيرفر لا يعمل

**الحل**:
```bash
cd "c:\Users\utilisateur\Desktop\sygma consult\web"
npm run dev
```

السيرفر يجب أن يعمل على: **http://localhost:3000**

---

### ❌ مشكلة: جدول admin_users غير موجود

**الحل**: نفذ هذا SQL في Supabase SQL Editor:

```sql
-- إنشاء جدول admin_users
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'admin',
  permissions JSONB DEFAULT '{"read": true, "write": true}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- تفعيل Row Level Security
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- السماح للجميع بالقراءة (للتحقق من صلاحيات Admin)
CREATE POLICY "Anyone can read admin_users"
  ON admin_users FOR SELECT
  USING (true);

-- إنشاء Indexes للأداء
CREATE INDEX IF NOT EXISTS idx_admin_users_user_id ON admin_users(user_id);
CREATE INDEX IF NOT EXISTS idx_admin_users_email ON admin_users(email);
```

---

## 📞 معلومات إضافية

### روابط مهمة:
- **الموقع**: http://localhost:3000
- **Admin Login**: http://localhost:3000/login
- **Sign Up**: http://localhost:3000/signup
- **Reset Password**: http://localhost:3000/reset-password
- **Supabase Dashboard**: https://ldbsacdpkinbpcguvgai.supabase.co

### ملفات مهمة:
- **Admin Layout**: `web/app/admin/layout.tsx` - يتحقق من صلاحيات Admin
- **AuthContext**: `web/context/AuthContext.tsx` - إدارة المصادقة
- **Supabase Config**: `web/lib/supabase.ts` - إعدادات Supabase

### أدوات مساعدة:
- **check-admin.mjs**: فحص حسابات Admin الموجودة
  ```bash
  node scripts/check-admin.mjs
  ```

---

## ⚙️ الصلاحيات (Roles)

### `super_admin` (موصى به للمدير الرئيسي):
- ✅ كل الصلاحيات
- ✅ الوصول لجميع الصفحات
- ✅ حذف وتعديل البيانات
- ✅ إدارة المستخدمين الآخرين

### `admin` (للموظفين):
- ✅ القراءة والكتابة
- ❌ لا يمكن حذف المستخدمين
- ✅ يمكن إدارة الحجوزات والاستشارات

### `viewer` (للمراقبة فقط):
- ✅ القراءة فقط
- ❌ لا يمكن التعديل أو الحذف

---

## 🎉 مثال كامل للخطوات

```
1. افتح: http://localhost:3000/signup
2. سجل بـ:
   - الاسم: Sygma Admin
   - البريد: admin@sygma-consult.com
   - كلمة المرور: Admin@2025!

3. اضغط F12 → Console → اكتب:
   localStorage.getItem('authUser')

4. انسخ UID (مثلاً: k4sN2pQm7LXe9R1...)

5. افتح Supabase SQL Editor ونفذ:
   INSERT INTO admin_users (user_id, email, role, permissions)
   VALUES ('k4sN2pQm7LXe9R1...', 'admin@sygma-consult.com', 'super_admin', '{"all": true}'::jsonb);

6. افتح: http://localhost:3000/login
   - البريد: admin@sygma-consult.com
   - كلمة المرور: Admin@2025!

7. ✅ أنت الآن في لوحة التحكم!
```

---

**تاريخ الإنشاء**: 2025-12-17
**آخر تحديث**: 2025-12-17
**الإصدار**: 1.0

للأسئلة أو الدعم، راجع الكود في:
- `web/app/admin/layout.tsx`
- `web/context/AuthContext.tsx`
