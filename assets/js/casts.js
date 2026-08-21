document.addEventListener('DOMContentLoaded', function () {
  var mounts = document.querySelectorAll('.ascii-player');
  if (!mounts.length || typeof AsciinemaPlayer === 'undefined') return;

  mounts.forEach(function (el) {
    AsciinemaPlayer.create(el.getAttribute('data-cast'), el, {
      preload: true,
      autoplay: false,
      loop: false,
      idleTimeLimit: 1,
      theme: 'monokai',
      terminalFontFamily: 'Fira Code, monospace'
    });
  });
});