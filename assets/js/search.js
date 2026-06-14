(function () {
  'use strict';

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c];
    });
  }

  // Filters the rows of the big apps table in-place.
  function initTableFilter() {
    var input = document.getElementById('app-search-input');
    var counter = document.getElementById('app-search-count');
    var archSel = document.getElementById('app-search-arch');
    if (!input) return;

    // Locate the apps table by its header cells; the search box may be at the
    // top of the page (via the `category` layout) or inline near the table.
    var table = null;
    var tables = document.getElementsByTagName('table');
    for (var t = 0; t < tables.length && !table; t++) {
      var headerRow = tables[t].rows[0];
      if (!headerRow) continue;
      for (var c = 0; c < headerRow.cells.length; c++) {
        if (/package\s*name/i.test(headerRow.cells[c].textContent || '')) {
          table = tables[t];
          break;
        }
      }
    }
    if (!table) return;

    var rows = Array.prototype.slice.call(table.tBodies[0] ? table.tBodies[0].rows : table.rows);
    if (rows.length && rows[0].cells[0] && rows[0].cells[0].tagName === 'TH') rows.shift();

    var haystacks = rows.map(function (row) {
      return (row.textContent || '').toLowerCase();
    });
    // Per-row architecture list from the hidden .arch-data marker emitted by
    // am2pla-site. Rows without it (pages generated before the arch filter)
    // default to x86_64, which every listed app supports.
    var rowArchs = rows.map(function (row) {
      var el = row.querySelector('.arch-data');
      return el ? (el.getAttribute('data-arch') || 'x86_64') : 'x86_64';
    });
    var total = rows.length;

    function update() {
      var q = input.value.trim().toLowerCase();
      // Whitespace-separated terms, ANDed. Empty query matches every row.
      var terms = q.split(/\s+/).filter(Boolean);
      var arch = archSel ? archSel.value : '';
      var visible = 0;
      for (var i = 0; i < rows.length; i++) {
        var hay = haystacks[i];
        var match = terms.every(function (t) { return hay.indexOf(t) !== -1; })
          && (!arch || rowArchs[i].split(/\s+/).indexOf(arch) !== -1);
        rows[i].style.display = match ? '' : 'none';
        if (match) visible++;
      }
      counter.textContent = (q === '' && !arch)
        ? '(' + total + ' apps)'
        : '(' + visible + ' of ' + total + ' shown)';
    }

    input.addEventListener('input', update);
    if (archSel) archSel.addEventListener('change', update);

    var params = new URLSearchParams(window.location.search);
    var initialQ = params.get('q');
    if (initialQ) {
      input.value = initialQ;
      input.focus();
    }
    var initialArch = params.get('arch');
    if (initialArch && archSel) archSel.value = initialArch;
    update();
  }

  // Fetches apps.json and renders a short list of matches with links.
  function initJsonSearch() {
    var MAX_RESULTS = 20;
    var APPS_URL = 'apps.json';
    var APPS_PAGE = 'apps.html';

    var input = document.getElementById('home-search-input');
    var status = document.getElementById('home-search-status');
    var results = document.getElementById('home-search-results');
    var more = document.getElementById('home-search-more');
    var archSel = document.getElementById('home-search-arch');
    if (!input) return;

    var apps = null;
    var pending = null;

    function load() {
      if (apps || pending) return pending;
      pending = fetch(APPS_URL).then(function (r) { return r.json(); }).then(function (data) {
        apps = data;
        status.textContent = apps.length + ' apps in the database.';
        if (input.value.trim()) render(input.value.trim());
      }).catch(function () {
        status.textContent = 'Could not load the app database. Try again later.';
      });
      return pending;
    }

    function render(q) {
      results.innerHTML = '';
      more.innerHTML = '';
      if (!apps) return;
      var arch = archSel ? archSel.value : '';
      if (!q) {
        status.textContent = apps.length + ' apps in the database.';
        return;
      }
      // Whitespace-separated terms, ANDed against name + description.
      var terms = q.toLowerCase().split(/\s+/).filter(Boolean);
      var matches = [];
      for (var i = 0; i < apps.length; i++) {
        var a = apps[i];
        var hay = (a.packageName + ' ' + (a.description || '')).toLowerCase();
        var archOk = !arch || (a.arch || ['x86_64']).indexOf(arch) !== -1;
        if (archOk && terms.every(function (t) { return hay.indexOf(t) !== -1; })) matches.push(a);
      }
      if (!matches.length) {
        status.textContent = 'No apps match "' + q + '".';
        return;
      }
      status.textContent = matches.length + ' match' + (matches.length === 1 ? '' : 'es')
        + (matches.length > MAX_RESULTS ? ' (showing first ' + MAX_RESULTS + ')' : '') + ':';
      var shown = matches.slice(0, MAX_RESULTS);
      var html = '';
      for (var j = 0; j < shown.length; j++) {
        var m = shown[j];
        var safeName = escapeHtml(m.packageName);
        var safeDesc = escapeHtml((m.description || '').replace(/\.\.\.$/, ''));
        var safeIcon = escapeHtml(m.icon || '');
        html += '<li style="display: flex; align-items: center; gap: 0.6em; padding: 0.35em 0.25em; border-bottom: 1px solid #eee;">'
             +   '<img loading="lazy" src="' + safeIcon + '" alt="" width="32" height="32" style="flex: 0 0 32px;">'
             +   '<span style="flex: 1;">'
             +     '<a href="apps/' + safeName + '.html"><strong>' + safeName + '</strong></a>'
             +     '<br><span style="color: #555; font-size: 0.9em;">' + safeDesc + '</span>'
             +   '</span>'
             + '</li>';
      }
      results.innerHTML = html;
      if (matches.length > MAX_RESULTS) {
        more.innerHTML = '<a href="' + APPS_PAGE + '?q=' + encodeURIComponent(q)
          + (arch ? '&arch=' + encodeURIComponent(arch) : '')
          + '">See all ' + matches.length + ' matches on the apps page &rarr;</a>';
      }
    }

    input.addEventListener('focus', load);
    input.addEventListener('input', function () {
      if (apps) render(input.value.trim());
      else load();
    });
    if (archSel) archSel.addEventListener('change', function () {
      if (apps) render(input.value.trim());
      else load();
    });

    load();
  }

  function init() {
    initTableFilter();
    initJsonSearch();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
