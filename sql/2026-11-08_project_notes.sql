-- Moment — 2026-11-08: project-wide notes (Settings › Notes).
-- Run in Supabase SQL Editor on the Family project (twvqvutrcobedvuhnzxq).
-- Safe to run more than once.
--
-- Why: general notes about the whole app, separate from per-game feedback
-- (game_feedback). Notes are shared by everyone signed in, so they live in
-- Supabase rather than the browser. Only signed-in users can read or write.

CREATE TABLE IF NOT EXISTS public.project_notes (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  body        text NOT NULL CHECK (char_length(body) BETWEEN 1 AND 2000),
  created_at  timestamptz NOT NULL DEFAULT now(),
  created_by  uuid DEFAULT auth.uid()
);

ALTER TABLE public.project_notes ENABLE ROW LEVEL SECURITY;

-- Anonymous visitors get no access at all.
REVOKE ALL ON public.project_notes FROM anon;
GRANT SELECT, INSERT, DELETE ON public.project_notes TO authenticated;

DROP POLICY IF EXISTS "auth_select_project_notes" ON public.project_notes;
CREATE POLICY "auth_select_project_notes" ON public.project_notes
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "auth_insert_project_notes" ON public.project_notes;
CREATE POLICY "auth_insert_project_notes" ON public.project_notes
  FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "auth_delete_project_notes" ON public.project_notes;
CREATE POLICY "auth_delete_project_notes" ON public.project_notes
  FOR DELETE TO authenticated USING (true);
