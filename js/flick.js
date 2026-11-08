// Moment — Flick mode: drag the wheel and let go, instead of pressing Spin.
// Pegs sit around the rim. Each wedge boundary that passes the pointer clicks.
// A flick is capped, so a child-sized wheel needs a hard flick, and the whole
// stop takes FLICK_DURATION_MS.

const FLICK_DURATION_MS  = 1500;
const FLICK_MAX_DEG_S    = 1000; // hardest possible flick
const FLICK_MIN_DEG_S    = 150;  // gentler releases just let the wheel rest
const FLICK_SAMPLE_MS    = 120;  // window used to measure release speed
const PEG_RING_RADIUS    = 137;
const PEG_RADIUS         = 3.2;

// ── Click sound (synthesised, no audio file) ────────────────

let _audioCtx  = null;
let _clickBuf  = null;

function _getAudio() {
  try {
    if (!_audioCtx) {
      _audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      const len = Math.floor(_audioCtx.sampleRate * 0.02);
      _clickBuf = _audioCtx.createBuffer(1, len, _audioCtx.sampleRate);
      const data = _clickBuf.getChannelData(0);
      for (let i = 0; i < len; i++) {
        data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / len, 4);
      }
    }
    if (_audioCtx.state === 'suspended') _audioCtx.resume();
    return _audioCtx;
  } catch (_) { return null; }
}

function playPegClick(volume = 0.5) {
  window._momentPegClicks = (window._momentPegClicks || 0) + 1;
  const ctx = _getAudio();
  if (!ctx || !_clickBuf) return;
  const src = ctx.createBufferSource();
  src.buffer = _clickBuf;
  const band = ctx.createBiquadFilter();
  band.type = 'bandpass';
  band.frequency.value = 2200;
  band.Q.value = 1.2;
  const gain = ctx.createGain();
  gain.gain.value = volume;
  src.connect(band);
  band.connect(gain);
  gain.connect(ctx.destination);
  src.start();
}

// ── Pegs (fixed on the frame, not on the wheel) ─────────────

function drawPegs(svgEl) {
  const old = svgEl.querySelector('#wheel-pegs');
  if (old) old.remove();

  const count = (svgEl._games || []).length;
  if (count === 0) return;
  const wedgeDeg = svgEl._wedgeDeg || 360 / count;

  const NS = 'http://www.w3.org/2000/svg';
  const g = document.createElementNS(NS, 'g');
  g.id = 'wheel-pegs';
  for (let i = 0; i < count; i++) {
    const p = _angleToXY(i * wedgeDeg, PEG_RING_RADIUS);
    const c = document.createElementNS(NS, 'circle');
    c.setAttribute('cx', p.x.toFixed(2));
    c.setAttribute('cy', p.y.toFixed(2));
    c.setAttribute('r', String(PEG_RADIUS));
    c.setAttribute('fill', '#2b2d42');
    c.setAttribute('stroke', '#ffffff');
    c.setAttribute('stroke-width', '1.2');
    g.appendChild(c);
  }
  const pointer = svgEl.querySelector('#wheel-pointer');
  svgEl.insertBefore(g, pointer || null);
}

// ── Geometry helpers ────────────────────────────────────────

function _wrap180(deg) {
  return ((deg + 180) % 360 + 360) % 360 - 180;
}

// Index of the wedge under the pointer (pointer is at 0°, wheel turns clockwise).
function _wedgeUnderPointer(rot, count, wedgeDeg) {
  const local = ((-rot) % 360 + 360) % 360;
  return Math.floor(local / wedgeDeg) % count;
}

// ── Flick controller ────────────────────────────────────────
// options.isEnabled() → bool  (false while a spin is already running)
// options.onLand(game)        (called once the wheel has stopped)

function initFlickWheel(svgEl, options) {
  svgEl.style.touchAction = 'none';

  let rot        = 0;
  let dragging   = false;
  let animating  = false;
  let lastAngle  = 0;
  let lastClickN = 0;
  let samples    = [];
  let flapTimer  = null;
  let animId     = 0;

  const wheelGroup = () => svgEl.querySelector('#wheel-group');
  const count      = () => (svgEl._games || []).length;
  const wedgeDeg   = () => svgEl._wedgeDeg || 360 / Math.max(1, count());

  function setRot(r) {
    const g = wheelGroup();
    if (!g) return;
    g.style.transition = 'none';
    g.style.transform  = `rotate(${r}deg)`;
  }

  function pointerAngle(e) {
    const box = svgEl.getBoundingClientRect();
    const dx = e.clientX - (box.left + box.width / 2);
    const dy = e.clientY - (box.top + box.height / 2);
    return Math.atan2(dx, -dy) * 180 / Math.PI;
  }

  function flapPointer() {
    const ptr = svgEl.querySelector('#wheel-pointer');
    if (!ptr) return;
    ptr.setAttribute('transform', 'rotate(-9 150 12)');
    clearTimeout(flapTimer);
    flapTimer = setTimeout(() => ptr.removeAttribute('transform'), 70);
  }

  // One click each time a wedge boundary (peg) passes the pointer.
  function clickForCrossings(currentRot) {
    const n = Math.floor(currentRot / wedgeDeg());
    if (n !== lastClickN) {
      lastClickN = n;
      playPegClick();
      flapPointer();
    }
  }

  svgEl.addEventListener('pointerdown', function (e) {
    if (animating || !options.isEnabled()) return;
    e.preventDefault();
    dragging  = true;
    rot       = getWheelRotation();
    lastAngle = pointerAngle(e);
    lastClickN = Math.floor(rot / wedgeDeg());
    samples   = [{ t: performance.now(), r: rot }];
    svgEl.setPointerCapture(e.pointerId);
    _getAudio(); // unlock audio inside the user gesture
  });

  svgEl.addEventListener('pointermove', function (e) {
    if (!dragging) return;
    const a = pointerAngle(e);
    rot += _wrap180(a - lastAngle);
    lastAngle = a;
    setRot(rot);
    clickForCrossings(rot);

    const now = performance.now();
    samples.push({ t: now, r: rot });
    while (samples.length > 2 && now - samples[0].t > FLICK_SAMPLE_MS) samples.shift();
  });

  function release(e) {
    if (!dragging) return;
    dragging = false;

    const now = performance.now();
    samples.push({ t: now, r: rot });
    const first = samples[0];
    const dt    = (now - first.t) / 1000;
    let v       = dt > 0 ? (rot - first.r) / dt : 0; // degrees per second

    if (Math.abs(v) < FLICK_MIN_DEG_S) {
      setWheelRotation(rot); // gentle release: wheel just rests where it is
      return;
    }
    v = Math.sign(v) * Math.min(Math.abs(v), FLICK_MAX_DEG_S);
    startStop(v);
  }
  svgEl.addEventListener('pointerup', release);
  svgEl.addEventListener('pointercancel', release);

  // Cubic ease-out from speed v over FLICK_DURATION_MS.
  // Distance = v * T / 3. The stop is nudged (at most half a wedge) so a
  // wedge centre finishes under the pointer.
  function startStop(v) {
    const n = count();
    if (!n) return;
    const wd    = wedgeDeg();
    const T     = FLICK_DURATION_MS / 1000;
    const start = rot;
    const rough = start + v * T / 3;

    const idx   = _wedgeUnderPointer(rough, n, wd);
    const centre = idx * wd + wd / 2;
    const final = rough + _wrap180(-centre - rough);
    const dist  = final - start;
    const game  = svgEl._games[idx];

    animating  = true;
    lastClickN = Math.floor(start / wd);
    const t0   = performance.now();

    function frame(now) {
      const u   = Math.min(1, (now - t0) / FLICK_DURATION_MS);
      const cur = start + dist * (1 - Math.pow(1 - u, 3));
      setRot(cur);
      clickForCrossings(cur);

      if (u < 1) {
        animId = requestAnimationFrame(frame);
        return;
      }
      rot = final;
      setRot(final);
      setWheelRotation(final);
      animating = false;
      options.onLand(game);
    }
    animId = requestAnimationFrame(frame);
  }
}
