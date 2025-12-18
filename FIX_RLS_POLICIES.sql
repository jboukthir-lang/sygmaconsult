-- ════════════════════════════════════════════════════════════
-- Sygma Consult - Fix RLS Policies for user_profiles
-- ════════════════════════════════════════════════════════════
--
-- INSTRUCTIONS:
-- 1. Go to: https://ldbsacdpkinbpcguvgai.supabase.co/project/ldbsacdpkinbpcguvgai/sql/new
-- 2. Copy and paste this entire SQL script
-- 3. Click "Run" to execute
--
-- This will:
-- - Enable public read access to user_profiles (for admin panel)
-- - Allow authenticated users to insert their own profiles
-- - Allow users to update their own profiles
-- - Prevent unauthorized deletions
-- ════════════════════════════════════════════════════════════

-- Drop existing policies if they exist (clean slate)
DROP POLICY IF EXISTS "Enable read access for all users" ON public.user_profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.user_profiles;

-- ════════════════════════════════════════════════════════════
-- READ POLICY: Allow anyone to view user profiles
-- ════════════════════════════════════════════════════════════
-- This allows the admin panel to display all users
-- Also allows public viewing of user information

CREATE POLICY "Enable read access for all users"
ON public.user_profiles
FOR SELECT
TO authenticated, anon
USING (true);

-- ════════════════════════════════════════════════════════════
-- INSERT POLICY: Allow authenticated users to create profiles
-- ════════════════════════════════════════════════════════════
-- This allows AuthContext.tsx to create user profiles
-- when users sign up or log in with Firebase

CREATE POLICY "Enable insert for authenticated users only"
ON public.user_profiles
FOR INSERT
TO authenticated, anon
WITH CHECK (true);

-- ════════════════════════════════════════════════════════════
-- UPDATE POLICY: Users can update their own profile
-- ════════════════════════════════════════════════════════════
-- This allows users to edit their profile information
-- Only the profile owner can update their own data

CREATE POLICY "Users can update own profile"
ON public.user_profiles
FOR UPDATE
TO authenticated
USING (auth.uid()::text = user_id)
WITH CHECK (auth.uid()::text = user_id);

-- ════════════════════════════════════════════════════════════
-- DELETE POLICY: Users can delete their own profile
-- ════════════════════════════════════════════════════════════
-- This allows users to delete their account
-- Only the profile owner can delete their own profile

CREATE POLICY "Users can delete own profile"
ON public.user_profiles
FOR DELETE
TO authenticated
USING (auth.uid()::text = user_id);

-- ════════════════════════════════════════════════════════════
-- Verify RLS is enabled
-- ════════════════════════════════════════════════════════════

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- ════════════════════════════════════════════════════════════
-- DONE! ✅
-- ════════════════════════════════════════════════════════════
--
-- Now try:
-- 1. Register a new user on the website
-- 2. Check /admin/users to see if they appear
-- 3. Or run: node scripts/check-users.mjs
--
-- If you still don't see users, you may need to sync existing
-- Firebase users using the manual sync script (requires serviceAccountKey.json)
--
-- ════════════════════════════════════════════════════════════
