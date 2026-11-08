// Moment — app version and change log (shown in Settings › Log).
//
// Versioning rule (also in CLAUDE.md):
//   • Every PR that merges adds a new MINOR version (0.4 → 0.5).
//   • A PR where the user states a major upgrade bumps MAJOR and resets MINOR (0.5 → 1.0).
//   • Add the new entry at the TOP of MOMENT_CHANGELOG in the same PR.

window.MOMENT_VERSION = '0.5';

window.MOMENT_CHANGELOG = [
  {
    version: '0.5',
    date: '2026-11-08',
    changes: [
      'Flick wheel: drag the wheel and let go. Turn it on in Settings › General › Wheel control. The Spin button stays the default.',
      'Pegs around the rim click as each wedge passes the pointer, and the pointer flicks with them.',
      'Flick speed is capped, so a hard flick is needed. The stop takes 1.5 seconds.'
    ]
  },
  {
    version: '0.4',
    date: '2026-11-08',
    changes: [
      'Settings button stays fixed in the lower-right corner and no longer covers the settings controls.',
      'Explore is the default playlist (replaces All). Favorites (Top) is no longer the starting setting.',
      'Spin selection is seeded from the time of the click (seconds and milliseconds) mixed with browser randomness.',
      'New Notes tab in Settings for project-wide notes. Needs sql/2026-11-08_project_notes.sql run once.',
      'New Log tab in Settings showing the version history.'
    ]
  },
  {
    version: '0.3',
    date: '2026-10-25',
    changes: [
      'Sign-in in Settings, with signed-in gameplay policies in Supabase.',
      'Security update 4 SQL for the Family project.',
      'Wheel shows at most 7 games.',
      'Feedback tab in Settings for reviewing per-game feedback.'
    ]
  },
  {
    version: '0.2',
    date: '2026-10-22',
    changes: [
      'Bigger wheel.',
      'Cleanup of the v0.2 layout and code.'
    ]
  }
];
