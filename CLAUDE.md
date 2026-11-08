# Moment — notes for Claude

## Versioning (applies to every PR)

- The app version lives in `js/version.js` (`MOMENT_VERSION` and `MOMENT_CHANGELOG`). Settings › Log shows it.
- Every PR that merges adds a new **minor** version: `0.4` → `0.5`.
- When the user states a major upgrade, bump the **major** and reset minor: `0.5` → `1.0`.
- In the same PR, set `MOMENT_VERSION`, and add the new entry at the **top** of `MOMENT_CHANGELOG` with the date and a short list of user-visible changes.

## Database changes

- SQL changes go in `sql/` as a dated file (`YYYY-MM-DD_name.sql`), written to be safe to run more than once. The user runs them in the Supabase SQL Editor. Say in the PR which file to run.

## Playlists

- The default playlist is `explore` (all games). `getPlaylist()` in `js/session.js` maps the old `all` value to `explore`.
