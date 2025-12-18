-- FINAL ROBUST FIX FOR DOCUMENTS TABLE (DYNAMIC POLICY CLEANUP)
-- 1. Create the table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size BIGINT,
    file_type TEXT,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. DYNAMICALLY DROP ALL POLICIES TO AVOID DEPENDENCY ERRORS
-- This script finds every policy on the 'documents' table and deletes it
DO $$ 
DECLARE 
    pol RECORD;
BEGIN 
    FOR pol IN (SELECT policyname FROM pg_policies WHERE tablename = 'documents' AND (schemaname = 'public' OR schemaname = 'storage')) 
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', pol.policyname, 'public', 'documents');
    END LOOP;
END $$;

-- 3. DISABLE RLS TEMPORARILY
ALTER TABLE public.documents DISABLE ROW LEVEL SECURITY;

-- 4. Handle column name mismatches
-- Rename 'name' to 'file_name' if it exists
DO $$ 
BEGIN 
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'documents' AND COLUMN_NAME = 'name') THEN
        ALTER TABLE public.documents RENAME COLUMN "name" TO "file_name";
    END IF;
END $$;

-- Rename 'created_at' to 'uploaded_at' if it exists
DO $$ 
BEGIN 
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'documents' AND COLUMN_NAME = 'created_at') 
       AND NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'documents' AND COLUMN_NAME = 'uploaded_at') THEN
        ALTER TABLE public.documents RENAME COLUMN "created_at" TO "uploaded_at";
    END IF;
END $$;

-- 5. NOW ALTER COLUMN TYPES (The "DETAIL" error should no longer happen)
ALTER TABLE public.documents ALTER COLUMN user_id TYPE TEXT;
ALTER TABLE public.documents ALTER COLUMN file_size TYPE BIGINT;

-- 6. Add the specific Foreign Key relationship
ALTER TABLE public.documents 
DROP CONSTRAINT IF EXISTS documents_user_id_fkey,
ADD CONSTRAINT documents_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES public.user_profiles(user_id) 
ON DELETE CASCADE;

-- 7. RE-ENABLE RLS AND RECREATE POLICIES
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

-- Policy: Admins see EVERYTHING
CREATE POLICY "Admins can view all documents"
ON public.documents FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.admin_users 
    WHERE public.admin_users.user_id = auth.uid()::text
  )
);

-- Policy: Users see OWN
CREATE POLICY "Users can view their own documents"
ON public.documents FOR SELECT
TO authenticated
USING (user_id = auth.uid()::text);

-- Policy: Users insert OWN
CREATE POLICY "Users can insert their own documents"
ON public.documents FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid()::text);

-- Policy: Users update OWN
CREATE POLICY "Users can update their own documents"
ON public.documents FOR UPDATE
TO authenticated
USING (user_id = auth.uid()::text);

-- Policy: Users delete OWN
CREATE POLICY "Users can delete own documents"
ON public.documents FOR DELETE
TO authenticated
USING (user_id = auth.uid()::text);

-- Policy: Service role full access
CREATE POLICY "Service role full access documents"
ON public.documents TO service_role USING (true) WITH CHECK (true);

-- 8. Ensure user_profiles access for the frontend join
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.user_profiles;
CREATE POLICY "Admins can view all profiles"
ON public.user_profiles FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.admin_users 
    WHERE public.admin_users.user_id = auth.uid()::text
  )
);

-- 9. Add comments
COMMENT ON TABLE public.documents IS 'Stores metadata for user documents and admin attachments.';
