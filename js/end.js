// Moment — End / Scoring Page Logic
// ALL_PLAYERS is declared in session.js — do not redeclare here

let selectedRating = null;
let selectedWinner = null;

document.addEventListener('DOMContentLoaded', () => {
  const session = getSession();
  if (!session || !session.currentGame) {
    window.location.href = 'index.html';
    return;
  }

  const game = session.currentGame;
  document.getElementById('endGameTitle').textContent = game.title;

  // Warn early if there's no play event (Supabase was offline during spin)
  if (!game.playEventId) {
    _showStatus(
      'Playing offline — ratings will not be saved to the cloud this round.',
      'warn'
    );
  }

  // ── Rating buttons ──────────────────────────────────────
  document.querySelectorAll('.rating-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.rating-btn').forEach(b => b.classList.remove('selected'));
      btn.classList.add('selected');
      selectedRating = parseInt(btn.dataset.rating, 10);
      _clearStatus();
    });
  });

  // ── Player checkboxes (default: last round, then session default) ─
  const playerGrid  = document.getElementById('playerGrid');
  playerGrid.innerHTML = '';
  const lastPlayers   = JSON.parse(localStorage.getItem('moment_last_players') || 'null');
  const activePlayers = lastPlayers || session.players || ALL_PLAYERS.slice(0, 4);

  ALL_PLAYERS.forEach(name => {
    const checked = activePlayers.includes(name);
    const div = document.createElement('div');
    div.className = 'player-check' + (checked ? ' checked' : '');
    div.dataset.player = name;
    div.innerHTML = `<span>${name}</span>`;
    div.addEventListener('click', () => {
      div.classList.toggle('checked');
      _rebuildWinnerGrid();
    });
    playerGrid.appendChild(div);
  });

  _rebuildWinnerGrid();

  // ── Scores table ────────────────────────────────────────
  _renderScores(session.scores);

  // ── Save & Spin ─────────────────────────────────────────
  document.getElementById('saveSpinBtn').addEventListener('click', async () => {
    const btn = document.getElementById('saveSpinBtn');

    // Catch the common mistake: notes typed but no rating chosen
    const notes = document.getElementById('notesInput').value.trim();
    if (notes && selectedRating === null) {
      _showStatus('Please select a rating (👍 😐 👎) before saving — notes need a rating to be stored.', 'warn');
      document.querySelector('.rating-row').scrollIntoView({ behavior: 'smooth', block: 'center' });
      return;
    }

    btn.disabled = true;
    btn.textContent = 'Saving…';
    _clearStatus();

    let result;
    try {
      result = await _submit();
    } catch (err) {
      // Unexpected throw — re-enable and surface the error
      _logError('saveSpinBtn', err.message || 'Unexpected error in _submit');
      result = { ok: false, errors: ['Unexpected error: ' + (err.message || String(err))] };
    }

    if (result.ok) {
      _showToast('Feedback saved! 🎉');
      setTimeout(() => { window.location.href = 'index.html'; }, 1200);
    } else if (result.navigateAnyway) {
      // Partial save (local state updated, Supabase failed) — tell the user and move on
      _showToast('Saved locally (cloud sync failed)');
      setTimeout(() => { window.location.href = 'index.html'; }, 1800);
    } else {
      // Hard failure — stay on page, show errors, re-enable button
      _showStatus(result.errors.join('\n'), 'error');
      btn.disabled = false;
      btn.textContent = 'Save & Spin';
    }
  });

  // ── Just Spin (no save) ─────────────────────────────────
  document.getElementById('skipSaveBtn').addEventListener('click', () => {
    clearCurrentGame();
    window.location.href = 'index.html';
  });
});

// ── Status display ──────────────────────────────────────────

function _showStatus(message, type) {
  let el = document.getElementById('submitStatus');
  if (!el) {
    el = document.createElement('div');
    el.id = 'submitStatus';
    el.style.cssText =
      'width:100%;max-width:360px;padding:10px 14px;border-radius:12px 18px 12px 18px;' +
      'font-family:"Quicksand",sans-serif;font-size:13px;font-weight:700;line-height:1.4;' +
      'white-space:pre-line;border:2px solid;';
    const btnRow = document.querySelector('.btn-row');
    if (btnRow) btnRow.insertAdjacentElement('afterend', el);
    else document.querySelector('.app-container').appendChild(el);
  }
  if (type === 'error') {
    el.style.background = '#fef2f2';
    el.style.borderColor = '#fca5a5';
    el.style.color = '#dc2626';
  } else {
    el.style.background = '#fffbeb';
    el.style.borderColor = '#fcd34d';
    el.style.color = '#92400e';
  }
  el.textContent = message;
  el.style.display = 'block';
  el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

function _clearStatus() {
  const el = document.getElementById('submitStatus');
  if (el) el.style.display = 'none';
}

// ── Core submit logic ───────────────────────────────────────

async function _submit() {
  const session = getSession();
  const game    = session?.currentGame;

  if (!game) {
    return { ok: false, errors: ['Session lost — no current game found. Try spinning again.'] };
  }

  const notes   = document.getElementById('notesInput')?.value.trim() || '';
  const players = [...document.querySelectorAll('.player-check.checked')]
    .map(el => el.dataset.player);

  // Persist player selection for the next round
  if (players.length > 0) {
    localStorage.setItem('moment_last_players', JSON.stringify(players));
  }

  const warnings = [];

  // ── No play event (Supabase was offline during spin) ─────
  if (!game.playEventId) {
    _logError('_submit', 'playEventId missing — updating local state only');
    updateScores(selectedWinner);
    updatePersistentScores(selectedWinner);
    recordPlayEvent(null, game.id, game.category);
    clearCurrentGame();
    return {
      ok: false,
      navigateAnyway: true,
      errors: ['No cloud connection during this round — stats saved locally only.']
    };
  }

  // ── Update play event ─────────────────────────────────────
  const eventOk = await updatePlayEvent(game.playEventId, {
    outcome: 'completed',
    players,
    winner: selectedWinner || null
  });
  if (!eventOk) warnings.push('Play event update failed (offline?)');

  // ── Submit feedback (rating + notes) ─────────────────────
  let feedbackOk = true;
  if (selectedRating !== null) {
    feedbackOk = await submitFeedback(
      game.playEventId,
      game.id,
      game.current_version_id,
      selectedRating,
      notes || null
    );
    if (!feedbackOk) {
      // Specific error detail will already be in _momentErrors via _logError
      const detail = window._momentErrors.length
        ? window._momentErrors[window._momentErrors.length - 1].message
        : 'unknown error';
      warnings.push(`Feedback/notes failed to save: ${detail}`);
    }
  }
  // notes without rating already blocked before _submit() is called

  // ── Save score ────────────────────────────────────────────
  if (selectedWinner && session.sessionId) {
    const scoreOk = await saveScore(
      session.sessionId,
      game.playEventId,
      selectedWinner,
      1
    );
    if (!scoreOk) warnings.push('Score save failed');
  }

  // ── Update local state regardless of cloud result ─────────
  updateScores(selectedWinner);
  updatePersistentScores(selectedWinner);
  recordPlayEvent(game.playEventId, game.id, game.category);
  clearCurrentGame();

  if (warnings.length > 0) {
    // Cloud had issues but local state is clean — navigate anyway with warning toast
    return { ok: false, navigateAnyway: true, errors: warnings };
  }

  return { ok: true, errors: [] };
}

// ── UI helpers ──────────────────────────────────────────────

function _showToast(msg) {
  const t = document.createElement('div');
  t.className = 'toast-msg';
  t.textContent = msg;
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 2000);
}

function _rebuildWinnerGrid() {
  const checked = [...document.querySelectorAll('.player-check.checked')]
    .map(el => el.dataset.player);
  const grid = document.getElementById('winnerGrid');
  grid.innerHTML = '';

  [...checked, 'No winner'].forEach(name => {
    const btn = document.createElement('button');
    btn.className = 'winner-btn' + (selectedWinner === name ? ' selected' : '');
    btn.textContent = name;
    btn.addEventListener('click', () => {
      document.querySelectorAll('.winner-btn').forEach(b => b.classList.remove('selected'));
      btn.classList.add('selected');
      selectedWinner = name === 'No winner' ? null : name;
    });
    grid.appendChild(btn);
  });
}

function _renderScores(scores) {
  const wrap = document.getElementById('scoresWrap');
  if (!scores) { wrap.classList.add('hidden'); return; }
  const players = Object.entries(scores).filter(([, v]) => v > 0);
  if (players.length === 0) { wrap.classList.add('hidden'); return; }
  wrap.classList.remove('hidden');
  const strip = document.getElementById('scoresStrip');
  strip.innerHTML = '';
  players.sort((a, b) => b[1] - a[1]).forEach(([name, pts]) => {
    const chip = document.createElement('div');
    chip.className = 'score-chip';
    chip.innerHTML = `<span class="score-chip-name">${name}</span>
                      <span class="score-chip-pts">${pts}</span>`;
    strip.appendChild(chip);
  });
}
