(function() {
  var params = new URLSearchParams(window.location.search);
  var name = params.get('name');
  var root = document.getElementById('app-root');

  if (!name) {
    root.innerHTML = '<div class="error-box"><h2>No app specified</h2><p>Use <code>?name=appname</code> in the URL.</p></div>';
    return;
  }

  fetch('apps/' + encodeURIComponent(name) + '.json')
    .then(function(r) {
      if (!r.ok) throw new Error('Not found');
      return r.json();
    })
    .then(function(app) {
      var html = '';

      // Header with icon, name, sites
      var iconUrl = 'icons/' + encodeURIComponent(name) + '.png';
      html += '<div class="app-detail-header">';
      html += '<img src="' + iconUrl + '" alt="" onerror="this.style.display=\'none\'">';
      html += '<div>';
      html += '<h1>' + escapeHtml(app.name || name) + '</h1>';
      html += '<div class="app-meta"></div>';
      html += '</div>';
      html += '<a class="install-btn" href="pla-install://' + encodeURIComponent(app.name || name) + '" title="If this button doesn&apos;t work, see FAQ">Install</a>';
      html += '</div>';

      // Description
      html += '<div class="app-body-content">';
      if (app.description) {
        html += markdownToHtml(app.description);
      }
      html += '</div>';

      // Screenshots gallery
      if (app.screenshots && app.screenshots.length) {
        html += '<div class="gallery" id="gallery">';
        html += '<h2>Screenshots</h2>';
        html += '<div class="gallery-inner">';
        html += '<button class="gallery-btn" id="gal-prev" aria-label="Previous">&#8592;</button>';
        html += '<img id="gal-img" src="' + app.screenshots[0] + '" alt="Screenshot">';
        html += '<button class="gallery-btn" id="gal-next" aria-label="Next">&#8594;</button>';
        html += '</div>';
        html += '<div class="gallery-dots" id="gal-dots"></div>';
        html += '</div>';
      }

      // Buttons
      if (app.buttons && app.buttons.length) {
        html += '<div class="app-links-section"><h2>Links</h2><ul class="button-list">';
        for (var i = 0; i < app.buttons.length; i++) {
          var parts = app.buttons[i].split('::');
          var label = parts[0].replaceAll('_', ' ') || 'Link';
          var url = parts[1] || '#';
          html += '<li><a href="' + url + '" class="app-button" target="_blank" rel="noopener">' + label + '</a></li>';
        }
        html += '</ul></div>';
      }

      // Sites
      if (app.sites && app.sites.length) {
        html += '<div class="app-links-section"><h2>Sites</h2><ul>';
        for (var i = 0; i < app.sites.length; i++) {
          html += '<li><a href="' + app.sites[i] + '" target="_blank" rel="noopener">' + app.sites[i] + '</a></li>';
        }
        html += '</ul></div>';
      }

      // Sources
      if (app.sources && app.sources.length) {
        html += '<div class="app-links-section"><h2>Sources</h2><ul>';
        for (var i = 0; i < app.sources.length; i++) {
          html += '<li><a href="' + app.sources[i] + '" target="_blank" rel="noopener">' + app.sources[i] + '</a></li>';
        }
        html += '</ul></div>';
      }

      root.innerHTML = html;

      // Gallery carousel
      if (app.screenshots && app.screenshots.length > 1) {
        var galIdx = 0;
        var galBusy = false;
        var galImg = document.getElementById('gal-img');
        var galPrev = document.getElementById('gal-prev');
        var galNext = document.getElementById('gal-next');
        var galDots = document.getElementById('gal-dots');
        var shots = app.screenshots;

        // Preload every screenshot up front so later swaps come from
        // the browser cache instead of waiting on the network.
        for (var p = 0; p < shots.length; p++) {
          var pre = new Image();
          pre.src = shots[p];
        }

        for (var i = 0; i < shots.length; i++) {
          var dot = document.createElement('button');
          dot.className = 'gallery-dot' + (i === 0 ? ' active' : '');
          dot.setAttribute('aria-label', 'Screenshot ' + (i + 1));
          (function(idx) {
            dot.addEventListener('click', function() {
              if (idx !== galIdx) showGal(idx, idx > galIdx ? 'next' : 'prev');
            });
          })(i);
          galDots.appendChild(dot);
        }

        function updateControls(idx) {
          galPrev.disabled = idx === 0;
          galNext.disabled = idx === shots.length - 1;
          var dots = galDots.children;
          for (var j = 0; j < dots.length; j++) {
            dots[j].className = 'gallery-dot' + (j === idx ? ' active' : '');
          }
        }

        function showGal(idx, dir) {
          if (galBusy || idx === galIdx) return;
          galBusy = true;
          galIdx = idx;
          updateControls(idx);

          // Fade/slide the current image out first...
          galImg.classList.add('gal-transition', dir === 'prev' ? 'gal-prev' : 'gal-next');

          setTimeout(function() {
            galImg.src = shots[idx];

            function reveal() {
              // Force a reflow so removing the class re-triggers the transition.
              void galImg.offsetWidth;
              galImg.classList.remove('gal-transition', 'gal-prev', 'gal-next');
              galBusy = false;
            }

            // Thanks to preloading this is almost always already cached,
            // so it resolves on the very next frame rather than stalling.
            if (galImg.complete) {
              requestAnimationFrame(reveal);
            } else {
              galImg.onload = reveal;
            }
          }, 160);
        }

        galPrev.addEventListener('click', function() {
          if (galIdx > 0) showGal(galIdx - 1, 'prev');
        });
        galNext.addEventListener('click', function() {
          if (galIdx < shots.length - 1) showGal(galIdx + 1, 'next');
        });
        document.addEventListener('keydown', function(e) {
          if (e.key === 'ArrowLeft' && galIdx > 0) showGal(galIdx - 1, 'prev');
          if (e.key === 'ArrowRight' && galIdx < shots.length - 1) showGal(galIdx + 1, 'next');
        });
      } else if (app.screenshots && app.screenshots.length === 1) {
        var p = document.getElementById('gal-prev');
        var n = document.getElementById('gal-next');
        if (p) p.style.display = 'none';
        if (n) n.style.display = 'none';
      }

      // Update page title
      document.title = (app.name || name).toUpperCase() + ' - PORTABLE LINUX APPS';
    })
    .catch(function(err) {
      root.innerHTML = '<div class="error-box"><h2>App not found</h2><p>Could not load data for <strong>' + escapeHtml(name) + '</strong>.</p></div>';
    });

  function escapeHtml(s) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(s));
    return div.innerHTML;
  }

  // Minimal markdown -> HTML for descriptions.
  // Supports only: **bold**, *italic*, ++underline++, and - / * / 1. lists.
  // Everything else is treated as plain text (and HTML-escaped first,
  // so no other tags can sneak in through the JSON data).
  function inlineMarkdown(s) {
    s = s.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
    s = s.replace(/__(.+?)__/g, '<strong>$1</strong>');
    s = s.replace(/\+\+(.+?)\+\+/g, '<u>$1</u>');
    s = s.replace(/\*(.+?)\*/g, '<em>$1</em>');
    s = s.replace(/_(.+?)_/g, '<em>$1</em>');
    return s;
  }

  function markdownToHtml(text) {
    var lines = escapeHtml(text).split('\n');
    var blocks = [];
    var i = 0;

    while (i < lines.length) {
      var line = lines[i];
      var trimmed = line.trim();

      // Skip completely empty lines – they should not produce <br>
      if (trimmed === '') {
        i++;
        continue;
      }

      var ulRe = /^[-*]\s+(.*)$/;
      var olRe = /^\d+\.\s+(.*)$/;
      var ulMatch = line.match(ulRe);
      var olMatch = !ulMatch && line.match(olRe);

      if (ulMatch || olMatch) {
        var tag = ulMatch ? 'ul' : 'ol';
        var re = ulMatch ? ulRe : olRe;
        var items = [];

        // Collect all consecutive list items, skipping blank lines
        while (i < lines.length) {
          var currentLine = lines[i];
          var trimmedCurrent = currentLine.trim();

          // Skip blank lines inside the list – they do not break it
          if (trimmedCurrent === '') {
            i++;
            continue;
          }

          var m = currentLine.match(re);
          if (!m) break; // non-list, non-empty line ends the list

          items.push('<li>' + inlineMarkdown(m[1]) + '</li>');
          i++;
        }

        if (items.length) {
          blocks.push('<' + tag + '>' + items.join('') + '</' + tag + '>');
        }
        // i is now positioned at the line that broke the list (or at end)
      } else {
        // Normal text block
        blocks.push(inlineMarkdown(line));
        i++;
      }
    }

    return blocks.join('<br>');
  }
})();

var btt = document.getElementById('back-to-top');
window.addEventListener('scroll', function() {
  btt.classList.toggle('btt-visible', window.scrollY > 300);
});
