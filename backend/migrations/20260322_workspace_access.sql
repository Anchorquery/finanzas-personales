ALTER TABLE public.workspaces
  ADD COLUMN IF NOT EXISTS access_scope character varying(32) NOT NULL DEFAULT 'restricted',
  ADD COLUMN IF NOT EXISTS access_member_ids jsonb NOT NULL DEFAULT '[]'::jsonb;

UPDATE public.workspaces
SET access_scope = CASE
  WHEN type = 'shared' THEN 'organization'
  ELSE 'restricted'
END
WHERE access_scope IS NULL
   OR access_scope NOT IN ('organization', 'restricted');

UPDATE public.workspaces
SET access_scope = 'organization'
WHERE access_scope = 'restricted'
  AND COALESCE(access_member_ids, '[]'::jsonb) = '[]'::jsonb;
