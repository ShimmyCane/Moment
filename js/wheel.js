// Moment — SVG Wheel Builder + Spin Animation
// Angle convention: 0° = 12-o'clock, clockwise positive.
// Wheel SVG is 300×300, center (150,150), radius 130.

const CENTER_X        = 150;
const CENTER_Y        = 150;
const WHEEL_RADIUS    = 130;
const TEXT_RADIUS     = 90;
const MAX_WHEEL_GAMES = 10;

// Emoji fallback for offline play (before graphic_upgrade.sql is run)
const GAME_EMOJI_FALLBACK = {
  'i-spy-weird':              '🔍',
  'sound-detective':          '👂',
  'what-changed':             '👁️',
  'three-word-story':         '📖',
  'fortunately-unfortunately':'🎭',
  'impossible-invention':     '⚗️',
  'mystery-number':           '🔢',
  'what-doesnt-belong':       '🧩',
  'space-mission':            '🚀',
  'would-you-rather':         '🤔',
  'superpower-swap':          '🦸',
  'family-forecast':          '🔮',
  'forbidden-word':           '🤐',
  'mini-charades':            '🎬',
  'three-things':             '🎯',
};

const CATEGORY_COLORS = {
  observation:     ['#F59E0B', '#FBBF24', '#D97706'],
  imagination:     ['#8B5CF6', '#A78BFA', '#7C3AED'],
  learning:        ['#3B82F6', '#60A5FA', '#2563EB'],
  conversation:    ['#10B981', '#34D399', '#059669'],
  quick_challenge: ['#EF4444', '#F87171', '#DC2626']
};

function _toRad(deg) { return deg * Math.PI / 180; }

function _angleToXY(angleDeg, r) {
  return {
    x: CENTER_X + r * Math.sin(_toRad(angleDeg)),
    y: CENTER_Y - r * Math.cos(_toRad(angleDeg))
  };
}

function _wedgePath(i, wedgeDeg) {
  const start = i * wedgeDeg;
  const end   = (i + 1) * wedgeDeg;
  const p1 = _angleToXY(start, WHEEL_RADIUS);
  const p2 = _angleToXY(end,   WHEEL_RADIUS);
  return [
    `M ${CENTER_X} ${CENTER_Y}`,
    `L ${p1.x.toFixed(2)} ${p1.y.toFixed(2)}`,
    `A ${WHEEL_RADIUS} ${WHEEL_RADIUS} 0 0 1 ${p2.x.toFixed(2)} ${p2.y.toFixed(2)}`,
    'Z'
  ].join(' ');
}

// Round-robin interleave across category buckets so adjacent wedges are
// from different categories. Caps display at MAX_WHEEL_GAMES.
function _interleaveByCategory(games) {
  const max = Math.min(games.length, MAX_WHEEL_GAMES);

  const bycat = {};
  games.forEach(g => {
    if (!bycat[g.category]) bycat[g.category] = [];
    bycat[g.category].push(g);
  });
  // Shuffle within each bucket for variety
  Object.values(bycat).forEach(arr => arr.sort(() => Math.random() - 0.5));

  // Shuffle bucket order so category sequence changes each build
  const buckets = Object.values(bycat).sort(() => Math.random() - 0.5);

  const result = [];
  while (result.length < max) {
    const nonempty = buckets.filter(b => b.length > 0);
    if (!nonempty.length) break;
    for (const bucket of nonempty) {
      if (result.length >= max) break;
      result.push(bucket.shift());
    }
  }
  return result;
}

function buildWheel(games, svgEl) {
  if (!games || games.length === 0) return;

  // Remove previous wheel group — supports playlist-change rebuilds
  const existing = svgEl.querySelector('#wheel-group');
  if (existing) existing.remove();

  const display   = _interleaveByCategory(games);
  const count     = display.length;
  if (count === 0) return;

  const wedgeDeg  = 360 / count;
  svgEl._games    = display;
  svgEl._wedgeDeg = wedgeDeg;

  const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
  g.id = 'wheel-group';

  // Restore stored rotation before inserting into DOM — no transition fires
  const storedRot = (typeof getWheelRotation === 'function') ? getWheelRotation() : 0;
  g.style.transform = `rotate(${storedRot}deg)`;

  // Track last shade per category to avoid repeating the same shade consecutively
  const lastShade = {};

  // ── Wedges ───────────────────────────────────────────────────
  display.forEach((game, i) => {
    const cat    = game.category;
    const colors = CATEGORY_COLORS[cat] || ['#94A3B8', '#CBD5E1', '#64748B'];

    let shade;
    if (colors.length === 1) {
      shade = 0;
    } else {
      const prev = lastShade[cat] !== undefined ? lastShade[cat] : -1;
      do { shade = Math.floor(Math.random() * colors.length); } while (shade === prev);
    }
    lastShade[cat] = shade;
    const fill = colors[shade];

    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('d', _wedgePath(i, wedgeDeg));
    path.setAttribute('fill', fill);
    path.setAttribute('stroke', '#fff');
    path.setAttribute('stroke-width', '2');
    g.appendChild(path);

    // ── Label (emoji preferred, else short text) ─────────────
    const mid   = i * wedgeDeg + wedgeDeg / 2;
    const emoji = game.emoji || GAME_EMOJI_FALLBACK[game.slug] || null;
    const tp    = _angleToXY(mid, TEXT_RADIUS);

    // Flip labels that would render upside-down (bottom half: 91°–269°)
    let textRot = mid;
    if (mid > 90 && mid < 270) textRot += 180;

    const txt = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    txt.setAttribute('transform',
      `translate(${tp.x.toFixed(2)}, ${tp.y.toFixed(2)}) rotate(${textRot.toFixed(1)})`);
    txt.setAttribute('text-anchor', 'middle');
    txt.setAttribute('dominant-baseline', 'middle');
    txt.setAttribute('fill', '#fff');

    if (emoji) {
      // Scale emoji size with wedge angle so larger wedges get larger emoji
      const emojiSize = Math.min(20, Math.max(10, Math.round(wedgeDeg * 0.45)));
      txt.setAttribute('font-size', String(emojiSize));
      txt.textContent = emoji;
    } else {
      txt.setAttribute('font-family', "'Quicksand', sans-serif");
      txt.setAttribute('font-size', '9');
      txt.setAttribute('font-weight', '700');
      txt.setAttribute('paint-order', 'stroke');
      txt.setAttribute('stroke', fill);
      txt.setAttribute('stroke-width', '3');
      txt.setAttribute('stroke-linejoin', 'round');
      txt.textContent = game.short_label || game.title;
    }
    g.appendChild(txt);
  });

  // ── Center cap ───────────────────────────────────────────────
  const cap = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
  cap.setAttribute('cx', CENTER_X);
  cap.setAttribute('cy', CENTER_Y);
  cap.setAttribute('r', '22');
  cap.setAttribute('fill', '#2b2d42');
  cap.setAttribute('stroke', '#fff');
  cap.setAttribute('stroke-width', '3');
  g.appendChild(cap);

  const capText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
  capText.setAttribute('x', CENTER_X);
  capText.setAttribute('y', CENTER_Y);
  capText.setAttribute('text-anchor', 'middle');
  capText.setAttribute('dominant-baseline', 'middle');
  capText.setAttribute('fill', '#fff');
  capText.setAttribute('font-family', "'Quicksand', sans-serif");
  capText.setAttribute('font-size', '11');
  capText.setAttribute('font-weight', '700');
  capText.textContent = '✦';
  g.appendChild(capText);

  // Insert before pointer so the fixed arrow stays on top
  const pointer = svgEl.querySelector('#wheel-pointer');
  if (pointer) svgEl.insertBefore(g, pointer);
  else         svgEl.appendChild(g);

  // ── Fixed pointer (created once) ─────────────────────────────
  if (!svgEl.querySelector('#wheel-pointer')) {
    const ptr = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');
    ptr.id = 'wheel-pointer';
    ptr.setAttribute('points', '136,10 164,10 150,28');
    ptr.setAttribute('fill', '#2b2d42');
    ptr.setAttribute('stroke', '#ffffff');
    ptr.setAttribute('stroke-width', '2');
    ptr.setAttribute('stroke-linejoin', 'round');
    ptr.style.filter = 'drop-shadow(0 2px 3px rgba(0,0,0,0.4))';
    svgEl.appendChild(ptr);
  }
}

// ── Spin ─────────────────────────────────────────────────────────
// Spins the wheel to land on the game with the given ID.
// If the game is not visible on the wheel, navigates without animating.
function spinTo(gameId, currentRotation, svgEl, onComplete) {
  const games       = svgEl._games || [];
  const wedgeDeg    = svgEl._wedgeDeg || (360 / Math.max(1, games.length));
  const visualIndex = games.findIndex(g => g.id === gameId);

  if (visualIndex === -1) {
    onComplete(currentRotation);
    return;
  }

  const wedgeCenter  = visualIndex * wedgeDeg + wedgeDeg / 2;
  const baseTarget   = (360 - wedgeCenter % 360) % 360;
  const currentMod   = ((currentRotation % 360) + 360) % 360;
  let   delta        = baseTarget - currentMod;
  if (delta <= 0) delta += 360;

  const finalRotation = currentRotation + delta + 8 * 360;

  const groupEl = svgEl.querySelector('#wheel-group');
  if (!groupEl) { onComplete(currentRotation); return; }

  groupEl.style.transition = 'transform 4.5s cubic-bezier(0.05, 0.92, 0.15, 1.0)';
  groupEl.style.transform  = `rotate(${finalRotation}deg)`;

  function handleEnd() {
    groupEl.removeEventListener('transitionend', handleEnd);
    onComplete(finalRotation);
  }
  groupEl.addEventListener('transitionend', handleEnd);
}
