-- Moment — 2026-10-25: let signed-in users play and save like anon.
-- Run in Supabase SQL Editor on the Family project (twvqvutrcobedvuhnzxq).
-- Run AFTER 2026-10-24_update4_security.sql. Safe to run more than once.
--
-- Why: the game app now has a sign-in in Settings. A signed-in browser sends the
-- `authenticated` role, which had INSERT grants but no matching policies, so
-- createSession() failed with a row-level security error.
-- These policies mirror the existing anon gameplay policies. No new grants.

-- play_sessions
DROP POLICY IF EXISTS "auth_insert_sessions" ON public.play_sessions;
CREATE POLICY "auth_insert_sessions" ON public.play_sessions
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "auth_select_sessions" ON public.play_sessions;
CREATE POLICY "auth_select_sessions" ON public.play_sessions
  FOR SELECT TO authenticated USING (true);

-- play_events
DROP POLICY IF EXISTS "auth_insert_events" ON public.play_events;
CREATE POLICY "auth_insert_events" ON public.play_events
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "auth_select_events" ON public.play_events;
CREATE POLICY "auth_select_events" ON public.play_events
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "auth_update_events" ON public.play_events;
CREATE POLICY "auth_update_events" ON public.play_events
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- scores
DROP POLICY IF EXISTS "auth_insert_scores" ON public.scores;
CREATE POLICY "auth_insert_scores" ON public.scores
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "auth_select_scores" ON public.scores;
CREATE POLICY "auth_select_scores" ON public.scores
  FOR SELECT TO authenticated USING (true);

-- game_feedback: insert only. Reads already exist for authenticated (auth_select_feedback).
DROP POLICY IF EXISTS "auth_insert_feedback" ON public.game_feedback;
CREATE POLICY "auth_insert_feedback" ON public.game_feedback
  FOR INSERT TO authenticated WITH CHECK (true);
