// Moment — Session State Management
// All session state lives in sessionStorage (cleared when tab closes).
// Persistent scores and game cache live in localStorage.

const SESSION_KEY          = 'moment_session';
const PERSISTENT_SCORES_KEY = 'moment_persistent_scores';
const GAMES_CACHE_KEY      = 'moment_games_cache';
const CACHE_TTL_HOURS      = 24;
const DEFAULT_PLAYERS      = ['Athena', 'Felix', 'Ying', 'Jimmy'];
const ALL_PLAYERS          = ['Athena', 'Felix', 'Ying', 'Jimmy', 'Guest'];

function _read() {
  try {
    return JSON.parse(sessionStorage.getItem(SESSION_KEY)) || null;
  } catch { return null; }
}

function _write(session) {
  sessionStorage.setItem(SESSION_KEY, JSON.stringify(session));
}

function _emptyScores() {
  return Object.fromEntries(ALL_PLAYERS.map(p => [p, 0]));
}

function initSession() {
  if (_read()) return;
  _write({
    sessionId:     crypto.randomUUID(),
    startedAt:     new Date().toISOString(),
    players:       [...DEFAULT_PLAYERS],
    currentGame:   null,
    history:       [],
    scores:        _emptyScores(),
    wheelRotation: 0,
    roundNumber:   0
  });
}

function getSession() {
  return _read();
}

function setCurrentGame(game) {
  const s = _read();
  s.currentGame = { ...game, selectedAt: new Date().toISOString() };
  _write(s);
}

function clearCurrentGame() {
  const s = _read();
  s.currentGame = null;
  _write(s);
}

function recordPlayEvent(playEventId, gameId, category) {
  const s = _read();
  s.history.push({ playEventId, gameId, category, playedAt: new Date().toISOString() });
  s.roundNumber = (s.roundNumber || 0) + 1;
  _write(s);
}

function updateScores(winner) {
  if (!winner) return;
  const s = _read();
  s.scores[winner] = (s.scores[winner] || 0) + 1;
  _write(s);
}

function getWheelRotation() {
  return (_read() || {}).wheelRotation || 0;
}

function setWheelRotation(deg) {
  const s = _read();
  s.wheelRotation = deg;
  _write(s);
}

function getPersistentScores() {
  try {
    return JSON.parse(localStorage.getItem(PERSISTENT_SCORES_KEY)) || _emptyScores();
  } catch { return _emptyScores(); }
}

function resetSessionScores() {
  const s = _read();
  s.scores = _emptyScores();
  _write(s);
}

function updatePersistentScores(winner) {
  if (!winner) return;
  const scores = getPersistentScores();
  scores[winner] = (scores[winner] || 0) + 1;
  scores.lastUpdated = new Date().toISOString();
  localStorage.setItem(PERSISTENT_SCORES_KEY, JSON.stringify(scores));
}

// ── Game Cache ──────────────────────────────────────────────

function getCachedGames() {
  try {
    const raw = JSON.parse(localStorage.getItem(GAMES_CACHE_KEY));
    if (!raw || !raw.games) return null;
    const ageMs = Date.now() - new Date(raw.cachedAt).getTime();
    if (ageMs > CACHE_TTL_HOURS * 3600 * 1000) return null;
    return raw.games;
  } catch { return null; }
}

function setCachedGames(games) {
  localStorage.setItem(GAMES_CACHE_KEY, JSON.stringify({
    cachedAt: new Date().toISOString(),
    games
  }));
}

// ── Smart Game Selection ─────────────────────────────────────

// ── Playlist choice ─────────────────────────────────────────

const PLAYLIST_KEY     = 'moment_playlist';
const DEFAULT_PLAYLIST = 'explore';

function getPlaylist() {
  try {
    const id = localStorage.getItem(PLAYLIST_KEY);
    if (!id || id === 'all') return DEFAULT_PLAYLIST; // 'all' was renamed to 'explore'
    return id;
  } catch { return DEFAULT_PLAYLIST; }
}

function setPlaylist(id) {
  try { localStorage.setItem(PLAYLIST_KEY, id); } catch {}
}

// ── Click-seeded randomness ─────────────────────────────────
// Each spin gets its own seed from the time of the click (seconds and
// milliseconds) mixed with crypto randomness. Seconds alone only give 60
// possible seeds, so the milliseconds and the crypto value are mixed in too.

function _mulberry32(seed) {
  let a = seed >>> 0;
  return function () {
    a = (a + 0x6D2B79F5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function makeClickRng(clickMs = Date.now()) {
  const d = new Date(clickMs);
  const timePart = d.getSeconds() * 1000 + d.getMilliseconds();
  const entropy = new Uint32Array(1);
  crypto.getRandomValues(entropy);
  const seed = Math.imul(timePart + 1, 2654435761) ^ entropy[0];
  return _mulberry32(seed);
}

function selectNextGame(games, rng = Math.random) {
  const session  = _read();
  const history  = session ? session.history : [];
  const lastCat  = history.length > 0 ? history[history.length - 1].category : null;
  const secondLastCat = history.length >= 2 ? history[history.length - 2].category : null;
  const recentIds = new Set(history.slice(-3).map(h => h.gameId));
  const recentCats = new Set(history.slice(-5).map(h => h.category));

  let pool = games.filter(g => !recentIds.has(g.id));
  if (pool.length === 0) {
    const lastId = history.length > 0 ? history[history.length - 1].gameId : null;
    pool = games.filter(g => g.id !== lastId);
  }
  if (pool.length === 0) pool = [...games];

  const weighted = pool.map(g => {
    let w = 10;
    if (g.category === lastCat)       w -= 7;
    if (g.category === secondLastCat) w -= 3;
    if (!recentCats.has(g.category))  w += 4;
    return { game: g, weight: Math.max(1, w) };
  });

  const total = weighted.reduce((s, x) => s + x.weight, 0);
  let rand = rng() * total;
  for (const { game, weight } of weighted) {
    rand -= weight;
    if (rand <= 0) return game;
  }
  return weighted[weighted.length - 1].game;
}
