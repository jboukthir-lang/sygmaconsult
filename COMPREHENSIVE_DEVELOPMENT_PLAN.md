# خطة التطوير الشاملة لموقع Sygma Consult
## Comprehensive Development Plan

> **تاريخ الإعداد:** 19 ديسمبر 2024
> **الإصدار الحالي:** v1.2.0-final
> **الإصدار المستهدف:** v2.0.0

---

## 📋 جدول المحتويات

1. [تحليل الوضع الحالي](#1-تحليل-الوضع-الحالي)
2. [تطوير الصفحة الرئيسية](#2-تطوير-الصفحة-الرئيسية)
3. [تطوير لوحة الإدارة](#3-تطوير-لوحة-الإدارة)
4. [تطوير نظام الحجوزات](#4-تطوير-نظام-الحجوزات)
5. [تكامل نظام الدفع Stripe](#5-تكامل-نظام-الدفع-stripe)
6. [التحسينات الإضافية](#6-التحسينات-الإضافية)
7. [خطة التنفيذ](#7-خطة-التنفيذ)

---

## 1. تحليل الوضع الحالي

### ✅ الميزات المكتملة

#### أ. البنية التحتية
- ✅ Next.js 14 مع App Router
- ✅ TypeScript بنسبة 100%
- ✅ Tailwind CSS للتصميم
- ✅ Supabase للقاعدة البيانات
- ✅ Firebase Authentication
- ✅ Real-time Subscriptions
- ✅ دعم ثلاث لغات (EN/FR/AR)

#### ب. الميزات الوظيفية
- ✅ نظام حجز المواعيد
- ✅ تكامل Google Calendar + Meet
- ✅ لوحة إدارة متقدمة
- ✅ نظام المستخدمين والصلاحيات
- ✅ إدارة الاستشارات
- ✅ نظام الرسائل والإشعارات
- ✅ إدارة المنشورات (Blog)
- ✅ تحليلات وإحصائيات
- ✅ إدارة الوثائق

### ❌ الميزات الناقصة الحرجة

1. **نظام الدفع الإلكتروني** - الأولوية القصوى
2. **نظام الفواتير** - مهم جداً
3. **تذكيرات تلقائية** - مهم
4. **نظام التقييمات** - مهم
5. **Chat في الوقت الفعلي** - مستقبلي

---

## 2. تطوير الصفحة الرئيسية

### 🎯 الأهداف
- تحسين تجربة المستخدم (UX)
- زيادة معدل التحويل
- تحديث المحتوى ليكون أكثر جاذبية
- إضافة عناصر تفاعلية جديدة

### 📝 التحسينات المقترحة

#### أ. Hero Section (القسم البطل)
**الوضع الحالي:**
```tsx
// مكونات بسيطة:
- عنوان رئيسي
- وصف
- زرّان CTA
- صورة واحدة
```

**التحسينات:**
```tsx
// إضافة:
1. Slider متحرك للصور (3-5 صور)
2. إحصائيات متحركة (عدد العملاء، المشاريع المنجزة، سنوات الخبرة)
3. شعار "Trusted by" مع لوجو الشركاء
4. فيديو تعريفي (optional)
5. Trust badges (certifications)
6. Animation عند التحميل (Framer Motion)
```

**الكود المقترح:**
```tsx
// components/Hero.tsx - Enhanced Version
import { motion } from 'framer-motion';
import { useState, useEffect } from 'react';

export default function HeroEnhanced() {
  const [currentSlide, setCurrentSlide] = useState(0);
  const slides = [image1, image2, image3];

  // Auto-rotate slides
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % slides.length);
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <section className="relative overflow-hidden">
      {/* Animated Background */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 1 }}
      >
        {/* Image Slider */}
        <ImageSlider slides={slides} current={currentSlide} />

        {/* Content with Animation */}
        <motion.div
          initial={{ y: 50, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.3 }}
        >
          <h1 className="text-6xl font-bold">
            Your Experts in <span className="text-gold">Paris & Tunis</span>
          </h1>

          {/* Animated Stats */}
          <div className="grid grid-cols-3 gap-8 mt-12">
            <StatCounter end={500} label="Clients Served" />
            <StatCounter end={50} label="Projects Completed" />
            <StatCounter end={10} label="Years Experience" />
          </div>

          {/* Trust Badges */}
          <TrustBadges />

          {/* CTA Buttons */}
          <CTAButtons />
        </motion.div>
      </motion.div>
    </section>
  );
}
```

#### ب. Services Section
**التحسينات:**
```tsx
1. تصميم بطاقات أكثر جاذبية
2. Hover effects متقدمة
3. إضافة أيقونات مخصصة أفضل
4. عرض السعر الابتدائي
5. زر "Book Now" مباشر لكل خدمة
6. شهادات العملاء تحت كل خدمة
```

**الكود المقترح:**
```tsx
// components/Services.tsx - Enhanced
export default function ServicesEnhanced() {
  return (
    <section className="py-20">
      <div className="grid md:grid-cols-3 gap-8">
        {services.map((service, i) => (
          <motion.div
            key={service.id}
            initial={{ opacity: 0, y: 50 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
            viewport={{ once: true }}
            whileHover={{ y: -10, scale: 1.02 }}
            className="group relative overflow-hidden rounded-2xl bg-white shadow-lg"
          >
            {/* Gradient Overlay */}
            <div className="absolute inset-0 bg-gradient-to-br from-blue-500/10 to-gold/10 opacity-0 group-hover:opacity-100 transition-opacity" />

            {/* Icon with Animation */}
            <div className="p-8">
              <motion.div
                whileHover={{ rotate: 360 }}
                transition={{ duration: 0.5 }}
                className="w-16 h-16 mb-4"
              >
                <service.icon className="w-full h-full text-blue-600" />
              </motion.div>

              <h3 className="text-2xl font-bold mb-2">{service.title}</h3>
              <p className="text-gray-600 mb-4">{service.description}</p>

              {/* Price */}
              <div className="flex items-baseline gap-2 mb-4">
                <span className="text-sm text-gray-500">Starting at</span>
                <span className="text-3xl font-bold text-gold">€{service.price}</span>
              </div>

              {/* Testimonial */}
              <div className="bg-gray-50 p-4 rounded-lg mb-4">
                <p className="text-sm italic">"{service.testimonial}"</p>
                <p className="text-xs text-gray-500 mt-2">- {service.clientName}</p>
              </div>

              {/* CTA Button */}
              <Link
                href={`/book?service=${service.id}`}
                className="block w-full text-center px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                Book Now
              </Link>
            </div>
          </motion.div>
        ))}
      </div>
    </section>
  );
}
```

#### ج. أقسام جديدة مقترحة

**1. Why Choose Us Section**
```tsx
<section className="py-20 bg-gray-50">
  <h2 className="text-4xl font-bold text-center mb-12">Why Choose Sygma Consult?</h2>
  <div className="grid md:grid-cols-4 gap-8">
    <FeatureCard
      icon={Shield}
      title="Trusted Expertise"
      description="10+ years serving clients in France & Tunisia"
    />
    <FeatureCard
      icon={Clock}
      title="Fast Response"
      description="Average response time: 2 hours"
    />
    <FeatureCard
      icon={Users}
      title="Expert Team"
      description="20+ certified consultants"
    />
    <FeatureCard
      icon={Award}
      title="Proven Results"
      description="98% client satisfaction rate"
    />
  </div>
</section>
```

**2. Testimonials Section**
```tsx
<section className="py-20">
  <h2 className="text-4xl font-bold text-center mb-12">What Our Clients Say</h2>
  <TestimonialSlider testimonials={[
    {
      quote: "Sygma Consult helped us navigate complex French business laws...",
      author: "Jean Dupont",
      company: "TechStart Paris",
      rating: 5
    },
    // ... more testimonials
  ]} />
</section>
```

**3. Process Section**
```tsx
<section className="py-20 bg-blue-900 text-white">
  <h2 className="text-4xl font-bold text-center mb-12">How It Works</h2>
  <div className="grid md:grid-cols-4 gap-8">
    <ProcessStep number="1" title="Book Online" description="Choose a time that works for you" />
    <ProcessStep number="2" title="Meet Your Consultant" description="Video or in-person consultation" />
    <ProcessStep number="3" title="Get Expert Advice" description="Tailored solutions for your needs" />
    <ProcessStep number="4" title="Achieve Your Goals" description="Follow-up support included" />
  </div>
</section>
```

**4. FAQ Section**
```tsx
<section className="py-20">
  <h2 className="text-4xl font-bold text-center mb-12">Frequently Asked Questions</h2>
  <Accordion items={[
    { q: "How long is a typical consultation?", a: "Most consultations are 45-60 minutes..." },
    { q: "Do you offer online consultations?", a: "Yes, we offer both online and in-person..." },
    { q: "What languages do you speak?", a: "Our team speaks French, Arabic, and English..." },
    // ... more FAQs
  ]} />
</section>
```

**5. Call-to-Action Section**
```tsx
<section className="py-20 bg-gradient-to-r from-blue-600 to-blue-800 text-white">
  <div className="text-center">
    <h2 className="text-5xl font-bold mb-6">Ready to Get Started?</h2>
    <p className="text-xl mb-8">Book your free 15-minute consultation today</p>
    <div className="flex gap-4 justify-center">
      <Link href="/book" className="px-8 py-4 bg-gold text-white rounded-lg text-lg font-semibold hover:bg-gold-600">
        Book Now - It's Free!
      </Link>
      <Link href="/contact" className="px-8 py-4 bg-white text-blue-600 rounded-lg text-lg font-semibold hover:bg-gray-100">
        Contact Us
      </Link>
    </div>
  </div>
</section>
```

#### د. تحسينات الأداء والـ SEO

```tsx
// app/page.tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Sygma Consult | Expert Business Consulting in Paris & Tunis',
  description: 'Professional business, legal, and financial consulting services in France and Tunisia. Book your consultation today.',
  keywords: ['business consulting', 'legal advice', 'paris', 'tunis', 'france', 'tunisia'],
  openGraph: {
    title: 'Sygma Consult | Expert Business Consulting',
    description: 'Professional consulting services in Paris & Tunis',
    images: ['/og-image.jpg'],
  },
};

// إضافة Structured Data
const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'ProfessionalService',
  name: 'Sygma Consult',
  description: 'Business consulting services',
  address: [
    {
      '@type': 'PostalAddress',
      streetAddress: 'Paris Office Address',
      addressLocality: 'Paris',
      addressCountry: 'FR'
    },
    {
      '@type': 'PostalAddress',
      streetAddress: 'Tunis Office Address',
      addressLocality: 'Tunis',
      addressCountry: 'TN'
    }
  ],
  priceRange: '€€',
  telephone: '+33-XXX-XXX-XXX',
  email: 'contact@sygmaconsult.com'
};
```

---

## 3. تطوير لوحة الإدارة

### 🎯 التحسينات المقترحة

#### أ. Dashboard الرئيسية

**إضافة مخططات بيانية تفاعلية:**

```bash
npm install recharts
```

```tsx
// components/admin/RevenueChart.tsx
import { LineChart, Line, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export default function RevenueChart({ data }) {
  return (
    <div className="bg-white rounded-xl p-6 shadow-sm">
      <h3 className="text-lg font-semibold mb-4">Revenue Overview</h3>
      <ResponsiveContainer width="100%" height={300}>
        <AreaChart data={data}>
          <defs>
            <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#3B82F6" stopOpacity={0.8}/>
              <stop offset="95%" stopColor="#3B82F6" stopOpacity={0}/>
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="month" />
          <YAxis />
          <Tooltip />
          <Area type="monotone" dataKey="revenue" stroke="#3B82F6" fillOpacity={1} fill="url(#colorRevenue)" />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}
```

**إضافة KPIs متقدمة:**

```tsx
// components/admin/KPIDashboard.tsx
export default function KPIDashboard() {
  return (
    <div className="grid md:grid-cols-4 gap-6 mb-8">
      <KPICard
        title="Monthly Recurring Revenue"
        value="€12,450"
        change="+23.5%"
        trend="up"
        icon={TrendingUp}
      />
      <KPICard
        title="Average Booking Value"
        value="€145"
        change="+5.2%"
        trend="up"
        icon={DollarSign}
      />
      <KPICard
        title="Conversion Rate"
        value="64.2%"
        change="-2.1%"
        trend="down"
        icon={Target}
      />
      <KPICard
        title="Customer Lifetime Value"
        value="€890"
        change="+12.8%"
        trend="up"
        icon={Users}
      />
    </div>
  );
}
```

#### ب. صفحة الحجوزات المحسّنة

**إضافة Drag & Drop للتقويم:**

```bash
npm install react-big-calendar moment
```

```tsx
// app/admin/bookings/calendar-view/page.tsx
import { Calendar, momentLocalizer } from 'react-big-calendar';
import moment from 'moment';
import 'react-big-calendar/lib/css/react-big-calendar.css';

const localizer = momentLocalizer(moment);

export default function BookingsCalendarView() {
  const [events, setEvents] = useState([]);

  const handleEventDrop = async ({ event, start, end }) => {
    // Update booking time in database
    await supabase
      .from('bookings')
      .update({ date: start, time: start })
      .eq('id', event.id);

    // Refresh events
    fetchEvents();
  };

  return (
    <div className="h-screen p-6">
      <Calendar
        localizer={localizer}
        events={events}
        startAccessor="start"
        endAccessor="end"
        onEventDrop={handleEventDrop}
        draggableAccessor={() => true}
        resizable
        style={{ height: '100%' }}
      />
    </div>
  );
}
```

#### ج. تحسينات الاستشارات

**إضافة محرر نصوص غني:**

```bash
npm install react-quill
```

```tsx
// components/admin/ConsultationNotes.tsx
import dynamic from 'next/dynamic';
const ReactQuill = dynamic(() => import('react-quill'), { ssr: false });
import 'react-quill/dist/quill.snow.css';

export default function ConsultationNotes({ consultationId }) {
  const [notes, setNotes] = useState('');

  const handleSave = async () => {
    await supabase
      .from('consultations')
      .update({ notes })
      .eq('id', consultationId);
  };

  return (
    <div>
      <ReactQuill
        value={notes}
        onChange={setNotes}
        modules={{
          toolbar: [
            ['bold', 'italic', 'underline'],
            [{ 'list': 'ordered'}, { 'list': 'bullet' }],
            ['link', 'image'],
            ['clean']
          ]
        }}
      />
      <button onClick={handleSave} className="mt-4 px-4 py-2 bg-blue-600 text-white rounded">
        Save Notes
      </button>
    </div>
  );
}
```

---

## 4. تطوير نظام الحجوزات

### 🎯 التحسينات المقترحة

#### أ. منع الحجوزات المتزامنة

```tsx
// lib/booking-utils.ts
export async function checkAvailability(consultantId: string, date: string, time: string) {
  const { data: existingBookings, error } = await supabase
    .from('bookings')
    .select('*')
    .eq('consultant_id', consultantId)
    .eq('date', date)
    .eq('time', time)
    .in('status', ['pending', 'confirmed', 'in-progress']);

  if (error) throw error;

  return existingBookings.length === 0;
}

// استخدام في صفحة الحجز:
const handleBooking = async (formData) => {
  const isAvailable = await checkAvailability(
    formData.consultantId,
    formData.date,
    formData.time
  );

  if (!isAvailable) {
    toast.error('This time slot is no longer available. Please choose another time.');
    return;
  }

  // Continue with booking...
};
```

#### ب. نظام قائمة الانتظار

```sql
-- إضافة جدول جديد
CREATE TABLE waitlist (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT,
  consultation_type_id UUID REFERENCES consultation_types(id),
  preferred_dates DATE[],
  preferred_times TIME[],
  is_flexible BOOLEAN DEFAULT false,
  status VARCHAR(50) DEFAULT 'waiting',
  created_at TIMESTAMP DEFAULT NOW()
);
```

```tsx
// components/WaitlistForm.tsx
export default function WaitlistForm() {
  const handleSubmit = async (data) => {
    await supabase.from('waitlist').insert({
      user_id: user.uid,
      consultation_type_id: data.consultationType,
      preferred_dates: data.dates,
      preferred_times: data.times,
      is_flexible: data.flexible
    });

    toast.success('You\'ve been added to the waitlist. We\'ll notify you when a spot opens up.');
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Form fields */}
    </form>
  );
}
```

#### ج. تذكيرات تلقائية

```tsx
// lib/cron/send-reminders.ts
import { CronJob } from 'cron';

// تشغيل كل ساعة
const job = new CronJob('0 * * * *', async () => {
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);

  // جلب الحجوزات للغد
  const { data: upcomingBookings } = await supabase
    .from('bookings')
    .select('*')
    .eq('date', tomorrow.toISOString().split('T')[0])
    .eq('status', 'confirmed');

  // إرسال تذكير لكل حجز
  for (const booking of upcomingBookings) {
    await sendReminderEmail({
      to: booking.email,
      subject: 'Reminder: Your consultation tomorrow',
      booking: booking
    });

    // إرسال SMS (اختياري)
    if (booking.phone) {
      await sendReminderSMS(booking.phone, booking);
    }

    // إنشاء إشعار في التطبيق
    await supabase.from('notifications').insert({
      user_id: booking.user_id,
      title: 'Consultation Reminder',
      message: `Your consultation is tomorrow at ${booking.time}`,
      type: 'reminder',
      link: `/profile/bookings/${booking.id}`
    });
  }
});

job.start();
```

#### د. نظام التقييمات

```sql
-- جدول التقييمات
CREATE TABLE reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES bookings(id),
  user_id TEXT NOT NULL,
  consultant_id TEXT,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);
```

```tsx
// components/RatingModal.tsx
export default function RatingModal({ bookingId, onClose }) {
  const [rating, setRating] = useState(0);
  const [comment, setComment] = useState('');

  const handleSubmit = async () => {
    await supabase.from('reviews').insert({
      booking_id: bookingId,
      user_id: user.uid,
      rating,
      comment
    });

    await supabase
      .from('bookings')
      .update({ reviewed: true })
      .eq('id', bookingId);

    toast.success('Thank you for your feedback!');
    onClose();
  };

  return (
    <Modal onClose={onClose}>
      <h2 className="text-2xl font-bold mb-4">Rate Your Consultation</h2>

      {/* Star Rating */}
      <div className="flex gap-2 mb-4">
        {[1, 2, 3, 4, 5].map((star) => (
          <button
            key={star}
            onClick={() => setRating(star)}
            className={`text-3xl ${rating >= star ? 'text-yellow-400' : 'text-gray-300'}`}
          >
            ★
          </button>
        ))}
      </div>

      {/* Comment */}
      <textarea
        value={comment}
        onChange={(e) => setComment(e.target.value)}
        placeholder="Tell us about your experience..."
        className="w-full p-3 border rounded-lg mb-4"
        rows={4}
      />

      <button
        onClick={handleSubmit}
        className="w-full px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
      >
        Submit Review
      </button>
    </Modal>
  );
}
```

---

## 5. تكامل نظام الدفع Stripe

### 🎯 الخطوات التفصيلية

#### المرحلة 1: الإعداد والتهيئة

**أ. تثبيت Stripe:**

```bash
npm install stripe @stripe/stripe-js
```

**ب. إنشاء حساب Stripe:**
1. انتقل إلى https://dashboard.stripe.com/register
2. أكمل التسجيل
3. احصل على API Keys (Test Mode):
   - Publishable key: `pk_test_...`
   - Secret key: `sk_test_...`

**ج. إضافة المفاتيح إلى `.env.local`:**

```env
# Stripe Keys
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_secret_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Site URL
NEXT_PUBLIC_URL=http://localhost:3000
```

#### المرحلة 2: إنشاء API Routes

**أ. إنشاء Checkout Session:**

```tsx
// app/api/stripe/create-checkout/route.ts
import { NextRequest, NextResponse } from 'next/server';
import Stripe from 'stripe';
import { supabase } from '@/lib/supabase';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-11-20.acacia'
});

export async function POST(req: NextRequest) {
  try {
    const { bookingId } = await req.json();

    // جلب بيانات الحجز
    const { data: booking, error } = await supabase
      .from('bookings')
      .select('*, consultation_types(*)')
      .eq('id', bookingId)
      .single();

    if (error || !booking) {
      return NextResponse.json({ error: 'Booking not found' }, { status: 404 });
    }

    // إنشاء Checkout Session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'eur',
            product_data: {
              name: `Consultation: ${booking.topic}`,
              description: `${booking.duration} minutes consultation`,
              images: ['https://your-logo-url.com/logo.png']
            },
            unit_amount: Math.round(booking.price * 100) // Convert to cents
          },
          quantity: 1
        }
      ],
      mode: 'payment',
      success_url: `${process.env.NEXT_PUBLIC_URL}/booking/success?session_id={CHECKOUT_SESSION_ID}&booking_id=${bookingId}`,
      cancel_url: `${process.env.NEXT_PUBLIC_URL}/booking/cancel?booking_id=${bookingId}`,
      client_reference_id: bookingId,
      customer_email: booking.email,
      metadata: {
        booking_id: bookingId,
        user_id: booking.user_id,
        consultation_type: booking.specialization
      }
    });

    return NextResponse.json({ url: session.url });
  } catch (error: any) {
    console.error('Stripe checkout error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
```

**ب. معالجة Webhook:**

```tsx
// app/api/stripe/webhook/route.ts
import { NextRequest, NextResponse } from 'next/server';
import Stripe from 'stripe';
import { supabase } from '@/lib/supabase';
import { sendBookingConfirmation } from '@/lib/email';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-11-20.acacia'
});

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!;

export async function POST(req: NextRequest) {
  const body = await req.text();
  const signature = req.headers.get('stripe-signature')!;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (err: any) {
    console.error('Webhook signature verification failed:', err.message);
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }

  // معالجة الأحداث المختلفة
  switch (event.type) {
    case 'checkout.session.completed':
      const session = event.data.object as Stripe.Checkout.Session;
      await handleSuccessfulPayment(session);
      break;

    case 'payment_intent.succeeded':
      const paymentIntent = event.data.object as Stripe.PaymentIntent;
      console.log('Payment succeeded:', paymentIntent.id);
      break;

    case 'payment_intent.payment_failed':
      const failedPayment = event.data.object as Stripe.PaymentIntent;
      await handleFailedPayment(failedPayment);
      break;

    default:
      console.log(`Unhandled event type: ${event.type}`);
  }

  return NextResponse.json({ received: true });
}

async function handleSuccessfulPayment(session: Stripe.Checkout.Session) {
  const bookingId = session.client_reference_id || session.metadata?.booking_id;

  if (!bookingId) {
    console.error('No booking ID found in session');
    return;
  }

  // تحديث حالة الدفع في قاعدة البيانات
  const { data, error } = await supabase
    .from('bookings')
    .update({
      payment_status: 'paid',
      status: 'confirmed',
      stripe_payment_id: session.payment_intent as string,
      updated_at: new Date().toISOString()
    })
    .eq('id', bookingId)
    .select()
    .single();

  if (error) {
    console.error('Error updating booking:', error);
    return;
  }

  // إرسال تأكيد بالبريد الإلكتروني
  await sendBookingConfirmation(data);

  // إنشاء إشعار للمستخدم
  await supabase.from('notifications').insert({
    user_id: data.user_id,
    title: 'Payment Successful',
    message: `Your payment of €${data.price} has been processed. Your consultation is confirmed!`,
    type: 'success',
    link: `/profile/bookings/${bookingId}`
  });

  // إنشاء إشعار للإدارة
  await supabase.from('notifications').insert({
    title: 'New Paid Booking',
    message: `${data.name} has completed payment for ${data.topic}`,
    type: 'booking',
    link: `/admin/bookings/${bookingId}`
  });
}

async function handleFailedPayment(paymentIntent: Stripe.PaymentIntent) {
  const bookingId = paymentIntent.metadata.booking_id;

  await supabase
    .from('bookings')
    .update({
      payment_status: 'failed',
      updated_at: new Date().toISOString()
    })
    .eq('id', bookingId);

  // إنشاء إشعار للمستخدم
  await supabase.from('notifications').insert({
    user_id: paymentIntent.metadata.user_id,
    title: 'Payment Failed',
    message: 'Your payment could not be processed. Please try again.',
    type: 'error'
  });
}
```

#### المرحلة 3: تعديل صفحة الحجز

**أ. إضافة زر الدفع:**

```tsx
// components/BookingCalendar.tsx (تحديث)
import { loadStripe } from '@stripe/stripe-js';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!);

export default function BookingCalendar() {
  const [selectedConsultationType, setSelectedConsultationType] = useState(null);
  const [showPayment, setShowPayment] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();

    // إنشاء الحجز أولاً
    const { data: booking, error } = await supabase
      .from('bookings')
      .insert({
        // ... booking data
        payment_status: 'pending'
      })
      .select()
      .single();

    if (error) {
      toast.error('Failed to create booking');
      return;
    }

    // إذا كان السعر > 0، اذهب للدفع
    if (selectedConsultationType.price > 0) {
      await redirectToCheckout(booking.id);
    } else {
      // حجز مجاني
      toast.success('Booking created successfully!');
      router.push('/profile/bookings');
    }
  };

  const redirectToCheckout = async (bookingId: string) => {
    try {
      const response = await fetch('/api/stripe/create-checkout', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ bookingId })
      });

      const { url, error } = await response.json();

      if (error) {
        toast.error('Payment initialization failed');
        return;
      }

      // إعادة توجيه إلى Stripe Checkout
      window.location.href = url;
    } catch (error) {
      console.error('Checkout error:', error);
      toast.error('An error occurred. Please try again.');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* ... existing form fields */}

      {/* عرض السعر */}
      {selectedConsultationType && (
        <div className="bg-blue-50 p-4 rounded-lg mb-4">
          <div className="flex justify-between items-center">
            <span className="font-medium">Consultation Fee:</span>
            <span className="text-2xl font-bold text-blue-600">
              €{selectedConsultationType.price}
            </span>
          </div>
          <p className="text-sm text-gray-600 mt-2">
            {selectedConsultationType.duration} minutes session
          </p>
        </div>
      )}

      {/* زر الحجز */}
      <button
        type="submit"
        className="w-full px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-semibold"
      >
        {selectedConsultationType?.price > 0
          ? `Proceed to Payment (€${selectedConsultationType.price})`
          : 'Confirm Booking'}
      </button>
    </form>
  );
}
```

#### المرحلة 4: صفحات النجاح والإلغاء

**أ. صفحة النجاح:**

```tsx
// app/booking/success/page.tsx
'use client';

import { useEffect, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { CheckCircle, Calendar, Clock, MapPin, Video } from 'lucide-react';
import { supabase } from '@/lib/supabase';

export default function BookingSuccessPage() {
  const searchParams = useSearchParams();
  const sessionId = searchParams.get('session_id');
  const bookingId = searchParams.get('booking_id');

  const [booking, setBooking] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (bookingId) {
      fetchBooking();
    }
  }, [bookingId]);

  const fetchBooking = async () => {
    const { data, error } = await supabase
      .from('bookings')
      .select('*')
      .eq('id', bookingId)
      .single();

    if (!error && data) {
      setBooking(data);
    }
    setLoading(false);
  };

  if (loading) {
    return <div className="min-h-screen flex items-center justify-center">Loading...</div>;
  }

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="container mx-auto px-4 max-w-2xl">
        <div className="bg-white rounded-2xl shadow-lg p-8">
          {/* Success Icon */}
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-20 h-20 bg-green-100 rounded-full mb-4">
              <CheckCircle className="w-12 h-12 text-green-600" />
            </div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Payment Successful!</h1>
            <p className="text-gray-600">Your consultation has been confirmed</p>
          </div>

          {/* Booking Details */}
          {booking && (
            <div className="space-y-4 mb-8">
              <div className="flex items-center gap-3 p-4 bg-gray-50 rounded-lg">
                <Calendar className="w-5 h-5 text-blue-600" />
                <div>
                  <p className="text-sm text-gray-500">Date</p>
                  <p className="font-medium">{new Date(booking.date).toLocaleDateString()}</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-4 bg-gray-50 rounded-lg">
                <Clock className="w-5 h-5 text-blue-600" />
                <div>
                  <p className="text-sm text-gray-500">Time</p>
                  <p className="font-medium">{booking.time}</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-4 bg-gray-50 rounded-lg">
                {booking.is_online ? (
                  <Video className="w-5 h-5 text-blue-600" />
                ) : (
                  <MapPin className="w-5 h-5 text-blue-600" />
                )}
                <div>
                  <p className="text-sm text-gray-500">Meeting Type</p>
                  <p className="font-medium">
                    {booking.is_online ? 'Online (Video Call)' : 'In-Person'}
                  </p>
                </div>
              </div>

              {booking.meeting_link && (
                <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                  <p className="text-sm text-blue-800 mb-2">Meeting Link:</p>
                  <a
                    href={booking.meeting_link}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-600 hover:underline break-all"
                  >
                    {booking.meeting_link}
                  </a>
                </div>
              )}
            </div>
          )}

          {/* Next Steps */}
          <div className="bg-blue-50 p-6 rounded-lg mb-8">
            <h3 className="font-semibold text-blue-900 mb-3">What's Next?</h3>
            <ul className="space-y-2 text-sm text-blue-800">
              <li className="flex items-start">
                <span className="mr-2">✓</span>
                You'll receive a confirmation email with all the details
              </li>
              <li className="flex items-start">
                <span className="mr-2">✓</span>
                We'll send you a reminder 24 hours before your consultation
              </li>
              <li className="flex items-start">
                <span className="mr-2">✓</span>
                You can view and manage your booking in your profile
              </li>
            </ul>
          </div>

          {/* Action Buttons */}
          <div className="flex gap-4">
            <Link
              href="/profile/bookings"
              className="flex-1 px-6 py-3 bg-blue-600 text-white text-center rounded-lg hover:bg-blue-700 transition-colors font-semibold"
            >
              View My Bookings
            </Link>
            <Link
              href="/"
              className="flex-1 px-6 py-3 bg-gray-200 text-gray-800 text-center rounded-lg hover:bg-gray-300 transition-colors font-semibold"
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

**ب. صفحة الإلغاء:**

```tsx
// app/booking/cancel/page.tsx
'use client';

import Link from 'next/link';
import { XCircle } from 'lucide-react';

export default function BookingCancelPage() {
  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="container mx-auto px-4 max-w-2xl">
        <div className="bg-white rounded-2xl shadow-lg p-8 text-center">
          <div className="inline-flex items-center justify-center w-20 h-20 bg-red-100 rounded-full mb-4">
            <XCircle className="w-12 h-12 text-red-600" />
          </div>

          <h1 className="text-3xl font-bold text-gray-900 mb-2">Payment Cancelled</h1>
          <p className="text-gray-600 mb-8">
            Your payment was not completed. Your booking has not been confirmed.
          </p>

          <div className="flex gap-4">
            <Link
              href="/book"
              className="flex-1 px-6 py-3 bg-blue-600 text-white text-center rounded-lg hover:bg-blue-700 transition-colors font-semibold"
            >
              Try Again
            </Link>
            <Link
              href="/"
              className="flex-1 px-6 py-3 bg-gray-200 text-gray-800 text-center rounded-lg hover:bg-gray-300 transition-colors font-semibold"
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

#### المرحلة 5: نظام الفواتير

```tsx
// lib/invoice-generator.ts
import { jsPDF } from 'jspdf';

export async function generateInvoice(bookingId: string) {
  const { data: booking } = await supabase
    .from('bookings')
    .select('*')
    .eq('id', bookingId)
    .single();

  const doc = new jsPDF();

  // Header
  doc.setFontSize(20);
  doc.text('INVOICE', 105, 20, { align: 'center' });

  // Company Info
  doc.setFontSize(10);
  doc.text('Sygma Consult', 20, 40);
  doc.text('Paris, France', 20, 45);
  doc.text('contact@sygmaconsult.com', 20, 50);

  // Client Info
  doc.text('Bill To:', 20, 70);
  doc.text(booking.name, 20, 75);
  doc.text(booking.email, 20, 80);

  // Invoice Details
  doc.text(`Invoice #: INV-${bookingId.slice(0, 8)}`, 120, 70);
  doc.text(`Date: ${new Date().toLocaleDateString()}`, 120, 75);
  doc.text(`Status: ${booking.payment_status}`, 120, 80);

  // Line Items
  doc.text('Description', 20, 100);
  doc.text('Amount', 170, 100);
  doc.line(20, 102, 190, 102);

  doc.text(`${booking.topic} - ${booking.duration} minutes`, 20, 110);
  doc.text(`€${booking.price.toFixed(2)}`, 170, 110);

  // Total
  doc.setFontSize(12);
  doc.text('Total:', 140, 130);
  doc.text(`€${booking.price.toFixed(2)}`, 170, 130);

  return doc.output('blob');
}

// استخدام:
const invoiceBlob = await generateInvoice(bookingId);
const invoiceUrl = URL.createObjectURL(invoiceBlob);
// تحميل أو إرسال بالبريد
```

#### المرحلة 6: إعداد Webhook في Stripe Dashboard

1. اذهب إلى https://dashboard.stripe.com/webhooks
2. اضغط "Add endpoint"
3. أدخل URL: `https://your-domain.com/api/stripe/webhook`
4. اختر الأحداث:
   - `checkout.session.completed`
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
5. احفظ `Signing secret`

---

## 6. التحسينات الإضافية

### أ. نظام Chat في الوقت الفعلي

```bash
npm install pusher pusher-js
```

```tsx
// lib/pusher.ts
import Pusher from 'pusher';
import PusherClient from 'pusher-js';

export const pusherServer = new Pusher({
  appId: process.env.PUSHER_APP_ID!,
  key: process.env.NEXT_PUBLIC_PUSHER_KEY!,
  secret: process.env.PUSHER_SECRET!,
  cluster: process.env.NEXT_PUBLIC_PUSHER_CLUSTER!,
  useTLS: true
});

export const pusherClient = new PusherClient(
  process.env.NEXT_PUBLIC_PUSHER_KEY!,
  { cluster: process.env.NEXT_PUBLIC_PUSHER_CLUSTER! }
);
```

### ب. Two-Factor Authentication

```bash
npm install speakeasy qrcode
```

### ج. Advanced Analytics

```bash
npm install recharts date-fns
```

### د. Export Reports

```bash
npm install xlsx jspdf
```

---

## 7. خطة التنفيذ

### المرحلة 1: الأساسيات (أسبوع 1)
- [x] ✅ تحليل شامل للموقع
- [ ] 🔄 تطوير الصفحة الرئيسية
- [ ] 🔄 تحسين Hero Section
- [ ] 🔄 إضافة أقسام جديدة

### المرحلة 2: تكامل Stripe (أسبوع 2)
- [ ] 🔄 إعداد Stripe
- [ ] 🔄 إنشاء API Routes
- [ ] 🔄 تعديل صفحة الحجز
- [ ] 🔄 إضافة صفحات Success/Cancel
- [ ] 🔄 نظام الفواتير

### المرحلة 3: تحسينات الحجوزات (أسبوع 3)
- [ ] 🔄 منع الحجوزات المتزامنة
- [ ] 🔄 نظام قائمة الانتظار
- [ ] 🔄 تذكيرات تلقائية
- [ ] 🔄 نظام التقييمات

### المرحلة 4: لوحة الإدارة (أسبوع 4)
- [ ] 🔄 مخططات بيانية تفاعلية
- [ ] 🔄 KPIs متقدمة
- [ ] 🔄 Calendar Drag & Drop
- [ ] 🔄 محرر نصوص غني

### المرحلة 5: الاختبار والنشر (أسبوع 5)
- [ ] 🔄 اختبار شامل
- [ ] 🔄 إصلاح الأخطاء
- [ ] 🔄 تحسين الأداء
- [ ] 🔄 نشر الإنتاج

---

## 📊 المقاييس المستهدفة

| المقياس | الحالي | المستهدف |
|---------|--------|----------|
| معدل التحويل | 64% | 75% |
| متوسط قيمة الحجز | €120 | €150 |
| رضا العملاء | 95% | 98% |
| وقت الاستجابة | 4 ساعات | 2 ساعات |
| معدل الإلغاء | 8% | 5% |

---

## 🎯 الأولويات

### عالية جداً (High Priority)
1. ✅ تكامل Stripe
2. ✅ نظام الفواتير
3. ✅ تحسين الصفحة الرئيسية

### عالية (Medium-High)
4. ⚠️ نظام التذكيرات
5. ⚠️ منع الحجوزات المتزامنة
6. ⚠️ نظام التقييمات

### متوسطة (Medium)
7. 📅 مخططات بيانية
8. 📅 تحسينات UX
9. 📅 قائمة الانتظار

### منخفضة (Low Priority)
10. 💡 Chat في الوقت الفعلي
11. 💡 2FA
12. 💡 تكامل WhatsApp

---

## 💰 التكلفة المقدرة

### خدمات خارجية شهرية:
- Stripe: 2.9% + €0.30 per transaction
- Vercel Pro: €20/month
- Supabase Pro: €25/month
- Email Service (SendGrid): €15/month
- **الإجمالي:** ~€60/month + transaction fees

### تطوير:
- تكلفة الوقت: 4-5 أسابيع
- الأدوات الجديدة: معظمها مجاني/open source

---

## 📝 ملاحظات نهائية

هذه الخطة قابلة للتعديل بناءً على:
1. الأولويات الفعلية للعمل
2. الميزانية المتاحة
3. الوقت المتاح للتطوير
4. ردود فعل المستخدمين

**يُوصى بالبدء بتكامل Stripe كأولوية قصوى لأنه سيفتح باب الإيرادات المباشرة.**

---

**آخر تحديث:** 19 ديسمبر 2024
**الإصدار:** 1.0
**المطور:** Claude (Anthropic)
