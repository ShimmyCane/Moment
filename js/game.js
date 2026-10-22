// Moment — Game Page Logic

const CATEGORY_EMOJI = {
  observation:    '👀',
  imagination:    '✨',
  learning:       '🧠',
  conversation:   '💬',
  quick_challenge:'⚡'
};

document.addEventListener('DOMContentLoaded', () => {
  const session = getSession();
  if (!session || !session.currentGame) {
    window.location.href = 'index.html';
    return;
  }

  const game = session.currentGame;
  const def  = game.definition || {};

  // Category badge
  const badge = document.getElementById('categoryBadge');
  badge.textContent = (CATEGORY_EMOJI[game.category] || '') + ' ' +
    game.category.replace('_', ' ').replace(/\b\w/g, c => c.toUpperCase());
  badge.className = `category-badge badge-${game.category}`;

  // Title
  document.getElementById('gameTitle').textContent = game.title;

  // Meta: duration + players
  const dMin = def.duration_min;
  const dMax = def.duration_max;
  const dur  = dMin && dMax ? `${dMin}–${dMax} min` : '';
  const pMin = def.players_min;
  const pMax = def.players_max;
  const pls  = pMin ? `${pMin}–${pMax}+ players` : '';
  const meta = [dur, pls, def.energy].filter(Boolean).join('  ·  ');
  document.getElementById('gameMeta').textContent = meta;

  // Instructions
  const list = document.getElementById('instructionsList');
  list.innerHTML = '';
  (def.instructions || []).forEach((step, i) => {
    const li  = document.createElement('li');
    const num = document.createElement('span');
    num.className   = 'step-num';
    num.textContent = i + 1;
    const txt = document.createElement('span');
    txt.textContent = step;
    li.appendChild(num);
    li.appendChild(txt);
    list.appendChild(li);
  });

  // Options — random round modifier
  if (Array.isArray(def.options) && def.options.length > 0) {
    const idx = Math.floor(Math.random() * def.options.length);
    document.getElementById('optionsText').textContent = def.options[idx];
    document.getElementById('optionsSection').classList.remove('hidden');
  }

  // Variants
  if (def.variants && def.variants.length > 0) {
    const section = document.getElementById('variantsSection');
    section.classList.remove('hidden');
    const ul = document.getElementById('variantsList');
    def.variants.forEach(v => {
      const li = document.createElement('li');
      li.textContent = v;
      ul.appendChild(li);
    });
  }

  // ── Seed Card ────────────────────────────────────────────────
  const seedCards = def.seed_cards;
  if (Array.isArray(seedCards) && seedCards.length > 0) {
    const seedSection  = document.getElementById('seedSection');
    const seedLabelEl  = document.getElementById('seedLabel');
    const seedCardEl   = document.getElementById('seedCard');
    const seedPromptEl = document.getElementById('seedPrompt');
    const mainActions  = document.getElementById('mainActions');

    // Show seed section, hide normal Next/Feedback buttons
    seedSection.classList.remove('hidden');
    mainActions.classList.add('hidden');

    if (def.seed_label) seedLabelEl.textContent = def.seed_label;

    let usedIndices = [];

    function drawCard(animate) {
      if (usedIndices.length >= seedCards.length) usedIndices = [];
      let idx, tries = 0;
      do {
        idx = Math.floor(Math.random() * seedCards.length);
        tries++;
      } while (usedIndices.includes(idx) && tries < seedCards.length * 2);
      usedIndices.push(idx);

      if (animate && seedCardEl) {
        seedCardEl.classList.add('flipping');
        setTimeout(() => {
          seedPromptEl.textContent = seedCards[idx];
          seedCardEl.classList.remove('flipping');
        }, 220);
      } else {
        seedPromptEl.textContent = seedCards[idx];
      }
    }

    drawCard(false);

    document.getElementById('changeCardBtn').addEventListener('click', () => drawCard(true));

    document.getElementById('endGameBtn').addEventListener('click', () => {
      window.location.href = 'end.html';
    });
  }

  // Next Game — marks completed, records history, goes to wheel
  document.getElementById('doneBtn').addEventListener('click', async () => {
    const s = getSession();
    const g = s.currentGame;
    if (g && g.playEventId) {
      await updatePlayEvent(g.playEventId, { outcome: 'completed' });
    }
    recordPlayEvent(g ? g.playEventId : null, g ? g.id : null, g ? g.category : null);
    clearCurrentGame();
    window.location.href = 'index.html';
  });

  // Feedback — goes to end.html for rating/notes (keeps currentGame in session)
  document.getElementById('feedbackBtn').addEventListener('click', () => {
    window.location.href = 'end.html';
  });

  // Skip — marks as skipped, goes to wheel
  document.getElementById('skipBtn').addEventListener('click', async () => {
    const s = getSession();
    if (s.currentGame && s.currentGame.playEventId) {
      await updatePlayEvent(s.currentGame.playEventId, { outcome: 'skipped' });
    }
    clearCurrentGame();
    window.location.href = 'index.html';
  });
});
