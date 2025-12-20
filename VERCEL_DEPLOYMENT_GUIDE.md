# 🚀 Vercel Deployment Guide - Sygma Consult

## ✅ Current Status

### What's Working:
- ✅ **Supabase Connection**: Fully operational
- ✅ **Services Table**: Created with 8 services (multilingual support)
- ✅ **Bookings Table**: Properly configured
- ✅ **Build Process**: Fixed to handle missing Stripe keys gracefully
- ✅ **Admin Panel**: All features working
- ✅ **Database Migrations**: Applied successfully

### What Needs Configuration on Vercel:

## 🔧 Required Environment Variables

To enable full functionality, add these environment variables in Vercel:

### 1. Supabase (REQUIRED - Already Working)
```
NEXT_PUBLIC_SUPABASE_URL=https://ldbsacdpkinbpcguvgai.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxkYnNhY2Rwa2luYnBjZ3V2Z2FpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4OTUwNzgsImV4cCI6MjA4MTQ3MTA3OH0.Qib8uCPcd6CJypKa_oNEDThIQNfTluH2eJE0nsewwug
```

### 2. Stripe Payment (REQUIRED for Paid Consultations)
```
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=<your_stripe_publishable_key>
STRIPE_SECRET_KEY=<your_stripe_secret_key>
STRIPE_WEBHOOK_SECRET=<your_stripe_webhook_secret>
```
**Note**: Get these values from your `.env.local` file or Stripe Dashboard

### 3. Email Service (REQUIRED for Notifications)
```
SMTP_HOST=<your_smtp_host>
SMTP_PORT=465
SMTP_USER=<your_smtp_user>
SMTP_PASSWORD=<your_smtp_password>
ADMIN_EMAIL=<your_admin_email>
```
**Note**: Get these values from your `.env.local` file or email provider

### 4. Google APIs (OPTIONAL - for Calendar Integration)
```
GOOGLE_CLIENT_ID=<your_google_client_id>
GOOGLE_CLIENT_SECRET=<your_google_client_secret>
GOOGLE_REDIRECT_URI=https://sygmaconsult.com/api/auth/google/callback
NEXT_PUBLIC_GOOGLE_CLIENT_ID=<your_google_client_id>
```
**Note**: Get these values from your `.env.local` file or Google Cloud Console

### 5. Groq AI (OPTIONAL - for Chat Feature)
```
GROQ_API_KEY=<your_groq_api_key>
```
**Note**: Get this value from your `.env.local` file or Groq Console

### 6. Site Configuration
```
NEXT_PUBLIC_URL=https://sygmaconsult.com
```

## 📝 How to Add Environment Variables in Vercel

1. Go to your project on Vercel Dashboard
2. Navigate to **Settings** → **Environment Variables**
3. Add each variable:
   - **Key**: Variable name (e.g., `STRIPE_SECRET_KEY`)
   - **Value**: The actual value
   - **Environment**: Select all (Production, Preview, Development)
4. Click **Save**
5. **Redeploy** your application for changes to take effect

## 🔍 Current Issue: "Failed to create checkout session"

### Root Cause:
The error occurs when a user tries to book a **paid consultation** but Stripe environment variables are not configured on Vercel.

### Current Behavior:
- ✅ Free consultations work perfectly
- ❌ Paid consultations fail at checkout because Stripe keys are missing

### Solution:
Add the Stripe environment variables (see section 2 above) to Vercel.

### Temporary Workaround:
The app is configured to gracefully handle missing Stripe keys:
- Build process won't fail
- API returns user-friendly error: "Payment system is not configured. Please contact support."

## 🗂️ Database Schema

### Services Table Structure:
```sql
- id: UUID (primary key)
- title_en, title_fr, title_ar: Multilingual titles
- description_en, description_fr, description_ar: Multilingual descriptions
- icon: Lucide icon name
- href: Service URL
- is_active: Boolean
- display_order: Integer (for ordering)
```

### Bookings Table Structure:
```sql
- id: UUID (primary key)
- user_id: UUID (nullable)
- name, email, topic: Text
- date, time: Date/Time
- status: 'pending' | 'confirmed' | 'in-progress' | 'completed' | 'cancelled'
- price: Decimal
- payment_status: 'pending' | 'paid' | 'failed' | 'refunded' | 'free'
- stripe_session_id, stripe_payment_id: Text (nullable)
- calendar_event_id, meet_link: Text (nullable)
```

## 🧪 Testing Checklist

After adding environment variables:

### Database (Already ✅):
- [x] Supabase connection works
- [x] Services table exists with data
- [x] Bookings table accessible
- [x] Admin can manage services
- [x] Admin can view consultations

### Payment System (Needs Stripe Keys):
- [ ] Free consultations work
- [ ] Paid consultation checkout redirects to Stripe
- [ ] Payment confirmation updates booking status
- [ ] Webhook processes payments correctly

### Email System (Needs SMTP Config):
- [ ] Booking confirmation emails sent to clients
- [ ] Admin notification emails work
- [ ] Contact form emails delivered

### Google Integration (Optional):
- [ ] Calendar events created for bookings
- [ ] Meet links generated
- [ ] Google account connection works

## 🚨 Important Notes

1. **Stripe Keys**: Use LIVE keys for production, TEST keys for development
2. **Webhook Secret**: Configure Stripe webhook endpoint: `https://sygmaconsult.com/api/stripe/webhook`
3. **SMTP Password**: Contains special character `%` - ensure proper encoding
4. **Google Redirect**: Must match exactly in Google Cloud Console
5. **Public Variables**: All `NEXT_PUBLIC_*` variables are exposed to the client

## 📊 Deployment History

### Latest Commits:
1. ✅ Fix Stripe initialization for builds without API keys
2. ✅ Add services management with multilingual support
3. ✅ Improve admin consultations functionality
4. ✅ Create services and bookings migrations

### Build Status:
- Local Build: ✅ Success (62 pages generated)
- Vercel Build: ✅ Success (after Stripe fix)
- Runtime: ⚠️ Needs environment variables for full functionality

## 🔗 Useful Links

- **Vercel Dashboard**: https://vercel.com/dashboard
- **Supabase Dashboard**: https://supabase.com/dashboard/project/ldbsacdpkinbpcguvgai
- **Stripe Dashboard**: https://dashboard.stripe.com
- **Production Site**: https://sygmaconsult.com

## 🆘 Troubleshooting

### Build Fails:
1. Check if all dependencies are in package.json
2. Verify TypeScript errors in local build
3. Check Vercel build logs for specific errors

### Runtime Errors:
1. Verify environment variables are set
2. Check browser console for client-side errors
3. Check Vercel function logs for server-side errors

### Payment Issues:
1. Ensure Stripe keys are correct and match environment (live/test)
2. Verify webhook endpoint is configured in Stripe dashboard
3. Check Stripe logs for payment events

### Email Issues:
1. Test SMTP credentials separately
2. Check spam folders
3. Verify SMTP_PORT is correct (465 for SSL)

---

**Last Updated**: December 20, 2025
**Status**: ✅ Deployed - Needs Environment Variables Configuration
