# Moment — Project Schematic

## 1. Vision

Create a lightweight family-play companion that turns small pockets of downtime into opportunities for laughter, imagination, discovery, and connection.

Inspired by the variety, anticipation, and pacing of Mario Party, the app is not one large game. It is a collection of small, varied activities orchestrated into a playful experience.

**The phone is a prompt generator, not the game itself.**

The app should encourage players to put the phone down and interact with one another. The quality of the experience comes from variety, rhythm, surprise, and shared enjoyment—not screen time or complexity.

## 2. Core Principles

- **Low friction:** Start playing in one or two taps.
- **Short by default:** Activities range from 15 seconds to approximately 15 minutes.
- **Offline first:** Prompts and instructions should work without continued screen interaction.
- **Variety over intensity:** Alternate between language, imagination, observation, reasoning, movement, and conversation.
- **Family friendly:** Accommodate different ages, abilities, and attention spans.
- **Playful, not academic:** Educational content should feel like play rather than homework.
- **Optional competition:** Support individual scoring, cooperative goals, and score-free play.
- **Expandable content:** New games should be addable without rewriting the application.
- **Data-informed iteration:** Use play history and feedback to improve the library and selection algorithm.
- **Safe authoring:** Validate all game definitions before they enter the active library.

## 3. Game Categories

Initial categories include:

1. Observation and discovery
2. Storytelling and imagination
3. Language and vocabulary
4. Mathematics and reasoning
5. Science and exploration
6. Creativity and association
7. Social connection and conversation
8. Physical play and performance
9. Quick challenges and party games
10. Quiet reflection and wind-down activities

Categories should be extensible. Games may belong to multiple categories and carry additional tags for educational subjects, language, duration, energy, and context.

## 4. Game Design Model

Separate reusable game mechanics from variable game content.

A game definition describes what the game is, how it works, and what content it uses. A reusable template determines how the game is presented and played.

Examples of templates:

- `turn_based_story`
- `quick_guess`
- `word_association`
- `math_challenge`
- `conversation_prompt`
- `physical_challenge`
- `creative_challenge`
- `observation_game`

A single template should support many variations through configuration, prompts, vocabulary banks, and difficulty settings.

### Required game metadata

Each game should support:

- Stable game ID
- Title and description
- Category and tags
- Estimated minimum and maximum duration
- Minimum and maximum players
- Energy level
- Required materials
- Suitable contexts
- Supported languages: English, Chinese, or mixed
- Educational topics and vocabulary tags
- Interaction type: cooperative, competitive, or individual
- Template identifier
- Game-specific configuration and content
- Instructions, setup, and ending conditions
- Scoring configuration, if any
- Lifecycle status
- Schema version and game version
- Optional experimental metadata

The schema must be extensible without allowing arbitrary fields to bypass validation.

## 5. Application Experience

### Landing page

The landing page is the central experience.

- Animated spinning wheel with polished transitions
- Optional sound effects and tactile feedback
- Clear entry points for quick play, playlists, and custom sessions
- Minimal setup for spontaneous play
- A visual identity that feels playful, warm, and surprising

The wheel should create anticipation, but the app must remain quick to use.

### Game screen

- Display the title, prompt, and concise instructions.
- Provide an obvious way to start, replay, or skip.
- Support game-specific interactions when necessary.
- Make it easy to put the device down.
- Avoid requiring constant screen attention.

### End-of-game screen

Offer optional feedback and scoring.

- Thumbs up, neutral, or thumbs down
- Short notes about what worked or should change
- Optional player scores
- Continue, replay, or return to the playlist

Feedback should be quick enough not to interrupt the fun.

## 6. Players

Fixed family roster: Athena, Felix, Ying, Jimmy, and Guest.

No login or identification required for play. Player selection is confirmed optionally after the first game (as part of the scoring/feedback step).

## 7. Session Modes

- **Quick Spark:** One short activity.
- **Family Mix:** A varied sequence of contrasting activities.
- **Mini Party:** Multiple rounds with optional scoring and winners.
- **Learning Adventure:** Activities drawn from selected educational topics.
- **Wind Down:** Calm, conversational, or imaginative prompts.
- **Custom Session:** User-defined playlists, filters, and selection preferences.

Players should be selectable at the session level, with optional guests. Player setup and scoring must not obstruct quick play.

The application should support both selecting one random game and orchestrating a sequence of games.

## 8. Playlists and Game Selection

Support four primary playlist types.

### Favorites

Automatically populated using positive feedback, favorites, and other configurable criteria.

### New Games

Prioritize games that are newly published or have little or no play history.

Allow recently added games to receive additional exposure without permanently displacing established favorites.

### Balanced Mix

Select games using configurable weights to encourage variety.

Consider:

- Category and template diversity
- Time since the game was last played
- Recent category repetition
- Game duration and energy
- Player count and session context
- Positive and negative feedback
- Underexposed games
- Favorite-game preferences

A game played in the immediately preceding rounds should generally receive a lower selection weight.

Selection should use weighted randomization rather than a rigid sequence. Weights and rules should be configurable and tunable.

### Custom Playlists

Allow users to create playlists with manually selected games, ordering, filters, and selection weights.

Support both fixed-order playlists and randomized playlists.

### Playlist settings

Provide controls for:

- Minimum and maximum duration
- Categories and educational topics
- Languages
- Energy level
- Include or exclude favorites
- New-game exposure
- Repeat frequency
- Whether games can repeat within a session
- Whether scoring is enabled

## 9. Game Library and Analytics

The application should record play history and feedback to support better selection and ongoing improvement.

### Play history

Record individual play events rather than relying only on mutable aggregate counters.

Track:

- Game ID and exact game version
- Session ID
- Timestamp
- Outcome: completed, skipped, or abandoned when known
- Duration when practical
- Playlist and selection mode
- Participating players when applicable

Derive aggregate metrics from these events.

### Game metrics

Track:

- Total plays
- Recent plays
- Last played date
- Completion and skip rates
- Positive, neutral, and negative feedback counts
- Favorite status
- Exposure to new games
- Performance by category and template
- Feedback notes and improvement suggestions

Distinguish raw counts from rates. A game with few plays should not automatically rank below a heavily exposed game.

### Feedback and notes

At the end of a game, allow players or the parent to record:

- Thumbs up, neutral, or thumbs down
- Optional written notes
- Suggested rule changes
- Difficulty or pacing feedback
- Whether the game worked well for the current group

Feedback records should be associated with the game version played, so improvements can be evaluated against previous versions.

### Player and session scoring

Scoring is optional and should support multiple models:

- Individual points
- Group voting
- Cooperative achievements
- Shared family streaks
- Score-free play

Avoid creating a reward system so elaborate that it becomes the purpose of the activity.

## 10. Database Architecture

Use a database as the canonical source of game definitions and application data.

A relational database with JSON support, such as PostgreSQL through Supabase, is the target implementation.

GitHub Pages hosts the static frontend. Supabase provides the database, server-side validation, and publishing operations.

### Core entities

- `games`: Stable identity, current published version, lifecycle status, and catalog metadata.
- `game_versions`: Immutable snapshots of published game definitions.
- `play_sessions`: Session configuration and history.
- `session_players`: Players participating in each session.
- `play_events`: Individual game plays, skips, and outcomes.
- `game_feedback`: Ratings, favorites, notes, and suggestions.
- `playlists`: Built-in and user-created playlist definitions.
- `playlist_items`: Explicit game membership, ordering, and optional weights.

Additional entities may be introduced when required by real functionality.

### Data principles

- Use stable IDs for games, players, sessions, and playlists.
- Store complete game definitions as structured JSON.
- Preserve immutable published game versions.
- Associate play events and feedback with the exact version used.
- Derive aggregate metrics from underlying records where practical.
- Enforce database constraints and access permissions.
- Prevent duplicate or conflicting records where appropriate.
- Use migrations for database schema changes.
- Do not expose privileged database credentials in the frontend.

## 11. LLM-Assisted Game Authoring Studio

Provide an administrative page for creating, reviewing, importing, updating, and publishing games.

The authoring interface should be designed around a structured JSON workflow.

### Authoring workflow

1. Generate a proposed game definition with an LLM.
2. Paste JSON into the authoring interface.
3. Parse and validate the document.
4. Display validation errors and warnings.
5. Preview the game using its intended template.
6. Compare with an existing game or previous version when applicable.
7. Save as a draft.
8. Publish explicitly after review.

### JSON editor

The authoring page should provide:

- Editable JSON text
- A readable game-rules view
- Validation results with useful error locations
- A preview of the rendered game
- A comparison view for revisions
- Draft saving and explicit publishing
- Clear success and failure messages

### Validation and sanitation

Validate both on the client and on the server.

Checks should include:

- Valid JSON syntax
- Supported schema version
- Required fields and correct data types
- Valid IDs, durations, player limits, and enum values
- Recognized template identifiers
- Valid template-specific configuration
- Supported language identifiers
- Properly structured instructions and content
- Valid references to other records
- Duplicate IDs and conflicting versions
- Payload size and nesting limits
- Safe rendering of user-authored text
- Rejection of unsupported fields or explicit handling of approved extension fields

Use a formal schema validator such as JSON Schema with Ajv.

Server-side validation and database constraints are authoritative. Frontend validation is for usability, not security.

Unknown fields should not silently become accepted application behavior.

### Drafts and publishing

Drafts must not automatically appear in normal game selection.

Publishing should create an immutable game-version record, validate the final definition, and explicitly activate the selected version.

Only authorized administrators should be able to create or publish game definitions in the initial release.

## 12. Versioning and Lifecycle Management

Distinguish the stable identity of a game from its individual definitions.

### Lifecycle states

- `draft`: Work in progress, not available for normal play.
- `active`: Eligible for normal selection.
- `deprecated`: Retained for historical purposes but excluded from ordinary selection.
- `archived`: Retained for reference and history, with no ordinary selection.

### Versioning rules

- Published versions are immutable.
- Editing a published game creates a new version.
- The game record identifies its current active version.
- Historical play events continue referencing the version originally played.
- Version comparisons should identify changed fields and rules.
- Reverting should create a new version based on an earlier definition, not overwrite history.
- Deprecating a game must not delete its play history or feedback.

### Library management

Provide sorting and filtering by:

- Name and category
- Creation and publication date
- Last played
- Total and recent play counts
- Rating and feedback
- Version and lifecycle status
- Educational topic and template

Allow administrators to deprecate, reactivate where appropriate, archive, and revise games without losing historical data.

## 13. Content Architecture and Expansion

Separate reusable content banks from game mechanics.

Potential content banks:

- English vocabulary
- Chinese vocabulary
- Grammar structures and sentence patterns
- Mathematics challenges
- Space and astronomy
- Color associations
- Conversation prompts
- Story ingredients and character ideas

New educational topics should be incorporable without modifying the core application.

### Initial game batches

- Batch 01: Core games and simple party mechanics
- Batch 02: Storytelling, vocabulary, and language
- Batch 03: Mathematics, science, and learning
- Batch 04: Social connection and conversation
- Batch 05: Observation, movement, and creative play

These batches are development and organization groupings, not permanent application categories.

The database is the canonical source of published game content. JSON files may be used for authoring, import/export, templates, backups, and version-controlled reference material.

## 14. MVP Scope

### Required

1. Polished landing page with an animated wheel.
2. Approximately 12–20 varied games.
3. Reusable game templates and structured game definitions.
4. Database-backed game library (Supabase).
5. Basic player and session selection (fixed roster: Athena, Felix, Ying, Jimmy, Guest).
6. Simple per-player scoring (optional tap-to-increment tally).
7. Play-event recording.
8. Optional game feedback (thumbs up/neutral/down + notes).
9. Favorites and basic new-game selection.
10. A functional JSON authoring studio.
11. Client-side and server-side validation.
12. Draft creation and explicit publishing.
13. Immutable published game versions.
14. Basic game sorting and deprecation.
15. A foundation for playlists and weighted selection.

### Defer until later

- Advanced adaptive balancing algorithms
- Elaborate reward economies and achievements
- Complex individual player profiles
- Automatic LLM generation inside the application
- Multi-user game authoring and collaborative editing
- Advanced analytics dashboards
- Automated recommendations based on long-term behavior
- Chinese/bilingual content

The data model should anticipate these capabilities, but implementation should be driven by demonstrated needs.

## 15. Tech Stack

- **Frontend:** Vanilla HTML/CSS/JS or React — web-first, minimal animation, informational focus, offline as possible
- **Hosting:** GitHub Pages (github.io)
- **Backend/DB:** Supabase (PostgreSQL + Row Level Security)
- **Validation:** JSON Schema + Ajv
- **Target:** Family use first; shareable within a few weeks after iteration

## 16. Success Criteria

The app succeeds when it:

- Helps a family start playing quickly.
- Encourages offline interaction.
- Produces varied and enjoyable experiences.
- Makes new games easy to create and publish.
- Preserves a reliable history of game definitions and revisions.
- Learns from feedback and play frequency.
- Keeps favorite games available without making sessions repetitive.
- Balances familiar favorites with opportunities to discover new games.
- Remains maintainable as the library grows.

## 17. Open Questions

- How should favorite status be calculated from votes, plays, and recency?
- How strongly should balanced selection penalize recently played games?
- Should the same game be allowed twice in one session?
- Should game notes be private administrative notes, player feedback, or both?
- How should scoring work across games with fundamentally different mechanics?
- Which game templates should be implemented first?
- Should game-definition exports include play history and analytics, or only content?
- What database backup and restoration process is required?
- How should schema migrations and older game definitions be handled when the application evolves?

## 18. Guiding Architectural Decision

**Separate game identity, game definitions, play history, feedback, and selection policy.**

This allows the game library to evolve independently of the interface, makes LLM-assisted authoring practical, preserves historical integrity, and enables increasingly sophisticated playlists without rewriting the core application.
