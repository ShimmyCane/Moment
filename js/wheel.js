// Moment — SVG Wheel Builder + Spin Animation
// Angle convention: 0° = 12-o'clock, clockwise positive.
// Wheel SVG is 300×300, center (150,150), radius 130.

const WEDGE_COUNT  = 6;
const WEDGE_DEG    = 360 / WEDGE_COUNT;    // 60°
const CENTER_X     = 150;
const CENTER_Y     = 150;
const WHEEL_RADIUS = 130;
const TEXT_RADIUS  = 90;

// Emoji fallback for offline play (before graphic_upgrade.sql is run)
const GAME_EMOJI_FALLBACK = {
  'i-spy-weird':             '🔍',
  'sound-detective':         '👂',
  'what-changed':            '👁️',
  'three-word-story':        '📖',
  'fortunately-unfortunately':'🎭',
  'impossible-invention':    '⚗️',
  'mystery-number':          '🔢',
  'what-doesnt-belong':      '🧩',
  'space-mission':           '🚀',
  'would-you-rather':        '🤔',
  'superpower-swap':         '🦸',
  'family-forecast':         '🔮',
  'forbidden-word':          '🤐',
  'mini-charades':           '🎬',
  'three-things':            '🎯',
};

const CATEGORY_COLORS = {
  observation:     ['#F59E0B', '#FBBF24', '#D97706'],
  imagination:     ['#8B5CF6', '#A78BFA', '#7C3AED'],
  learning:        ['#3B82F6', '#60A5FA', '#2563EB'],
  conversation:    ['#10B981', '#34D399', '#059669'],
  quick_challenge: ['#EF4444', '#F87171', '#DC2626']
};

function _toRad(deg) { return deg * Math.PI / 180; }

// Convert angle (0=12-o'clock, clockwise) to SVG x,y at given radius
function _angleToXY(angleDeg, r) {
  return {
    x: CENTER_X + r * Math.sin(_toRad(angleDeg)),
    y: CENTER_Y - r * Math.cos(_toRad(angleDeg))
  };
}

function _wedgePath(i) {
  const start = i * WEDGE_DEG;
  const end   = (i + 1) * WEDGE_DEG;
  const p1 = _angleToXY(start, WHEEL_RADIUS);
  const p2 = _angleToXY(end,   WHEEL_RADIUS);
  return [
    `M ${CENTER_X} ${CENTER_Y}`,
    `L ${p1.x.toFixed(2)} ${p1.y.toFixed(2)}`,
    `A ${WHEEL_RADIUS} ${WHEEL_RADIUS} 0 0 1 ${p2.x.toFixed(2)} ${p2.y.toFixed(2)}`,
    'Z'
  ].join(' ');
}

function buildWheel(games, svgEl) {
  // Sort by wheel_slot so indices match slot numbers
  const sorted = [...games].sort((a, b) => a.wheel_slot - b.wheel_slot);

  const catCount = {};

  const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
  g.id = 'wheel-group';

  // ── Wedges ───────────────────────────────────────────────
  sorted.forEach((game, i) => {
    const cat = game.category;
    catCount[cat] = (catCount[cat] || 0);
    const colorIdx = catCount[cat] % 3;
    catCount[cat]++;

    const colors = CATEGORY_COLORS[cat] || ['#94A3B8', '#CBD5E1', '#64748B'];
    const fill   = colors[colorIdx];

    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('d', _wedgePath(i));
    path.setAttribute('fill', fill);
    path.setAttribute('stroke', '#fff');
    path.setAttribute('stroke-width', '2');
    g.appendChild(path);

    // ── Label (emoji preferred, else text) ───────────────
    const mid = i * WEDGE_DEG + WEDGE_DEG / 2;
    const emoji = game.emoji || GAME_EMOJI_FALLBACK[game.slug] || null;
    const tp  = _angleToXY(mid, emoji ? TEXT_RADIUS : TEXT_RADIUS);

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
      txt.setAttribute('font-size', '16');
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

  // ── Center cap ───────────────────────────────────────────
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

  svgEl.appendChild(g);

  // ── Fixed pointer (not in wheel-group, stays at 12-o'clock) ──
  // Triangle tip at (150,28), base at y=10 — confirmed inside the clip circle (r=150)
  if (!svgEl.querySelector('#wheel-pointer')) {
    const pointer = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');
    pointer.id = 'wheel-pointer';
    pointer.setAttribute('points', '136,10 164,10 150,28');
    pointer.setAttribute('fill', '#2b2d42');
    pointer.setAttribute('stroke', '#ffffff');
    pointer.setAttribute('stroke-width', '2');
    pointer.setAttribute('stroke-linejoin', 'round');
    pointer.style.filter = 'drop-shadow(0 2px 3px rgba(0,0,0,0.4))';
    svgEl.appendChild(pointer);
  }

  // Store sorted games on the SVG for later reference
  svgEl._games = sorted;
}

// ── Spin ────────────────────────────────────────────────────

function spinTo(gameIndex, currentRotation, svgEl, onComplete) {
  const wedgeCenter = gameIndex * WEDGE_DEG + WEDGE_DEG / 2;
  const baseTarget  = (360 - wedgeCenter % 360) % 360;

  const currentMod = ((currentRotation % 360) + 360) % 360;
  let   delta      = baseTarget - currentMod;
  if (delta <= 0) delta += 360;

  const finalRotation = currentRotation + delta + 8 * 360;

  const groupEl = svgEl.querySelector('#wheel-group');
  if (!groupEl) return;

  groupEl.style.transition = 'transform 4.5s cubic-bezier(0.05, 0.92, 0.15, 1.0)';
  groupEl.style.transform  = `rotate(${finalRotation}deg)`;

  function handleEnd() {
    groupEl.removeEventListener('transitionend', handleEnd);
    onComplete(finalRotation);
  }
  groupEl.addEventListener('transitionend', handleEnd);
}

function getGameAtSlot(svgEl, slot) {
  if (!svgEl._games) return null;
  return svgEl._games.find(g => g.wheel_slot === slot) || null;
}
