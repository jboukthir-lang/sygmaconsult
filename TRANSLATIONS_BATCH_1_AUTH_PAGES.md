# المجموعة الأولى: ترجمات صفحات المصادقة
## Batch 1: Authentication Pages Translations

هذه الترجمات يجب إضافتها إلى ملف `web/lib/translations.ts` قبل قسم `company`.

---

## الترجمات المطلوبة:

```typescript
  // Login Page
  login: {
    title: {
      fr: 'Connexion',
      ar: 'تسجيل الدخول',
      en: 'Sign In',
    },
    subtitle: {
      fr: 'Accédez à votre espace client',
      ar: 'الوصول إلى حسابك',
      en: 'Access your account',
    },
    welcomeBack: {
      fr: 'Bon retour!',
      ar: 'مرحباً بعودتك!',
      en: 'Welcome back!',
    },
    enterCredentials: {
      fr: 'Entrez vos identifiants pour accéder à votre compte',
      ar: 'أدخل بياناتك للوصول إلى حسابك',
      en: 'Enter your credentials to access your account',
    },
    emailPlaceholder: {
      fr: 'votre@email.com',
      ar: 'your@email.com',
      en: 'your@email.com',
    },
    passwordPlaceholder: {
      fr: 'Votre mot de passe',
      ar: 'كلمة المرور',
      en: 'Your password',
    },
    rememberMe: {
      fr: 'Se souvenir de moi',
      ar: 'تذكرني',
      en: 'Remember me',
    },
    signingIn: {
      fr: 'Connexion en cours...',
      ar: 'جاري تسجيل الدخول...',
      en: 'Signing in...',
    },
    loginError: {
      fr: 'Email ou mot de passe incorrect',
      ar: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      en: 'Invalid email or password',
    },
    noAccount: {
      fr: 'Pas encore de compte?',
      ar: 'ليس لديك حساب؟',
      en: 'Don\'t have an account?',
    },
    signUpHere: {
      fr: 'Inscrivez-vous ici',
      ar: 'سجل هنا',
      en: 'Sign up here',
    },
  },

  // Signup Page
  signup: {
    title: {
      fr: 'Créer un compte',
      ar: 'إنشاء حساب',
      en: 'Create Account',
    },
    subtitle: {
      fr: 'Rejoignez Sygma Consult',
      ar: 'انضم إلى سيجما كونسلت',
      en: 'Join Sygma Consult',
    },
    getStarted: {
      fr: 'Commencez dès aujourd\'hui',
      ar: 'ابدأ اليوم',
      en: 'Get started today',
    },
    createAccountDesc: {
      fr: 'Créez votre compte pour accéder à nos services de conseil',
      ar: 'أنشئ حسابك للوصول إلى خدماتنا الاستشارية',
      en: 'Create your account to access our consulting services',
    },
    fullNamePlaceholder: {
      fr: 'Votre nom complet',
      ar: 'اسمك الكامل',
      en: 'Your full name',
    },
    emailPlaceholder: {
      fr: 'votre@email.com',
      ar: 'your@email.com',
      en: 'your@email.com',
    },
    passwordPlaceholder: {
      fr: 'Créer un mot de passe',
      ar: 'إنشاء كلمة مرور',
      en: 'Create a password',
    },
    confirmPasswordPlaceholder: {
      fr: 'Confirmer le mot de passe',
      ar: 'تأكيد كلمة المرور',
      en: 'Confirm password',
    },
    agreeToTerms: {
      fr: 'J\'accepte les',
      ar: 'أوافق على',
      en: 'I agree to the',
    },
    termsAndConditions: {
      fr: 'conditions d\'utilisation',
      ar: 'الشروط والأحكام',
      en: 'terms and conditions',
    },
    and: {
      fr: 'et la',
      ar: 'و',
      en: 'and',
    },
    privacyPolicy: {
      fr: 'politique de confidentialité',
      ar: 'سياسة الخصوصية',
      en: 'privacy policy',
    },
    creating: {
      fr: 'Création en cours...',
      ar: 'جاري الإنشاء...',
      en: 'Creating...',
    },
    signupError: {
      fr: 'Erreur lors de la création du compte',
      ar: 'خطأ في إنشاء الحساب',
      en: 'Error creating account',
    },
    passwordMismatch: {
      fr: 'Les mots de passe ne correspondent pas',
      ar: 'كلمات المرور غير متطابقة',
      en: 'Passwords do not match',
    },
    mustAgreeTerms: {
      fr: 'Vous devez accepter les conditions',
      ar: 'يجب الموافقة على الشروط',
      en: 'You must agree to the terms',
    },
    haveAccount: {
      fr: 'Vous avez déjà un compte?',
      ar: 'لديك حساب بالفعل؟',
      en: 'Already have an account?',
    },
    signInHere: {
      fr: 'Connectez-vous ici',
      ar: 'سجل الدخول هنا',
      en: 'Sign in here',
    },
  },

  // Reset Password Page
  resetPassword: {
    title: {
      fr: 'Réinitialiser le mot de passe',
      ar: 'إعادة تعيين كلمة المرور',
      en: 'Reset Password',
    },
    subtitle: {
      fr: 'Mot de passe oublié?',
      ar: 'نسيت كلمة المرور؟',
      en: 'Forgot Password?',
    },
    description: {
      fr: 'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe',
      ar: 'أدخل عنوان بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور',
      en: 'Enter your email address and we\'ll send you a link to reset your password',
    },
    emailPlaceholder: {
      fr: 'votre@email.com',
      ar: 'your@email.com',
      en: 'your@email.com',
    },
    sendResetLink: {
      fr: 'Envoyer le lien',
      ar: 'إرسال الرابط',
      en: 'Send Reset Link',
    },
    sending: {
      fr: 'Envoi en cours...',
      ar: 'جاري الإرسال...',
      en: 'Sending...',
    },
    emailSent: {
      fr: 'Email envoyé! Vérifiez votre boîte de réception.',
      ar: 'تم إرسال البريد! تحقق من صندوق الوارد.',
      en: 'Email sent! Check your inbox.',
    },
    sendError: {
      fr: 'Erreur lors de l\'envoi de l\'email',
      ar: 'خطأ في إرسال البريد',
      en: 'Error sending email',
    },
    backToLogin: {
      fr: 'Retour à la connexion',
      ar: 'العودة لتسجيل الدخول',
      en: 'Back to login',
    },
    rememberPassword: {
      fr: 'Vous vous souvenez de votre mot de passe?',
      ar: 'تذكرت كلمة المرور؟',
      en: 'Remember your password?',
    },
  },
```

---

## الموقع في الملف:

يجب إضافة هذه الأقسام الثلاثة في ملف `web/lib/translations.ts` **قبل** قسم `company` (السطر الذي يبدأ بـ `// Company info`).

---

## الصفحات المتأثرة:

1. ✅ `/app/login/page.tsx` - صفحة تسجيل الدخول
2. ✅ `/app/signup/page.tsx` - صفحة التسجيل
3. ✅ `/app/reset-password/page.tsx` - صفحة إعادة تعيين كلمة المرور

---

## الخطوة التالية:

بعد إضافة هذه الترجمات والـ commit، سننتقل إلى:
- **المجموعة الثانية:** صفحات Contact و About
- **المجموعة الثالثة:** صفحات Insights, Careers
- **المجموعة الرابعة:** صفحات Legal, Privacy, Terms
- **المجموعة الخامسة:** Footer وباقي المكونات

---

**الحالة:** ✅ جاهز للمراجعة والموافقة
**التاريخ:** 2025-01-18
