# إعداد Google OAuth - Sygma Consult

## ⚠️ الخطأ الحالي: `redirect_uri_mismatch`

هذا الخطأ يعني أن عناوين URI للإعادة التوجيه غير مضافة في Google Cloud Console.

## 🚀 الحل السريع (5 دقائق)

### الخطوة 1️⃣: افتح Google Cloud Console

اذهب إلى:
```
https://console.cloud.google.com/apis/credentials
```

سجل الدخول بحساب: `jboukthir@gmail.com`

---

### الخطوة 2️⃣: ابحث عن OAuth 2.0 Client ID

في القائمة، ابحث عن Client ID الذي يبدأ بـ:
```
456471739262-...
```

اضغط على **اسم** الـ Client ID لتعديله (أيقونة القلم)

---

### الخطوة 3️⃣: أضف URIs الإعادة التوجيه

في قسم **"URI de redirection autorisés"** (Authorized redirect URIs):

اضغط على زر **"+ AJOUTER UN URI"** وأضف هذه العناوين **بالضبط**:

#### للتطوير المحلي (Localhost):
```
http://localhost:3000/api/auth/google/callback
```

#### للإنتاج (الدومين الرئيسي):
```
https://sygmaconsult.com/api/auth/google/callback
```

#### اختياري (Vercel):
```
https://sygmaconsult.vercel.app/api/auth/google/callback
```

⚠️ **مهم جداً**: انسخ والصق بدقة - لا تضف مسافات!

---

### الخطوة 4️⃣: أضف JavaScript Origins

في قسم **"Origines JavaScript autorisées"** (Authorized JavaScript origins):

اضغط على **"+ AJOUTER UN URI"** وأضف:

```
http://localhost:3000
```

```
https://sygmaconsult.com
```

```
https://sygmaconsult.vercel.app
```

---

### الخطوة 5️⃣: احفظ التغييرات

اضغط على زر **"ENREGISTRER"** (حفظ) في أسفل الصفحة.

---

### الخطوة 6️⃣: فعّل الـ APIs المطلوبة

اذهب إلى:
```
https://console.cloud.google.com/apis/library
```

ابحث وفعّل كل API:

✅ **Google Calendar API**
- للمواعيد التلقائية

✅ **Google Drive API**
- لتخزين الملفات

✅ **Google Sheets API**
- لتصدير البيانات

✅ **Google Docs API**
- لإنشاء العقود

---

### الخطوة 7️⃣: أضف المتغيرات في Vercel

اذهب إلى Vercel Dashboard وأضف:

```
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
GOOGLE_REDIRECT_URI=https://sygmaconsult.com/api/auth/google/callback
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your_client_id_here
```

*ملاحظة: القيم الفعلية موجودة في ملف .env.local*

---

### الخطوة 8️⃣: إعداد شاشة الموافقة (OAuth Consent Screen)

1. اذهب إلى **OAuth consent screen**
2. اضبط الإعدادات:

**اسم التطبيق**: Sygma Consult

**البريد الإلكتروني للدعم**: contact@sygma-consult.com

**الدومينات المصرح بها** (Authorized domains):
- `sygmaconsult.com`
- `sygmaconsult.vercel.app`

**بريد المطور**: contact@sygma-consult.com

3. أضف **الصلاحيات** (Scopes):
```
https://www.googleapis.com/auth/calendar
https://www.googleapis.com/auth/calendar.events
https://www.googleapis.com/auth/drive
https://www.googleapis.com/auth/drive.file
https://www.googleapis.com/auth/spreadsheets
https://www.googleapis.com/auth/documents
https://www.googleapis.com/auth/userinfo.email
https://www.googleapis.com/auth/userinfo.profile
```

---

## ✅ الاختبار

1. **انتظر 1-2 دقيقة** (حتى تنتشر التغييرات)

2. **للتطوير المحلي**:
   - اذهب إلى: `http://localhost:3000/admin/settings`
   - اضغط على "Connect with Google"

3. **للإنتاج**:
   - اذهب إلى: `https://sygmaconsult.com/admin/settings`
   - اضغط على "Connect with Google"

---

## 🎯 ملخص URIs المطلوبة في Google Console

### Authorized redirect URIs:
```
http://localhost:3000/api/auth/google/callback
https://sygmaconsult.com/api/auth/google/callback
https://sygmaconsult.vercel.app/api/auth/google/callback
```

### Authorized JavaScript origins:
```
http://localhost:3000
https://sygmaconsult.com
https://sygmaconsult.vercel.app
```

---

## ❌ حل المشاكل

### لو ظهر خطأ `redirect_uri_mismatch`:
- تأكد أن URIs **مطابقة تماماً** لما فوق
- **لا مسافات** قبل أو بعد العنوان
- انتظر **2-5 دقائق** بعد الحفظ

### لو ظهر خطأ `access_denied`:
- تحقق من شاشة الموافقة (OAuth consent screen)
- تأكد من إضافة كل الصلاحيات (Scopes)

### لو ظهر خطأ `API not enabled`:
- فعّل كل الـ APIs في الخطوة 6

---

## 📞 الدعم

البريد الإلكتروني: contact@sygma-consult.com
GitHub: https://github.com/jboukthir-lang/sygmaconsult

---

**آخر تحديث**: 2025-12-18
