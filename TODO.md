# Moment — to-do

## Do first (blocking features)

- [ ] **Run `sql/2026-11-08_project_notes.sql`** in the Supabase SQL Editor (project `twvqvutrcobedvuhnzxq`). The Notes tab won't load until this runs. It is safe to run more than once.
- [ ] Sign in on the General tab and check that a project note can be added and deleted.

## Test on a real phone

- [ ] Flick wheel: drag, release, and check the stop takes about 1.5 s and feels right.
- [ ] Click sound and pointer flick line up with the pegs. Check volume with the phone on silent.
- [ ] Screen lock: no pinch or double-tap zoom, and no iOS edge swipe-back. Test in Safari and in the home-screen app. Safari may still take a swipe that starts at the very edge; if so, the edge zone width in `js/lock.js` (`EDGE_PX`) needs widening.
- [ ] Explore is the default playlist, and the Spin button still works in spin mode.

## Later

- [ ] Remove the `sql/` update files from the repo, or move them to an `sql/applied/` folder, once they are confirmed applied.
- [ ] Rebuild the spin-mode selection so it draws from all games, not only the 7 on the wheel.
- [ ] Game-level feedback on the Notes tab: decide whether project notes should also be attached to a version.
- [ ] Check the schematic's playlist settings (duration, energy, languages) against what the app does.

## Done

- [x] v0.4: gear corner fix, Explore default, click-seeded spins, Notes and Log tabs
- [x] v0.5: flick wheel with pegs and click sync, 1.5 s stop, screen lock
