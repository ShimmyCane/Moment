// Moment — Shared UI: floating gear, settings panel, playlist selector, error display
(function () {
  window._momentErrors      = window._momentErrors      || [];
  window._supabaseConnected = window._supabaseConnected || false;

  var PLAYLISTS = [
    { id: 'all',   label: 'All' },
    { id: 'new',   label: 'New' },
    { id: 'top',   label: '⭐ Top' },
    { id: 'felix', label: "Felix's" },
    { id: 'mix',   label: 'Mix' }
  ];

  function init() {
    // Gear button
    var gear = document.createElement('button');
    gear.id = 'gearBtn';
    gear.className = 'floating-gear';
    gear.setAttribute('aria-label', 'Settings');
    gear.textContent = '⚙';
    document.body.appendChild(gear);

    // Settings panel
    var panel = document.createElement('div');
    panel.id = 'settingsPanel';
    panel.className = 'settings-panel hidden';
    panel.innerHTML = _buildPanelHTML();
    document.body.appendChild(panel);

    // Error panel inside .app-container
    var container = document.querySelector('.app-container');
    if (container) {
      var errPanel = document.createElement('div');
      errPanel.id = 'errorPanel';
      errPanel.className = 'error-panel hidden';
      errPanel.innerHTML = '<div class="error-panel-title">⚠ Errors</div><div id="errorList"></div>';
      container.appendChild(errPanel);
    }

    // Restore settings
    var pl = localStorage.getItem('moment_playlist') || 'all';
    _setActivePlaylist(pl, false);

    var stored = localStorage.getItem('moment_show_errors') === '1';
    document.getElementById('showErrorsToggle').checked = stored;
    _applyErrorVisibility(stored);

    // Gear toggle
    gear.addEventListener('click', function (e) {
      e.stopPropagation();
      panel.classList.toggle('hidden');
    });
    document.addEventListener('click', function () {
      panel.classList.add('hidden');
    });

    // Playlist buttons
    PLAYLISTS.forEach(function (pl) {
      var btn = document.getElementById('pl-' + pl.id);
      if (btn) {
        btn.addEventListener('click', function (e) {
          e.stopPropagation();
          _setActivePlaylist(pl.id, true);
        });
      }
    });

    // Show errors toggle
    document.getElementById('showErrorsToggle').addEventListener('change', function () {
      var show = this.checked;
      localStorage.setItem('moment_show_errors', show ? '1' : '0');
      panel.classList.add('hidden');
      _applyErrorVisibility(show);
    });

    // Hooks from db.js
    window._onErrorLogged = function () {
      var count = window._momentErrors.length;
      var g = document.getElementById('gearBtn');
      if (g) g.dataset.errorCount = count > 0 ? String(count) : '';
      if (localStorage.getItem('moment_show_errors') === '1') _renderErrors();
    };
    window._onSupabaseStatus = function (connected) {
      var dot  = document.getElementById('sbDot');
      var text = document.getElementById('sbText');
      if (dot)  dot.className  = 'status-dot ' + (connected ? 'status-connected' : 'status-offline');
      if (text) text.textContent = connected ? 'Supabase ✓' : 'Supabase ✗';
    };
    // Reflect current status if already known
    window._onSupabaseStatus(window._supabaseConnected);

    if (stored) _renderErrors();
  }

  function _buildPanelHTML() {
    var html = '<div class="settings-title">Settings</div>';

    // Supabase status
    html += '<div class="settings-status">' +
              '<span id="sbDot" class="status-dot status-offline"></span>' +
              '<span id="sbText">Supabase</span>' +
            '</div>';

    // Playlist selector (only shown on index.html)
    html += '<div class="settings-section-label">Playlist</div>';
    html += '<div class="playlist-row">';
    PLAYLISTS.forEach(function (pl) {
      html += '<button id="pl-' + pl.id + '" class="pl-btn" data-pl="' + pl.id + '">' + pl.label + '</button>';
    });
    html += '</div>';

    // Errors toggle
    html += '<div style="margin-top:12px;padding-top:10px;border-top:2px dashed #e5e7eb;">';
    html += '<label class="settings-row">' +
              '<input type="checkbox" id="showErrorsToggle">' +
              '<span>Show errors</span>' +
            '</label>';
    html += '</div>';

    return html;
  }

  function _setActivePlaylist(id, save) {
    if (save) {
      localStorage.setItem('moment_playlist', id);
      // Notify index.html if the listener is set
      if (typeof window._onPlaylistChange === 'function') window._onPlaylistChange(id);
    }
    PLAYLISTS.forEach(function (pl) {
      var btn = document.getElementById('pl-' + pl.id);
      if (btn) btn.classList.toggle('pl-active', pl.id === id);
    });
    // Update spin button label if present
    var spinBtn = document.getElementById('spinBtn');
    if (spinBtn && !spinBtn.disabled) {
      var names = { all:'Spin!', new:'Spin New!', top:'Spin Top!', felix:"Spin Felix's!", mix:'Spin Mix!' };
      spinBtn.textContent = names[id] || 'Spin!';
    }
  }

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
    var list = document.getElementById('errorList');
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

  document.addEventListener('DOMContentLoaded', init);
})();
