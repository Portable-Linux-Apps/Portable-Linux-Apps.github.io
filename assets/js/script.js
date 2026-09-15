var appNodes = [];

function escapeHtml(s) {
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function renderApps(data) {
  var container = document.getElementById('app-list');
  var arch = document.getElementById('arch-select');
  var lang = document.getElementById('lang');
  var lang_value = lang.innerHTML || 'en';
  var arch_value = arch.value ? arch.value : 'x86_64'
  var html = '<div class="app-list">';
  for (var i = 0; i < data.length; i++) {
    var app = data[i];
    html += '<div class="app-item" data-index="' + i + '">';
    html += '<img loading="lazy" src="/icons_48/' + encodeURIComponent(app.name) + '.webp" width="48" height="48" alt="icon for ' + escapeHtml(app.name) + '" onerror="this.onerror=null;this.src=\'/no-icon_48.webp\'" class="app-icon">';
    html += '<div class="app-body">';
    html += '<a href="/' + lang_value + '/app/' + encodeURIComponent(app.name) + '.html" class="app-name"><strong>' + escapeHtml(app.name) + '</strong></a>';
    html += '<p class="app-desc">' + escapeHtml(app.description) + '</p>';
    html += '</div>';
    html += '<div class="app-links">';
    var suiteMatch = app.description && app.description.match(/This is part of "([^"]+)"/);
    var scriptName = suiteMatch ? suiteMatch[1] : app.name;
    html += '<a href="https://github.com/ivan-hc/AM/blob/main/programs/' + encodeURIComponent(arch_value) + '/' + encodeURIComponent(scriptName) + '" class="install-link install-blob" data-script="' + encodeURIComponent(scriptName) + '">blob</a>';
    html += '<a href="https://raw.githubusercontent.com/ivan-hc/AM/main/programs/' + encodeURIComponent(arch_value) +'/' + encodeURIComponent(scriptName) + '" class="install-link install-raw" data-script="' + encodeURIComponent(scriptName) + '">raw</a>';
    html += '</div>';
    html += '</div>';
  }
  html += '</div>';
  container.innerHTML = html;

  appNodes = [];
  var items = container.querySelectorAll('.app-item');
  for (var j = 0; j < items.length; j++) {
    appNodes.push(items[j]);
  }
}

document.addEventListener('DOMContentLoaded', function() {
  var el = document.getElementById('app-list');
  if (!el) return;
  var jsonUrl = el.getAttribute('data-json');
  if (!jsonUrl) return;

  fetch(jsonUrl)
    .then(function(r) { return r.json() })
    .then(function(data) {
      // Convert object {name: {...}, ...} to array [{name, ...}, ...]
      var dataArray = [];
      for (var key in data) {
        if (data.hasOwnProperty(key)) {
          dataArray.push({ name: key, description: data[key].description, archs: data[key].archs || [] });
        }
      }

      var cache = [];
      for (var i = 0; i < dataArray.length; i++) {
        cache.push({
          name: dataArray[i].name.toLowerCase(),
          desc: dataArray[i].description ? dataArray[i].description.toLowerCase() : '',
          archs: dataArray[i].archs || []
        });
      }

      renderApps(dataArray);

      var input = document.getElementById('search-input');
      var arch = document.getElementById('arch-select');

      // Parse ?s=term and ?a=arch from URL and initialize search/arch
      function getUrlParam(name) {
        var params = new URLSearchParams(window.location.search);
        return params.get(name) || '';
      }
      var searchParam = getUrlParam('s');
      var archParam = getUrlParam('a');
      if (input && searchParam) {
        input.value = searchParam;
      }
      if (arch && archParam) {
        arch.value = archParam;
      }
      // Trigger filter immediately for initial URL-based search/arch
      if ((input && searchParam) || (arch && archParam)) {
        setTimeout(applyFilters, 0);
      }

      function updateArchLinks(selectedArch) {
        var a = selectedArch || 'x86_64';
        var blobs = document.querySelectorAll('.install-blob');
        var raws = document.querySelectorAll('.install-raw');
        for (var m = 0; m < blobs.length; m++) {
          blobs[m].href = 'https://github.com/ivan-hc/AM/blob/main/programs/' + encodeURIComponent(a) + '/' + blobs[m].getAttribute('data-script');
        }
        for (var n = 0; n < raws.length; n++) {
          raws[n].href = 'https://raw.githubusercontent.com/ivan-hc/AM/main/programs/' + encodeURIComponent(a) + '/' + raws[n].getAttribute('data-script');
        }
      }

      // Relevance rank: 0 exact name, 1 name starts with, 2 name contains, 3 description only.
      var RANK_LABELS = ['Exact match', 'Name match', 'Name match', 'Description match'];

      function matchRank(k, terms) {
        var name = cache[k].name;
        if (terms.length === 1 && name === terms[0]) return 0;
        var nameHit = terms.every(function(t) { return name.indexOf(t) !== -1; });
        if (!nameHit) return 3;
        return name.indexOf(terms[0]) === 0 ? 1 : 2;
      }

      function applyFilters() {
        var terms = input ? input.value.toLowerCase().split(/\s+/).filter(Boolean) : [];
        var selectedArch = arch ? arch.value : '';
        var container = document.getElementById('app-list');
        var list = container ? container.querySelector('.app-list') : null;
        if (!list) return;
        var matched = [];

        var oldHeadings = list.querySelectorAll('.app-group-heading');
        for (var h = 0; h < oldHeadings.length; h++) oldHeadings[h].remove();
        var oldEmpty = container.querySelector('.search-empty-state');
        if (oldEmpty) oldEmpty.remove();

        for (var k = 0; k < appNodes.length; k++) {
          var matchesSearch = !terms.length ||
            terms.every(function(t) {
              return cache[k].name.indexOf(t) !== -1 ||
                     cache[k].desc.indexOf(t) !== -1;
            });
          var matchesArch = !selectedArch ||
            cache[k].archs.some(function(a) { return a === selectedArch; });
          var visible = matchesSearch && matchesArch;
          appNodes[k].style.display = visible ? '' : 'none';
          if (visible) matched.push({ index: k, rank: terms.length ? matchRank(k, terms) : 0 });
        }

        var countEl = document.getElementById('results-count');

        if (matched.length === 0) {
          if (countEl) countEl.textContent = '';
          list.style.display = 'none';

          var emptyDiv = document.createElement('div');
          emptyDiv.className = 'search-empty-state';
          var rawTerm = input ? input.value.trim() : '';
          var message = rawTerm ? 'No applications found matching "' + escapeHtml(rawTerm) + '"' : 'No applications found';
          var subMessage = selectedArch ? 'Try selecting "All architectures" or broadening your search keywords.' : 'Check for typos or try searching with different keywords.';
          emptyDiv.innerHTML =
            '<div class="search-empty-icon">' +
              '<svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">' +
                '<circle cx="11" cy="11" r="8"></circle>' +
                '<line x1="21" y1="21" x2="16.65" y2="16.65"></line>' +
                '<line x1="8" y1="11" x2="14" y2="11"></line>' +
              '</svg>' +
            '</div>' +
            '<h3>' + message + '</h3>' +
            '<p class="search-empty-hint">' + subMessage + '</p>' +
            '<button type="button" class="search-empty-reset">Clear search</button>';

          emptyDiv.querySelector('.search-empty-reset').addEventListener('click', function() {
            if (input) input.value = '';
            if (arch) arch.value = '';
            updateArchLinks('');
            applyFilters();
            if (input) input.focus();
          });

          container.appendChild(emptyDiv);
          return;
        }

        list.style.display = '';
        if (countEl) countEl.textContent = matched.length + ' results';

        if (terms.length) {
          matched.sort(function(a, b) {
            return a.rank !== b.rank ? a.rank - b.rank : cache[a.index].name.localeCompare(cache[b.index].name);
          });
        }

        var lastLabel = null;
        for (var m = 0; m < matched.length; m++) {
          var entry = matched[m];
          if (terms.length) {
            var label = RANK_LABELS[entry.rank];
            if (label !== lastLabel) {
              var heading = document.createElement('div');
              heading.className = 'app-group-heading';
              heading.textContent = label;
              list.appendChild(heading);
              lastLabel = label;
            }
          }
          list.appendChild(appNodes[entry.index]);
        }
      }

      if (input) {
        var timer;
        input.addEventListener('input', function() {
          clearTimeout(timer);
          timer = setTimeout(applyFilters, 150);
        });
      }

      if (arch) {
        arch.addEventListener('change', function() {
          updateArchLinks(arch.value);
          applyFilters();
        });
      }

      var btt = document.getElementById('back-to-top');
      if (btt) {
        window.addEventListener('scroll', function() {
          btt.classList.toggle('btt-visible', window.scrollY > 300);
        });
      }
    })
    .catch(function(err) {
      document.getElementById('app-list').innerHTML = '<p>Failed to load apps.</p>' + err;
    });
});
