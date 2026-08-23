var appNodes = [];

function escapeHtml(s) {
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function renderApps(data) {
  var container = document.getElementById('app-list');
  var arch = document.getElementById('arch-select');
  var arch_value = arch.value ? arch.value : 'x86_64'
  var html = '<div class="app-list">';
  for (var i = 0; i < data.length; i++) {
    var app = data[i];
    html += '<div class="app-item" data-index="' + i + '">';
    html += '<img loading="lazy" src="icons_48/' + encodeURIComponent(app.name) + '.webp" width="48" height="48" onerror="this.src=\'no-icon_48.webp\'" alt="" class="app-icon">';
    html += '<div class="app-body">';
    html += '<a href="app/' + encodeURIComponent(app.name) + '.html" class="app-name"><strong>' + escapeHtml(app.name) + '</strong></a>';
    html += '<p class="app-desc">' + escapeHtml(app.description) + '</p>';
    html += '</div>';
    html += '<div class="app-links">';
    var suiteMatch = app.description && app.description.match(/This is part of "([^"]+)"/);
    var scriptName = suiteMatch ? suiteMatch[1] : app.name;
    html += '<a href="https://github.com/ivan-hc/AM/blob/main/programs/' + encodeURIComponent(arch_value) + '/' + encodeURIComponent(scriptName) + '" class="install-link">blob</a>';
    html += '<a href="https://raw.githubusercontent.com/ivan-hc/AM/main/programs/' + arch_value +'/' + encodeURIComponent(scriptName) + '" class="install-link">raw</a>';
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

      function applyFilters() {
        var terms = input ? input.value.toLowerCase().split(/\s+/).filter(Boolean) : [];
        var selectedArch = arch ? arch.value : '';

        for (var k = 0; k < appNodes.length; k++) {
          var matchesSearch = !terms.length ||
            terms.every(function(t) {
              return cache[k].name.indexOf(t) !== -1 ||
                     cache[k].desc.indexOf(t) !== -1;
            });
          var matchesArch = !selectedArch ||
            cache[k].archs.some(function(a) { return a === selectedArch; });
          appNodes[k].style.display = (matchesSearch && matchesArch) ? '' : 'none';
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
        arch.addEventListener('change', applyFilters);
      }

      var btt = document.getElementById('back-to-top');
      if (btt) {
        window.addEventListener('scroll', function() {
          btt.classList.toggle('btt-visible', window.scrollY > 300);
        });
      }
    })
    .catch(function(err) {
      document.getElementById('app-list').innerHTML = '<p>Failed to load apps.</p>';
    });
});
