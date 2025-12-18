-- 1. Ensure the documents table has the correct structure (aligning with extended-schema.sql)
-- Note: user_id is TEXT in this project to match Firebase/Auth setup
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size BIGINT,
    file_type TEXT,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Add the missing foreign key relationship that the frontend expects
-- This is critical for the .select('..., user_profiles(...)') query to work
ALTER TABLE public.documents 
DROP CONSTRAINT IF EXISTS documents_user_id_fkey,
ADD CONSTRAINT documents_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES public.user_profiles(user_id) 
ON DELETE CASCADE;

-- 3. Enable RLS
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

-- 4. Clean up and recreate policies with correct type casting (TEXT)
DROP POLICY IF EXISTS "Users can view own documents" ON public.documents;
DROP POLICY IF EXISTS "Users can view their own documents" ON public.documents;
DROP POLICY IF EXISTS "Admins can view all documents" ON public.documents;
DROP POLICY IF EXISTS "Users can insert documents" ON public.documents;
DROP POLICY IF EXISTS "Users can insert their own documents" ON public.documents;
DROP POLICY IF EXISTS "Users can delete own documents" ON public.documents;

-- Policy: Users can view their own documents
CREATE POLICY "Users can view their own documents"
ON public.documents FOR SELECT
TO authenticated
USING (user_id = auth.uid()::text);

-- Policy: Authenticated users can insert their own documents
CREATE POLICY "Users can insert their own documents"
ON public.documents FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid()::text);

-- Policy: Users can delete their own documents
CREATE POLICY "Users can delete own documents"
ON public.documents FOR DELETE
TO authenticated
USING (user_id = auth.uid()::text);

-- Policy: Service role (Admin) full access
CREATE POLICY "Service role full access documents"
ON public.documents TO service_role USING (true) WITH CHECK (true);

-- 5. Add comments
COMMENT ON TABLE public.documents IS 'Stores metadata for user-uploaded documents and admin attachments.';
