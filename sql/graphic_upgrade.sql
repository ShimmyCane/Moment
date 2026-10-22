-- Moment — Graphic Upgrade v1.0
-- Adds emoji column to games table and patches the active_games_view.
-- Run in Supabase SQL Editor (Dashboard > SQL Editor > New Query).
-- Safe to run multiple times (idempotent).

-- ============================================================
-- 1. Add emoji column
-- ============================================================

ALTER TABLE games
  ADD COLUMN IF NOT EXISTS emoji VARCHAR(10);

-- ============================================================
-- 2. Set emoji per game (keyed by slug for safety)
-- ============================================================

UPDATE games SET emoji = '🔍' WHERE slug = 'i-spy-weird';
UPDATE games SET emoji = '👂' WHERE slug = 'sound-detective';
UPDATE games SET emoji = '👁️' WHERE slug = 'what-changed';
UPDATE games SET emoji = '📖' WHERE slug = 'three-word-story';
UPDATE games SET emoji = '🎭' WHERE slug = 'fortunately-unfortunately';
UPDATE games SET emoji = '⚗️' WHERE slug = 'impossible-invention';
UPDATE games SET emoji = '🔢' WHERE slug = 'mystery-number';
UPDATE games SET emoji = '🧩' WHERE slug = 'what-doesnt-belong';
UPDATE games SET emoji = '🚀' WHERE slug = 'space-mission';
UPDATE games SET emoji = '🤔' WHERE slug = 'would-you-rather';
UPDATE games SET emoji = '🦸' WHERE slug = 'superpower-swap';
UPDATE games SET emoji = '🔮' WHERE slug = 'family-forecast';
UPDATE games SET emoji = '🤐' WHERE slug = 'forbidden-word';
UPDATE games SET emoji = '🎬' WHERE slug = 'mini-charades';
UPDATE games SET emoji = '🎯' WHERE slug = 'three-things';

-- ============================================================
-- 3. Rebuild active_games_view to expose emoji column
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
    g.emoji,
    gv.definition,
    gv.version_number,
    gv.schema_version
  FROM games g
  LEFT JOIN game_versions gv ON g.current_version_id = gv.id
  WHERE g.status = 'active'
  ORDER BY g.wheel_slot;
