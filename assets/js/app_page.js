(function() {
  var galImg = document.getElementById('gal-img');
  var galPrev = document.getElementById('gal-prev');
  var galNext = document.getElementById('gal-next');
  var galDots = document.getElementById('gal-dots');

  // The page is pre-rendered: the generator emits the gallery markup, so a
  // missing gallery here just means the app has no screenshots.
  if (!galImg || !galDots) return;

  var dots = galDots.querySelectorAll('.gallery-dot');

  if (dots.length < 2) {
    if (galPrev) galPrev.style.display = 'none';
    if (galNext) galNext.style.display = 'none';
    return;
  }

  if (!galPrev || !galNext) return;

  var galIdx = 0;
  var galBusy = false;

  // The first screenshot is already the <img> src, so preload from the
  // second onwards to make later swaps come from the browser cache instead
  // of waiting on the network.
  for (var p = 1; p < dots.length; p++) {
    var pre = new Image();
    pre.src = dots[p].dataset.src;
  }

  function updateControls(idx) {
    galPrev.disabled = idx === 0;
    galNext.disabled = idx === dots.length - 1;
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
      galImg.src = dots[idx].dataset.src;
      galImg.alt = dots[idx].dataset.alt;

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

  for (var i = 0; i < dots.length; i++) {
    (function(idx) {
      dots[idx].addEventListener('click', function() {
        if (idx !== galIdx) showGal(idx, idx > galIdx ? 'next' : 'prev');
      });
    })(i);
  }

  galPrev.addEventListener('click', function() {
    if (galIdx > 0) showGal(galIdx - 1, 'prev');
  });
  galNext.addEventListener('click', function() {
    if (galIdx < dots.length - 1) showGal(galIdx + 1, 'next');
  });
  document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowLeft' && galIdx > 0) showGal(galIdx - 1, 'prev');
    if (e.key === 'ArrowRight' && galIdx < dots.length - 1) showGal(galIdx + 1, 'next');
  });
})();

var btt = document.getElementById('back-to-top');
if (btt) {
  window.addEventListener('scroll', function() {
    btt.classList.toggle('btt-visible', window.scrollY > 300);
  });
}
