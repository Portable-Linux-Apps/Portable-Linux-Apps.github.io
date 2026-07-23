import os

CAT_PAGE_TEMPLATE = """<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$CAT_NAME_PRETTY - PORTABLE LINUX APPS</title>
  <meta name="description" content="$CAT_NAME_PRETTY - Portable Linux Apps category page.">
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://portable-linux-apps.github.io/$CAT_NAME.html">
  <meta property="og:image" content="https://portable-linux-apps.github.io/pla.png">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="$CAT_NAME_PRETTY - PORTABLE LINUX APPS">
  <meta name="twitter:image" content="https://portable-linux-apps.github.io/pla.png">
  <meta name="twitter:description" content="$CAT_NAME_PRETTY - Portable Linux Apps category page.">
  <link rel="canonical" href="https://portable-linux-apps.github.io/$CAT_NAME.html">
  <link rel="icon" href="favicon.ico" type="image/x-icon">
  <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>

<nav aria-label="Main navigation">
  <a href="index.html">Home</a>
  <a href="apps.html">Apps</a>
  <a href="faq.html">FAQ</a>
  <a href="wiki.html">Wiki</a>
  <a href="https://github.com/ivan-hc/AM">AM on GitHub</a>
</nav>
<main>

<section>
  <h1>$CAT_NAME_PRETTY</h1>
  <p class="category-meta" id="category-meta"></p>
    <div class="search-box">
    <input type="search" id="search-input" placeholder="Filter apps by name or keyword..." autocomplete="off">
  </div>
  <div id="app-list" data-json="categories/$CAT_NAME.json"></div>
</section>

<a href="#" id="back-to-top" title="Back to top">&uarr;</a>
<script src="assets/js/script.js"></script>

</main>
<footer>
  <div class="footer-links">
    <a href="https://ko-fi.com/IvanAlexHC">ko-fi.com</a>
    <a href="https://paypal.me/IvanAlexHC">PayPal.me</a>
    <a href="https://github.com/ivan-hc/AM">AM on GitHub</a>
  </div>
  <p>&copy; 2020-present Ivan Alessandro Sala aka 'Ivan-HC' &mdash; I'm here just for fun!</p>
</footer>

</body>
</html>

"""

def pretty_name(s: str) -> str:
    toks = s.split('-')
    words = []

    for tok in toks:
        if tok == "gnome" or tok == "kde":
            words.append(tok.upper()) # uppercase gnome and kde
            continue
        if tok == "youtube":
            words.append("YouTube")
            continue
        if len(tok) == 2:
            cap = tok.upper() # uppercase two letter words
            words.append(cap)
            continue

        words.append(tok.capitalize()) # capitalize first letter of each word

    return " ".join(words)

# create html pages for each .json file in categories folder
for f in os.listdir("categories/"):
    if f.startswith("."):
        continue

    cat_name = f[:-5] # name without .json extension
    cat_pretty = pretty_name(cat_name)
    print(cat_name, cat_pretty)

    text = CAT_PAGE_TEMPLATE.replace("$CAT_NAME_PRETTY", cat_pretty).replace("$CAT_NAME", cat_name)

    with open(f"{cat_name}.html", 'w') as file:
        file.write(text)
