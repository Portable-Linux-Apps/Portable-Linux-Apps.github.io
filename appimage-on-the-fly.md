# APPIMAGE ON THE FLY

| [Back to Home](index.md) | [Back to Applications](apps.md)
| --- | --- |

#### Here are listed **12** AppImages built on the fly from the official portable builds, showing how easily portable apps can be converted to AppImages to gain isolated dotfiles, sandboxing via [AM](https://github.com/ivan-hc/AM) and [AppMan](https://github.com/ivan-hc/AppMan), and reduced disk usage, serving as a proof of concept to encourage upstream developers to distribute them directly in such packaging format. Powered by **[portable2appimage](https://github.com/ivan-hc/portable2appimage)**.


<div id="app-search-box" style="margin: 1em 0;">
  <label for="app-search-input" style="font-weight: bold;">Search applications:</label>
  <input type="search" id="app-search-input" placeholder="Type a name or keyword..." autocomplete="off"
    style="width: 100%; max-width: 480px; padding: 0.5em 0.75em; margin-top: 0.25em; font-size: 1em; border: 1px solid #999; border-radius: 4px; box-sizing: border-box;">
  <select id="app-search-arch" aria-label="Filter by architecture"
    style="margin-top: 0.25em; padding: 0.5em; font-size: 1em; border: 1px solid #999; border-radius: 4px;">
    <option value="">Any architecture</option>
    <option value="x86_64">x86_64</option>
    <option value="aarch64">aarch64</option>
    <option value="i686">i686</option>
  </select>
  <span id="app-search-count" style="margin-left: 0.5em; font-style: italic; color: #666;"></span>
</div>

#### *Categories*

<div class="cat-grid">
  <a class="cat-pill" href="appimages.html">AppImages</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="ai.html">ai</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="am-utils.html">am-utils</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="android.html">android</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill cat-pill--all" href="appimage-on-the-fly.html">appimage-on-the-fly</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="audio.html">audio</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="comic.html">comic</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="command-line.html">command-line</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="communication.html">communication</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="disk.html">disk</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="education.html">education</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="emulator.html">emulator</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="file-manager.html">file-manager</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="finance.html">finance</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="game.html">game</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="gnome.html">gnome</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="graphic.html">graphic</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="internet.html">internet</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="kde.html">kde</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="metapackages.html">metapackages</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="office.html">office</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="password.html">password</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="portable.html">Portable</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="portable-cli.html">portable-cli</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="portable-desktop.html">portable-desktop</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="steam.html">steam</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="system-monitor.html">system-monitor</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="video.html">video</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="virtual-machine.html">virtual-machine</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="wallet.html">wallet</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="web-app.html">web-app</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="web-browser.html">web-browser</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="wine.html">wine</a>
  <span class="cat-sep" aria-hidden="true">•</span>
  <a class="cat-pill" href="youtube.html">youtube</a>
</div>

-----------------

***NOTE, Installer scripts (blob/raw) are provided for reading only: do not run them manually! Use "[AM](https://github.com/ivan-hc/AM)" or "[AppMan](https://github.com/ivan-hc/AppMan)" instead.***

-----------------

| ICON | PACKAGE NAME | DESCRIPTION | INSTALLER |
| --- | --- | --- | --- |
| <img loading="lazy" src="icons/antigravity.png" width="48" height="48"><span class="arch-data" data-arch="x86_64" hidden></span> | [***antigravity***](apps/antigravity.md) | *Google Antigravity IDE.*..[ *read more* ](apps/antigravity.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/antigravity) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/antigravity) |
| <img loading="lazy" src="icons/czkawka.png" width="48" height="48"><span class="arch-data" data-arch="x86_64" hidden></span> | [***czkawka***](apps/czkawka.md) | *App to find duplicates, empty folders, similar images etc.*..[ *read more* ](apps/czkawka.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/czkawka) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/czkawka) |
| <img loading="lazy" src="icons/fdm.png" width="48" height="48"><span class="arch-data" data-arch="x86_64" hidden></span> | [***fdm***](apps/fdm.md) | *Free Download Manager, multiplatform powerful modern download accelerator and organizer.*..[ *read more* ](apps/fdm.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/fdm) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/fdm) |
| <img loading="lazy" src="icons/krokiet.png" width="48" height="48"><span class="arch-data" data-arch="x86_64" hidden></span> | [***krokiet***](apps/krokiet.md) | *App to find duplicates, empty folders, similar images etc. The successor of czkawka.*..[ *read more* ](apps/krokiet.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/krokiet) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/krokiet) |
| <img loading="lazy" src="icons/ntsc-rs.png" width="48" height="48"><span class="arch-data" data-arch="x86_64" hidden></span> | [***ntsc-rs***](apps/ntsc-rs.md) | *Free, open-source VHS effect. Standalone application + plugin (After Effects, Premiere, and OpenFX).*..[ *read more* ](apps/ntsc-rs.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/ntsc-rs) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/ntsc-rs) |
| <img loading="lazy" src="icons/ollama.png" width="48" height="48"><span class="arch-data" data-arch="x86_64" hidden></span> | [***ollama***](apps/ollama.md) | *Get up and running with Llama 3, Mistral, Gemma, and other LLMs.*..[ *read more* ](apps/ollama.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/ollama) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/ollama) |
| <img loading="lazy" src="icons/syncthing.png" width="48" height="48"><span class="arch-data" data-arch="x86_64 aarch64" hidden></span> | [***syncthing***](apps/syncthing.md) | *Open Source Continuous File Synchronization.*..[ *read more* ](apps/syncthing.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/syncthing) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/syncthing) |
| <img loading="lazy" src="icons/syncthingctl.png" width="48" height="48"><span class="arch-data" data-arch="x86_64" hidden></span> | [***syncthingctl***](apps/syncthingctl.md) | *Tray control application and Dolphin/Plasma integration for Syncthing.*..[ *read more* ](apps/syncthingctl.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/syncthingctl) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/syncthingctl) |
| <img loading="lazy" src="icons/syncthingtray.png" width="48" height="48"><span class="arch-data" data-arch="x86_64" hidden></span> | [***syncthingtray***](apps/syncthingtray.md) | *Tray application and Dolphin/Plasma integration for Syncthing.*..[ *read more* ](apps/syncthingtray.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/syncthingtray) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/syncthingtray) |
| <img loading="lazy" src="icons/terabox.png" width="48" height="48"><span class="arch-data" data-arch="x86_64" hidden></span> | [***terabox***](apps/terabox.md) | *Terabox is the simplest way to send your files around the world. Back up and Share photos, videos, docs, and other files of any size to cloud storage.*..[ *read more* ](apps/terabox.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/terabox) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/terabox) |
| <img loading="lazy" src="icons/tixati.png" width="48" height="48"><span class="arch-data" data-arch="x86_64" hidden></span> | [***tixati***](apps/tixati.md) | *A New and Powerful P2P System 100% Free, Simple and Easy to Use Bittorrent Client.*..[ *read more* ](apps/tixati.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/tixati) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/tixati) |
| <img loading="lazy" src="icons/windows95.png" width="48" height="48"><span class="arch-data" data-arch="x86_64" hidden></span> | [***windows95***](apps/windows95.md) | *Unofficial. Windows 95 in Electron.*..[ *read more* ](apps/windows95.md)*!* | [*blob*](https://github.com/ivan-hc/AM/blob/main/programs/x86_64/windows95) **/** [*raw*](https://raw.githubusercontent.com/ivan-hc/AM/main/programs/x86_64/windows95) |


---

You can improve these pages via a [pull request](https://github.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io/pulls) to this site's [GitHub repository](https://github.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io), or report any problems related to the installation scripts in the '[issue](https://github.com/ivan-hc/AM/issues)' section of the main database, at [https://github.com/ivan-hc/AM](https://github.com/ivan-hc/AM).

***PORTABLE-LINUX-APPS.github.io is my gift to the Linux community and was made with love for GNU/Linux and the Open Source philosophy.***

---

| [Back to Home](index.md) | [Back to Applications](apps.md)
| --- | --- |

--------

# Contacts
- **Ivan-HC** *on* [**GitHub**](https://github.com/ivan-hc)
- **AM-Ivan** *on* [**Reddit**](https://www.reddit.com/u/am-ivan)

###### *You can support me and my work on [**ko-fi.com**](https://ko-fi.com/IvanAlexHC) and [**PayPal.me**](https://paypal.me/IvanAlexHC). Thank you!*

--------

*© 2020-present Ivan Alessandro Sala aka 'Ivan-HC'* - I'm here just for fun!


