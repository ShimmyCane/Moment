// Moment — Shared UI: floating gear, settings bottom-sheet, playlist selector, error display
(function () {
  window._momentErrors      = window._momentErrors      || [];
  window._supabaseConnected = window._supabaseConnected || false;

  var PLAYLISTS = [
    { id: 'explore', label: 'Explore' },
    { id: 'new',     label: 'New' },
    { id: 'top',     label: '⭐ Top' },
    { id: 'felix',   label: "Felix's" },
    { id: 'mix',     label: 'Mix' }
  ];

  // One-time reset so browsers that saved an older choice (e.g. Top) land on Explore.
  var PLAYLIST_MIGRATION_KEY = 'moment_playlist_migrated';
  var PLAYLIST_MIGRATION_VER = '0.4';

  var GAME_JSON_TEMPLATE = {
    slug: 'my-new-game',
    title: 'My New Game',
    short_label: 'New Game',
    category: 'observation',
    emoji: '🎯',
    definition: {
      schema_version: '1.0',
      instructions: [
        'Step 1: describe what players do first.',
        'Step 2: describe the next action.',
        'Step 3: how to determine a winner.'
      ],
      variants: [
        'Easier: simplify the main challenge.',
        'Harder: add a time limit or extra twist.'
      ],
      duration_min: 3,
      duration_max: 10,
      players_min: 2,
      players_max: 8,
      energy: 'calm',
      materials: [],
      contexts: ['home'],
      languages: ['en'],
      educational_topics: [],
      interaction: 'competitive',
      template: 'quick_guess',
      scoring: {
        type: 'winner_takes_one',
        description: 'First player to complete the challenge wins a point.'
      }
    }
  };

  var _panel, _overlay, _gear;

  // ── Init ─────────────────────────────────────────────────────

  function init() {
    _gear = document.createElement('button');
    _gear.id = 'gearBtn';
    _gear.className = 'floating-gear';
    _gear.setAttribute('aria-label', 'Settings');
    _gear.textContent = '⚙';
    document.body.appendChild(_gear);

    _overlay = document.createElement('div');
    _overlay.id = 'settingsOverlay';
    _overlay.className = 'settings-overlay hidden';
    document.body.appendChild(_overlay);

    _panel = document.createElement('div');
    _panel.id = 'settingsPanel';
    _panel.className = 'settings-panel hidden';
    _panel.innerHTML = _buildPanelHTML();
    document.body.appendChild(_panel);

    var container = document.querySelector('.app-container');
    if (container) {
      var errPanel = document.createElement('div');
      errPanel.id = 'errorPanel';
      errPanel.className = 'error-panel hidden';
      errPanel.innerHTML = '<div class="error-panel-title">⚠ Errors</div><div id="errorList"></div>';
      container.appendChild(errPanel);
    }

    try {
      if (localStorage.getItem(PLAYLIST_MIGRATION_KEY) !== PLAYLIST_MIGRATION_VER) {
        setPlaylist(DEFAULT_PLAYLIST);
        localStorage.setItem(PLAYLIST_MIGRATION_KEY, PLAYLIST_MIGRATION_VER);
      }
    } catch (_) {}

    _setActivePlaylist(getPlaylist(), false);

    var stored = localStorage.getItem('moment_show_errors') === '1';
    document.getElementById('showErrorsToggle').checked = stored;
    _applyErrorVisibility(stored);

    _gear.addEventListener('click', function (e) {
      e.stopPropagation();
      _openPanel();
    });
    _overlay.addEventListener('click', _closePanel);
    document.getElementById('settingsCloseBtn').addEventListener('click', _closePanel);

    _panel.querySelectorAll('.settings-tab').forEach(function (tab) {
      tab.addEventListener('click', function (e) {
        e.stopPropagation();
        _switchTab(tab.dataset.tab);
      });
    });

    PLAYLISTS.forEach(function (pl) {
      var btn = document.getElementById('pl-' + pl.id);
      if (btn) {
        btn.addEventListener('click', function (e) {
          e.stopPropagation();
          _setActivePlaylist(pl.id, true);
        });
      }
    });

    ['spin', 'flick'].forEach(function (m) {
      document.getElementById('wm-' + m).addEventListener('click', function (e) {
        e.stopPropagation();
        setWheelMode(m);
        _setWheelModeActive(m);
        if (typeof window._onWheelModeChange === 'function') window._onWheelModeChange();
      });
    });
    _setWheelModeActive(getWheelMode());

    document.getElementById('showErrorsToggle').addEventListener('change', function () {
      var show = this.checked;
      localStorage.setItem('moment_show_errors', show ? '1' : '0');
      _applyErrorVisibility(show);
    });

    document.getElementById('loadFeedbackBtn').addEventListener('click', function (e) {
      e.stopPropagation();
      _loadFeedback();
    });

    document.getElementById('projectNoteAddBtn').addEventListener('click', function (e) {
      e.stopPropagation();
      _addProjectNote();
    });

    document.getElementById('copyTemplateBtn').addEventListener('click', function (e) {
      e.stopPropagation();
      var btn = this;
      var text = JSON.stringify(GAME_JSON_TEMPLATE, null, 2);
      if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(function () {
          btn.textContent = 'Copied!';
          setTimeout(function () { btn.textContent = 'Copy'; }, 2000);
        });
      } else {
        var ta = document.getElementById('templateDisplay');
        ta.select();
        document.execCommand('copy');
        btn.textContent = 'Copied!';
        setTimeout(function () { btn.textContent = 'Copy'; }, 2000);
      }
    });

    document.getElementById('validateGameBtn').addEventListener('click', function (e) {
      e.stopPropagation();
      _validateGameJSON(
        document.getElementById('newGameJSON').value,
        document.getElementById('gameValidationResult')
      );
    });

    document.getElementById('submitGameBtn').addEventListener('click', function (e) {
      e.stopPropagation();
      _submitNewGame();
    });

    window._onErrorLogged = function () {
      var count = window._momentErrors.length;
      if (_gear) _gear.dataset.errorCount = count > 0 ? String(count) : '';
      if (localStorage.getItem('moment_show_errors') === '1') _renderErrors();
    };
    window._onSupabaseStatus = function (connected) {
      var dot  = document.getElementById('sbDot');
      var text = document.getElementById('sbText');
      if (dot)  dot.className  = 'status-dot ' + (connected ? 'status-connected' : 'status-offline');
      if (text) text.textContent = connected ? 'Supabase ✓' : 'Supabase ✗';
    };
    window._onSupabaseStatus(window._supabaseConnected);

    if (stored) _renderErrors();
  }

  function _openPanel() {
    _panel.classList.remove('hidden');
    _overlay.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
    _renderAccount();
  }

  // ── Account (sign-in) ─────────────────────────────────────────
  // supabase-js keeps the session in localStorage, so a sign-in
  // persists across reloads until the user signs out.

  async function _renderAccount() {
    var box = document.getElementById('accountBox');
    if (!box) return;

    var sb = (typeof getClient === 'function') ? getClient() : null;
    if (!sb) {
      box.innerHTML = '<p class="settings-hint">Supabase not connected.</p>';
      return;
    }

    var res = await sb.auth.getSession();
    var session = res.data && res.data.session;

    if (session) {
      box.innerHTML =
        '<p class="settings-hint">Signed in as ' + _esc(session.user.email) + '.</p>' +
        '<button id="accountSignOutBtn" class="pl-btn">Sign out</button>';
      document.getElementById('accountSignOutBtn').addEventListener('click', _signOut);
    } else {
      box.innerHTML =
        '<form id="accountForm" class="account-form">' +
          '<input id="accountEmail" class="form-input" type="email" placeholder="Email" required autocomplete="email">' +
          '<input id="accountPass" class="form-input" type="password" placeholder="Password" required autocomplete="current-password">' +
          '<button type="submit" class="pl-btn">Sign in</button>' +
          '<div id="accountError" class="settings-error"></div>' +
        '</form>';
      document.getElementById('accountForm').addEventListener('submit', _signIn);
    }
  }

  async function _signIn(e) {
    e.preventDefault();
    var sb = getClient();
    var errEl = document.getElementById('accountError');
    var email = document.getElementById('accountEmail').value.trim();
    var pass  = document.getElementById('accountPass').value;

    var res = await sb.auth.signInWithPassword({ email: email, password: pass });
    if (res.error) { errEl.textContent = res.error.message; return; }
    _renderAccount();
    _loadNotes();
  }

  async function _signOut() {
    var sb = getClient();
    await sb.auth.signOut();
    _renderAccount();
  }

  function _closePanel() {
    _panel.classList.add('hidden');
    _overlay.classList.add('hidden');
    document.body.style.overflow = '';
  }

  function _switchTab(tabId) {
    _panel.querySelectorAll('.settings-tab').forEach(function (t) {
      t.classList.toggle('active', t.dataset.tab === tabId);
    });
    _panel.querySelectorAll('.settings-section').forEach(function (s) {
      s.classList.toggle('active', s.id === 'section-' + tabId);
    });
    if (tabId === 'notes') _loadNotes();
  }

  // ── Project notes (Supabase table: project_notes) ─────────────
  // Notes are shared across the family's devices, so they live in Supabase,
  // not localStorage. Reading and writing require a signed-in session.

  async function _hasSignedInSession(sb) {
    var res = await sb.auth.getSession();
    return !!(res.data && res.data.session);
  }

  async function _loadNotes() {
    var list = document.getElementById('projectNoteList');
    if (!list) return;

    var sb = (typeof getClient === 'function') ? getClient() : null;
    if (!sb) { list.innerHTML = '<p class="settings-error">Supabase not connected.</p>'; return; }

    if (!(await _hasSignedInSession(sb))) {
      list.innerHTML = '<p class="settings-hint">Sign in on the General tab to view and add project notes.</p>';
      return;
    }

    list.innerHTML = '<p class="settings-hint">Loading…</p>';
    var res = await sb.from('project_notes')
      .select('id, body, created_at')
      .order('created_at', { ascending: false });

    if (res.error) {
      list.innerHTML = '<p class="settings-error">' + _esc(res.error.message) + '</p>' +
        '<p class="settings-hint">Run sql/2026-11-08_project_notes.sql in the Supabase SQL Editor once.</p>';
      return;
    }
    _renderNotes(res.data || []);
  }

  function _renderNotes(notes) {
    var list = document.getElementById('projectNoteList');
    if (!list) return;
    if (notes.length === 0) {
      list.innerHTML = '<p class="settings-hint">No project notes yet.</p>';
      return;
    }
    list.innerHTML = notes.map(function (n) {
      var when = new Date(n.created_at).toLocaleString();
      return '<div class="fb-card note-card" data-note-id="' + _esc(n.id) + '">' +
               '<div class="fb-card-row">' +
                 '<span class="note-body">' + _esc(n.body) + '</span>' +
                 '<button class="fb-delete-btn" data-note-id="' + _esc(n.id) + '" aria-label="Delete note">✕</button>' +
               '</div>' +
               '<div class="note-time">' + _esc(when) + '</div>' +
             '</div>';
    }).join('');

    list.querySelectorAll('.fb-delete-btn').forEach(function (btn) {
      btn.addEventListener('click', function (e) {
        e.stopPropagation();
        _deleteNote(btn.dataset.noteId);
      });
    });
  }

  async function _addProjectNote() {
    var input    = document.getElementById('projectNoteInput');
    var resultEl = document.getElementById('projectNoteResult');
    var body     = (input.value || '').trim();

    if (!body) { resultEl.innerHTML = '<div class="error-item">Write something first.</div>'; return; }

    var sb = (typeof getClient === 'function') ? getClient() : null;
    if (!sb) { resultEl.innerHTML = '<div class="error-item">Supabase not connected.</div>'; return; }
    if (!(await _hasSignedInSession(sb))) {
      resultEl.innerHTML = '<div class="error-item">Sign in on the General tab first.</div>';
      return;
    }

    var res = await sb.from('project_notes').insert({ body: body }).select('id').single();
    if (res.error) {
      resultEl.innerHTML = '<div class="error-item">Save failed: ' + _esc(res.error.message) + '</div>';
      return;
    }
    input.value = '';
    resultEl.innerHTML = '<div class="success-msg">✓ Note added</div>';
    _loadNotes();
  }

  async function _deleteNote(noteId) {
    var resultEl = document.getElementById('projectNoteResult');
    var sb = (typeof getClient === 'function') ? getClient() : null;
    if (!sb) return;

    var res = await sb.from('project_notes').delete().eq('id', noteId);
    if (res.error) {
      resultEl.innerHTML = '<div class="error-item">Delete failed: ' + _esc(res.error.message) + '</div>';
      return;
    }
    _loadNotes();
  }

  // ── Log tab (version history from js/version.js) ──────────────

  function _buildChangelogHTML() {
    var entries = window.MOMENT_CHANGELOG || [];
    if (entries.length === 0) return '<p class="settings-hint">No log entries yet.</p>';

    return entries.map(function (entry, i) {
      var head = '<div class="log-head">' +
                   '<span class="log-version">v' + _esc(entry.version) + '</span>' +
                   (i === 0 ? '<span class="log-current">current</span>' : '') +
                   '<span class="log-date">' + _esc(entry.date) + '</span>' +
                 '</div>';
      var items = '<ul class="log-list">' + entry.changes.map(function (c) {
        return '<li>' + _esc(c) + '</li>';
      }).join('') + '</ul>';
      return '<div class="log-entry">' + head + items + '</div>';
    }).join('');
  }

  // ── Panel HTML ────────────────────────────────────────────────

  function _buildPanelHTML() {
    var html = '<div class="settings-drag-handle"></div>';

    html += '<div class="settings-header">' +
              '<span class="settings-header-title">Settings</span>' +
              '<button id="settingsCloseBtn" class="settings-close-btn">×</button>' +
            '</div>';

    html += '<div class="settings-tabs">' +
              '<button class="settings-tab active" data-tab="general">General</button>' +
              '<button class="settings-tab" data-tab="notes">Notes</button>' +
              '<button class="settings-tab" data-tab="feedback">Feedback</button>' +
              '<button class="settings-tab" data-tab="add-game">Add Game</button>' +
              '<button class="settings-tab" data-tab="log">Log</button>' +
            '</div>';

    html += '<div class="settings-content">';

    // ── General ──
    html += '<div id="section-general" class="settings-section active">';

    html += '<div class="settings-status">' +
              '<span id="sbDot" class="status-dot status-offline"></span>' +
              '<span id="sbText">Supabase</span>' +
            '</div>';

    html += '<div class="settings-section-label">Playlist</div>';
    html += '<div class="playlist-row">';
    PLAYLISTS.forEach(function (pl) {
      html += '<button id="pl-' + pl.id + '" class="pl-btn" data-pl="' + pl.id + '">' + pl.label + '</button>';
    });
    html += '</div>';

    html += '<div class="settings-section-label">Wheel control</div>';
    html += '<div class="playlist-row">' +
              '<button id="wm-spin" class="pl-btn" data-wm="spin">Spin button</button>' +
              '<button id="wm-flick" class="pl-btn" data-wm="flick">Flick wheel</button>' +
            '</div>';

    html += '<div class="settings-divider"></div>';
    html += '<label class="settings-row">' +
              '<input type="checkbox" id="showErrorsToggle">' +
              '<span>Show errors</span>' +
            '</label>';

    html += '<div class="settings-divider"></div>';
    html += '<div class="settings-section-label">Account</div>';
    html += '<div id="accountBox"></div>';

    html += '<div class="settings-divider"></div>';
    html += '<div class="settings-version">Moment v' + _esc(window.MOMENT_VERSION || '?') + '</div>';

    html += '</div>'; // section-general

    // ── Notes (project-wide, not tied to a game) ──
    html += '<div id="section-notes" class="settings-section">';
    html += '<div class="settings-section-label">Project Notes</div>';
    html += '<p class="settings-hint" style="margin-bottom:8px">General notes about the whole app. For a single game, use Feedback.</p>';
    html += '<textarea id="projectNoteInput" class="settings-json-editor" style="min-height:90px" maxlength="2000" placeholder="Write a note…"></textarea>';
    html += '<div class="settings-btn-row">' +
              '<button id="projectNoteAddBtn" class="btn btn-primary">Add note</button>' +
            '</div>';
    html += '<div id="projectNoteResult" class="validation-area"></div>';
    html += '<div id="projectNoteList" class="feedback-list-wrap"></div>';
    html += '</div>'; // section-notes

    // ── Feedback ──
    html += '<div id="section-feedback" class="settings-section">';
    html += '<div class="settings-section-top-row">' +
              '<span class="settings-section-label" style="margin-bottom:0">Feedback by Game</span>' +
              '<button id="loadFeedbackBtn" class="pl-btn">Load</button>' +
            '</div>';
    html += '<div id="feedbackList" class="feedback-list-wrap">' +
              '<p class="settings-hint">Press Load to fetch feedback from Supabase.</p>' +
            '</div>';
    html += '</div>'; // section-feedback

    // ── Add Game ──
    html += '<div id="section-add-game" class="settings-section">';

    html += '<div class="settings-section-label">Accepted JSON Format</div>';
    html += '<div class="template-box-wrap">';
    html += '<textarea id="templateDisplay" class="json-template-box" readonly></textarea>';
    html += '<button id="copyTemplateBtn" class="copy-overlay-btn">Copy</button>';
    html += '</div>';

    html += '<div class="settings-divider"></div>';
    html += '<div class="settings-section-label">Paste Your Game JSON</div>';
    html += '<textarea id="newGameJSON" class="settings-json-editor" placeholder="Paste completed game JSON here…"></textarea>';
    html += '<div id="gameValidationResult" class="validation-area"></div>';
    html += '<div class="settings-btn-row">';
    html += '<button id="validateGameBtn" class="btn btn-ghost">Validate</button>';
    html += '<button id="submitGameBtn" class="btn btn-primary">Add to game_versions</button>';
    html += '</div>';

    html += '</div>'; // section-add-game

    // ── Log (version history) ──
    html += '<div id="section-log" class="settings-section">';
    html += _buildChangelogHTML();
    html += '</div>'; // section-log

    html += '</div>'; // settings-content

    return html;
  }

  // ── Feedback tab ──────────────────────────────────────────────

  async function _loadFeedback() {
    var btn  = document.getElementById('loadFeedbackBtn');
    var list = document.getElementById('feedbackList');
    if (!btn || !list) return;

    btn.textContent = '…';
    btn.disabled = true;

    var sb = (typeof getClient === 'function') ? getClient() : null;
    if (!sb) {
      list.innerHTML = '<p class="settings-error">Supabase not connected.</p>';
      btn.textContent = 'Load'; btn.disabled = false;
      return;
    }

    try {
      var fbRes = await sb.from('game_feedback').select('id, game_id, rating, notes');
      if (fbRes.error) throw new Error(fbRes.error.message);

      var hidden  = new Set(JSON.parse(localStorage.getItem('moment_feedback_hidden')  || '[]'));
      var readIds = new Set(JSON.parse(localStorage.getItem('moment_feedback_read_ids') || '[]'));

      var allFeedback = (fbRes.data || []).filter(function (f) { return !hidden.has(f.id); });

      if (allFeedback.length === 0) {
        list.innerHTML = '<p class="settings-hint">No feedback found.</p>';
        btn.textContent = 'Refresh'; btn.disabled = false;
        return;
      }

      // Group feedback by game and collect unique game IDs
      var byGame   = {};
      var gameIdSet = new Set();
      allFeedback.forEach(function (f) {
        if (!byGame[f.game_id]) byGame[f.game_id] = [];
        byGame[f.game_id].push(f);
        gameIdSet.add(f.game_id);
      });

      // Fetch game details for all games that have feedback (including inactive)
      var gamesRes = await sb.from('games')
        .select('id, title, emoji, category, status, current_version_id, definition')
        .in('id', [...gameIdSet]);

      var games = gamesRes.data || [];
      window._settingsGames = games;

      var gamesById = {};
      games.forEach(function (g) { gamesById[g.id] = g; });

      var html = '';
      Object.keys(byGame).forEach(function (gameId) {
        var entries = byGame[gameId];
        var game    = gamesById[gameId] || { title: 'Unknown Game', emoji: '🎮', id: gameId, definition: {} };
        var hasNew  = entries.some(function (e) { return !readIds.has(e.id); });
        var isDraft = game.status && game.status !== 'active';

        html += '<div class="fb-card" data-game-id="' + _esc(gameId) + '">';
        html += '<div class="fb-card-row">';
        html += '<span class="fb-emoji">' + _esc(game.emoji || '🎮') + '</span>';
        html += '<span class="fb-title">' + _esc(game.title);
        if (isDraft) html += ' <span class="fb-status-badge">' + _esc(game.status) + '</span>';
        html += '</span>';
        if (hasNew) html += '<span class="fb-new-badge">NEW</span>';
        html += '<button class="tweak-btn" data-game-id="' + _esc(gameId) + '" data-version-id="' + _esc(game.current_version_id || '') + '">✏</button>';
        html += '</div>';

        html += '<div class="fb-entries">';
        entries.forEach(function (entry) {
          var ratingEmoji = entry.rating === 1 ? '👍' : entry.rating === -1 ? '👎' : '😐';
          var isNew = !readIds.has(entry.id);
          html += '<div class="fb-entry" data-entry-id="' + _esc(entry.id) + '">';
          html += '<span class="fb-entry-rating">' + ratingEmoji + '</span>';
          if (entry.notes) {
            html += '<span class="fb-entry-notes">' + _esc(entry.notes) + '</span>';
          } else {
            html += '<span class="fb-entry-notes fb-entry-empty">no notes</span>';
          }
          if (isNew) html += '<span class="fb-entry-new">●</span>';
          html += '<button class="fb-delete-btn" data-entry-id="' + _esc(entry.id) + '" data-game-id="' + _esc(gameId) + '">✕</button>';
          html += '</div>';
        });
        html += '</div>'; // fb-entries

        if (hasNew) {
          html += '<button class="fb-mark-read-btn" data-game-id="' + _esc(gameId) + '">Mark all read</button>';
        }

        html += '</div>'; // fb-card
      });

      list.innerHTML = html;

      list.querySelectorAll('.tweak-btn').forEach(function (tweakBtn) {
        tweakBtn.addEventListener('click', function (e) {
          e.stopPropagation();
          _openTweakEditor(tweakBtn.dataset.gameId);
        });
      });

      list.querySelectorAll('.fb-delete-btn').forEach(function (deleteBtn) {
        deleteBtn.addEventListener('click', function (e) {
          e.stopPropagation();
          _deleteFeedbackEntry(deleteBtn.dataset.entryId, deleteBtn.dataset.gameId);
        });
      });

      list.querySelectorAll('.fb-mark-read-btn').forEach(function (readBtn) {
        readBtn.addEventListener('click', function (e) {
          e.stopPropagation();
          _markGameFeedbackRead(readBtn.dataset.gameId, byGame[readBtn.dataset.gameId] || []);
        });
      });

      btn.textContent = 'Refresh'; btn.disabled = false;

    } catch (err) {
      list.innerHTML = '<p class="settings-error">Error: ' + _esc(err.message || 'Unknown') + '</p>';
      btn.textContent = 'Retry'; btn.disabled = false;
    }
  }

  function _deleteFeedbackEntry(entryId, gameId) {
    var entryEl = document.querySelector('.fb-entry[data-entry-id="' + entryId + '"]');
    if (entryEl) entryEl.remove();

    // Keep in local hidden so it filters out on next load even if Supabase delete fails
    var hidden = new Set(JSON.parse(localStorage.getItem('moment_feedback_hidden') || '[]'));
    hidden.add(entryId);
    localStorage.setItem('moment_feedback_hidden', JSON.stringify([...hidden]));

    var sb = (typeof getClient === 'function') ? getClient() : null;
    if (sb) sb.from('game_feedback').delete().eq('id', entryId);

    _refreshFeedbackCard(gameId);
  }

  function _markGameFeedbackRead(gameId, entries) {
    var readIds = new Set(JSON.parse(localStorage.getItem('moment_feedback_read_ids') || '[]'));
    entries.forEach(function (e) { readIds.add(e.id); });
    localStorage.setItem('moment_feedback_read_ids', JSON.stringify([...readIds]));

    var card = document.querySelector('.fb-card[data-game-id="' + gameId + '"]');
    if (!card) return;
    var badge = card.querySelector('.fb-new-badge');
    if (badge) badge.remove();
    var markBtn = card.querySelector('.fb-mark-read-btn');
    if (markBtn) markBtn.remove();
    card.querySelectorAll('.fb-entry-new').forEach(function (dot) { dot.remove(); });
  }

  function _refreshFeedbackCard(gameId) {
    var card = document.querySelector('.fb-card[data-game-id="' + gameId + '"]');
    if (!card) return;
    if (card.querySelectorAll('.fb-entry').length === 0) card.remove();
  }

  // ── Tweak editor ──────────────────────────────────────────────

  function _openTweakEditor(gameId) {
    var games = window._settingsGames || [];
    var game  = games.find(function (g) { return g.id === gameId; });
    if (!game) return;

    var list = document.getElementById('feedbackList');
    list.innerHTML = '<p class="settings-hint">Loading definition…</p>';

    function _showEditor(defJSON) {
      list.innerHTML =
        '<div class="tweak-header">' +
          '<button id="tweakBackBtn" class="pl-btn">← Back</button>' +
          '<span class="tweak-title">' + _esc(game.emoji || '') + ' ' + _esc(game.title) + '</span>' +
        '</div>' +
        '<div class="settings-section-label" style="margin-top:12px;margin-bottom:4px">Definition JSON</div>' +
        '<textarea id="tweakJSON" class="settings-json-editor" style="min-height:220px"></textarea>' +
        '<div id="tweakResult" class="validation-area"></div>' +
        '<div class="settings-btn-row">' +
          '<button id="tweakSaveLocalBtn" class="btn btn-ghost">Save Locally</button>' +
          '<button id="tweakSaveRemoteBtn" class="btn btn-primary">Save to Supabase</button>' +
        '</div>';

      document.getElementById('tweakJSON').value = defJSON;

      document.getElementById('tweakBackBtn').addEventListener('click', function (e) {
        e.stopPropagation();
        _loadFeedback();
      });
      document.getElementById('tweakSaveLocalBtn').addEventListener('click', function (e) {
        e.stopPropagation();
        _saveTweakLocally(gameId);
      });
      document.getElementById('tweakSaveRemoteBtn').addEventListener('click', function (e) {
        e.stopPropagation();
        _saveTweakToSupabase(gameId, game);
      });
    }

    var sb = (typeof getClient === 'function') ? getClient() : null;
    var versionId = game.current_version_id || (document.querySelector('[data-game-id="' + gameId + '"]') || {}).dataset.versionId;

    if (sb && versionId) {
      sb.from('game_versions').select('definition').eq('id', versionId).single()
        .then(function (res) {
          game.definition = res.data ? res.data.definition : {};
          _showEditor(JSON.stringify(game.definition, null, 2));
        }).catch(function () {
          _showEditor(JSON.stringify(game.definition || {}, null, 2));
        });
    } else {
      _showEditor(JSON.stringify(game.definition || {}, null, 2));
    }
  }

  function _saveTweakLocally(gameId) {
    var result = _parseJSON(
      document.getElementById('tweakJSON').value,
      document.getElementById('tweakResult')
    );
    if (!result) return;

    var overrides = JSON.parse(localStorage.getItem('moment_game_overrides') || '{}');
    overrides[gameId] = { definition: result, updatedAt: new Date().toISOString() };
    localStorage.setItem('moment_game_overrides', JSON.stringify(overrides));
    document.getElementById('tweakResult').innerHTML =
      '<div class="success-msg">Saved locally ✓  — takes effect on next game load.</div>';
  }

  async function _saveTweakToSupabase(gameId, game) {
    var resultEl = document.getElementById('tweakResult');
    var definition = _parseJSON(
      document.getElementById('tweakJSON').value,
      resultEl
    );
    if (!definition) return;

    var sb = (typeof getClient === 'function') ? getClient() : null;
    if (!sb) {
      resultEl.innerHTML = '<div class="error-item">Supabase not connected.</div>';
      return;
    }

    resultEl.innerHTML = '<p class="settings-hint">Saving…</p>';

    try {
      var verRes = await sb.from('game_versions')
        .select('version_number')
        .eq('game_id', gameId)
        .order('version_number', { ascending: false })
        .limit(1);

      if (verRes.error) throw new Error(verRes.error.message);
      var nextVer = (verRes.data && verRes.data[0]) ? verRes.data[0].version_number + 1 : 1;

      var insRes = await sb.from('game_versions')
        .insert({ game_id: gameId, version_number: nextVer, definition: definition })
        .select('id').single();

      if (insRes.error) throw new Error(insRes.error.message);

      var updRes = await sb.from('games')
        .update({ current_version_id: insRes.data.id, updated_at: new Date().toISOString() })
        .eq('id', gameId);

      if (updRes.error) throw new Error(updRes.error.message);

      // Patch cached game so the back-list shows the new version without re-fetching
      if (window._settingsGames) {
        var g = window._settingsGames.find(function (x) { return x.id === gameId; });
        if (g) { g.current_version_id = insRes.data.id; g.definition = definition; }
      }

      resultEl.innerHTML =
        '<div class="success-msg">✓ Saved as version ' + nextVer + ' in game_versions.</div>';
    } catch (e) {
      var msg = _esc(e.message);
      resultEl.innerHTML =
        '<div class="error-item">Save failed: ' + msg + '</div>' +
        '<p class="settings-hint" style="margin-top:6px">Write access requires an authenticated Supabase session. ' +
        'Log in via the admin panel first, then try again.</p>';
    }
  }

  // ── Add Game tab ──────────────────────────────────────────────

  async function _submitNewGame() {
    var resultEl = document.getElementById('gameValidationResult');
    var game = _validateGameJSON(
      document.getElementById('newGameJSON').value,
      resultEl
    );
    if (!game) return;

    var sb = (typeof getClient === 'function') ? getClient() : null;
    if (!sb) {
      resultEl.innerHTML = '<div class="error-item">Supabase not connected.</div>';
      return;
    }

    resultEl.innerHTML = '<p class="settings-hint">Saving…</p>';

    try {
      var gameRes = await sb.from('games').insert({
        slug:        game.slug,
        title:       game.title,
        short_label: game.short_label,
        category:    game.category,
        emoji:       game.emoji || null,
        status:      'draft'
      }).select('id').single();

      if (gameRes.error) throw new Error('Insert game: ' + gameRes.error.message);

      var verRes = await sb.from('game_versions').insert({
        game_id:        gameRes.data.id,
        version_number: 1,
        definition:     game.definition
      }).select('id').single();

      if (verRes.error) throw new Error('Insert version: ' + verRes.error.message);

      var updRes = await sb.from('games')
        .update({ current_version_id: verRes.data.id })
        .eq('id', gameRes.data.id);

      if (updRes.error) throw new Error('Link version: ' + updRes.error.message);

      resultEl.innerHTML =
        '<div class="success-msg">✓ "' + _esc(game.title) + '" added as draft!<br>' +
        '<span style="font-size:12px;font-weight:400">Game ID: ' + gameRes.data.id + '</span></div>';
      document.getElementById('newGameJSON').value = '';
    } catch (e) {
      var msg = _esc(e.message);
      resultEl.innerHTML =
        '<div class="error-item">Save failed: ' + msg + '</div>' +
        '<p class="settings-hint" style="margin-top:6px">Inserting games requires an authenticated session. ' +
        'Log in via the admin panel first, then try again.</p>';
    }
  }

  // ── JSON helpers ──────────────────────────────────────────────

  function _parseJSON(jsonStr, feedbackEl) {
    feedbackEl.innerHTML = '';
    try {
      var p = JSON.parse(jsonStr);
      feedbackEl.innerHTML = '<div class="success-msg">✓ Valid JSON</div>';
      return p;
    } catch (e) {
      feedbackEl.innerHTML = '<div class="error-item">JSON error: ' + _esc(e.message) + '</div>';
      return null;
    }
  }

  function _validateGameJSON(jsonStr, feedbackEl) {
    feedbackEl.innerHTML = '';
    var game;
    try {
      game = JSON.parse(jsonStr);
    } catch (e) {
      feedbackEl.innerHTML = '<div class="error-item">JSON parse error: ' + _esc(e.message) + '</div>';
      return null;
    }

    var errors = [];
    ['slug', 'title', 'short_label', 'category', 'definition'].forEach(function (k) {
      if (!game[k]) errors.push('Missing required field: <strong>' + k + '</strong>');
    });

    var validCats = ['observation', 'imagination', 'learning', 'conversation', 'quick_challenge'];
    if (game.category && !validCats.includes(game.category)) {
      errors.push('category must be one of: ' + validCats.join(', '));
    }
    if (game.short_label && game.short_label.length > 15) {
      errors.push('short_label must be ≤15 characters (currently ' + game.short_label.length + ')');
    }
    if (game.definition) {
      var d = game.definition;
      if (!Array.isArray(d.instructions) || d.instructions.length === 0) {
        errors.push('definition.instructions must be a non-empty array');
      }
      if (!d.duration_min || !d.duration_max) {
        errors.push('definition.duration_min and duration_max are required');
      }
      if (d.energy && !['calm', 'active'].includes(d.energy)) {
        errors.push('definition.energy must be "calm" or "active"');
      }
    }

    if (errors.length > 0) {
      feedbackEl.innerHTML = errors.map(function (e) {
        return '<div class="error-item">' + e + '</div>';
      }).join('');
      return null;
    }

    var steps = (game.definition.instructions || []).length;
    feedbackEl.innerHTML =
      '<div class="success-msg">✓ Valid — ' + steps + ' step' + (steps !== 1 ? 's' : '') +
      ', category: ' + _esc(game.category) + '</div>';
    return game;
  }

  // ── Playlist helpers ──────────────────────────────────────────

  function _setActivePlaylist(id, save) {
    if (save) {
      setPlaylist(id);
      if (typeof window._onPlaylistChange === 'function') window._onPlaylistChange(id);
    }
    PLAYLISTS.forEach(function (pl) {
      var btn = document.getElementById('pl-' + pl.id);
      if (btn) btn.classList.toggle('pl-active', pl.id === id);
    });
    var spinBtn = document.getElementById('spinBtn');
    if (spinBtn && !spinBtn.disabled) {
      var names = { explore: 'Spin!', new: 'Spin New!', top: 'Spin Top!', felix: "Spin Felix's!", mix: 'Spin Mix!' };
      spinBtn.textContent = names[id] || 'Spin!';
    }
  }

  function _setWheelModeActive(mode) {
    ['spin', 'flick'].forEach(function (m) {
      var btn = document.getElementById('wm-' + m);
      if (btn) btn.classList.toggle('pl-active', m === mode);
    });
  }

  // ── Error panel ───────────────────────────────────────────────

  function _applyErrorVisibility(show) {
    var errPanel = document.getElementById('errorPanel');
    if (!errPanel) return;
    if (show && window._momentErrors.length > 0) {
      errPanel.classList.remove('hidden');
      _renderErrors();
    } else if (!show) {
      errPanel.classList.add('hidden');
    }
  }

  function _renderErrors() {
    var errPanel = document.getElementById('errorPanel');
    var list     = document.getElementById('errorList');
    if (!errPanel || !list) return;
    var errors = window._momentErrors;
    if (errors.length === 0) return;
    errPanel.classList.remove('hidden');
    list.innerHTML = errors.map(function (e) {
      return '<div class="error-entry"><span class="error-ctx">[' + e.context + ']</span> ' +
             e.message + '<span class="error-time"> ' + e.time + '</span></div>';
    }).join('');
    errPanel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }

  function _esc(str) {
    return String(str || '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  // ── Post-render setup (template textarea needs .value, not innerHTML) ──

  function _initAddGameTab() {
    var ta = document.getElementById('templateDisplay');
    if (ta) ta.value = JSON.stringify(GAME_JSON_TEMPLATE, null, 2);
  }

  document.addEventListener('DOMContentLoaded', function () {
    init();
    _initAddGameTab();
  });
})();
