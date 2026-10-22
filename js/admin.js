// Moment — Admin Authoring Studio

const VALID_CATEGORIES = ['observation','imagination','learning','conversation','quick_challenge'];
const VALID_TEMPLATES  = ['observation_game','turn_based_story','quick_guess','word_association',
                          'math_challenge','conversation_prompt','physical_challenge','creative_challenge'];
const VALID_ENERGY     = ['calm','active','wild'];
const VALID_INTERACTIONS = ['cooperative','competitive','individual','group'];

let _sb          = null;
let _currentDraft = null;

// ── Auth ────────────────────────────────────────────────────

async function initAdmin() {
  _sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

  const { data: { session } } = await _sb.auth.getSession();
  if (session) {
    showStudio();
    loadGameLibrary();
    loadFeedback();
  } else {
    showLogin();
  }
}

function showLogin() {
  document.getElementById('loginSection').classList.remove('hidden');
  document.getElementById('studioSection').classList.add('hidden');
}

function showStudio() {
  document.getElementById('loginSection').classList.add('hidden');
  document.getElementById('studioSection').classList.remove('hidden');
}

// ── Template ─────────────────────────────────────────────────

const GAME_TEMPLATE = {
  schema_version: '1.0',
  id: 'my-game-slug',
  title: 'My Game Title',
  short_label: 'My Game',
  category: 'observation',
  emoji: '🎯',
  difficulty: 'medium',
  template: 'observation_game',
  duration_min: 2,
  duration_max: 5,
  players_min: 2,
  players_max: 6,
  energy: 'calm',
  materials: [],
  contexts: ['home', 'car', 'table', 'waiting'],
  languages: ['en'],
  educational_topics: [],
  interaction: 'competitive',
  instructions: [
    'Step one — setup or opening action.',
    'Step two — the main mechanic.',
    'Step three — how a round ends.',
    'Step four — optional advanced move.'
  ],
  variants: [
    'Easier version or theme swap.',
    'Harder version or rule addition.'
  ],
  scoring: {
    type: 'winner_takes_one',
    description: 'First correct guess gets +1.'
  }
};

document.getElementById('showTemplateBtn').addEventListener('click', () => {
  document.getElementById('jsonEditor').value = JSON.stringify(GAME_TEMPLATE, null, 2);
  document.getElementById('saveDraftBtn').disabled = true;
  document.getElementById('publishBtn').disabled = true;
  document.getElementById('validationResult').innerHTML = '';
});

document.getElementById('loginForm').addEventListener('submit', async e => {
  e.preventDefault();
  const email = document.getElementById('emailInput').value.trim();
  const pass  = document.getElementById('passInput').value;
  const { error } = await _sb.auth.signInWithPassword({ email, password: pass });
  if (error) {
    document.getElementById('loginError').textContent = error.message;
  } else {
    showStudio();
    loadGameLibrary();
    loadFeedback();
  }
});

// ── Validation ───────────────────────────────────────────────

function validateDefinition(raw) {
  const errors = [];

  let def;
  try { def = JSON.parse(raw); } catch (e) {
    return [{ msg: 'Invalid JSON: ' + e.message }];
  }

  const req = ['schema_version','title','category','template','instructions'];
  req.forEach(k => { if (!def[k]) errors.push({ msg: `Missing required field: "${k}"` }); });

  if (def.category && !VALID_CATEGORIES.includes(def.category))
    errors.push({ msg: `Unknown category "${def.category}". Valid: ${VALID_CATEGORIES.join(', ')}` });

  if (def.template && !VALID_TEMPLATES.includes(def.template))
    errors.push({ msg: `Unknown template "${def.template}". Valid: ${VALID_TEMPLATES.join(', ')}` });

  if (def.energy && !VALID_ENERGY.includes(def.energy))
    errors.push({ msg: `Unknown energy "${def.energy}". Valid: calm, active, wild` });

  if (def.interaction && !VALID_INTERACTIONS.includes(def.interaction))
    errors.push({ msg: `Unknown interaction "${def.interaction}"` });

  if (def.duration_min && def.duration_max && def.duration_min > def.duration_max)
    errors.push({ msg: 'duration_min must be ≤ duration_max' });

  if (def.players_min && def.players_max && def.players_min > def.players_max)
    errors.push({ msg: 'players_min must be ≤ players_max' });

  const shortLabel = def.short_label || def.title || '';
  if (shortLabel.length > 15)
    errors.push({ msg: `short_label is ${shortLabel.length} chars — max is 15 for wheel display` });

  if (!Array.isArray(def.instructions) || def.instructions.length === 0)
    errors.push({ msg: '"instructions" must be a non-empty array of strings' });

  // Prototype pollution guard
  const forbidden = ['__proto__','constructor','prototype'];
  const rawStr = raw;
  forbidden.forEach(k => {
    if (rawStr.includes(`"${k}"`)) errors.push({ msg: `Forbidden key detected: "${k}"` });
  });

  if (raw.length > 50000)
    errors.push({ msg: `Payload too large (${(raw.length/1000).toFixed(1)}KB). Max 50KB.` });

  return errors;
}

document.getElementById('validateBtn').addEventListener('click', () => {
  const raw    = document.getElementById('jsonEditor').value;
  const errors = validateDefinition(raw);
  const result = document.getElementById('validationResult');

  if (errors.length === 0) {
    result.innerHTML = '<div class="success-msg">✓ Looks good — ready to save as draft</div>';
    _currentDraft = JSON.parse(raw);
    document.getElementById('saveDraftBtn').disabled = false;
    renderPreview(_currentDraft);
  } else {
    result.innerHTML = errors.map(e =>
      `<div class="error-item">✗ ${e.msg}</div>`
    ).join('');
    document.getElementById('saveDraftBtn').disabled = true;
  }
});

// ── Preview ──────────────────────────────────────────────────

function renderPreview(def) {
  const wrap = document.getElementById('previewWrap');
  const catEmoji = { observation:'👀', imagination:'✨', learning:'🧠',
                     conversation:'💬', quick_challenge:'⚡' };
  wrap.innerHTML = `
    <div class="game-card">
      <span class="category-badge badge-${def.category}">
        ${catEmoji[def.category] || ''} ${(def.category||'').replace('_',' ')}
      </span>
      <h2 style="font-size:22px;font-weight:700;margin:8px 0;">${def.title || '—'}</h2>
      <div style="font-size:12px;color:var(--text-muted);margin-bottom:12px;">
        ${def.duration_min}–${def.duration_max} min · ${def.players_min}–${def.players_max} players · ${def.energy || '—'}
      </div>
      <ol class="instructions-list">
        ${(def.instructions||[]).map((s,i)=>`
          <li><span class="step-num">${i+1}</span><span>${s}</span></li>
        `).join('')}
      </ol>
    </div>`;
  wrap.classList.remove('hidden');
}

// ── Save Draft ───────────────────────────────────────────────

document.getElementById('saveDraftBtn').addEventListener('click', async () => {
  if (!_currentDraft) return;
  const btn = document.getElementById('saveDraftBtn');
  btn.disabled = true;
  btn.textContent = 'Saving…';

  const slug = (_currentDraft.id || _currentDraft.title)
    .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

  // Upsert the game record
  const { data: gameData, error: gameErr } = await _sb
    .from('games')
    .upsert({
      slug,
      title:       _currentDraft.title,
      short_label: _currentDraft.short_label || _currentDraft.title.slice(0, 15),
      category:    _currentDraft.category,
      wheel_slot:  _currentDraft.wheel_slot ?? null,
      status:      'draft'
    }, { onConflict: 'slug' })
    .select('id')
    .single();

  if (gameErr) {
    alert('Error saving game: ' + gameErr.message);
    btn.disabled = false;
    btn.textContent = 'Save Draft';
    return;
  }

  // Get next version number
  const { data: versions } = await _sb
    .from('game_versions')
    .select('version_number')
    .eq('game_id', gameData.id)
    .order('version_number', { ascending: false })
    .limit(1);

  const nextVer = versions && versions.length > 0 ? versions[0].version_number + 1 : 1;

  const { data: verData, error: verErr } = await _sb
    .from('game_versions')
    .insert({
      game_id:        gameData.id,
      version_number: nextVer,
      definition:     _currentDraft
    })
    .select('id')
    .single();

  if (verErr) {
    alert('Error saving version: ' + verErr.message);
    btn.disabled = false;
    btn.textContent = 'Save Draft';
    return;
  }

  _currentDraft._dbGameId    = gameData.id;
  _currentDraft._dbVersionId = verData.id;

  document.getElementById('validationResult').innerHTML +=
    `<div class="success-msg">✓ Draft saved (v${nextVer})</div>`;

  document.getElementById('publishBtn').disabled = false;
  btn.textContent = 'Saved';
  loadGameLibrary();
  loadFeedback();
});

// ── Publish ──────────────────────────────────────────────────

document.getElementById('publishBtn').addEventListener('click', async () => {
  if (!_currentDraft || !_currentDraft._dbGameId) return;
  const btn = document.getElementById('publishBtn');
  btn.disabled = true;
  btn.textContent = 'Publishing…';

  const { error } = await _sb
    .from('games')
    .update({ status: 'active', current_version_id: _currentDraft._dbVersionId })
    .eq('id', _currentDraft._dbGameId);

  if (error) {
    alert('Error publishing: ' + error.message);
    btn.disabled = false;
    btn.textContent = 'Publish';
  } else {
    document.getElementById('validationResult').innerHTML +=
      '<div class="success-msg">🎉 Published and live</div>';
    btn.textContent = 'Published';
    loadGameLibrary();
    loadFeedback();
  }
});

// ── Game Library ─────────────────────────────────────────────

async function loadGameLibrary() {
  const { data, error } = await _sb
    .from('games')
    .select('id, slug, title, category, wheel_slot, status, updated_at')
    .order('wheel_slot');

  if (error || !data) return;

  const tbody = document.getElementById('libraryBody');
  tbody.innerHTML = '';
  data.forEach(g => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${g.title}</td>
      <td>${g.category}</td>
      <td><span class="status-badge status-${g.status}">${g.status}</span></td>
      <td>${g.wheel_slot != null ? g.wheel_slot : '—'}</td>
      <td>
        ${g.status === 'active'
          ? `<button onclick="deprecateGame('${g.id}')" style="font-size:12px;cursor:pointer;">Deprecate</button>`
          : g.status === 'deprecated'
            ? `<button onclick="reactivateGame('${g.id}')" style="font-size:12px;cursor:pointer;">Reactivate</button>`
            : `<button onclick="activateGame('${g.id}')" style="font-size:12px;cursor:pointer;" title="Assign a wheel slot first">Activate…</button>`}
      </td>`;
    tbody.appendChild(tr);
  });
}

async function deprecateGame(id) {
  await _sb.from('games').update({ status: 'deprecated' }).eq('id', id);
  loadGameLibrary();
}

async function reactivateGame(id) {
  await _sb.from('games').update({ status: 'active' }).eq('id', id);
  loadGameLibrary();
}

async function activateGame(id) {
  const slotStr = prompt('Enter a wheel slot (0–14) to assign to this game:');
  if (slotStr === null) return;
  const slot = parseInt(slotStr, 10);
  if (isNaN(slot) || slot < 0 || slot > 14) {
    alert('Wheel slot must be a number from 0 to 14.');
    return;
  }
  const { error } = await _sb
    .from('games')
    .update({ status: 'active', wheel_slot: slot })
    .eq('id', id);
  if (error) alert('Error: ' + error.message);
  else { loadGameLibrary(); loadFeedback(); }
}

// ── Feedback Review ───────────────────────────────────────────

async function loadFeedback() {
  const wrap = document.getElementById('feedbackBody');
  if (!wrap) return;

  const { data, error } = await _sb
    .from('game_feedback')
    .select('game_id, rating, notes, created_at, games(title, slug)')
    .order('created_at', { ascending: false });

  if (error || !data) {
    wrap.innerHTML = '<div style="color:#DC2626;font-size:13px;">Could not load feedback: ' + (error ? error.message : 'no data') + '</div>';
    return;
  }

  if (data.length === 0) {
    wrap.innerHTML = '<div style="color:var(--text-muted);font-size:13px;">No feedback yet.</div>';
    return;
  }

  // Group by game_id
  const byGame = {};
  data.forEach(row => {
    const id = row.game_id;
    if (!byGame[id]) {
      byGame[id] = {
        title: row.games ? row.games.title : id,
        up: 0, neutral: 0, down: 0,
        notes: []
      };
    }
    if (row.rating === 1)  byGame[id].up++;
    else if (row.rating === 0)  byGame[id].neutral++;
    else if (row.rating === -1) byGame[id].down++;
    if (row.notes) byGame[id].notes.push({ text: row.notes, at: row.created_at });
  });

  const rows = Object.entries(byGame)
    .sort((a, b) => (b[1].up - b[1].down) - (a[1].up - a[1].down));

  let html = '<div style="overflow-x:auto;"><table class="game-table"><thead><tr>' +
    '<th>Game</th><th>👍</th><th>😐</th><th>👎</th><th>Score</th><th>Latest Note</th><th></th>' +
    '</tr></thead><tbody>';

  rows.forEach(([id, g]) => {
    const score = g.up - g.down;
    const scoreColor = score > 0 ? '#16a34a' : score < 0 ? '#DC2626' : 'inherit';
    const latestNote = g.notes.length > 0
      ? `<span title="${g.notes[0].at}">${_truncate(g.notes[0].text, 60)}</span>`
      : '<span style="color:var(--text-muted)">—</span>';
    html += `<tr>
      <td style="font-weight:700;">${g.title}</td>
      <td style="text-align:center;">${g.up}</td>
      <td style="text-align:center;">${g.neutral}</td>
      <td style="text-align:center;">${g.down}</td>
      <td style="text-align:center;font-weight:700;color:${scoreColor};">${score > 0 ? '+' : ''}${score}</td>
      <td style="font-size:12px;max-width:200px;">${latestNote}</td>
      <td><button onclick="loadGameForEdit('${id}')" style="font-size:12px;cursor:pointer;">Load</button></td>
    </tr>`;
  });

  html += '</tbody></table></div>';
  wrap.innerHTML = html;
}

function _truncate(str, n) {
  return str.length <= n ? str : str.slice(0, n - 1) + '…';
}

async function loadGameForEdit(gameId) {
  const { data, error } = await _sb
    .from('games')
    .select('id, slug, title, short_label, category, wheel_slot, current_version_id, game_versions(definition)')
    .eq('id', gameId)
    .single();

  if (error || !data) {
    alert('Could not load game: ' + (error ? error.message : 'not found'));
    return;
  }

  const def = data.game_versions ? data.game_versions.definition : {};
  def.id = data.slug;
  def.title = data.title;
  def.short_label = data.short_label;
  def.category = data.category;
  if (data.wheel_slot != null) def.wheel_slot = data.wheel_slot;

  document.getElementById('jsonEditor').value = JSON.stringify(def, null, 2);
  document.getElementById('validationResult').innerHTML =
    '<div style="color:#2563EB;font-size:13px;">✎ Loaded — edit, then Validate → Save Draft → Publish to update.</div>';
  document.getElementById('saveDraftBtn').disabled = true;
  document.getElementById('publishBtn').disabled = true;

  // Scroll to editor
  document.getElementById('jsonEditor').scrollIntoView({ behavior: 'smooth', block: 'start' });
}

initAdmin();
