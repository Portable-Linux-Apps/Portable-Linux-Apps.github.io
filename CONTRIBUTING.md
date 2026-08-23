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

  - `index.html` — home page (hero, install carousel, categories, about, FAQ)
  - `apps.html`, `wiki.html` — apps list and wiki
  - `app_page.in`, `cat_page.in` — templates used to generate app pages and category pages
  - `assets/css/`, `assets/js/` — styles and scripts
  - `pla-site.toml` — site configuration, including the regex patterns that assign apps to categories
  - `apps/.template` — the template shown to contributors

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

Note: `public/` is the build output and is gitignored.

------------------------------------

# Conclusion

If you are able to open an issue here, it means you have a GitHub account, and therefore you can make a pull request yourself — or ask for help:

  - Check the [wiki](wiki.html) first
  - Open an issue at https://github.com/ivan-hc/AM
  - Join the [pkgforge Discord](https://discord.gg/uxvPepQUkY)

**You are strongly encouraged to actively participate in this project!**
