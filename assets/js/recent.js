// "New apps" page: /recent.json ({name: "YYYY-MM-DD"}, newest first, see gen_recent)
// joined with /apps.json for descriptions and archs, grouped by date.

var PREVIEW = 20; // apps shown before "Show all" in days with many additions
var expanded = {};

function getUrlParam(name) {
  return new URLSearchParams(window.location.search).get(name) || '';
}

function updateFilterUrl(filters) {
  var url = new URL(window.location.href);
  Object.keys(filters).forEach(function(name) {
    if (filters[name]) {
      url.searchParams.set(name, filters[name]);
    } else {
      url.searchParams.delete(name);
    }
  });
  window.history.replaceState(window.history.state, '', url.pathname + url.search + url.hash);
}

function escapeHtml(s) {
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// Same markup as the app list of apps.html (see renderApps in script.js)
function appHtml(app, lang, arch) {
  var suiteMatch = app.description && app.description.match(/This is part of "([^"]+)"/);
  var scriptName = encodeURIComponent(suiteMatch ? suiteMatch[1] : app.name);
  var html = '<div class="app-item">';
  html += '<img loading="lazy" src="/icons_48/' + encodeURIComponent(app.name) + '.webp" width="48" height="48" alt="icon for ' + escapeHtml(app.name) + '" onerror="this.onerror=null;this.src=\'/no-icon_48.webp\'" class="app-icon">';
  html += '<div class="app-body">';
  html += '<a href="/' + lang + '/app/' + encodeURIComponent(app.name) + '.html" class="app-name"><strong>' + escapeHtml(app.name) + '</strong></a>';
  html += '<p class="app-desc">' + escapeHtml(app.description) + '</p>';
  html += '</div>';
  html += '<div class="app-links">';
  html += '<div class="app-script-links">';
  html += '<a href="https://github.com/ivan-hc/AM/blob/main/programs/' + encodeURIComponent(arch) + '/' + scriptName + '">blob</a>';
  html += '<a href="https://raw.githubusercontent.com/ivan-hc/AM/main/programs/' + encodeURIComponent(arch) + '/' + scriptName + '">raw</a>';
  html += '</div>';
  html += '<a class="app-install-btn" href="pla-install://' + encodeURIComponent(app.name) + '" title="If this does not work, see FAQ#1">Install</a>';
  html += '</div>';
  html += '</div>';
  return html;
}

document.addEventListener('DOMContentLoaded', function() {
  var container = document.getElementById('recent-list');
  var input = document.getElementById('search-input');
  var days = document.getElementById('days-select');
  var arch = document.getElementById('arch-select');
  var count = document.getElementById('results-count');
  var i18n = document.getElementById('recent-i18n').dataset;
  var lang = document.getElementById('lang').innerHTML || 'en';
  var dateFormat = new Intl.DateTimeFormat(lang.replace('_', '-'), { weekday: 'short', year: 'numeric', month: 'long', day: 'numeric' });

  document.getElementById('recent-meta').textContent = i18n.meta;
  if (getUrlParam('s')) input.value = getUrlParam('s');
  if (getUrlParam('d')) days.value = getUrlParam('d');
  if (getUrlParam('a')) arch.value = getUrlParam('a');

  function fetchJson(url) {
    return fetch(url).then(function(r) {
      if (!r.ok) throw new Error(url + ': ' + r.status);
      return r.json();
    });
  }

  Promise.all([fetchJson('/recent.json'), fetchJson('/apps.json')])
    .then(function(results) {
      var recent = results[0];
      var apps = results[1];
      var list = [];
      for (var name in recent) {
        if (recent.hasOwnProperty(name) && apps.hasOwnProperty(name)) {
          list.push({
            name: name,
            date: recent[name],
            description: apps[name].description || '',
            archs: apps[name].archs || []
          });
        }
      }

      function render() {
        var terms = input.value.trim().toLowerCase().split(/\s+/).filter(Boolean);
        var selectedArch = arch.value;
        var since = new Date(Date.now() - days.value * 86400000).toISOString().slice(0, 10);
        updateFilterUrl({ s: input.value.trim(), d: days.value === '30' ? '' : days.value, a: selectedArch });

        // Group the matching apps by date, keeping the newest-first order of recent.json
        var groups = [];
        var total = 0;
        for (var i = 0; i < list.length; i++) {
          var app = list[i];
          if (app.date < since) continue;
          if (selectedArch && app.archs.indexOf(selectedArch) === -1) continue;
          var text = (app.name + ' ' + app.description).toLowerCase();
          if (!terms.every(function(t) { return text.indexOf(t) !== -1; })) continue;
          if (!groups.length || groups[groups.length - 1].date !== app.date) groups.push({ date: app.date, apps: [] });
          groups[groups.length - 1].apps.push(app);
          total++;
        }

        var html = '';
        for (var g = 0; g < groups.length; g++) {
          var group = groups[g];
          var n = group.apps.length;
          // Large days (bulk imports) are collapsed, unless searching or expanded
          var collapsed = !terms.length && !expanded[group.date] && n > PREVIEW * 2;
          var shown = collapsed ? group.apps.slice(0, PREVIEW) : group.apps;
          html += '<div class="app-group-heading recent-heading"><span>' + escapeHtml(dateFormat.format(new Date(group.date + 'T00:00:00'))) + '</span>';
          html += '<span>' + n + ' ' + escapeHtml(n === 1 ? i18n.app : i18n.apps) + '</span></div>';
          for (var k = 0; k < shown.length; k++) {
            html += appHtml(shown[k], lang, selectedArch || 'x86_64');
          }
          if (collapsed) {
            html += '<button type="button" class="recent-show-all" data-date="' + group.date + '">' + escapeHtml(i18n.showAll) + ' (' + n + ')</button>';
          }
        }
        container.innerHTML = html || '<p class="recent-status">' + escapeHtml(i18n.empty) + '</p>';
        count.textContent = total + ' ' + (total === 1 ? i18n.app : i18n.apps);
      }

      container.addEventListener('click', function(e) {
        var button = e.target.closest('.recent-show-all');
        if (!button) return;
        expanded[button.getAttribute('data-date')] = true;
        render();
      });

      var timer;
      input.addEventListener('input', function() {
        clearTimeout(timer);
        timer = setTimeout(render, 150);
      });
      days.addEventListener('change', render);
      arch.addEventListener('change', render);
      render();
    })
    .catch(function(err) {
      console.error(err);
      container.innerHTML = '<p class="recent-status">' + escapeHtml(i18n.error) + '</p>';
    });
});
