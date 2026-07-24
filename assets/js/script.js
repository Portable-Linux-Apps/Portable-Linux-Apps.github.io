var appNodes = [];

function escapeHtml(s) {
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function renderApps(data) {
  var container = document.getElementById('app-list');
  var html = '<div class="app-list">';
  for (var i = 0; i < data.length; i++) {
    var app = data[i];
    html += '<div class="app-item" data-index="' + i + '">';
    html += '<img loading="lazy" src="icons/' + encodeURIComponent(app.name) + '.png" width="48" height="48" alt="" class="app-icon">';
    html += '<div class="app-body">';
    html += '<a href="app.html?name=' + encodeURIComponent(app.name) + '" class="app-name"><strong>' + escapeHtml(app.name) + '</strong></a>';
    html += '<p class="app-desc">' + escapeHtml(app.description) + '</p>';
    html += '</div>';
    html += '<div class="app-links">';
    html += '<a href="https://github.com/ivan-hc/AM/blob/main/programs/x86_64/' + encodeURIComponent(app.name) + '" class="install-link">blob</a>';
    html += '<a href="https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/' + encodeURIComponent(app.name) + '" class="install-link">raw</a>';
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
      var meta = document.getElementById('category-meta');
      if (meta) meta.textContent = 'Here are listed ' + data.length + ' apps for this category.';

      var cache = [];
      for (var i = 0; i < data.length; i++) {
        cache.push({
          name: data[i].name.toLowerCase(),
          desc: data[i].description ? data[i].description.toLowerCase() : ''
        });
      }

      renderApps(data);

      var input = document.getElementById('search-input');
      if (input) {
        var timer;
        input.addEventListener('input', function() {
          clearTimeout(timer);
          var self = this;
          timer = setTimeout(function() {
            var terms = self.value.toLowerCase().split(/\s+/).filter(Boolean);
            for (var k = 0; k < appNodes.length; k++) {
              var show = !terms.length || terms.every(function(t) { return cache[k].name.indexOf(t) !== -1 || cache[k].desc.indexOf(t) !== -1; });
              appNodes[k].style.display = show ? '' : 'none';
            }
          }, 150);
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
      document.getElementById('app-list').innerHTML = '<p>Failed to load apps.</p>';
    });
});
