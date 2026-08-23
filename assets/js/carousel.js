document.addEventListener('DOMContentLoaded', function () {
  var carousel = document.getElementById('app-carousel');
  if (!carousel) return;

  var track = carousel.querySelector('.carousel-track');
  var slides = carousel.querySelectorAll('.carousel-slide');
  var prevBtn = carousel.querySelector('.carousel-prev');
  var nextBtn = carousel.querySelector('.carousel-next');
  var dotsWrap = carousel.querySelector('.carousel-dots');
  var index = 0;

  if (!track || slides.length < 2) return;

  var dots = [];
  for (var i = 0; i < slides.length; i++) {
    (function (i) {
      var dot = document.createElement('button');
      dot.type = 'button';
      dot.className = 'carousel-dot';
      dot.setAttribute('aria-label', 'Go to slide ' + (i + 1));
      dot.addEventListener('click', function () {
        goTo(i);
      });
      dotsWrap.appendChild(dot);
      dots.push(dot);
    })(i);
  }

  function goTo(n) {
    index = (n + slides.length) % slides.length;
    track.style.transform = 'translateX(-' + index * 100 + '%)';
    for (var i = 0; i < slides.length; i++) {
      slides[i].setAttribute('aria-hidden', i === index ? 'false' : 'true');
      dots[i].classList.toggle('active', i === index);
      dots[i].setAttribute('aria-current', i === index ? 'true' : 'false');
    }
  }

  prevBtn.addEventListener('click', function () { goTo(index - 1); });
  nextBtn.addEventListener('click', function () { goTo(index + 1); });

  goTo(0);
});
