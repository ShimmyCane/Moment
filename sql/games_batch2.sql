-- Moment — Games Batch 2 (50 games)
-- Run AFTER schema.sql + seed.sql + graphic_upgrade.sql.
-- All games start as status='draft'. Activate via admin panel.
-- Safe to re-run (ON CONFLICT DO NOTHING).
--
-- IDs: 00000000-0000-4000-8000-000000000010 through ...000041
-- Categories: 10 per category × 5 = 50 games
-- Difficulty: Easy (E), Medium (M), Hard (H) noted in definition JSONB

-- ============================================================
-- SCHEMA PATCH — allow draft games without a wheel slot
-- ============================================================

ALTER TABLE games ALTER COLUMN wheel_slot DROP NOT NULL;
ALTER TABLE games DROP CONSTRAINT IF EXISTS games_wheel_slot_key;
CREATE UNIQUE INDEX IF NOT EXISTS uidx_games_wheel_slot
  ON games(wheel_slot)
  WHERE wheel_slot IS NOT NULL;

-- ============================================================
-- 1. GAMES (all draft, no wheel slot assigned yet)
-- ============================================================

INSERT INTO games (id, slug, title, short_label, category, wheel_slot, status, emoji) VALUES
  -- ── Observation ───────────────────────────────────────────
  ('00000000-0000-4000-8000-000000000010','color-count',        'Color Count',           'Color Count',    'observation',    NULL,'draft','🎨'),
  ('00000000-0000-4000-8000-000000000011','mirror-game',        'Mirror Game',           'Mirror Game',    'observation',    NULL,'draft','🪞'),
  ('00000000-0000-4000-8000-000000000012','texture-safari',     'Texture Safari',        'Texture Safari', 'observation',    NULL,'draft','🤏'),
  ('00000000-0000-4000-8000-000000000013','detail-close-up',    'Detail Close-Up',       'Detail Close-Up','observation',    NULL,'draft','🔎'),
  ('00000000-0000-4000-8000-000000000014','copycat-sequence',   'Copycat Sequence',      'Copycat Seq.',   'observation',    NULL,'draft','🐒'),
  ('00000000-0000-4000-8000-000000000015','spot-the-lie',       'Spot the Lie',          'Spot the Lie',   'observation',    NULL,'draft','🕵️'),
  ('00000000-0000-4000-8000-000000000016','background-noise',   'Background Noise',      'Bkgd Noise',     'observation',    NULL,'draft','🔊'),
  ('00000000-0000-4000-8000-000000000017','memory-tray',        'Memory Tray',           'Memory Tray',    'observation',    NULL,'draft','🧠'),
  ('00000000-0000-4000-8000-000000000018','scene-recall',       'Scene Recall',          'Scene Recall',   'observation',    NULL,'draft','📷'),
  ('00000000-0000-4000-8000-000000000019','slow-motion-mime',   'Slow Motion Mime',      'Slow Mime',      'observation',    NULL,'draft','🐌'),
  -- ── Imagination ───────────────────────────────────────────
  ('00000000-0000-4000-8000-00000000001a','one-word-character', 'One-Word Character',    '1-Word Char.',   'imagination',    NULL,'draft','🎭'),
  ('00000000-0000-4000-8000-00000000001b','caption-contest',    'Caption Contest',       'Caption Contest','imagination',    NULL,'draft','💬'),
  ('00000000-0000-4000-8000-00000000001c','story-add-one',      'Story Add-One',         'Story Add-One',  'imagination',    NULL,'draft','✍️'),
  ('00000000-0000-4000-8000-00000000001d','time-machine',       'Time Machine',          'Time Machine',   'imagination',    NULL,'draft','⏰'),
  ('00000000-0000-4000-8000-00000000001e','alternative-uses',   'Alternative Uses',      'Alt. Uses',      'imagination',    NULL,'draft','💡'),
  ('00000000-0000-4000-8000-00000000001f','fairy-tale-twist',   'Fairy Tale Twist',      'Fairy Twist',    'imagination',    NULL,'draft','🧚'),
  ('00000000-0000-4000-8000-000000000020','future-invention',   'Future Invention',      'Future Invent.', 'imagination',    NULL,'draft','🔬'),
  ('00000000-0000-4000-8000-000000000021','reverse-world',      'Reverse World',         'Reverse World',  'imagination',    NULL,'draft','🙃'),
  ('00000000-0000-4000-8000-000000000022','character-mashup',   'Character Mashup',      'Char. Mashup',   'imagination',    NULL,'draft','🦄'),
  ('00000000-0000-4000-8000-000000000023','dream-job-2100',     'Dream Job 2100',        'Dream Job 2100', 'imagination',    NULL,'draft','🌟'),
  -- ── Learning ──────────────────────────────────────────────
  ('00000000-0000-4000-8000-000000000024','animal-abc',         'Animal ABC',            'Animal ABC',     'learning',       NULL,'draft','🐘'),
  ('00000000-0000-4000-8000-000000000025','true-or-false-facts','True or False!',        'True or False!', 'learning',       NULL,'draft','✅'),
  ('00000000-0000-4000-8000-000000000026','country-chain',      'Country Chain',         'Country Chain',  'learning',       NULL,'draft','🌍'),
  ('00000000-0000-4000-8000-000000000027','map-from-memory',    'Map from Memory',       'Map Memory',     'learning',       NULL,'draft','🗺️'),
  ('00000000-0000-4000-8000-000000000028','word-family-race',   'Word Family Race',      'Word Family',    'learning',       NULL,'draft','📚'),
  ('00000000-0000-4000-8000-000000000029','body-trick-science', 'Body Trick Science',    'Body Tricks',    'learning',       NULL,'draft','🧬'),
  ('00000000-0000-4000-8000-00000000002a','time-math',          'Time Math',             'Time Math',      'learning',       NULL,'draft','⏱️'),
  ('00000000-0000-4000-8000-00000000002b','science-riddle',     'Science Riddle',        'Science Riddle', 'learning',       NULL,'draft','🔭'),
  ('00000000-0000-4000-8000-00000000002c','mini-debate',        'Mini Debate',           'Mini Debate',    'learning',       NULL,'draft','🎤'),
  ('00000000-0000-4000-8000-00000000002d','word-etymology',     'Word Etymology',        'Word Origins',   'learning',       NULL,'draft','📜'),
  -- ── Conversation ──────────────────────────────────────────
  ('00000000-0000-4000-8000-00000000002e','rose-bud-thorn',     'Rose Bud Thorn',        'Rose Bud Thorn', 'conversation',   NULL,'draft','🌹'),
  ('00000000-0000-4000-8000-00000000002f','gratitude-round',    'Gratitude Round',       'Gratitude',      'conversation',   NULL,'draft','🙏'),
  ('00000000-0000-4000-8000-000000000030','dinner-table-tour',  'Dinner Table Tour',     'Dinner Tour',    'conversation',   NULL,'draft','🍽️'),
  ('00000000-0000-4000-8000-000000000031','desert-island',      'Desert Island',         'Desert Island',  'conversation',   NULL,'draft','🏝️'),
  ('00000000-0000-4000-8000-000000000032','compliment-circle',  'Compliment Circle',     'Compliments',    'conversation',   NULL,'draft','💝'),
  ('00000000-0000-4000-8000-000000000033','change-one-thing',   'Change One Thing',      'Change 1 Thing', 'conversation',   NULL,'draft','🔄'),
  ('00000000-0000-4000-8000-000000000034','hot-takes',          'Hot Takes',             'Hot Takes',      'conversation',   NULL,'draft','🌶️'),
  ('00000000-0000-4000-8000-000000000035','advice-to-young-self','Advice to Young Self', 'Young Self',     'conversation',   NULL,'draft','📝'),
  ('00000000-0000-4000-8000-000000000036','family-values',      'Family Values',         'Family Values',  'conversation',   NULL,'draft','❤️'),
  ('00000000-0000-4000-8000-000000000037','future-me',          'Future Me',             'Future Me',      'conversation',   NULL,'draft','🌈'),
  -- ── Quick Challenge ───────────────────────────────────────
  ('00000000-0000-4000-8000-000000000038','lightning-round',    'Lightning Round',       'Lightning Rnd',  'quick_challenge',NULL,'draft','⚡'),
  ('00000000-0000-4000-8000-000000000039','tongue-twister',     'Tongue Twister',        'Tongue Twister', 'quick_challenge',NULL,'draft','👅'),
  ('00000000-0000-4000-8000-00000000003a','freeze-frame',       'Freeze Frame',          'Freeze Frame',   'quick_challenge',NULL,'draft','🧊'),
  ('00000000-0000-4000-8000-00000000003b','one-minute-story',   'One Minute Story',      '1-Min Story',    'quick_challenge',NULL,'draft','⏳'),
  ('00000000-0000-4000-8000-00000000003c','sentence-backwards', 'Sentence Backwards',    'Sentence Bkwd',  'quick_challenge',NULL,'draft','🔁'),
  ('00000000-0000-4000-8000-00000000003d','balance-and-talk',   'Balance & Talk',        'Balance & Talk', 'quick_challenge',NULL,'draft','🧘'),
  ('00000000-0000-4000-8000-00000000003e','paper-airplane',     'Paper Airplane',        'Paper Airplane', 'quick_challenge',NULL,'draft','✈️'),
  ('00000000-0000-4000-8000-00000000003f','impossible-pose',    'Impossible Pose',       'Impossible Pose','quick_challenge',NULL,'draft','🤸'),
  ('00000000-0000-4000-8000-000000000040','speed-alphabet',     'Speed Alphabet',        'Speed Alphabet', 'quick_challenge',NULL,'draft','🅰️'),
  ('00000000-0000-4000-8000-000000000041','beat-detective',     'Beat Detective',        'Beat Detective', 'quick_challenge',NULL,'draft','🥁')
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 2. GAME VERSIONS
-- ============================================================

-- ── Observation ──────────────────────────────────────────────

INSERT INTO game_versions (id, game_id, version_number, definition) VALUES
(
  '00000001-0000-4000-8000-000000000010',
  '00000000-0000-4000-8000-000000000010', 1,
  $json${"schema_version":"1.0","title":"Color Count","category":"observation","difficulty":"easy","tags":["observation","colors","speed"],"duration_min":1,"duration_max":2,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","waiting","restaurant"],"languages":["en"],"educational_topics":["colors","counting"],"interaction":"competitive","template":"observation_game","instructions":["Everyone looks around the room (or out the window in a car) for exactly 30 seconds.","Count how many distinct colors you can spot — each object only counts once.","When time is up, everyone announces their count.","Highest count wins. Ties go to whoever can name their colors fastest."],"variants":["Pick a specific shade: how many shades of blue?","Limit to one object category: colors on clothing only."],"scoring":{"type":"winner_takes_one","description":"Most colors spotted gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000011',
  '00000000-0000-4000-8000-000000000011', 1,
  $json${"schema_version":"1.0","title":"Mirror Game","category":"observation","difficulty":"easy","tags":["observation","movement","attention","cooperation"],"duration_min":2,"duration_max":4,"players_min":2,"players_max":6,"energy":"active","materials":[],"contexts":["home","table"],"languages":["en"],"educational_topics":[],"interaction":"cooperative","template":"physical_challenge","instructions":["Pair up. One player is the Leader, one is the Mirror.","The Leader moves slowly — hands, head, face, shoulders. No talking.","The Mirror copies every movement exactly and simultaneously, as if they are a reflection.","After 60 seconds, swap roles. Goal: make it impossible to tell who is leading."],"variants":["Allow the Mirror to occasionally take over without announcement — the Leader must notice.","Play with three people: one Leader, two Mirrors."],"scoring":{"type":"group_vote","description":"Other players vote for the pair that looked most like a real mirror. Best pair gets +1 each."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000012',
  '00000000-0000-4000-8000-000000000012', 1,
  $json${"schema_version":"1.0","title":"Texture Safari","category":"observation","difficulty":"easy","tags":["observation","touch","nature","sensory"],"duration_min":2,"duration_max":4,"players_min":2,"players_max":6,"energy":"active","materials":[],"contexts":["home","outdoors","waiting"],"languages":["en"],"educational_topics":["science","nature","vocabulary"],"interaction":"cooperative","template":"observation_game","instructions":["Agree on a list of textures: rough, smooth, soft, bumpy, sharp, cold, warm, fuzzy, hard, slimy.","Players race to find and touch one real object matching each texture.","Shout out the texture and show the object when you find one.","First to complete all 10 textures (or the most in 2 minutes) wins."],"variants":["Eyes closed: someone hands you objects and you identify the texture by touch alone.","Rate each object 1-10 for how well it matches the texture."],"scoring":{"type":"winner_takes_one","description":"Most textures found in 2 minutes gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000013',
  '00000000-0000-4000-8000-000000000013', 1,
  $json${"schema_version":"1.0","title":"Detail Close-Up","category":"observation","difficulty":"medium","tags":["observation","memory","attention","detail"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","table","waiting"],"languages":["en"],"educational_topics":[],"interaction":"competitive","template":"observation_game","instructions":["Pick any nearby object — a cup, a shoe, a book.","Everyone studies it for 60 seconds. Notice color, texture, marks, writing, shape, weight.","Put it out of sight. The player who studied it longest goes last.","Take turns: describe one detail nobody else has mentioned yet. The last player standing wins."],"variants":["First player sets a 30-second timer — everyone must remember details before time runs out.","Allow yes/no questions about the object instead of stating facts."],"scoring":{"type":"winner_takes_one","description":"Last player to successfully add a unique detail gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000014',
  '00000000-0000-4000-8000-000000000014', 1,
  $json${"schema_version":"1.0","title":"Copycat Sequence","category":"observation","difficulty":"medium","tags":["observation","memory","movement","sequence"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":5,"energy":"active","materials":[],"contexts":["home","table"],"languages":["en"],"educational_topics":["memory","pattern recognition"],"interaction":"competitive","template":"physical_challenge","instructions":["The first player does one physical action: clap once.","The second player repeats it and adds a new action: clap, snap.","Continue adding one action each turn.","A player who gets the sequence wrong is out. Last player in wins."],"variants":["Use sounds only (no movement) — clap, snap, tap, stomp, whistle.","After 6 actions, the sequence resets but must include one action from the previous sequence."],"scoring":{"type":"survivor","description":"Last player to make a mistake gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000015',
  '00000000-0000-4000-8000-000000000015', 1,
  $json${"schema_version":"1.0","title":"Spot the Lie","category":"observation","difficulty":"medium","tags":["observation","deduction","humor","bluffing"],"duration_min":3,"duration_max":6,"players_min":3,"players_max":8,"energy":"calm","materials":[],"contexts":["home","table","car","waiting"],"languages":["en"],"educational_topics":[],"interaction":"competitive","template":"observation_game","instructions":["One player makes three statements about things they can observe right now — two true, one false.","Example: 'There are more than 5 windows visible. The floor is darker than the ceiling. There is something red in every corner.'","Others silently observe and decide which statement is false.","Reveal votes. Correct guessers get +1. The liar gets +1 if nobody spots the lie."],"variants":["Allow statements about sounds and smells too, not just things you can see.","Harder: make the lie very specific and plausible."],"scoring":{"type":"mixed","description":"Correct guessers get +1. Liar gets +1 if nobody spots the false statement."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000016',
  '00000000-0000-4000-8000-000000000016', 1,
  $json${"schema_version":"1.0","title":"Background Noise","category":"observation","difficulty":"medium","tags":["listening","observation","awareness","nature"],"duration_min":2,"duration_max":4,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","outdoors","car","waiting"],"languages":["en"],"educational_topics":["science","nature"],"interaction":"competitive","template":"observation_game","instructions":["One player leaves the room or goes around a corner (in a car: one player covers their ears).","The remaining players arrange or create a soundscape using only things present — rustling, tapping, humming.","They call the listener back. The listener closes their eyes and identifies as many separate sounds as possible.","Compare their list to what was actually made. Correct identifications = score."],"variants":["Outside version: sit quietly and catalogue every sound you hear from nature vs. human-made.","Mystery round: one sound is added and the listener must identify what object made it."],"scoring":{"type":"winner_takes_one","description":"Most correct sound identifications gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000017',
  '00000000-0000-4000-8000-000000000017', 1,
  $json${"schema_version":"1.0","title":"Memory Tray","category":"observation","difficulty":"hard","tags":["observation","memory","concentration","classic"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":["tray or flat surface","10-12 small objects"],"contexts":["home","table"],"languages":["en"],"educational_topics":["memory","concentration"],"interaction":"competitive","template":"observation_game","instructions":["Gather 10-12 small objects and arrange them on a tray or table.","Everyone studies the tray for 60 seconds — no notes allowed.","Cover the tray with a cloth. Secretly remove one object.","Reveal the tray again. First player to correctly identify the missing object wins the round."],"variants":["Remove 2-3 objects for a harder round.","Add new objects between rounds instead of (or as well as) removing them."],"scoring":{"type":"winner_takes_one","description":"Correct identification gets +1. Play best-of-5."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000018',
  '00000000-0000-4000-8000-000000000018', 1,
  $json${"schema_version":"1.0","title":"Scene Recall","category":"observation","difficulty":"hard","tags":["observation","memory","attention","detail"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","table"],"languages":["en"],"educational_topics":["memory","spatial awareness"],"interaction":"competitive","template":"observation_game","instructions":["Everyone sits in a room and studies it silently for 90 seconds.","One player leaves the room. While they are gone, other players change 3 things — move an object, open a drawer, turn something upside down.","The absent player returns and tries to identify all 3 changes.","Then roles rotate. Each player takes a turn being the observer."],"variants":["Start with 1 change for younger players, increase to 5 for older.","The returning player also notes one thing that DIDN'T change — a detail others may not have noticed."],"scoring":{"type":"winner_takes_one","description":"Most correct changes spotted gets +1 per correct answer."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000019',
  '00000000-0000-4000-8000-000000000019', 1,
  $json${"schema_version":"1.0","title":"Slow Motion Mime","category":"observation","difficulty":"hard","tags":["observation","performance","movement","attention"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":6,"energy":"active","materials":[],"contexts":["home","table"],"languages":["en"],"educational_topics":[],"interaction":"competitive","template":"physical_challenge","instructions":["One player chooses an everyday activity — making breakfast, opening a door, swimming.","They perform it in extreme slow motion. Every movement takes at least 10× longer than normal.","Others watch carefully and guess the activity. Fast guessing is penalised — wait for a count of 5 before guessing.","Correct guesser takes the next turn. The performer gets +1 if nobody guesses in the full 60 seconds."],"variants":["Add sound effects, also in slow motion.","Two players perform the same activity in slow motion — first to be correctly identified gets +1."],"scoring":{"type":"mixed","description":"Guesser gets +1 for correct guess. Performer gets +1 if nobody guesses."}}$json$::jsonb
)
ON CONFLICT (game_id, version_number) DO NOTHING;

-- ── Imagination ───────────────────────────────────────────────

INSERT INTO game_versions (id, game_id, version_number, definition) VALUES
(
  '00000001-0000-4000-8000-00000000001a',
  '00000000-0000-4000-8000-00000000001a', 1,
  $json${"schema_version":"1.0","title":"One-Word Character","category":"imagination","difficulty":"easy","tags":["storytelling","creativity","character","quick"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["language arts","character development"],"interaction":"cooperative","template":"creative_challenge","instructions":["One player is the Character Builder — everyone else contributes one word.","The Character Builder points at each player in turn and says a category: 'Name!' 'Job!' 'Fear!' 'Special power!' 'Catch phrase!'","Each player instantly says one word. No hesitation allowed.","The Character Builder weaves all the words into a short character introduction."],"variants":["Limit words to adjectives only.","After introducing the character, act out one scene involving them."],"scoring":{"type":"group_vote","description":"Group votes for the funniest character introduction. Winner gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000001b',
  '00000000-0000-4000-8000-00000000001b', 1,
  $json${"schema_version":"1.0","title":"Caption Contest","category":"imagination","difficulty":"easy","tags":["humor","creativity","language","quick"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["language arts","humor"],"interaction":"competitive","template":"creative_challenge","instructions":["One player describes an imaginary, bizarre photo: 'A cat is sitting in a shopping trolley wearing sunglasses. It looks extremely serious.'","Everyone has 30 seconds to invent the best caption for that photo.","Share captions in turn. The group votes for the funniest.","The winner picks the next imaginary photo to caption."],"variants":["Instead of voting, build on each other's captions to make one collaborative mega-caption.","Use real photos from a magazine or book — works just as well."],"scoring":{"type":"group_vote","description":"Most votes for funniest caption gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000001c',
  '00000000-0000-4000-8000-00000000001c', 1,
  $json${"schema_version":"1.0","title":"Story Add-One","category":"imagination","difficulty":"easy","tags":["storytelling","creativity","cooperation","language"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","bedtime","waiting"],"languages":["en"],"educational_topics":["language arts","narrative structure"],"interaction":"cooperative","template":"turn_based_story","instructions":["One player begins: 'Once there was a [anything]...' and adds two sentences.","The next player adds exactly two sentences. Every sentence must begin where the previous one ended.","Continue until the story has gone around twice, then anyone can call 'Ending!' and add a final sentence.","Read the whole story back at the end."],"variants":["Each addition must include at least one sound effect, said aloud.","Sentences must start with the last word of the previous sentence."],"scoring":{"type":"no_score","description":"No winner — read the story back together and celebrate the weirdness."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000001d',
  '00000000-0000-4000-8000-00000000001d', 1,
  $json${"schema_version":"1.0","title":"Time Machine","category":"imagination","difficulty":"medium","tags":["creativity","history","future","imagination","conversation"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["history","science","social studies"],"interaction":"group","template":"conversation_prompt","instructions":["Pick a destination together: a real historical era or a specific future year.","Each player imagines they just arrived and has 2 minutes to prepare.","Take turns answering: What is the first thing you do when you arrive? What is the biggest surprise?","Then discuss: what do you bring back with you — and what do you wish you could change?"],"variants":["Destinations: Ancient Egypt, 2150 AD, a day in your parents' childhood, the day you were born.","Only bring items that fit in one pocket. What do you choose?"],"scoring":{"type":"group_vote","description":"Best single answer (funniest or most creative) gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000001e',
  '00000000-0000-4000-8000-00000000001e', 1,
  $json${"schema_version":"1.0","title":"Alternative Uses","category":"imagination","difficulty":"medium","tags":["creativity","problem-solving","lateral thinking","design thinking"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["design thinking","creative thinking"],"interaction":"competitive","template":"creative_challenge","instructions":["One player picks a common object in the room — a fork, a chair, a sock.","Everyone has 60 seconds to list as many alternative uses as possible. No regular use allowed.","Share your list. One point per unique use that nobody else thought of.","Rotate who picks the object."],"variants":["Objects: a broken umbrella, an empty cardboard box, a pencil, a spoon, a shoelace.","Combine two objects and find uses for the combination."],"scoring":{"type":"unique_answers","description":"+1 per valid use that nobody else listed."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000001f',
  '00000000-0000-4000-8000-00000000001f', 1,
  $json${"schema_version":"1.0","title":"Fairy Tale Twist","category":"imagination","difficulty":"medium","tags":["storytelling","creativity","narrative","humor"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","bedtime"],"languages":["en"],"educational_topics":["language arts","narrative structure","literature"],"interaction":"cooperative","template":"turn_based_story","instructions":["Choose a familiar fairy tale together.","One player announces one rule change before the story begins: 'Cinderella is afraid of nice things' or 'The Big Bad Wolf is actually the hero.'","Retell the story from the beginning with the new rule in effect. Take turns adding 2-3 sentences.","The rule change must affect every major event. If you forget — the next player gets to make another rule change."],"variants":["Set the fairy tale in a modern city.","Combine two fairy tales into one — both must end at the same point."],"scoring":{"type":"group_vote","description":"Vote for the most creative rule change. Best twist gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000020',
  '00000000-0000-4000-8000-000000000020', 1,
  $json${"schema_version":"1.0","title":"Future Invention","category":"imagination","difficulty":"medium","tags":["creativity","science","design thinking","future"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","table","car"],"languages":["en"],"educational_topics":["science","design thinking","engineering"],"interaction":"competitive","template":"creative_challenge","instructions":["Announce the year: 2075. Technology is advanced but families still face real problems.","Each player has 90 seconds to design one invention that does not exist yet.","Present it: give it a name, explain how it works in one sentence, and describe its strangest side effect.","The group votes on which invention they would actually want to exist."],"variants":["The invention must be powered by something unusual: laughter, rainwater, boredom.","The side effect must be more interesting than the main use."],"scoring":{"type":"group_vote","description":"Most votes for invention they'd actually want gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000021',
  '00000000-0000-4000-8000-000000000021', 1,
  $json${"schema_version":"1.0","title":"Reverse World","category":"imagination","difficulty":"hard","tags":["creativity","logic","lateral thinking","humor"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["logic","creative thinking"],"interaction":"group","template":"conversation_prompt","instructions":["Announce a rule reversal: 'In this world, children teach adults. Adults go to school.'","Each player asks one question about what this reversed world is like: 'What do adults learn in school?'","The previous player must answer in-character. The new answer creates the next question.","After 2 full rounds, discuss: what would be better about this world? What would be worse?"],"variants":["Reversals: night and day are swapped / money flows upward from employers to workers / food makes you hungrier.","The rule must apply consistently — every answer must follow the logic of the reversal."],"scoring":{"type":"group_vote","description":"Best answer in the reversed world gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000022',
  '00000000-0000-4000-8000-000000000022', 1,
  $json${"schema_version":"1.0","title":"Character Mashup","category":"imagination","difficulty":"hard","tags":["creativity","storytelling","humor","character"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","table","car","waiting"],"languages":["en"],"educational_topics":["language arts","character development"],"interaction":"competitive","template":"creative_challenge","instructions":["Player 1 names a famous character (real, fictional, or historical). Player 2 names another, completely different character.","Everyone secretly designs a mashup of both: one combined name, one combined power or skill, one glaring contradiction.","Present your mashup to the group with a one-sentence origin story.","The group votes on the mashup they'd most want to watch a movie about."],"variants":["The mashup must also have a fatal weakness combining both originals.","The two characters must be from completely different genres or centuries."],"scoring":{"type":"group_vote","description":"Most votes for their mashup gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000023',
  '00000000-0000-4000-8000-000000000023', 1,
  $json${"schema_version":"1.0","title":"Dream Job 2100","category":"imagination","difficulty":"hard","tags":["creativity","future","problem-solving","career"],"duration_min":5,"duration_max":10,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","table","car"],"languages":["en"],"educational_topics":["design thinking","social studies","futures thinking"],"interaction":"competitive","template":"creative_challenge","instructions":["It's the year 2100. Most old jobs are automated. New problems need new solutions.","Each player invents a job that does not exist today. Give it a job title, one sentence of duties, and a salary in year-2100 currency.","Present it to the group and answer one question from the audience.","Vote: which job is most likely to actually exist? Which would you most want?"],"variants":["The job must specifically address a problem that exists in your family's daily life today.","Job titles must be exactly four words."],"scoring":{"type":"group_vote","description":"+1 for most likely to exist, +1 for most wanted. A player can win both."}}$json$::jsonb
)
ON CONFLICT (game_id, version_number) DO NOTHING;

-- ── Learning ──────────────────────────────────────────────────

INSERT INTO game_versions (id, game_id, version_number, definition) VALUES
(
  '00000001-0000-4000-8000-000000000024',
  '00000000-0000-4000-8000-000000000024', 1,
  $json${"schema_version":"1.0","title":"Animal ABC","category":"learning","difficulty":"easy","tags":["vocabulary","animals","alphabet","knowledge"],"duration_min":2,"duration_max":4,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["vocabulary","animals","alphabet"],"interaction":"competitive","template":"quick_guess","instructions":["Go around the group, one letter at a time: A, B, C...","Each player names a real animal beginning with their letter. No repeating an animal already used.","A player who cannot name an animal in 5 seconds is out.","Last player remaining wins. Skip Q, X, and Z unless someone genuinely knows one."],"variants":["Limit to animals that live in water only, or animals you can find in one country.","For a harder version: name the animal AND one surprising fact about it."],"scoring":{"type":"survivor","description":"Last player in the game gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000025',
  '00000000-0000-4000-8000-000000000025', 1,
  $json${"schema_version":"1.0","title":"True or False!","category":"learning","difficulty":"easy","tags":["knowledge","science","nature","facts"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["science","nature","general knowledge"],"interaction":"competitive","template":"quick_guess","instructions":["One player reads out a fact — true or invented. Example: 'A group of flamingos is called a flamboyance.'","Everyone holds up a thumb for True or a flat hand for False — simultaneously.","Reveal the answer. All correct guessers get +1.","Rotate who announces the fact each round. Make up your own facts or use ones you genuinely know."],"variants":["Starters: 'Octopuses have three hearts.' (True) / 'A sneeze travels at 160 km/h.' (True) / 'Bananas grow underground.' (False)","Points double if you can also explain why the fact is true."],"scoring":{"type":"tally","description":"+1 per correct true/false guess. 5 rounds per game."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000026',
  '00000000-0000-4000-8000-000000000026', 1,
  $json${"schema_version":"1.0","title":"Country Chain","category":"learning","difficulty":"easy","tags":["geography","vocabulary","knowledge","countries"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["geography","social studies"],"interaction":"competitive","template":"quick_guess","instructions":["Player 1 names any country: 'Brazil.'","Player 2 must name a country starting with the last letter of that country: 'Lebanon.'","Player 3 continues: 'Norway.'","A player who cannot continue in 5 seconds is out. No repeating countries."],"variants":["Allow capitals, cities, or rivers — not just countries.","Only countries in a specific continent (easier) or only countries in Africa (harder)."],"scoring":{"type":"survivor","description":"Last player remaining wins +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000027',
  '00000000-0000-4000-8000-000000000027', 1,
  $json${"schema_version":"1.0","title":"Map from Memory","category":"learning","difficulty":"medium","tags":["memory","spatial reasoning","geography","drawing"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":["paper","pens or pencils"],"contexts":["home","table"],"languages":["en"],"educational_topics":["geography","spatial reasoning","memory"],"interaction":"competitive","template":"creative_challenge","instructions":["Pick a route or space everyone knows: the way from the front door to the kitchen; the layout of the school; the street your grandparents live on.","Without looking, each player draws it from memory in 3 minutes.","Compare drawings. Discuss what each person remembered or misremembered.","The group votes on the most accurate map — but also the most creative one."],"variants":["Draw a map of the inside of your own bedroom from memory.","Include labels: room names, distances, landmarks."],"scoring":{"type":"group_vote","description":"One point for most accurate, one point for most creative. Different people can win each."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000028',
  '00000000-0000-4000-8000-000000000028', 1,
  $json${"schema_version":"1.0","title":"Word Family Race","category":"learning","difficulty":"medium","tags":["vocabulary","language","literacy","roots"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["vocabulary","language arts","etymology"],"interaction":"competitive","template":"quick_guess","instructions":["Announce a word root or base word: 'LIGHT', 'HAND', 'OVER', 'FISH', 'PLAY'.","Everyone has 60 seconds to mentally list as many words as possible that share that root.","Go around and share one word at a time. If it's already been said or doesn't count — skip.","When nobody can add a new word, count totals."],"variants":["Roots: un- / re- / -ful / -less / -tion / -er.","For bonus +1: use one of your words in a sentence on the spot."],"scoring":{"type":"tally","description":"Most unique valid words found gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000029',
  '00000000-0000-4000-8000-000000000029', 1,
  $json${"schema_version":"1.0","title":"Body Trick Science","category":"learning","difficulty":"medium","tags":["science","body","optical illusions","explanation"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":6,"energy":"active","materials":[],"contexts":["home","table"],"languages":["en"],"educational_topics":["biology","physics","neuroscience"],"interaction":"group","template":"physical_challenge","instructions":["One player demonstrates a body trick. Everyone tries it. Then the group guesses why it works.","Trick 1: Try to lick your elbow. (Almost nobody can — try for 30 seconds.)","Trick 2: Cross your arms, clasp hands, pull inside out — now touch a finger when someone points (you may touch the wrong one).","Trick 3: Sit in a chair, lift one foot slightly, draw a clockwise circle with it. Now draw a 6 in the air with your hand.","After each trick, take turns explaining the science. The closest explanation gets +1."],"variants":["Add: try to raise your ring finger with your other fingers flat on the table (the tendons are connected).","Research the real explanation beforehand and reveal it at the end."],"scoring":{"type":"group_vote","description":"Best scientific explanation per trick gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000002a',
  '00000000-0000-4000-8000-00000000002a', 1,
  $json${"schema_version":"1.0","title":"Time Math","category":"learning","difficulty":"medium","tags":["math","time","mental arithmetic","estimation"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["mathematics","time","mental arithmetic"],"interaction":"competitive","template":"quick_guess","instructions":["The Questioner asks time-based questions. Fastest correct answer gets the point.","Sample questions: 'How many Sundays are there in a non-leap year?' (52) 'If it is 11:45 am, what time is it in Tokyo if we are 8 hours behind?' 'How many minutes in two and a half days?'","Scale difficulty to ages present. Let younger players use fingers.","Play 5 rounds. Most points wins."],"variants":["Use real-life scenarios: 'We leave at 7:15 and the film is 1h 45min. When do we get home if the drive is 20 minutes?'","Allow 10 seconds per question — use a visual countdown."],"scoring":{"type":"tally","description":"Fastest correct answer per question gets +1. 5 questions per game."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000002b',
  '00000000-0000-4000-8000-00000000002b', 1,
  $json${"schema_version":"1.0","title":"Science Riddle","category":"learning","difficulty":"hard","tags":["science","riddles","deduction","knowledge"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["science","critical thinking","deduction"],"interaction":"competitive","template":"quick_guess","instructions":["One player reads a science riddle — the answer must be a real phenomenon or object.","Others may ask up to 5 yes/no questions to narrow it down, then guess.","Riddle examples: 'I get smaller every time you use me but I never disappear into the bin' (a bar of soap dissolving) / 'I travel faster than anything but I have no mass' (light).","Correct guesser picks the next riddle or makes one up."],"variants":["Riddles must relate to something the family studied this week.","Make up your own riddles — the cleverest new riddle gets bonus +1."],"scoring":{"type":"winner_takes_one","description":"First correct guess gets +1. +1 bonus for inventing a new riddle the others can't solve."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000002c',
  '00000000-0000-4000-8000-00000000002c', 1,
  $json${"schema_version":"1.0","title":"Mini Debate","category":"learning","difficulty":"hard","tags":["reasoning","persuasion","vocabulary","critical thinking"],"duration_min":5,"duration_max":10,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","table"],"languages":["en"],"educational_topics":["language arts","critical thinking","argumentation"],"interaction":"competitive","template":"creative_challenge","instructions":["Pick a fun, low-stakes topic: 'Breakfast is better than dinner' or 'Cats are better pets than dogs.'","Assign sides randomly — you might have to argue for the side you disagree with.","Each player gets 60 seconds to argue their side. Then 30 seconds to rebut the other side.","The audience votes: who made the more convincing argument — regardless of personal opinion."],"variants":["Topics: 'Homework should be banned.' / 'Summer is better than winter.' / 'Books are better than films.'","Allow each side to call one witness (another player) for a 15-second testimony."],"scoring":{"type":"group_vote","description":"Most convincing argument wins +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000002d',
  '00000000-0000-4000-8000-00000000002d', 1,
  $json${"schema_version":"1.0","title":"Word Etymology","category":"learning","difficulty":"hard","tags":["vocabulary","language","history","roots","literacy"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["vocabulary","etymology","language arts","history"],"interaction":"competitive","template":"quick_guess","instructions":["One player announces a word with an interesting origin: 'disaster', 'robot', 'salary', 'muscle', 'nightmare', 'window'.","Others have 60 seconds to guess the original language and meaning.","Reveal the answer. +1 for correct language, +1 for correct original meaning.","Rotate who announces the word. You can use words you genuinely know."],"variants":["Salary: from Latin 'salarium' — payment of salt to Roman soldiers. / Robot: from Czech 'robota' — forced labor. / Window: from Old Norse 'vindauga' — wind eye.","Extra challenge: use the word correctly in a sentence using its original meaning."],"scoring":{"type":"tally","description":"+1 for correct language, +1 for correct meaning. Maximum 2 per round."}}$json$::jsonb
)
ON CONFLICT (game_id, version_number) DO NOTHING;

-- ── Conversation ──────────────────────────────────────────────

INSERT INTO game_versions (id, game_id, version_number, definition) VALUES
(
  '00000001-0000-4000-8000-00000000002e',
  '00000000-0000-4000-8000-00000000002e', 1,
  $json${"schema_version":"1.0","title":"Rose Bud Thorn","category":"conversation","difficulty":"easy","tags":["reflection","wellbeing","family","check-in"],"duration_min":3,"duration_max":8,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","table","bedtime","car"],"languages":["en"],"educational_topics":["social-emotional learning","reflection"],"interaction":"group","template":"conversation_prompt","instructions":["Rose: share one good thing that happened today — a highlight or something that made you smile.","Bud: share one thing you are looking forward to, however small: 'I'm excited about Thursday's lunch.'","Thorn: share one thing that was difficult, frustrating, or didn't go how you hoped.","Go around once. Nobody is required to solve the Thorns — just listen."],"variants":["Add a fourth: 'Root' — something you are grateful for about your family or home.","Use physical gestures: hands open for Rose, fingers together for Bud, one finger pointed for Thorn."],"scoring":{"type":"no_score","description":"No scoring — this one is about connection, not competition."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000002f',
  '00000000-0000-4000-8000-00000000002f', 1,
  $json${"schema_version":"1.0","title":"Gratitude Round","category":"conversation","difficulty":"easy","tags":["gratitude","wellbeing","family","reflection"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","table","bedtime","car"],"languages":["en"],"educational_topics":["social-emotional learning","mindfulness"],"interaction":"group","template":"conversation_prompt","instructions":["Each player names three specific things they are grateful for from today or this week.","Rule: no repeating what someone else has already said.","Rule: at least one must be something very small — a comfortable chair, the smell of dinner, a moment of quiet.","After all shares, the group picks the most surprising or touching gratitude to talk about more."],"variants":["Write them on paper and fold them up — mix and read them aloud anonymously.","One must relate to another person in the room."],"scoring":{"type":"no_score","description":"No scoring — pure reflection."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000030',
  '00000000-0000-4000-8000-000000000030', 1,
  $json${"schema_version":"1.0","title":"Dinner Table Tour","category":"conversation","difficulty":"easy","tags":["check-in","family","storytelling","daily life"],"duration_min":3,"duration_max":8,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","table","bedtime"],"languages":["en"],"educational_topics":["social-emotional learning","communication"],"interaction":"group","template":"conversation_prompt","instructions":["Go around the table. Each person shares one story from their day — not a summary, but a specific moment.","The story must have a beginning, middle, and end: 'I was in the queue and then...'","After each story, the next person asks one follow-up question before sharing their own story.","Rule: phones put face-down. Eye contact with the storyteller."],"variants":["The story must begin with: 'The strangest thing happened...'","Take turns picking a prompt: 'best conversation you had today' / 'something that surprised you'."],"scoring":{"type":"no_score","description":"No scoring — this is the game."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000031',
  '00000000-0000-4000-8000-000000000031', 1,
  $json${"schema_version":"1.0","title":"Desert Island","category":"conversation","difficulty":"medium","tags":["values","priorities","creativity","conversation"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["social-emotional learning","values","decision making"],"interaction":"group","template":"conversation_prompt","instructions":["You are stranded on a beautiful island. You have food, shelter, and water — but nothing else.","You can bring exactly 3 items from your current life. Not people — objects only.","Share your 3 items and explain each one. Be specific: not 'a book' but 'my mum's favourite cookbook.'","The group asks one challenging question per item: 'Why that one and not something more useful?'"],"variants":["Change the scenario: a long space voyage / a year in Antarctica / the last day before everything changes.","One of your 3 items must surprise the group — something they wouldn't expect from you."],"scoring":{"type":"no_score","description":"No winner — the conversation is the point."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000032',
  '00000000-0000-4000-8000-000000000032', 1,
  $json${"schema_version":"1.0","title":"Compliment Circle","category":"conversation","difficulty":"medium","tags":["kindness","empathy","family","connection"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","table","bedtime"],"languages":["en"],"educational_topics":["social-emotional learning","empathy","communication"],"interaction":"group","template":"conversation_prompt","instructions":["Focus on one player for one minute — let's call them the Star.","Everyone else gives one specific compliment about something they noticed recently.","Rule: no generic compliments ('You're nice'). Must be specific: 'You remembered what I said about my project and asked how it went.'","The Star may only respond with 'Thank you' and nothing else during the round. Switch Stars."],"variants":["Written round: pass a piece of paper. Everyone writes one compliment and folds it over.","The compliment must relate to something that happened in the last 7 days."],"scoring":{"type":"no_score","description":"No winner — only connection."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000033',
  '00000000-0000-4000-8000-000000000033', 1,
  $json${"schema_version":"1.0","title":"Change One Thing","category":"conversation","difficulty":"medium","tags":["reflection","values","problem-solving","conversation"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","table","bedtime"],"languages":["en"],"educational_topics":["social-emotional learning","reflection","decision making"],"interaction":"group","template":"conversation_prompt","instructions":["Each person thinks about today — or this week — and identifies one thing they would change if they could redo it.","Share your change. Be honest but kind. It can be something you did, said, thought, or missed.","After sharing: what would you do differently? Is it something you can still fix?","Nobody is allowed to comment negatively on anyone else's change. Only listen and ask one gentle question."],"variants":["Apply to the family as a whole: 'One thing we'd change about this week as a family.'","Look further back: change one thing from this year."],"scoring":{"type":"no_score","description":"No scoring — this is reflection, not competition."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000034',
  '00000000-0000-4000-8000-000000000034', 1,
  $json${"schema_version":"1.0","title":"Hot Takes","category":"conversation","difficulty":"medium","tags":["opinions","humor","values","conversation","debate"],"duration_min":4,"duration_max":8,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","table","car"],"languages":["en"],"educational_topics":["social-emotional learning","critical thinking","communication"],"interaction":"group","template":"conversation_prompt","instructions":["Each player shares one unpopular or surprising opinion they genuinely hold — about food, habits, entertainment, family rules, anything.","Rule: opinions must be low-stakes and not hurtful. 'Cold pizza is better than hot pizza.' Not 'I dislike a family member.'","After each hot take, others give a thumbs up if they secretly agree or a thumbs down if they don't.","Discuss the most divisive takes — the ones that split the table."],"variants":["Hot take must be about the family itself: 'We are at our best on Saturday mornings.'","Most surprising take (the one nobody expected) gets bonus recognition."],"scoring":{"type":"group_vote","description":"Most divisive take (closest split) wins +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000035',
  '00000000-0000-4000-8000-000000000035', 1,
  $json${"schema_version":"1.0","title":"Advice to Young Self","category":"conversation","difficulty":"hard","tags":["reflection","values","empathy","storytelling"],"duration_min":5,"duration_max":10,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","table","bedtime"],"languages":["en"],"educational_topics":["social-emotional learning","reflection","empathy"],"interaction":"group","template":"conversation_prompt","instructions":["Think of yourself at a specific younger age: 5, 10, or your child's current age.","Compose one piece of advice you would give that younger version of yourself — must be specific, not generic.","Share it. Then answer one question from the group: 'Why didn't you know this then?'","Optional follow-up: is there anything your younger self knew that you've since forgotten?"],"variants":["Write the advice as the opening of a letter. Read it aloud.","Parent and child swap: the child gives advice to their parent's younger self."],"scoring":{"type":"no_score","description":"No scoring — the depth of conversation is the reward."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000036',
  '00000000-0000-4000-8000-000000000036', 1,
  $json${"schema_version":"1.0","title":"Family Values","category":"conversation","difficulty":"hard","tags":["values","family identity","reflection","conversation"],"duration_min":6,"duration_max":12,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","table"],"languages":["en"],"educational_topics":["social-emotional learning","values","family identity"],"interaction":"group","template":"conversation_prompt","instructions":["Each player secretly writes or thinks of 3 words they believe describe your family's core values.","Share and group similar words together on a surface.","As a family, narrow down to exactly 3 values that everyone can agree on.","For each value: give one example from real life — something the family did or said that showed this value in action."],"variants":["Disagreement is welcome — defend your choice with evidence, not just feeling.","Display the 3 values somewhere visible for a week and look for examples in daily life."],"scoring":{"type":"no_score","description":"No scoring — the outcome is a shared identity statement."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000037',
  '00000000-0000-4000-8000-000000000037', 1,
  $json${"schema_version":"1.0","title":"Future Me","category":"conversation","difficulty":"hard","tags":["reflection","goals","imagination","identity"],"duration_min":5,"duration_max":10,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","table","bedtime"],"languages":["en"],"educational_topics":["social-emotional learning","goal setting","identity"],"interaction":"group","template":"conversation_prompt","instructions":["Each person imagines themselves exactly 10 years from now.","Answer three questions: Where are you? What are you doing most days? What does your face look like when you're happy?","Share your answers. The group asks one question about the future you described.","Then: what would you need to do in the next year to make that future more likely?"],"variants":["5-year version for younger players.","Describe one typical Tuesday in your future life — morning to evening."],"scoring":{"type":"no_score","description":"No scoring — the conversation is the point."}}$json$::jsonb
)
ON CONFLICT (game_id, version_number) DO NOTHING;

-- ── Quick Challenge ───────────────────────────────────────────

INSERT INTO game_versions (id, game_id, version_number, definition) VALUES
(
  '00000001-0000-4000-8000-000000000038',
  '00000000-0000-4000-8000-000000000038', 1,
  $json${"schema_version":"1.0","title":"Lightning Round","category":"quick_challenge","difficulty":"easy","tags":["vocabulary","speed","knowledge","quick"],"duration_min":2,"duration_max":4,"players_min":2,"players_max":8,"energy":"active","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["vocabulary","general knowledge"],"interaction":"competitive","template":"quick_guess","instructions":["Announce a category: 'Things you find in a kitchen.'","The active player must name 5 things in that category in under 15 seconds.","No hesitation longer than 2 seconds — if they freeze, count to 3 then move on.","Success = +1. Rotate the active player each round."],"variants":["Categories: things that are round / things in a school bag / things that make noise / types of weather.","Harder: items must be in alphabetical order within the category."],"scoring":{"type":"tally","description":"+1 for successfully naming 5 things before time runs out."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000039',
  '00000000-0000-4000-8000-000000000039', 1,
  $json${"schema_version":"1.0","title":"Tongue Twister","category":"quick_challenge","difficulty":"easy","tags":["language","pronunciation","humor","quick"],"duration_min":2,"duration_max":4,"players_min":2,"players_max":8,"energy":"active","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["language arts","phonics","pronunciation"],"interaction":"competitive","template":"quick_guess","instructions":["Announce a tongue twister. Everyone tries to say it correctly three times fast.","Anyone who makes a mistake on the third attempt is out for that round.","The last player to say it without a mistake wins the round.","Twisters: 'She sells seashells.' / 'Red lorry yellow lorry.' / 'Unique New York.' / 'Toy boat.' / 'Irish wristwatch.'"],"variants":["Invent your own tongue twister using the family's names.","Say it in slow motion first, then gradually speed up."],"scoring":{"type":"survivor","description":"Last player without a mistake wins +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000003a',
  '00000000-0000-4000-8000-00000000003a', 1,
  $json${"schema_version":"1.0","title":"Freeze Frame","category":"quick_challenge","difficulty":"easy","tags":["movement","body control","humor","quick"],"duration_min":2,"duration_max":4,"players_min":2,"players_max":8,"energy":"active","materials":[],"contexts":["home","table","outdoors"],"languages":["en"],"educational_topics":["body awareness","self-regulation"],"interaction":"competitive","template":"physical_challenge","instructions":["Everyone moves around freely — walking, dancing, anything.","When the caller shouts 'Freeze!' everyone must stop completely still in whatever position they are in.","The caller studies the frozen poses and picks the funniest or most interesting one.","That player calls the next round."],"variants":["Call a theme when you shout Freeze: 'Freeze — you're a tree!' and everyone must hold their pose as a tree.","Add: keep your eyes open and hold the pose for 20 seconds without blinking or moving."],"scoring":{"type":"group_vote","description":"Funniest or most creative freeze pose wins +1 each round."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000003b',
  '00000000-0000-4000-8000-00000000003b', 1,
  $json${"schema_version":"1.0","title":"One Minute Story","category":"quick_challenge","difficulty":"medium","tags":["storytelling","timing","language","quick"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["language arts","narrative structure","time management"],"interaction":"competitive","template":"creative_challenge","instructions":["One player starts a story. They have exactly 60 seconds.","The story must have a beginning, a complication, and a resolution — all in 60 seconds.","One other player silently watches the clock. When 55 seconds pass they hold up 5 fingers as a silent warning.","If you end before 55 seconds or go past 65 seconds, no score. End within the window: +1."],"variants":["Story must include one word chosen by the audience before you begin.","Start mid-story: 'And that is when she saw the dragon was actually wearing a tiny hat...'"],"scoring":{"type":"timed_success","description":"+1 for completing a coherent story between 55 and 65 seconds."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000003c',
  '00000000-0000-4000-8000-00000000003c', 1,
  $json${"schema_version":"1.0","title":"Sentence Backwards","category":"quick_challenge","difficulty":"medium","tags":["language","memory","quick","humor"],"duration_min":2,"duration_max":4,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["language arts","memory","working memory"],"interaction":"competitive","template":"quick_guess","instructions":["Say a short sentence aloud: 'The cat sat on the mat.'","The active player must repeat it in reverse word order: 'Mat the on sat cat the.'","Start simple (3-4 words) and increase length each round.","If they get it right on first attempt: +1. If they need a repeat: 0."],"variants":["Sentences: 'I like cold pizza.' / 'We are playing a game.' / 'The dog jumped over the fence.'","Reverse the letters in each word as well as the word order — for a very hard version."],"scoring":{"type":"tally","description":"+1 for correct reversal on first attempt. Rounds increase in difficulty."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000003d',
  '00000000-0000-4000-8000-00000000003d', 1,
  $json${"schema_version":"1.0","title":"Balance & Talk","category":"quick_challenge","difficulty":"medium","tags":["movement","language","body control","multitasking"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":6,"energy":"active","materials":[],"contexts":["home","table","outdoors"],"languages":["en"],"educational_topics":["body awareness","communication"],"interaction":"competitive","template":"physical_challenge","instructions":["Stand on one foot. Begin answering the question announced at the start of your turn.","While balancing, answer fully and clearly: 'Name all seven continents' or 'Describe your bedroom without using colors.'","If your foot touches down: answer forfeited. Put foot down intentionally: normal answer.","Balance for minimum 15 seconds AND give a complete answer for +1."],"variants":["Eyes closed while balancing — much harder.","Two players balance simultaneously and answer the same question — score for who balances longer."],"scoring":{"type":"timed_success","description":"+1 for maintaining balance for 15 seconds while answering correctly."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000003e',
  '00000000-0000-4000-8000-00000000003e', 1,
  $json${"schema_version":"1.0","title":"Paper Airplane","category":"quick_challenge","difficulty":"hard","tags":["engineering","design","competition","hands-on"],"duration_min":5,"duration_max":10,"players_min":2,"players_max":6,"energy":"active","materials":["one sheet of paper per player"],"contexts":["home","table","outdoors"],"languages":["en"],"educational_topics":["engineering","physics","design thinking"],"interaction":"competitive","template":"physical_challenge","instructions":["Each player gets one sheet of paper. Everyone folds their airplane in exactly 2 minutes — no help from others.","Test flights: each player gets 3 throws. Measure or estimate the distance of the best throw.","Judging: longest flight gets +1. Best landing accuracy (nearest to a target) gets +1.","Optional: explain one design decision you made."],"variants":["Only allowed to use the basic fold (valley fold) — no cuts or tears.","Design must have a name and a story: 'The Thunderbolt — built for speed after a near-miss with a sock.'"],"scoring":{"type":"measured","description":"+1 for longest flight. +1 for most accurate landing to a target."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000003f',
  '00000000-0000-4000-8000-00000000003f', 1,
  $json${"schema_version":"1.0","title":"Impossible Pose","category":"quick_challenge","difficulty":"hard","tags":["movement","balance","focus","body control"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":6,"energy":"active","materials":[],"contexts":["home","table","outdoors"],"languages":["en"],"educational_topics":["body awareness","self-regulation","focus"],"interaction":"competitive","template":"physical_challenge","instructions":["One player strikes a pose that looks impossible or deeply uncomfortable to hold — think contorted, balanced, or stretched.","Everyone else must hold the same pose for 30 seconds.","While holding it, the pose-setter asks each player a trivia or story question that they must answer aloud.","Fall out of the pose: answer doesn't count. Hold it and answer correctly: +1."],"variants":["The pose must be recreatable from a description only — no looking at the model.","Poses: one leg raised, arms wide, eyes closed / deep squat with arms out / standing on tiptoes with arms above head."],"scoring":{"type":"tally","description":"+1 for holding the pose for 30 seconds AND answering correctly."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000040',
  '00000000-0000-4000-8000-000000000040', 1,
  $json${"schema_version":"1.0","title":"Speed Alphabet","category":"quick_challenge","difficulty":"hard","tags":["vocabulary","speed","knowledge","alphabet"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":8,"energy":"active","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["vocabulary","general knowledge","alphabet"],"interaction":"competitive","template":"quick_guess","instructions":["Announce a category: 'animals', 'countries', 'foods', 'things in a school'.","The active player must name one item from A to Z without stopping — A: anteater, B: buffalo, C: cobra...","Skip X and Z unless you genuinely know one. Allow 3 seconds per letter.","Complete A-W (25 letters skipping X) in under 90 seconds: +1."],"variants":["Team version: alternate letters between two players. One player gets even letters, one odd.","Random start letter — begin at a random point in the alphabet and loop around."],"scoring":{"type":"timed_success","description":"+1 for completing A-Z (skipping X) in the category within 90 seconds."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000041',
  '00000000-0000-4000-8000-000000000041', 1,
  $json${"schema_version":"1.0","title":"Beat Detective","category":"quick_challenge","difficulty":"hard","tags":["music","rhythm","listening","memory"],"duration_min":3,"duration_max":6,"players_min":2,"players_max":8,"energy":"active","materials":[],"contexts":["home","table"],"languages":["en"],"educational_topics":["music","pattern recognition","listening"],"interaction":"competitive","template":"quick_guess","instructions":["One player thinks of a well-known song. They tap out the rhythm on the table — just the beat, no melody, no humming.","Others listen carefully and try to identify the song.","First correct guess wins the round. If nobody guesses in 30 seconds, hum just the first note.","Rotate who taps. Try to choose songs everyone in the group would know."],"variants":["Songs that work well: Happy Birthday, Twinkle Twinkle, Baby Shark, Jingle Bells, BINGO.","Advanced: tap the rhythm for a verse AND chorus without stopping."],"scoring":{"type":"winner_takes_one","description":"First correct guess gets +1."}}$json$::jsonb
)
ON CONFLICT (game_id, version_number) DO NOTHING;

-- ============================================================
-- 3. LINK games → current version
-- ============================================================

UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000010' WHERE id = '00000000-0000-4000-8000-000000000010' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000011' WHERE id = '00000000-0000-4000-8000-000000000011' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000012' WHERE id = '00000000-0000-4000-8000-000000000012' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000013' WHERE id = '00000000-0000-4000-8000-000000000013' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000014' WHERE id = '00000000-0000-4000-8000-000000000014' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000015' WHERE id = '00000000-0000-4000-8000-000000000015' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000016' WHERE id = '00000000-0000-4000-8000-000000000016' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000017' WHERE id = '00000000-0000-4000-8000-000000000017' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000018' WHERE id = '00000000-0000-4000-8000-000000000018' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000019' WHERE id = '00000000-0000-4000-8000-000000000019' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000001a' WHERE id = '00000000-0000-4000-8000-00000000001a' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000001b' WHERE id = '00000000-0000-4000-8000-00000000001b' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000001c' WHERE id = '00000000-0000-4000-8000-00000000001c' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000001d' WHERE id = '00000000-0000-4000-8000-00000000001d' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000001e' WHERE id = '00000000-0000-4000-8000-00000000001e' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000001f' WHERE id = '00000000-0000-4000-8000-00000000001f' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000020' WHERE id = '00000000-0000-4000-8000-000000000020' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000021' WHERE id = '00000000-0000-4000-8000-000000000021' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000022' WHERE id = '00000000-0000-4000-8000-000000000022' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000023' WHERE id = '00000000-0000-4000-8000-000000000023' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000024' WHERE id = '00000000-0000-4000-8000-000000000024' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000025' WHERE id = '00000000-0000-4000-8000-000000000025' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000026' WHERE id = '00000000-0000-4000-8000-000000000026' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000027' WHERE id = '00000000-0000-4000-8000-000000000027' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000028' WHERE id = '00000000-0000-4000-8000-000000000028' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000029' WHERE id = '00000000-0000-4000-8000-000000000029' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000002a' WHERE id = '00000000-0000-4000-8000-00000000002a' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000002b' WHERE id = '00000000-0000-4000-8000-00000000002b' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000002c' WHERE id = '00000000-0000-4000-8000-00000000002c' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000002d' WHERE id = '00000000-0000-4000-8000-00000000002d' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000002e' WHERE id = '00000000-0000-4000-8000-00000000002e' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000002f' WHERE id = '00000000-0000-4000-8000-00000000002f' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000030' WHERE id = '00000000-0000-4000-8000-000000000030' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000031' WHERE id = '00000000-0000-4000-8000-000000000031' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000032' WHERE id = '00000000-0000-4000-8000-000000000032' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000033' WHERE id = '00000000-0000-4000-8000-000000000033' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000034' WHERE id = '00000000-0000-4000-8000-000000000034' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000035' WHERE id = '00000000-0000-4000-8000-000000000035' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000036' WHERE id = '00000000-0000-4000-8000-000000000036' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000037' WHERE id = '00000000-0000-4000-8000-000000000037' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000038' WHERE id = '00000000-0000-4000-8000-000000000038' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000039' WHERE id = '00000000-0000-4000-8000-000000000039' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000003a' WHERE id = '00000000-0000-4000-8000-00000000003a' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000003b' WHERE id = '00000000-0000-4000-8000-00000000003b' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000003c' WHERE id = '00000000-0000-4000-8000-00000000003c' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000003d' WHERE id = '00000000-0000-4000-8000-00000000003d' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000003e' WHERE id = '00000000-0000-4000-8000-00000000003e' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000003f' WHERE id = '00000000-0000-4000-8000-00000000003f' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000040' WHERE id = '00000000-0000-4000-8000-000000000040' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000041' WHERE id = '00000000-0000-4000-8000-000000000041' AND current_version_id IS NULL;
