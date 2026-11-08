// Moment — keep the screen still while playing.
// Blocks pinch zoom, double-tap zoom, and the iOS edge swipe that goes back a page.
// Buttons and inputs are left alone, so taps keep working, even at the edges.
(function () {
  var EDGE_PX = 14;
  var INTERACTIVE = 'button, input, textarea, select, a, label';

  function isInteractive(target) {
    return !!(target && target.closest && target.closest(INTERACTIVE));
  }

  ['gesturestart', 'gesturechange', 'gestureend'].forEach(function (type) {
    document.addEventListener(type, function (e) { e.preventDefault(); }, { passive: false });
  });

  document.addEventListener('touchstart', function (e) {
    if (e.touches.length > 1) { e.preventDefault(); return; }
    var x = e.touches[0].clientX;
    var inEdge = x < EDGE_PX || x > window.innerWidth - EDGE_PX;
    if (inEdge && !isInteractive(e.target)) e.preventDefault();
  }, { passive: false });

  document.addEventListener('touchmove', function (e) {
    if (e.touches.length > 1) e.preventDefault();
  }, { passive: false });

  // Double-tap zoom: swallow a second touchend that follows within 350 ms.
  var lastEnd = 0;
  document.addEventListener('touchend', function (e) {
    var now = Date.now();
    if (now - lastEnd < 350 && !isInteractive(e.target)) e.preventDefault();
    lastEnd = now;
  }, { passive: false });
})();
