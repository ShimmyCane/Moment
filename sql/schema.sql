-- Moment Family Play App — Database Schema v1.0
-- Run this in Supabase SQL Editor (Dashboard > SQL Editor > New Query)

-- ============================================================
-- TABLES (dependency order)
-- ============================================================

CREATE TABLE IF NOT EXISTS games (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  slug             TEXT        UNIQUE NOT NULL,
  title            TEXT        NOT NULL,
  short_label      TEXT        NOT NULL,   -- ≤15 chars, displayed on wheel
  category         TEXT        NOT NULL
                               CHECK (category IN ('observation','imagination','learning','conversation','quick_challenge')),
  wheel_slot       INTEGER     NOT NULL UNIQUE
                               CHECK (wheel_slot >= 0 AND wheel_slot <= 14),
  current_version_id UUID,                -- FK added below after game_versions exists
  status           TEXT        NOT NULL DEFAULT 'draft'
                               CHECK (status IN ('draft','active','deprecated','archived')),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS game_versions (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id          UUID        NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  version_number   INTEGER     NOT NULL,
  schema_version   TEXT        NOT NULL DEFAULT '1.0',
  definition       JSONB       NOT NULL,
  published_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (game_id, version_number)
);

-- Circular FK: games → game_versions (deferred to avoid insert-order issues)
ALTER TABLE games
  ADD CONSTRAINT fk_games_current_version
  FOREIGN KEY (current_version_id)
  REFERENCES game_versions(id)
  DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE IF NOT EXISTS play_sessions (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  mode             TEXT        NOT NULL DEFAULT 'family_mix'
                               CHECK (mode IN ('quick_spark','family_mix','mini_party','learning_adventure','wind_down')),
  started_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at         TIMESTAMPTZ,
  metadata         JSONB       NOT NULL DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS play_events (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id       UUID        NOT NULL REFERENCES play_sessions(id),
  game_id          UUID        NOT NULL REFERENCES games(id),
  game_version_id  UUID        REFERENCES game_versions(id),
  played_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  outcome          TEXT        NOT NULL DEFAULT 'completed'
                               CHECK (outcome IN ('completed','skipped','abandoned')),
  players          TEXT[]      NOT NULL DEFAULT '{}',
  winner           TEXT,
  duration_seconds INTEGER     CHECK (duration_seconds >= 0)
);

CREATE TABLE IF NOT EXISTS game_feedback (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  play_event_id    UUID        NOT NULL REFERENCES play_events(id),
  game_id          UUID        NOT NULL REFERENCES games(id),
  game_version_id  UUID        REFERENCES game_versions(id),
  rating           SMALLINT    NOT NULL CHECK (rating IN (-1, 0, 1)),
  notes            TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS scores (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id       UUID        NOT NULL REFERENCES play_sessions(id),
  play_event_id    UUID        REFERENCES play_events(id),
  player_name      TEXT        NOT NULL,
  points           INTEGER     NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_games_status      ON games(status);
CREATE INDEX IF NOT EXISTS idx_games_category    ON games(category);
CREATE INDEX IF NOT EXISTS idx_games_wheel_slot  ON games(wheel_slot);
CREATE INDEX IF NOT EXISTS idx_gv_game_id        ON game_versions(game_id);
CREATE INDEX IF NOT EXISTS idx_pe_session_id     ON play_events(session_id);
CREATE INDEX IF NOT EXISTS idx_pe_game_id        ON play_events(game_id);
CREATE INDEX IF NOT EXISTS idx_pe_played_at      ON play_events(played_at);
CREATE INDEX IF NOT EXISTS idx_scores_session    ON scores(session_id);
CREATE INDEX IF NOT EXISTS idx_scores_player     ON scores(player_name);

-- ============================================================
-- AUTO-UPDATE updated_at
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_games_updated_at
  BEFORE UPDATE ON games
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

-- games: anon reads active only; auth reads/writes all
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_active_games"
  ON games FOR SELECT TO anon
  USING (status = 'active');
CREATE POLICY "auth_full_games"
  ON games FOR ALL TO authenticated
  USING (true) WITH CHECK (true);

-- game_versions: anon reads versions of active games only
ALTER TABLE game_versions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_active_versions"
  ON game_versions FOR SELECT TO anon
  USING (
    EXISTS (
      SELECT 1 FROM games
      WHERE games.id = game_versions.game_id
      AND games.status = 'active'
    )
  );
CREATE POLICY "auth_full_game_versions"
  ON game_versions FOR ALL TO authenticated
  USING (true) WITH CHECK (true);

-- play_sessions: anon can insert + read
ALTER TABLE play_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_insert_sessions" ON play_sessions FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_select_sessions" ON play_sessions FOR SELECT TO anon USING (true);

-- play_events: anon can insert + read + update (for outcome)
ALTER TABLE play_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_insert_events" ON play_events FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_select_events" ON play_events FOR SELECT TO anon USING (true);
CREATE POLICY "anon_update_events" ON play_events FOR UPDATE TO anon USING (true) WITH CHECK (true);

-- game_feedback: anon inserts; only auth reads (admin reviews)
ALTER TABLE game_feedback ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_insert_feedback" ON game_feedback FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "auth_select_feedback" ON game_feedback FOR SELECT TO authenticated USING (true);

-- scores: anon can insert + read
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_insert_scores" ON scores FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_select_scores" ON scores FOR SELECT TO anon USING (true);

-- ============================================================
-- CONVENIENCE VIEW
-- ============================================================

CREATE OR REPLACE VIEW active_games_view AS
  SELECT
    g.id,
    g.slug,
    g.title,
    g.short_label,
    g.category,
    g.wheel_slot,
    g.status,
    g.current_version_id,
    g.updated_at,
    gv.definition,
    gv.version_number,
    gv.schema_version
  FROM games g
  LEFT JOIN game_versions gv ON g.current_version_id = gv.id
  WHERE g.status = 'active'
  ORDER BY g.wheel_slot;
