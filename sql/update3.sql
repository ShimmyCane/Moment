-- Moment — Update 3: Round Options
-- Adds an "options" array to every game definition.
-- A random option is drawn each time the game page loads, shown as
-- "This round" just above the Variants section.
--
-- Safe to run multiple times (idempotent):
--   - INSERT … ON CONFLICT DO NOTHING
--   - The WHERE NOT EXISTS (definition ? 'options') guard prevents
--     double-adding if the version already has options.
-- Run AFTER update2.sql.

-- ============================================================
-- Helper macro:
--   For each game we:
--   1. Insert a new version = (current max version + 1) that merges
--      "options" into the current definition.
--      Skipped entirely if the latest definition already has "options".
--   2. Update current_version_id to the highest version number.
-- ============================================================

-- ── 1. I Spy But Weird ──────────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-000000000001',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-000000000001'),
  definition || $json${"options":[
    "This round: describe it using only comparisons to food.",
    "This round: the spy must choose something above waist height.",
    "This round: each guesser gets exactly one guess, then must pass.",
    "This round: your description must be exactly five words."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-000000000001'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-000000000001'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-000000000001';

-- ── 2. Sound Detective ──────────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-000000000002',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-000000000002'),
  definition || $json${"options":[
    "This round: also try to guess which direction each sound is coming from.",
    "This round: describe every sound as a type of weather.",
    "This round: only count sounds that are not made by people.",
    "This round: listen for 60 seconds instead of 30."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-000000000002'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-000000000002'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-000000000002';

-- ── 3. What Changed? ────────────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-000000000003',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-000000000003'),
  definition || $json${"options":[
    "This round: the Changer makes two changes instead of one.",
    "This round: no pointing allowed — only describe the change in words.",
    "This round: the youngest player is always the Changer.",
    "This round: the Changer has only 8 seconds to make the change."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-000000000003'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-000000000003'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-000000000003';

-- ── 4. Three-Word Story ─────────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-000000000004',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-000000000004'),
  definition || $json${"options":[
    "This round: every sentence must include at least one animal.",
    "This round: nobody may use the word 'and'.",
    "This round: the entire story must be set in space.",
    "This round: each player adds two sentences instead of one."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-000000000004'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-000000000004'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-000000000004';

-- ── 5. Fortunately Unfortunately ────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-000000000005',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-000000000005'),
  definition || $json${"options":[
    "This round: each sentence must be at least 10 words long.",
    "This round: start with 'Fortunately, our cat learned to drive.'",
    "This round: whisper your sentence — everyone must listen very carefully.",
    "This round: every 'Fortunately' sentence must involve food."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-000000000005'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-000000000005'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-000000000005';

-- ── 6. Impossible Invention ─────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-000000000006',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-000000000006'),
  definition || $json${"options":[
    "This round: your invention must be wearable.",
    "This round: your invention must make a funny noise when it works.",
    "This round: name your invention before you describe how it works.",
    "This round: your invention must solve a problem that happened this week."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-000000000006'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-000000000006'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-000000000006';

-- ── 7. Mystery Number ───────────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-000000000007',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-000000000007'),
  definition || $json${"options":[
    "This round: clues must use comparisons only — no 'bigger than' or 'smaller than'.",
    "This round: the number must be a multiple of 3.",
    "This round: guessers may only ask yes/no questions.",
    "This round: pick from 1–1000. Bonus point for guessing in 5 clues or fewer."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-000000000007'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-000000000007'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-000000000007';

-- ── 8. What Doesn't Belong? ─────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-000000000008',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-000000000008'),
  definition || $json${"options":[
    "This round: everyone defends their answer before anyone reveals.",
    "This round: bonus +1 if you can argue convincingly that ALL four belong.",
    "This round: the youngest player picks the four things.",
    "This round: use people — real or fictional — instead of objects."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-000000000008'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-000000000008'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-000000000008';

-- ── 9. Space Mission ────────────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-000000000009',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-000000000009'),
  definition || $json${"options":[
    "This round: your destination is a planet you invent — name it before anything else.",
    "This round: your invention must have a name that sounds like a food.",
    "This round: Mission Controller adds a second surprise challenge mid-mission.",
    "This round: each crew member describes what could go wrong — then how to fix it."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-000000000009'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-000000000009'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-000000000009';

-- ── 10. Would You Rather? ───────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-00000000000a',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-00000000000a'),
  definition || $json${"options":[
    "This round: before choosing, everyone predicts what the person to their left will pick.",
    "This round: you must defend the option you would NOT pick.",
    "This round: after choosing, explain what you'd do first.",
    "This round: the person with the most unusual reason picks the next dilemma."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-00000000000a'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-00000000000a'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-00000000000a';

-- ── 11. Superpower Swap ─────────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-00000000000b',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-00000000000b'),
  definition || $json${"options":[
    "This round: every superpower must have a ridiculous weakness.",
    "This round: assign the power to someone not in the room — a celebrity or fictional character.",
    "This round: your power must be completely invisible to everyone else.",
    "This round: after assigning, everyone votes for the most genuinely useful power."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-00000000000b'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-00000000000b'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-00000000000b';

-- ── 12. Family Forecast ─────────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-00000000000c',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-00000000000c'),
  definition || $json${"options":[
    "This round: every prediction must name a specific time — 'At 8:30 tomorrow morning…'",
    "This round: each prediction must involve a sound.",
    "This round: predict something about next week instead of tomorrow.",
    "This round: every prediction must start with 'Someone will accidentally…'"
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-00000000000c'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-00000000000c'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-00000000000c';

-- ── 13. Forbidden Word ──────────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-00000000000d',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-00000000000d'),
  definition || $json${"options":[
    "This round: also forbid any word that rhymes with the object.",
    "This round: describe using only questions — no statements.",
    "This round: the describer must stand up while describing.",
    "This round: double points if described in under 10 seconds."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-00000000000d'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-00000000000d'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-00000000000d';

-- ── 14. Mini Charades ───────────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-00000000000e',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-00000000000e'),
  definition || $json${"options":[
    "This round: the actor may make exactly one sound.",
    "This round: the actor must stay seated the entire time.",
    "This round: guessers may only respond by pointing — no shouting.",
    "This round: the actor has 60 seconds but must move in slow motion."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-00000000000e'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-00000000000e'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-00000000000e';

-- ── 15. Three Things ────────────────────────────────────────
INSERT INTO game_versions (game_id, version_number, definition)
SELECT
  '00000000-0000-4000-8000-00000000000f',
  (SELECT MAX(version_number) + 1 FROM game_versions
     WHERE game_id = '00000000-0000-4000-8000-00000000000f'),
  definition || $json${"options":[
    "This round: name 5 things instead of 3.",
    "This round: things must be from our own house specifically.",
    "This round: no thinking time — start the moment the category is read.",
    "This round: name your things in alphabetical order."
  ]}$json$::jsonb
FROM game_versions
WHERE game_id = '00000000-0000-4000-8000-00000000000f'
  AND NOT (definition ? 'options')
ORDER BY version_number DESC LIMIT 1
ON CONFLICT (game_id, version_number) DO NOTHING;

UPDATE games SET current_version_id = (
  SELECT id FROM game_versions
  WHERE game_id = '00000000-0000-4000-8000-00000000000f'
  ORDER BY version_number DESC LIMIT 1
) WHERE id = '00000000-0000-4000-8000-00000000000f';
