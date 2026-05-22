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
    if (!input) return;

    var table = input.closest('div').nextElementSibling;
    while (table && table.tagName !== 'TABLE') table = table.nextElementSibling;
    if (!table) return;

    var rows = Array.prototype.slice.call(table.tBodies[0] ? table.tBodies[0].rows : table.rows);
    if (rows.length && rows[0].cells[0] && rows[0].cells[0].tagName === 'TH') rows.shift();

    var haystacks = rows.map(function (row) {
      return (row.textContent || '').toLowerCase();
    });
    var total = rows.length;

    function update() {
      var q = input.value.trim().toLowerCase();
      var visible = 0;
      for (var i = 0; i < rows.length; i++) {
        var match = q === '' || haystacks[i].indexOf(q) !== -1;
        rows[i].style.display = match ? '' : 'none';
        if (match) visible++;
      }
      counter.textContent = q === ''
        ? '(' + total + ' apps)'
        : '(' + visible + ' of ' + total + ' shown)';
    }

    input.addEventListener('input', update);

    var params = new URLSearchParams(window.location.search);
    var initialQ = params.get('q');
    if (initialQ) {
      input.value = initialQ;
      input.focus();
    }
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
      if (!q) {
        status.textContent = apps.length + ' apps in the database.';
        return;
      }
      var needle = q.toLowerCase();
      var matches = [];
      for (var i = 0; i < apps.length; i++) {
        var a = apps[i];
        var hay = (a.packageName + ' ' + (a.description || '')).toLowerCase();
        if (hay.indexOf(needle) !== -1) matches.push(a);
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
        more.innerHTML = '<a href="' + APPS_PAGE + '?q=' + encodeURIComponent(q) + '">See all '
          + matches.length + ' matches on the apps page &rarr;</a>';
      }
    }

    input.addEventListener('focus', load);
    input.addEventListener('input', function () {
      if (apps) render(input.value.trim());
      else load();
    });
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
