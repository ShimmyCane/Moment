// Moment — Supabase Data Layer
// Priority: Supabase (timeout via Promise.race) → localStorage cache (24h) → data/games.json

window._momentErrors      = window._momentErrors      || [];
window._supabaseConnected = false;

function _logError(context, message) {
  const entry = { context, message, time: new Date().toLocaleTimeString() };
  window._momentErrors.push(entry);
  if (typeof window._onErrorLogged === 'function') window._onErrorLogged(entry);
}

function _timeout(ms, label) {
  return new Promise((_, reject) =>
    setTimeout(() => reject(new Error(`${label} timed out after ${ms}ms`)), ms)
  );
}

let _supabase = null;

function getClient() {
  if (_supabase) return _supabase;
  if (!window.supabase) {
    _logError('getClient', 'Supabase SDK not loaded — check CDN script tag');
    return null;
  }
  if (SUPABASE_URL === 'https://YOUR_PROJECT.supabase.co') {
    _logError('getClient', 'SUPABASE_URL not configured in js/config.js');
    return null;
  }
  try {
    _supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  } catch (e) {
    _logError('getClient', 'createClient failed: ' + e.message);
    return null;
  }
  return _supabase;
}

function _normalizeGame(row, definition) {
  return {
    id:                 row.id,
    slug:               row.slug,
    title:              row.title,
    short_label:        row.short_label,
    category:           row.category,
    wheel_slot:         row.wheel_slot,
    status:             row.status,
    emoji:              row.emoji || null,
    current_version_id: row.current_version_id,
    definition:         definition || row.definition || {}
  };
}

function _showOfflineBanner() {
  const el = document.getElementById('offlineBanner');
  if (el) {
    el.classList.remove('hidden');
    setTimeout(() => el.classList.add('hidden'), 5000);
  }
}

async function loadGames() {
  const sb = getClient();

  if (sb) {
    try {
      const query = sb.from('active_games_view').select('*').order('wheel_slot');
      const { data, error } = await Promise.race([
        query,
        _timeout(SUPABASE_TIMEOUT_MS, 'loadGames')
      ]);

      if (!error && data && data.length > 0) {
        window._supabaseConnected = true;
        if (typeof window._onSupabaseStatus === 'function') window._onSupabaseStatus(true);
        const games = data.map(r => _normalizeGame(r, r.definition));
        setCachedGames(games);
        return games;
      }
      if (error) {
        _logError('loadGames', `Supabase error (${error.code || 'unknown'}): ${error.message}`);
      } else if (!data || data.length === 0) {
        _logError('loadGames', 'Supabase returned 0 games — check active_games_view and RLS policies');
      }
    } catch (e) {
      _logError('loadGames', e.message || 'Unknown network error');
    }
  } else {
    _logError('loadGames', 'No Supabase client — falling back to cache/JSON');
  }

  // Try localStorage cache
  const cached = getCachedGames();
  if (cached) {
    _showOfflineBanner();
    _logError('loadGames', 'Using localStorage cache (Supabase unavailable)');
    return cached;
  }

  // Fall back to bundled games.json
  _showOfflineBanner();
  try {
    const res = await fetch('./data/games.json');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const raw = await res.json();
    _logError('loadGames', 'Using bundled games.json fallback — data may be stale');
    return raw.map(r => _normalizeGame(r));
  } catch (e) {
    _logError('loadGames:fallback', 'Could not load games.json: ' + (e.message || 'fetch failed'));
    return [];
  }
}

async function createSession(mode = 'family_mix') {
  const sb = getClient();
  if (!sb) return null;
  try {
    const { data, error } = await Promise.race([
      sb.from('play_sessions').insert({ mode }).select('id').single(),
      _timeout(SUPABASE_TIMEOUT_MS, 'createSession')
    ]);
    if (error) { _logError('createSession', error.message); return null; }
    return data.id;
  } catch (e) {
    _logError('createSession', e.message);
    return null;
  }
}

async function createPlayEvent(sessionId, gameId, versionId) {
  const sb = getClient();
  if (!sb || !sessionId) return null;
  try {
    const { data, error } = await Promise.race([
      sb.from('play_events')
        .insert({ session_id: sessionId, game_id: gameId, game_version_id: versionId })
        .select('id').single(),
      _timeout(SUPABASE_TIMEOUT_MS, 'createPlayEvent')
    ]);
    if (error) { _logError('createPlayEvent', error.message); return null; }
    return data.id;
  } catch (e) {
    _logError('createPlayEvent', e.message);
    return null;
  }
}

async function updatePlayEvent(playEventId, updates) {
  const sb = getClient();
  if (!sb)          { _logError('updatePlayEvent', 'No Supabase client'); return false; }
  if (!playEventId) { _logError('updatePlayEvent', 'playEventId is null — play event was never created'); return false; }
  try {
    const { error } = await Promise.race([
      sb.from('play_events').update(updates).eq('id', playEventId),
      _timeout(SUPABASE_TIMEOUT_MS, 'updatePlayEvent')
    ]);
    if (error) { _logError('updatePlayEvent', `${error.code || 'error'}: ${error.message}`); return false; }
    return true;
  } catch (e) {
    _logError('updatePlayEvent', e.message || 'Unknown error');
    return false;
  }
}

async function submitFeedback(playEventId, gameId, versionId, rating, notes) {
  const sb = getClient();
  if (!sb)          { _logError('submitFeedback', 'No Supabase client'); return false; }
  if (!playEventId) { _logError('submitFeedback', 'playEventId is null — cannot link feedback to a play event'); return false; }
  if (!gameId)      { _logError('submitFeedback', 'gameId is null'); return false; }
  if (rating === undefined || rating === null) { _logError('submitFeedback', 'rating is null — skipping insert'); return false; }
  try {
    const row = {
      play_event_id:   playEventId,
      game_id:         gameId,
      rating,
      notes:           notes || null
    };
    // game_version_id is nullable in schema — include only if present
    if (versionId) row.game_version_id = versionId;

    const { error } = await Promise.race([
      sb.from('game_feedback').insert(row),
      _timeout(SUPABASE_TIMEOUT_MS, 'submitFeedback')
    ]);
    if (error) {
      _logError('submitFeedback', `${error.code || 'error'}: ${error.message} | payload: rating=${rating}, notes=${JSON.stringify(notes)}, versionId=${versionId}`);
      return false;
    }
    return true;
  } catch (e) {
    _logError('submitFeedback', e.message || 'Unknown error');
    return false;
  }
}

async function saveScore(sessionId, playEventId, playerName, points) {
  const sb = getClient();
  if (!sb)        { _logError('saveScore', 'No Supabase client'); return false; }
  if (!sessionId) { _logError('saveScore', 'sessionId is null'); return false; }
  try {
    const { error } = await Promise.race([
      sb.from('scores').insert({
        session_id:    sessionId,
        play_event_id: playEventId,
        player_name:   playerName,
        points
      }),
      _timeout(SUPABASE_TIMEOUT_MS, 'saveScore')
    ]);
    if (error) { _logError('saveScore', `${error.code || 'error'}: ${error.message}`); return false; }
    return true;
  } catch (e) {
    _logError('saveScore', e.message || 'Unknown error');
    return false;
  }
}
