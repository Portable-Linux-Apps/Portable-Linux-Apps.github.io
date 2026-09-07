# Premise

This catalog is the frontend of the [AM](https://github.com/ivan-hc/AM) package manager. The app pages are generated from the files in the [`apps/`](apps/) folder, which are kept in sync with AM's application list every 30 minutes by a [GitHub Actions workflow](.github/workflows/sync-with-AM.yml).

The category pages and app pages are built by the [`pla-site-tool`](https://gitlab.com/kazam0180/pla-site-tool) generator and deployed with another [workflow](.github/workflows/static.yml) on every push to `main`.

**Any app that is not listed in AM will be automatically removed from this catalog!**<br>
However, you are allowed to add icons and edit the app files of existing apps, and to contribute to the website itself.

## Adding an app
  - Open an issue or a pull request at https://github.com/ivan-hc/AM
  - Once the app is in the [x86_64-apps list](https://github.com/ivan-hc/AM/blob/main/programs/x86_64-apps), the sync workflow creates a matching file in `apps/` with its description and sites
  - The site is rebuilt and the new page appears automatically

## Removing an app
  - Open an issue or a pull request at https://github.com/ivan-hc/AM
  - The sync workflow removes its file from `apps/`
  - The icon is retained in case the application is added again in the future (use the ["Remove icons" workflow](.github/workflows/remove-icons-manually.yml) to clean up orphans)

------------------------------------

# Contributing

This catalog is for everyone, so anyone can make a [pull request](https://github.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io/pulls).

## Improve an app's page

Each app's data lives in a plain text file in the `apps/` folder, named after the app (all lowercase). The format is documented in [`apps/.template`](apps/.template):

```
# some app

===
description of your app, between the `===` lines.
only use **bold**, *italic*, ++underline++, lists markdown here
- do not add links or images here
- use SOURCES field if you package someone else's app
===

# SCREENSHOTS: https://Portable-Linux-Apps.github.io/contribute_ss.webp
# SITES: https://someapp.io
# SOURCES: https://github.com/name/someapp-appimage
# BUTTONS: Label_of_Button::https://discord.gg Donation_Link::https://someapp.io/donate
```

- The `# name` line and the description between `===` come from the AM list; you can improve them.
- `SCREENSHOTS` — a space separated list of image URLs, shown in the gallery of the app page.
- `SITES` — space separated site URLs that provide the AppImage.
- `SOURCES` — if you are packaging someone else's app, link the git repo(s) here.
- `BUTTONS` — space separated button definitions in the form of `Button_Title::URL`, e.g. a donation link.

## Add icons
  - Icons must be in PNG format and have the same name as the app (for example, the app `tizio` will have the icon `icons/tizio.png`, all lowercase)
  - Icons must be 128x128 pixels or smaller
  - At the time of site deployment, they are converted to WebP (and to a 48x48 variant for the lists) for better website performance, the PNG stays the only source of truth

## Contribute to the website itself

The static pages those files are generated from can be edited freely:

  - `index.in` — home page template (hero, install carousel, categories, about, FAQ)
  - `apps.in`, `wiki.in` — apps list and wiki templates
  - `app_page.in`, `cat_page.in`, `metapkg_page.in` — templates used to generate app pages, category pages, and metapackage pages
  - `assets/css/`, `assets/js/` — styles and scripts
  - `pla-site.toml` — site configuration, including the regex patterns that assign apps to categories
  - `apps/.template` — the template shown to contributors

### Translations

The site supports multiple languages using gettext `.po` files. Translatable strings in templates are marked with `_("text")`.

**Directory structure:**
```
locales/
├── pla-site.pot          # Translation template (auto-generated)
├── apps-list.pot         # App names and list descriptions
├── descriptions.pot      # App page descriptions
├── en/
│   └── pla-site.po       # English translations (source language)
├── it/
│   └── pla-site.po       # Italian translations
└── <lang>/
    └── pla-site.po       # Other languages
```

**How to add a new language:**

1. Create the directory structure: `mkdir -p locales/<lang>`
2. Copy the template: `cp locales/pla-site.pot locales/<lang>/pla-site.po`
3. Edit the `.po` file and fill in `msgstr` for each `msgid`
4. Add the language code to `languages` in `pla-site.toml`:
   ```toml
   languages = ["en", "it", "<lang>"]
   ```
5. Build the site — output goes to `public/<lang>/`

**Translation files:**
- `locales/pla-site.pot` — auto-generated template with all translatable strings from the site templates
- `locales/apps-list.pot` — app names and list descriptions (separate from site translations)
- `locales/descriptions.pot` — app page descriptions (separate from site translations)

**Notes:**
- English (`en`) is the source language; its `.po` file has `msgstr` equal to `msgid`
- Leave `msgstr ""` empty to use the original English text
- HTML markup inside `_("...")` is preserved in translations
- Template variables like `$CAT_NAME` are not translated — they're replaced at build time
- Category names (AppImages, AI, Audio, etc.) are not translated — they're kept as-is across languages
- **Important:** Always use straight quotes (`"`) in `.po` files, never curly/Unicode quotes (`"` `"`). Curly quotes will cause translations to silently fail (the entry won't be found). This commonly happens when copying text from web pages or word processors.

**Updating translations:**

1. Regenerate the `.pot` files: `./pla-site-tool --extract-pot --pla-dir .`
2. Merge changes into each `.po` file, preserving existing translations:
   ```sh
   msgmerge --update locales/<lang>/pla-site.po locales/pla-site.pot
   ```
   This adds new untranslated entries, removes obsolete ones, and marks changed entries as fuzzy. Use `--no-fuzzy-matching` to skip fuzzy matching if you don't want it.
3. Edit the `.po` file and translate new/changed `msgstr` entries
4. Validate syntax: `msgfmt --check locales/<lang>/pla-site.po -o /dev/null`

**Removing a language:**

1. Delete the `.po` file: `rm locales/<lang>/pla-site.po`
2. Remove the language code from `languages` in `pla-site.toml`
3. The `public/<lang>/` output directory will no longer be generated

### Build locally

The [static.yml](.github/workflows/static.yml) workflow builds and deploys the site, but you can also build it locally:

```sh
# download the generator
wget -O pla-site-tool "https://github.com/kazam0180/portable-apps/releases/download/pla-site-tool-0.1.3/pla-site-tool_0.1.3-x86_64.AppImage"
chmod +x pla-site-tool

./pla-site-tool          # generates the site into public/
./gen_sitemap public https://portable-linux-apps.github.io sitemap.xml
./convert_icons public    # requires ImageMagick (sudo apt install imagemagick)
./minify public           # requires esbuild
```

Note: `public/` is the build output and is gitignored. The build generates per-language output directories (e.g., `public/en/`, `public/it/`) based on the `languages` setting in `pla-site.toml`.

### Regenerate the translation template

When you add or change translatable strings (`_("...")`) in the templates, regenerate the `.pot` files:

```sh
./pla-site-tool --extract-pot --pla-dir .
```

This scans all `.in` templates and writes:
- `locales/pla-site.pot` — site UI strings (nav, footer, FAQ, category comments, etc.)
- `locales/apps-list.pot` — app names and list descriptions
- `locales/descriptions.pot` — app page descriptions

Then merge the updated `.pot` into each language's `.po` file to pick up new/changed strings while preserving existing translations:

```sh
# For each language:
msgmerge --update locales/<lang>/pla-site.po locales/pla-site.pot
```

This will:
- Add new untranslated entries
- Mark changed entries as fuzzy
- Preserve all existing `msgstr` translations
- Remove entries no longer in the `.pot` file

After merging, edit the `.po` files to fill in translations for any new entries and review any fuzzy matches.

------------------------------------

# Conclusion

If you are able to open an issue here, it means you have a GitHub account, and therefore you can make a pull request yourself — or ask for help:

  - Check the [wiki](wiki.html) first
  - Open an issue at https://github.com/ivan-hc/AM
  - Join the [pkgforge Discord](https://discord.gg/uxvPepQUkY)

**You are strongly encouraged to actively participate in this project!**
