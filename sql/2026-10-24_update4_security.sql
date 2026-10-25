-- Moment — Update 4 (2026-10-24): security tightening + feedback ratings read
-- Run in Supabase SQL Editor on the Family project (twvqvutrcobedvuhnzxq).
-- Run AFTER update3.sql. Safe to run more than once.

-- 1. Remove privileges RLS cannot guard (TRUNCATE bypasses RLS) and writes with no policy.
REVOKE TRUNCATE, REFERENCES, TRIGGER ON public.games, public.game_versions, public.game_feedback,
  public.play_events, public.play_sessions, public.scores FROM anon, authenticated;
REVOKE UPDATE, DELETE ON public.games, public.game_versions, public.game_feedback,
  public.play_sessions, public.scores FROM anon;
REVOKE DELETE ON public.play_events FROM anon;

-- 2. Views run as the owner by default and skip RLS. Make them respect the caller's RLS,
--    and grant read only.
ALTER VIEW public.active_games_view SET (security_invoker = true);
ALTER VIEW public.all_games_view SET (security_invoker = true);
REVOKE ALL ON public.active_games_view, public.all_games_view FROM anon, authenticated;
GRANT SELECT ON public.active_games_view, public.all_games_view TO anon, authenticated;

-- 3. Feedback: anon may read ratings (home-page ranking, settings tab) but not notes.
REVOKE SELECT ON public.game_feedback FROM anon;
GRANT SELECT (id, game_id, rating, created_at) ON public.game_feedback TO anon;
DROP POLICY IF EXISTS "anon_select_feedback_ratings" ON public.game_feedback;
CREATE POLICY "anon_select_feedback_ratings" ON public.game_feedback
  FOR SELECT TO anon USING (true);

-- 4. Pin the search_path on Moment's trigger function.
ALTER FUNCTION public.update_updated_at() SET search_path = '';

-- 5. Register the tables and views this app owns in app_table_registry.
INSERT INTO public.app_table_registry (app, object_name, object_type, access, description, repo)
SELECT v.app, v.object_name, v.object_type, 'owner', v.description, 'ShimmyCane/moment'
FROM (VALUES
  ('moment', 'games', 'table', 'Game catalogue: slug, title, wheel slot, status, emoji. Anon reads active games only.'),
  ('moment', 'game_versions', 'table', 'Versioned JSON definitions for each game. games.current_version_id points at the live one.'),
  ('moment', 'play_sessions', 'table', 'One row per app session (family mode).'),
  ('moment', 'play_events', 'table', 'One row per game played in a session: players, winner, outcome.'),
  ('moment', 'game_feedback', 'table', 'Rating (-1/0/1) and optional notes per play event. Anon reads ratings only; notes are admin-only.'),
  ('moment', 'scores', 'table', 'Points awarded per play event.'),
  ('moment', 'active_games_view', 'view', 'Games with status = active, joined to their current version.'),
  ('moment', 'all_games_view', 'view', 'All games joined to their current version (admin feedback tab).')
) AS v(app, object_name, object_type, description)
WHERE NOT EXISTS (
  SELECT 1 FROM public.app_table_registry r WHERE r.object_name = v.object_name AND r.app = v.app
);
