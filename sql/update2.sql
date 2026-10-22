-- Moment — Update 2
-- Run in Supabase SQL Editor after schema.sql + seed.sql + graphic_upgrade.sql.
-- Safe to run multiple times (idempotent).

-- ============================================================
-- 1. Make wheel_slot nullable (draft games don't need a slot)
-- ============================================================
ALTER TABLE games ALTER COLUMN wheel_slot DROP NOT NULL;

-- ============================================================
-- 2. Ensure emoji column exists
-- ============================================================
ALTER TABLE games ADD COLUMN IF NOT EXISTS emoji VARCHAR(10);

-- ============================================================
-- 3. Rebuild active_games_view (with emoji, idempotent)
-- ============================================================
CREATE OR REPLACE VIEW active_games_view AS
  SELECT
    g.id, g.slug, g.title, g.short_label,
    g.category, g.wheel_slot, g.status,
    g.current_version_id, g.updated_at, g.emoji,
    gv.definition, gv.version_number, gv.schema_version
  FROM games g
  LEFT JOIN game_versions gv ON g.current_version_id = gv.id
  WHERE g.status = 'active'
  ORDER BY g.wheel_slot NULLS LAST;

-- ============================================================
-- 4. All-games view (used by settings Feedback tab — shows
--    every game regardless of status so admin sees full history)
-- ============================================================
CREATE OR REPLACE VIEW all_games_view AS
  SELECT
    g.id, g.slug, g.title, g.short_label,
    g.category, g.wheel_slot, g.status,
    g.current_version_id, g.updated_at, g.emoji,
    gv.definition, gv.version_number, gv.schema_version
  FROM games g
  LEFT JOIN game_versions gv ON g.current_version_id = gv.id
  ORDER BY g.wheel_slot NULLS LAST, g.title;

-- ============================================================
-- 5. Seed cards — Mini Charades (v2)
--    Adds "seed_cards" and "seed_label" to existing definition.
-- ============================================================
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-00000000000e',
  2,
  gv.definition || $json${
    "seed_label": "Act this out:",
    "seed_cards": [
      "Penguin", "Elephant", "Cat washing its face", "Bee", "Kangaroo",
      "Dog taking a nap", "Snake", "Monkey eating a banana", "Frog jumping",
      "Bear scratching its back", "Butterfly", "Baby dinosaur",
      "Chef cooking", "Doctor", "Astronaut floating in zero gravity",
      "Firefighter with a hose", "Teacher writing on a board",
      "Dentist", "Painter on a ladder", "Guitarist on stage",
      "Pirate steering a ship", "Surfer", "Ballet dancer",
      "Giant stomping", "Tiny fairy", "Dragon breathing fire",
      "Robot walking stiffly", "Wizard casting a spell",
      "Superhero flying", "Zombie", "Submarine captain at the periscope"
    ]
  }$json$::jsonb
FROM game_versions gv
WHERE gv.id = '00000001-0000-4000-8000-00000000000e'
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games
SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-00000000000e'
    AND version_number = 2
)
WHERE id = '00000000-0000-4000-8000-00000000000e'
  AND (
    current_version_id = '00000001-0000-4000-8000-00000000000e'
    OR current_version_id IS NULL
  );

-- ============================================================
-- 6. Seed cards — Forbidden Word (v2)
-- ============================================================
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-00000000000d',
  2,
  gv.definition || $json${
    "seed_label": "Describe this — don't say the word:",
    "seed_cards": [
      "Umbrella", "Refrigerator", "Bicycle", "Toothbrush", "Pillow",
      "Glasses", "Clock", "Sock", "Sandwich", "Trampoline",
      "Swimming pool", "Hairbrush", "Candle", "Doorbell",
      "Elevator", "Rollercoaster", "Snowflake", "Telescope",
      "Calendar", "Compass", "Seatbelt", "Hammock",
      "Microwave", "Escalator", "Backpack"
    ]
  }$json$::jsonb
FROM game_versions gv
WHERE gv.id = '00000001-0000-4000-8000-00000000000d'
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games
SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-00000000000d'
    AND version_number = 2
)
WHERE id = '00000000-0000-4000-8000-00000000000d'
  AND (
    current_version_id = '00000001-0000-4000-8000-00000000000d'
    OR current_version_id IS NULL
  );

-- ============================================================
-- 7. Seed cards — Three Things (v2)
-- ============================================================
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-00000000000f',
  2,
  gv.definition || $json${
    "seed_label": "Name 3 things in this category:",
    "seed_cards": [
      "Things that glow in the dark",
      "Animals with spots",
      "Things you find at a beach",
      "Things that are perfectly round",
      "Things that make a loud noise",
      "Things you can eat straight from the fridge",
      "Things taller than a person",
      "Things that live underground",
      "Things with wings",
      "Things you find in a kitchen",
      "Things that are yellow",
      "Things that float on water",
      "Things that are very soft",
      "Things that spin",
      "Things you wear on your head",
      "Things that smell really good",
      "Things that are always cold",
      "Things that start with the letter S",
      "Animals that live in water",
      "Things you can throw",
      "Things that are sticky",
      "Things that come in pairs",
      "Things that have wheels",
      "Things you do before breakfast"
    ]
  }$json$::jsonb
FROM game_versions gv
WHERE gv.id = '00000001-0000-4000-8000-00000000000f'
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games
SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-00000000000f'
    AND version_number = 2
)
WHERE id = '00000000-0000-4000-8000-00000000000f'
  AND (
    current_version_id = '00000001-0000-4000-8000-00000000000f'
    OR current_version_id IS NULL
  );

-- ============================================================
-- 8. Seed cards — Would You Rather (v2)
-- ============================================================
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-00000000000a',
  2,
  gv.definition || $json${
    "seed_label": "Would you rather…",
    "seed_cards": [
      "Have a pet dragon, or be able to fly?",
      "Eat only pizza, or only spaghetti forever?",
      "Speak to animals, or speak every language in the world?",
      "Have super speed, or super strength?",
      "Live in a treehouse, or on a houseboat?",
      "Be invisible, or be able to read minds?",
      "Never feel cold, or never feel hot?",
      "Have a tail like a monkey, or ears like a rabbit?",
      "Only be able to whisper, or only be able to shout?",
      "Never have to sleep, or never have to eat?",
      "Have hands where your feet are, or feet where your hands are?",
      "Travel to the past, or to the future?",
      "Explore the deep ocean, or outer space?",
      "Have a personal robot, or a magic carpet?",
      "Be the funniest person alive, or the smartest?",
      "Live in summer all year, or winter all year?",
      "Be ant-sized for a day, or house-sized for a day?",
      "Meet a friendly alien, or discover a live dinosaur?",
      "Only eat sweet food, or only eat savoury food?",
      "Have eyes in the back of your head, or a third arm?"
    ]
  }$json$::jsonb
FROM game_versions gv
WHERE gv.id = '00000001-0000-4000-8000-00000000000a'
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games
SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-00000000000a'
    AND version_number = 2
)
WHERE id = '00000000-0000-4000-8000-00000000000a'
  AND (
    current_version_id = '00000001-0000-4000-8000-00000000000a'
    OR current_version_id IS NULL
  );
