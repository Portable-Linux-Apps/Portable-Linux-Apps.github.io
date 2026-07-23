var allApps = [];

function renderApps(list) {
  var html = '<div class="app-list">';
  for (var i = 0; i < list.length; i++) {
    var app = list[i];
    html += '<div class="app-item">';
    html += '<img loading="lazy" src="icons/' + app.name + '.png" width="48" height="48" alt="" class="app-icon">';
    html += '<div class="app-body">';
    html += '<a href="app.html?name=' + encodeURIComponent(app.name) + '" class="app-name"><strong>' + app.name + '</strong></a>';
    html += '<p class="app-desc">' + app.description + '</p>';
    html += '</div>';
    html += '<div class="app-links">';
    html += '<a href="https://github.com/ivan-hc/AM/blob/main/programs/x86_64/' + app.name + '" class="install-link">blob</a>';
    html += '<a href="https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/' + app.name + '" class="install-link">raw</a>';
    html += '</div>';
    html += '</div>';
  }
  html += '</div>';
  document.getElementById('app-list').innerHTML = html;
}

document.addEventListener('DOMContentLoaded', function() {
  var el = document.getElementById('app-list');
  if (!el) return;
  var jsonUrl = el.getAttribute('data-json');
  if (!jsonUrl) return;

  fetch(jsonUrl)
    .then(function(r) { return r.json() })
    .then(function(data) {
      allApps = data;
      var meta = document.getElementById('category-meta');
      if (meta) meta.textContent = 'Here are listed ' + data.length + ' apps for this category.';
      renderApps(data);
    })
    .catch(function(err) {
      document.getElementById('app-list').innerHTML = '<p>Failed to load apps.</p>';
    });

  var input = document.getElementById('search-input');
  if (input) {
    input.addEventListener('input', function() {
      var q = this.value.toLowerCase();
      if (!q) { renderApps(allApps); return; }
      renderApps(allApps.filter(function(a) {
        return a.name.toLowerCase().indexOf(q) !== -1 ||
               (a.description && a.description.toLowerCase().indexOf(q) !== -1);
      }));
    });
  }

  var btt = document.getElementById('back-to-top');
  if (btt) {
    window.addEventListener('scroll', function() {
      btt.classList.toggle('btt-visible', window.scrollY > 300);
    });
  }
});
