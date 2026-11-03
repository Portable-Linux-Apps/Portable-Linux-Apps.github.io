// UI strings come from the translated page itself: the templates render
// <span data-key="..."> elements inside #i18n via gettext (_("...")).
function tr(key, arg) {
  var el = document.querySelector('#i18n [data-key="' + key + '"]');
  var text = el ? el.textContent : key;
  return arg === undefined ? text : text.replace('{0}', arg);
}
