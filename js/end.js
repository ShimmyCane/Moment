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

  // ── Rating buttons ──────────────────────────────────────
  document.querySelectorAll('.rating-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.rating-btn').forEach(b => b.classList.remove('selected'));
      btn.classList.add('selected');
      selectedRating = parseInt(btn.dataset.rating, 10);
    });
  });

  // ── Player checkboxes (default: session players) ────────
  const playerGrid = document.getElementById('playerGrid');
  playerGrid.innerHTML = '';
  const activePlayers = session.players || ALL_PLAYERS.slice(0, 4);

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
    btn.disabled = true;
    btn.textContent = 'Saving…';
    await _submit();
    _showToast('Feedback saved! 🎉');
    setTimeout(() => { window.location.href = 'index.html'; }, 1200);
  });

  // ── Just Spin (no save) ─────────────────────────────────
  document.getElementById('skipSaveBtn').addEventListener('click', () => {
    clearCurrentGame();
    window.location.href = 'index.html';
  });
});

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

async function _submit() {
  const session  = getSession();
  const game     = session.currentGame;
  const notes    = document.getElementById('notesInput').value.trim();
  const players  = [...document.querySelectorAll('.player-check.checked')]
    .map(el => el.dataset.player);

  if (game.playEventId) {
    await updatePlayEvent(game.playEventId, {
      outcome: 'completed',
      players,
      winner: selectedWinner || null
    });

    if (selectedRating !== null) {
      await submitFeedback(
        game.playEventId,
        game.id,
        game.current_version_id,
        selectedRating,
        notes || null
      );
    }

    if (selectedWinner && session.sessionId) {
      await saveScore(session.sessionId, game.playEventId, selectedWinner, 1);
    }
  }

  updateScores(selectedWinner);
  updatePersistentScores(selectedWinner);
  recordPlayEvent(game.playEventId, game.id, game.category);
  clearCurrentGame();
}
