/**
 * Accessible Custom Dropdowns for Portable Linux Apps
 * Progressively enhances native <select> elements into modern, theme-matched custom listboxes.
 */
(function() {
  function initDropdown(select) {
    if (select.dataset.customized === 'true') return;
    select.dataset.customized = 'true';

    var isLang = !!select.closest('.lang-selector');
    var wrapper = document.createElement('div');
    wrapper.className = 'custom-dropdown' + (isLang ? ' lang-dropdown' : '');

    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'custom-dropdown-trigger';
    btn.setAttribute('aria-haspopup', 'listbox');
    btn.setAttribute('aria-expanded', 'false');

    var labelSpan = document.createElement('span');
    labelSpan.className = 'custom-dropdown-label';
    var selectedOpt = select.options[select.selectedIndex] || select.options[0];
    labelSpan.textContent = selectedOpt ? selectedOpt.text : '';
    btn.appendChild(labelSpan);

    var arrow = document.createElement('span');
    arrow.className = 'custom-dropdown-arrow';
    arrow.setAttribute('aria-hidden', 'true');
    arrow.innerHTML = '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>';
    btn.appendChild(arrow);

    var menu = document.createElement('div');
    menu.className = 'custom-dropdown-menu';
    menu.setAttribute('role', 'listbox');

    function rebuildOptions() {
      menu.innerHTML = '';
      for (var i = 0; i < select.options.length; i++) {
        var opt = select.options[i];
        var item = document.createElement('div');
        item.className = 'custom-dropdown-item' + (i === select.selectedIndex ? ' is-selected' : '');
        item.setAttribute('role', 'option');
        item.setAttribute('tabindex', '-1');
        item.setAttribute('aria-selected', i === select.selectedIndex ? 'true' : 'false');
        item.dataset.value = opt.value;

        var textSpan = document.createElement('span');
        textSpan.className = 'custom-dropdown-item-text';
        textSpan.textContent = opt.text;
        item.appendChild(textSpan);

        var check = document.createElement('span');
        check.className = 'custom-dropdown-check';
        check.setAttribute('aria-hidden', 'true');
        check.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>';
        item.appendChild(check);

        (function(index, val, text) {
          item.addEventListener('click', function(e) {
            e.stopPropagation();
            if (select.selectedIndex !== index) {
              select.selectedIndex = index;
              select.value = val;
              labelSpan.textContent = text;
              updateSelectedClass();
              select.dispatchEvent(new Event('change', { bubbles: true }));
            }
            closeMenu();
            btn.focus();
          });
        })(i, opt.value, opt.text);

        menu.appendChild(item);
      }
    }

    function updateSelectedClass() {
      var items = menu.querySelectorAll('.custom-dropdown-item');
      for (var i = 0; i < items.length; i++) {
        var isSel = (i === select.selectedIndex);
        items[i].classList.toggle('is-selected', isSel);
        items[i].setAttribute('aria-selected', isSel ? 'true' : 'false');
      }
      var opt = select.options[select.selectedIndex];
      if (opt) {
        labelSpan.textContent = opt.text;
      }
    }

    if (select.id === 'home-cat-select' && select.options.length <= 1) {
      var catLinks = document.querySelectorAll('#categories-section .category-link');
      for (var k = 0; k < catLinks.length; k++) {
        var href = catLinks[k].getAttribute('href') || '';
        var catSlug = href.replace(/\.html$/, '').replace(/^\.\//, '').replace(/^.*\//, '');
        if (catSlug && catSlug !== 'apps') {
          var opt = document.createElement('option');
          opt.value = catSlug;
          opt.textContent = catLinks[k].textContent.trim();
          select.appendChild(opt);
        }
      }
    }

    rebuildOptions();

    function openMenu() {
      // Close all other open dropdowns first
      var allOpen = document.querySelectorAll('.custom-dropdown.is-open');
      for (var i = 0; i < allOpen.length; i++) {
        if (allOpen[i] !== wrapper) {
          allOpen[i].classList.remove('is-open');
          var otherBtn = allOpen[i].querySelector('.custom-dropdown-trigger');
          if (otherBtn) otherBtn.setAttribute('aria-expanded', 'false');
        }
      }
      wrapper.classList.add('is-open');
      btn.setAttribute('aria-expanded', 'true');
    }

    function closeMenu() {
      wrapper.classList.remove('is-open');
      btn.setAttribute('aria-expanded', 'false');
    }

    btn.addEventListener('click', function(e) {
      e.stopPropagation();
      if (wrapper.classList.contains('is-open')) {
        closeMenu();
      } else {
        openMenu();
      }
    });

    btn.addEventListener('keydown', function(e) {
      if (e.key === 'ArrowDown' || e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        openMenu();
        var selectedItem = menu.querySelector('.custom-dropdown-item.is-selected') || menu.querySelector('.custom-dropdown-item');
        if (selectedItem) selectedItem.focus();
      }
    });

    menu.addEventListener('keydown', function(e) {
      var items = Array.prototype.slice.call(menu.querySelectorAll('.custom-dropdown-item'));
      var currentIndex = items.indexOf(document.activeElement);

      if (e.key === 'ArrowDown') {
        e.preventDefault();
        var nextIndex = (currentIndex + 1) % items.length;
        items[nextIndex].focus();
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        var prevIndex = (currentIndex - 1 + items.length) % items.length;
        items[prevIndex].focus();
      } else if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        if (currentIndex >= 0) {
          items[currentIndex].click();
        }
      } else if (e.key === 'Escape' || e.key === 'Tab') {
        closeMenu();
        btn.focus();
      }
    });

    // Listen to programmatic changes on original select
    select.addEventListener('change', function() {
      updateSelectedClass();
    });

    // Insert wrapper in place of select
    select.parentNode.insertBefore(wrapper, select);
    wrapper.appendChild(select);
    wrapper.appendChild(btn);
    wrapper.appendChild(menu);

    select.classList.add('visually-hidden-select');
  }

  function initAllDropdowns() {
    var targets = document.querySelectorAll('.lang-selector select, #home-arch-select, #home-cat-select, #arch-select, select.custom-select');
    for (var i = 0; i < targets.length; i++) {
      initDropdown(targets[i]);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAllDropdowns);
  } else {
    initAllDropdowns();
  }

  // Global listeners for click outside and Escape
  document.addEventListener('click', function(e) {
    if (!e.target.closest('.custom-dropdown')) {
      var allOpen = document.querySelectorAll('.custom-dropdown.is-open');
      for (var i = 0; i < allOpen.length; i++) {
        allOpen[i].classList.remove('is-open');
        var b = allOpen[i].querySelector('.custom-dropdown-trigger');
        if (b) b.setAttribute('aria-expanded', 'false');
      }
    }
  });

  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
      var allOpen = document.querySelectorAll('.custom-dropdown.is-open');
      for (var i = 0; i < allOpen.length; i++) {
        allOpen[i].classList.remove('is-open');
        var b = allOpen[i].querySelector('.custom-dropdown-trigger');
        if (b) {
          b.setAttribute('aria-expanded', 'false');
          b.focus();
        }
      }
    }
  });

  window.initCustomDropdowns = initAllDropdowns;
})();
