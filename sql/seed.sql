-- Moment Family Play App — Seed Data v1.0
-- Run AFTER schema.sql in Supabase SQL Editor.
-- Uses stable UUIDs so re-running is safe with ON CONFLICT DO NOTHING.

-- ============================================================
-- 1. GAMES
-- ============================================================
INSERT INTO games (id, slug, title, short_label, category, wheel_slot, status)
VALUES
  ('00000000-0000-4000-8000-000000000001','i-spy-weird',            'I Spy But Weird',          'I Spy Weird',     'observation',    0,  'active'),
  ('00000000-0000-4000-8000-000000000002','sound-detective',        'Sound Detective',           'Sound Detective', 'observation',    1,  'active'),
  ('00000000-0000-4000-8000-000000000003','what-changed',           'What Changed?',             'What Changed?',   'observation',    2,  'active'),
  ('00000000-0000-4000-8000-000000000004','three-word-story',       'Three-Word Story',          '3-Word Story',    'imagination',    3,  'active'),
  ('00000000-0000-4000-8000-000000000005','fortunately-unfortunately','Fortunately Unfortunately','Fort. Unfort.',   'imagination',    4,  'active'),
  ('00000000-0000-4000-8000-000000000006','impossible-invention',   'Impossible Invention',      'Imp. Invention',  'imagination',    5,  'active'),
  ('00000000-0000-4000-8000-000000000007','mystery-number',         'Mystery Number',            'Mystery Number',  'learning',       6,  'active'),
  ('00000000-0000-4000-8000-000000000008','what-doesnt-belong',     'What Doesn''t Belong?',     'Doesn''t Belong?','learning',       7,  'active'),
  ('00000000-0000-4000-8000-000000000009','space-mission',          'Space Mission',             'Space Mission',   'learning',       8,  'active'),
  ('00000000-0000-4000-8000-00000000000a','would-you-rather',       'Would You Rather?',         'Would U Rather?', 'conversation',   9,  'active'),
  ('00000000-0000-4000-8000-00000000000b','superpower-swap',        'Superpower Swap',           'Superpower Swap', 'conversation',   10, 'active'),
  ('00000000-0000-4000-8000-00000000000c','family-forecast',        'Family Forecast',           'Family Forecast', 'conversation',   11, 'active'),
  ('00000000-0000-4000-8000-00000000000d','forbidden-word',         'Forbidden Word',            'Forbidden Word',  'quick_challenge',12, 'active'),
  ('00000000-0000-4000-8000-00000000000e','mini-charades',          'Mini Charades',             'Mini Charades',   'quick_challenge',13, 'active'),
  ('00000000-0000-4000-8000-00000000000f','three-things',           'Three Things',              'Three Things',    'quick_challenge',14, 'active')
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 2. GAME VERSIONS  (one version per game, v1)
-- ============================================================

INSERT INTO game_versions (id, game_id, version_number, definition) VALUES
(
  '00000001-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000001', 1,
  $json${"schema_version":"1.0","title":"I Spy But Weird","category":"observation","tags":["observation","creativity"],"duration_min":1,"duration_max":3,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","waiting","restaurant"],"languages":["en"],"educational_topics":[],"interaction":"competitive","template":"observation_game","instructions":["Pick something nearby without telling anyone what it is.","Describe it with a fun comparison: \"I spy something that looks like a tiny spaceship.\"","Others take turns guessing. The first correct guess wins the round.","If nobody guesses after 3 tries, reveal the answer and pick a new object."],"variants":["Use silly comparisons: 'a sleeping giant', 'a melting castle', 'a confused robot'.","Add a 30-second timer for guessing."],"scoring":{"type":"winner_takes_one","description":"The player who guesses correctly gets +1. If nobody guesses, the spy gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000002',
  '00000000-0000-4000-8000-000000000002', 1,
  $json${"schema_version":"1.0","title":"Sound Detective","category":"observation","tags":["listening","observation","awareness"],"duration_min":1,"duration_max":2,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","waiting","restaurant","outdoors"],"languages":["en"],"educational_topics":["science","nature"],"interaction":"competitive","template":"observation_game","instructions":["Everyone closes their eyes and stays completely silent for 30 seconds.","Each person secretly counts how many different sounds they can hear.","Open your eyes and go around — everyone shares their count and names each sound.","The player who identified the most sounds wins the round."],"variants":["Describe each sound as a character: 'the wind is a sleeping giant'.","Play outside — the variety of sounds is usually much greater."],"scoring":{"type":"winner_takes_one","description":"Most sounds correctly identified gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000003',
  '00000000-0000-4000-8000-000000000003', 1,
  $json${"schema_version":"1.0","title":"What Changed?","category":"observation","tags":["memory","observation","attention"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","table","waiting"],"languages":["en"],"educational_topics":[],"interaction":"competitive","template":"observation_game","instructions":["Everyone studies a small area for 30 seconds.","One player (the Changer) asks everyone to close their eyes.","The Changer makes one small change: moves an object, swaps two things.","Everyone opens their eyes and tries to spot what changed. First correct guess wins."],"variants":["Make 2-3 changes at once for a harder round.","The youngest player is always the Changer."],"scoring":{"type":"winner_takes_one","description":"First correct guess gets +1. The Changer gets +1 if nobody spots the change."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000004',
  '00000000-0000-4000-8000-000000000004', 1,
  $json${"schema_version":"1.0","title":"Three-Word Story","category":"imagination","tags":["storytelling","vocabulary","creativity","language"],"duration_min":3,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["vocabulary","language arts"],"interaction":"cooperative","template":"turn_based_story","instructions":["Go around the circle — each player says exactly one word. Collect three words total.","Announce the three words: everyone must use all three in a single shared story.","Take turns adding one sentence at a time. Each sentence must move the story forward.","Aim for a funny, surprising, or impossible ending."],"variants":["Use vocabulary words from school.","Allow double meanings — the word 'light' can mean a lamp or something weightless."],"scoring":{"type":"group_vote","description":"After the story, everyone votes for the best sentence. Most votes gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000005',
  '00000000-0000-4000-8000-000000000005', 1,
  $json${"schema_version":"1.0","title":"Fortunately Unfortunately","category":"imagination","tags":["storytelling","creativity","language","humor"],"duration_min":3,"duration_max":8,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["language arts","narrative structure"],"interaction":"cooperative","template":"turn_based_story","instructions":["One player starts: \"Fortunately, [something good happened].\"","The next player adds: \"Unfortunately, [something bad happened].\"","Keep alternating Fortunately / Unfortunately, each adding one sentence.","Continue until the story reaches a natural — or wonderfully ridiculous — ending."],"variants":["Starter: 'Fortunately, we found a magical door in the kitchen.'","Challenge: each sentence must connect directly to the one before it."],"scoring":{"type":"group_vote","description":"Vote for the funniest single sentence. Most votes gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000006',
  '00000000-0000-4000-8000-000000000006', 1,
  $json${"schema_version":"1.0","title":"Impossible Invention","category":"imagination","tags":["creativity","problem-solving","humor","design thinking"],"duration_min":3,"duration_max":8,"players_min":2,"players_max":8,"energy":"active","materials":[],"contexts":["home","table","car"],"languages":["en"],"educational_topics":["design thinking","science"],"interaction":"competitive","template":"creative_challenge","instructions":["Someone announces a ridiculous problem — for example: 'Socks that disappear in the dryer.'","Everyone has 60 seconds to invent a machine that solves it.","Take turns pitching your invention: name it, explain it, demonstrate one feature.","The group votes on the best invention. The winner announces the next ridiculous problem."],"variants":["Problems: 'Vegetables children refuse to eat.' / 'Shoes that smell after PE.'","Each invention must have exactly three parts."],"scoring":{"type":"group_vote","description":"Group votes for best invention. Winner gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000007',
  '00000000-0000-4000-8000-000000000007', 1,
  $json${"schema_version":"1.0","title":"Mystery Number","category":"learning","tags":["math","logic","deduction","number sense"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["mathematics","number sense"],"interaction":"competitive","template":"quick_guess","instructions":["One player secretly picks a number. Ages 5-6: pick from 1-20. Ages 7+: pick from 1-100.","Give one clue at a time: 'It is bigger than 10.' 'It is even.' 'You say it counting by 5.'","Others guess after each clue. The player who guesses correctly goes next.","Give clues slowly — the challenge is making it last as long as possible."],"variants":["Use a calculator as a secret helper.","Allow yes/no questions instead of clues."],"scoring":{"type":"winner_takes_one","description":"First correct guess gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000008',
  '00000000-0000-4000-8000-000000000008', 1,
  $json${"schema_version":"1.0","title":"What Doesn't Belong?","category":"learning","tags":["logic","reasoning","classification","vocabulary"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["logic","classification","language arts"],"interaction":"competitive","template":"quick_guess","instructions":["One player names four things: for example, 'apple, banana, chair, orange.'","Everyone secretly decides which one doesn't belong — and, most importantly, why.","Go around and share your answers. Any reason is valid if you can defend it.","Bonus +1 for anyone who gives a reason nobody else thought of."],"variants":["Starters: 'dog, cat, fish, parrot' / 'red, blue, three, green' / 'run, jump, happy, swim'","The youngest player picks the four things."],"scoring":{"type":"group_vote","description":"+1 for a unique and defensible answer that nobody else gave."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-000000000009',
  '00000000-0000-4000-8000-000000000009', 1,
  $json${"schema_version":"1.0","title":"Space Mission","category":"learning","tags":["science","space","creativity","problem-solving"],"duration_min":3,"duration_max":8,"players_min":2,"players_max":6,"energy":"active","materials":[],"contexts":["home","table","car"],"languages":["en"],"educational_topics":["science","space","engineering"],"interaction":"cooperative","template":"creative_challenge","instructions":["Together, choose a destination: the Moon, Mars, Jupiter's moon Europa, or make one up.","The youngest player (Mission Controller) announces one challenge before launch.","The crew invents something to bring from Earth to help them survive there.","Each crew member describes one feature of the invention."],"variants":["Challenges: 'There is no gravity.' / 'It is -100C.' / 'There is no water.'","Draw your invention after the round."],"scoring":{"type":"group_vote","description":"Group votes for most creative invention feature. Winner gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000000a',
  '00000000-0000-4000-8000-00000000000a', 1,
  $json${"schema_version":"1.0","title":"Would You Rather?","category":"conversation","tags":["conversation","values","humor","social"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","car","table","waiting","bedtime"],"languages":["en"],"educational_topics":[],"interaction":"group","template":"conversation_prompt","instructions":["One player poses a dilemma: 'Would you rather have a pet dragon or the ability to fly?'","Everyone secretly chooses A or B — hold up 1 or 2 fingers.","Reveal at the same time, then everyone explains their choice.","The player with the most unusual or surprising answer asks the next question."],"variants":["Starters: 'Eat one food forever, or never eat your favourite food?' / 'Speak to animals, or speak all languages?'","Take turns asking — no voting, just sharing and discussing."],"scoring":{"type":"group_vote","description":"Most unusual or funniest explanation gets +1 (group decides)."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000000b',
  '00000000-0000-4000-8000-00000000000b', 1,
  $json${"schema_version":"1.0","title":"Superpower Swap","category":"conversation","tags":["conversation","empathy","creativity","social"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":6,"energy":"calm","materials":[],"contexts":["home","table","car","bedtime"],"languages":["en"],"educational_topics":[],"interaction":"group","template":"conversation_prompt","instructions":["Pick another player and give them a specific superpower that suits their personality.","Explain why it suits them: 'Felix gets the power to hear thoughts, because he always knows when you're hiding something.'","That player can accept the power — or swap it for something else and explain why.","Continue around until everyone has a power."],"variants":["Add a limitation: 'You can fly, but only backwards.'","Ask: what would be the most annoying side effect of your power?"],"scoring":{"type":"no_score","description":"No winner — this one is just for fun and connection."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000000c',
  '00000000-0000-4000-8000-00000000000c', 1,
  $json${"schema_version":"1.0","title":"Family Forecast","category":"conversation","tags":["conversation","prediction","humor","family"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":8,"energy":"calm","materials":[],"contexts":["home","table","bedtime"],"languages":["en"],"educational_topics":[],"interaction":"group","template":"conversation_prompt","instructions":["Each player predicts one funny or unexpected thing that will happen to the family in the next 24 hours.","Keep your predictions short and specific: 'Someone will spill something at breakfast.'","Write them down — or choose one person to remember all of them.","Check back tomorrow. Award +1 for any prediction that actually happened (even a little)."],"variants":["Predict something about a specific family member.","Make the predictions about next week instead of tomorrow."],"scoring":{"type":"deferred","description":"+1 for any prediction that comes true. Check back tomorrow."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000000d',
  '00000000-0000-4000-8000-00000000000d', 1,
  $json${"schema_version":"1.0","title":"Forbidden Word","category":"quick_challenge","tags":["vocabulary","quick","language","party"],"duration_min":1,"duration_max":3,"players_min":2,"players_max":8,"energy":"active","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["vocabulary","language arts"],"interaction":"competitive","template":"quick_guess","instructions":["One player secretly picks an everyday object — for example, 'umbrella'.","They have 30 seconds to describe it without saying the object's name or obvious synonyms.","Other players guess aloud. The fastest correct guess wins.","If nobody guesses in 30 seconds, the describer gets the point."],"variants":["Objects: umbrella, refrigerator, bicycle, toothbrush, pillow, glasses, clock, sock.","Harder: also forbid related words. 'Umbrella' also forbids 'rain' and 'wet'."],"scoring":{"type":"winner_takes_one","description":"Fastest guesser gets +1. If nobody guesses, the describer gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000000e',
  '00000000-0000-4000-8000-00000000000e', 1,
  $json${"schema_version":"1.0","title":"Mini Charades","category":"quick_challenge","tags":["performance","guessing","movement","party"],"duration_min":2,"duration_max":5,"players_min":2,"players_max":8,"energy":"active","materials":[],"contexts":["home","table"],"languages":["en"],"educational_topics":[],"interaction":"competitive","template":"physical_challenge","instructions":["One player picks a category: Animal, Job, or Storybook Character.","They act it out silently — no sounds, no pointing at objects in the room.","Others guess aloud. First correct guess goes next.","Keep rounds to 30 seconds. Adjust the timer based on age and skill."],"variants":["Animals: penguin, elephant, cat washing its face, bee, kangaroo.","Jobs: chef, doctor, astronaut, firefighter, teacher.","Characters: giant, fairy, dragon, robot, submarine captain."],"scoring":{"type":"winner_takes_one","description":"First correct guesser gets +1."}}$json$::jsonb
),
(
  '00000001-0000-4000-8000-00000000000f',
  '00000000-0000-4000-8000-00000000000f', 1,
  $json${"schema_version":"1.0","title":"Three Things","category":"quick_challenge","tags":["vocabulary","quick","knowledge","party"],"duration_min":1,"duration_max":3,"players_min":2,"players_max":8,"energy":"active","materials":[],"contexts":["home","car","table","waiting"],"languages":["en"],"educational_topics":["vocabulary","general knowledge"],"interaction":"competitive","template":"quick_guess","instructions":["One player announces a category: 'Name three things that glow in the dark.'","Start a 15-second countdown.","The active player must say three different things in that category before time runs out.","If they succeed: +1. If they get stuck, pass to the next player with the same category."],"variants":["Starters: things that fly / things that live underground / things that are always cold / things with wheels.","Increase the required count to 5 for older players."],"scoring":{"type":"winner_takes_one","description":"Successfully naming three things gets +1."}}$json$::jsonb
)
ON CONFLICT (game_id, version_number) DO NOTHING;

-- ============================================================
-- 3. LINK games → current version
-- ============================================================

UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000001'
  WHERE id = '00000000-0000-4000-8000-000000000001' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000002'
  WHERE id = '00000000-0000-4000-8000-000000000002' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000003'
  WHERE id = '00000000-0000-4000-8000-000000000003' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000004'
  WHERE id = '00000000-0000-4000-8000-000000000004' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000005'
  WHERE id = '00000000-0000-4000-8000-000000000005' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000006'
  WHERE id = '00000000-0000-4000-8000-000000000006' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000007'
  WHERE id = '00000000-0000-4000-8000-000000000007' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000008'
  WHERE id = '00000000-0000-4000-8000-000000000008' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-000000000009'
  WHERE id = '00000000-0000-4000-8000-000000000009' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000000a'
  WHERE id = '00000000-0000-4000-8000-00000000000a' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000000b'
  WHERE id = '00000000-0000-4000-8000-00000000000b' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000000c'
  WHERE id = '00000000-0000-4000-8000-00000000000c' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000000d'
  WHERE id = '00000000-0000-4000-8000-00000000000d' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000000e'
  WHERE id = '00000000-0000-4000-8000-00000000000e' AND current_version_id IS NULL;
UPDATE games SET current_version_id = '00000001-0000-4000-8000-00000000000f'
  WHERE id = '00000000-0000-4000-8000-00000000000f' AND current_version_id IS NULL;
