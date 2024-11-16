<div align="center">

###### *Welcome to the most complete database of all AppImage packages and portable applications for GNU/Linux.*

# PORTABLE LINUX APPS

### *the first AUR-inspired AppImage Software Center!*

--------

#### *This site lists **2520** unique apps (**2112** Appimage packages and **408** standalone/portable programs), plus **79** items.*

*From here you can download them, install them, update them (for real), get more information about the sources and their developers... and if you want, you can contribute yourself by adding the missing information, because this site is **open source**!*

--------

| *[Go to the applications list](https://portable-linux-apps.github.io/apps.html)* | *[Install "AM", the package manager](https://github.com/ivan-hc/AM)* |
| - | - |
| [<img src="https://github.com/user-attachments/assets/5ae2be73-76da-4528-af23-6e8ca3500e5e" width="512" height="256">](https://portable-linux-apps.github.io/apps.html) | [<img src="https://github.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io/assets/88724353/b0cbada6-9054-46ed-84ab-35db379dbf53" width="512" height="256">](https://github.com/ivan-hc/AM) |

#### *Categories*

***[AppImages](appimages.md)*** 		 - ***[android](android.md)*** - ***[audio](audio.md)*** - ***[comic](comic.md)*** - ***[command-line](command-line.md)*** - ***[communication](communication.md)*** - ***[disk](disk.md)*** - ***[education](education.md)*** - ***[file-manager](file-manager.md)*** - ***[finance](finance.md)*** - ***[game](game.md)*** - ***[gnome](gnome.md)*** - ***[graphic](graphic.md)*** - ***[internet](internet.md)*** - ***[kde](kde.md)*** - ***[office](office.md)*** - ***[password](password.md)*** - ***[steam](steam.md)*** - ***[system-monitor](system-monitor.md)*** - ***[video](video.md)*** - ***[web-app](web-app.md)*** - ***[web-browser](web-browser.md)*** - ***[wine](wine.md)***

--------

</div>

------------------------------------------------------------------------
### Main Index
------------------------------------------------------------------------

- [What are the portable linux apps?](#what-are-the-portable-linux-apps)
- [How is this site different from other sites that list AppImage packages?](#how-is-this-site-different-from-other-sites-that-list-appimage-packages)
- [How can I improve the pages on this site?](#how-can-i-improve-the-pages-on-this-site)
- [Is there a centralized repository for AppImage packages?](#is-there-a-centralized-repository-for-appimage-packages)
- [How to install "AM"](#how-to-install-am)
  - [What is "AppMan"?](#what-is-appman)
  - [AM installation structure](#am-installation-structure)
  - [How are apps installed](#how-are-apps-installed)
  - [What programs can be installed](#what-programs-can-be-installed)
  - [How to update all programs, for real](#how-to-update-all-programs-for-real)
- [External links index (tutorials, troubleshooting, sandboxing... more)](#external-links-index)
- [Related projects](#related-projects)

--------

### What are the portable linux apps?
*Portable Linux Apps are standalone applications for GNU/Linux that can (theoretically) run everywhere, also on a USB stick. These applications can be AppImage packages (see [appimage.org](https://appimage.org/)) or standalone archives (for example Firefox, Blender, Thunderbird...).*

--------

### How is this site different from other sites that list AppImage packages?
*This catalog aims to survey and list all the AppImages and autonomous programs, and aims to provide a centralized point where you can document yourself on individual apps and where you can easily reach the URLs to the sources, both through the pages dedicated to each app and by reading the "installation scripts".*

*Yeah, each app has its own installation script, PKGBUILD style, but with an alternative package manager named "**[AM](https://github.com/ivan-hc/AM)**", which works like the more classic APT, PacMan/YAY, DNF... and which can therefore place them in specific paths of the filesystem , like any program, and allows updates via a system of scripts called "AM-updater". If an app can't update itself, the dedicated "AM-updater" script will use an application-specific method to always update your favorite apps to the latest version. FOR REAL!*

*This catalog is open source. You can edit its pages, update them and see the sources clearly, as a "wiki".*

#### About other catalogs
*While I recognize the role they have had so far in supporting the diffusion of AppImage as a packaging format, through the years, as a former user, I would like to underline what led me to open an alternative catalogue:*
- *"**[appimage.github.io](https://appimage.github.io/)**" serves more than anything else to catalog the AppImages based on validation processes based on Github Actions (i.e. that the package is compatible with old versions of Ubuntu LTS). From the developer's point of view it's fine, but **from the point of view of the user who searches for AppImage packages without going into the depths of the internet, it's totally useless**. As a catalog it is limited to showing only that an app exists or has existed in the past, without worrying about **obsolete packages that no longer exist, but still listed only "to make up the numbers"**. Many pages have no buttons to the sources and all pages have no additional information on individual apps, **each page is simply a copy/paste message** that says that the app "is available as an AppImage which means one app = one file..." etcetera etcetera.*
- *"**[appimagehub.com](https://www.appimagehub.com/)**" hosts applications not always provided by the original developer, just check the profile of whoever uploaded the application and how many "products" they uploaded. Some admit that they are not the developers, despite having a donation button available, effectively **leading them to earning on work of others**, and are often greedy enough to not include the real source! These profiles use random hosting services for these applications, and Pling's APIs does not allow you to clearly verify the origin of any package that is downloaded. There is no control over this, and the only validity check of a "product" is the feedback of the users who use it, and which in any case is **not sufficient either to guarantee the safety of an app, nor to do justice to the real owner of that package, who was in fact "robbed" of its work**.*

*Furthermore, **none of them track updates consistently**.*

*From the aforementioned defects I understood what a catalog of portable applications should NOT do to be reliable.*

--------

## How can I improve the pages on this site?
*All pages are simple Markdown files. If you have a [Github](https://github.com) profile, just click on "**Improve this page**" at the bottom of the page you are interested in:*
- *for each app you can add additional URLs (also for donations), information, screenshots, tables and annotations related to bugs, always respecting the layout (note that the same pages are what you see in the terminal using "AM"/"AppMan" through the `-a` option);*
- *icons must be 128x128 PNG files (they could be used by "AM"/"AppMan" during installation, in case an icon is not found);*
- *the application lists instead are automatically generated by the developer of this site through [this script](https://github.com/ivan-hc/AM/blob/main/tools/am2pla-site). Any changes to the lists and descriptions must be made to [this file](https://github.com/ivan-hc/AM/blob/main/programs/x86_64-apps), which is the general list of apps managed by "AM"/"AppMan". The script will create the [Applications](apps.md) page first and then it will create and update the categories.*

*For any suggestions, open an [issue](https://github.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io/issues) or a [pull request](https://github.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io/pulls) to the [repository](https://github.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io) of this site.*

--------

## Is there a centralized repository for AppImage packages?
*Depends on what you mean by "**centralized package repository**", if you mean a repository that stores them all like Debian-based distributions do with DEB packages, no, there are thousands of packages, and they are usually distributed to remote sites and difficult to find.*

*If instead you mean an AUR-style repo with scripts that easily find all AppImages, **you're in the right place!***

*This catalog and its CLI, "[**AM**](https://github.com/ivan-hc/AM)", make it easy for you to find, install, integrate and update all AppImage packages!*

<div align="center">

## *[https://github.com/ivan-hc/AM](https://github.com/ivan-hc/AM)*

| [<img src="https://raw.githubusercontent.com/ivan-hc/AM/main/sample/sandbox.gif">](https://github.com/ivan-hc/AM) | [<img src="https://raw.githubusercontent.com/ivan-hc/AM/main/sample/list.gif">](https://github.com/ivan-hc/AM) | [<img src="https://raw.githubusercontent.com/ivan-hc/AM/main/sample/about.gif">](https://github.com/ivan-hc/AM) |
| - | - | - |
| *sandbox AppImages* | *list available apps* | *info about the apps* |
| [<img src="https://raw.githubusercontent.com/ivan-hc/AM/main/sample/install.gif">](https://github.com/ivan-hc/AM) | [<img src="https://raw.githubusercontent.com/ivan-hc/AM/main/sample/query.gif">](https://github.com/ivan-hc/AM) | [<img src="https://raw.githubusercontent.com/ivan-hc/AM/main/sample/files.gif">](https://github.com/ivan-hc/AM) |
| *install applications* | *query lists using keywords* | *show the installed apps* |
| [<img src="https://raw.githubusercontent.com/ivan-hc/AM/main/sample/backup-overwrite.gif">](https://github.com/ivan-hc/AM) | [<img src="https://raw.githubusercontent.com/ivan-hc/AM/main/sample/update.gif">](https://github.com/ivan-hc/AM) | [<img src="https://raw.githubusercontent.com/ivan-hc/AM/main/sample/nolibfuse.gif">](https://github.com/ivan-hc/AM) |
| *create and restore snapshots* | *update everything* | *get rid of libfuse2* |

</div>

*This catalog is just the frontend for an ever growing database that aims to extend not only to x86_64 architecture apps listed here, but also to all others, from the modern ARM64/aarch64 to oldest i686, as an universal solution for all AppImages and portable programs for GNU/Linux!*

*All the installation scripts are stored in the repository of the "**AM**" package manager.*

------------------------------------------------------------------------

# How to install AM

*To install "AM" you must first install the "core" dependencies from your package manager:*
- *"`coreutils`" (contains "`cat`", "`chmod`", "`chown`"...);*
- *"`curl`", to check URLs;*
- *"`grep`", to check files;*
- *"`less`", to read the ever-longer lists;*
- *"`sed`", to edit/adapt installed files;*
- *"`wget`" to download all programs and update "AM" itself.*
- *"`sudo`" or "`doas`", for installing and removing programs at the system level.*

<details>
  <summary>Additionally, you may need these optional dependencies, click here.</summary>

- *"`binutils`", contains a series of basic commands, including "`ar`" which extracts .deb packages;*
- *"`unzip`", to extract .zip packages;*
- *"`tar`", to extract .tar* packages;*
- *"`torsocks`", to connect to the TOR network;*
- *"`zsync`", required by very few programs and AppImages (although it is mentioned in all installation scripts, it is often disabled because the managed .zsync files are often broken, especially for apps hosted on github.com).*

</details>


### Quick installation

*Copy/paste the following one line command to download and run the "[AM-INSTALLER](https://github.com/ivan-hc/AM/blob/main/AM-INSTALLER)" script*
```
wget -q https://raw.githubusercontent.com/ivan-hc/AM/main/AM-INSTALLER && chmod a+x ./AM-INSTALLER && ./AM-INSTALLER
```
*...below, the screenshot of what will appear.*

| ![AM-INSTALLER](https://github.com/user-attachments/assets/7bb170da-5b17-4d36-8d86-679d477debf5) |
| - |

*Type "1" to install "AM", "2" to install "[AppMan](#what-is-appman)". Any other key will abort the installation.*

**Installation is complete!**

*Run `am -h` or jump to "**[Usage](#usage)**" to see all the available options.*

------------------------------------------------------------------------

### What is AppMan?

*AppMan is a portable version of "AM", limited to installing and managing apps only locally and without root privileges.*

*The command name changes, from `am` to `appman`, but the script is the same.*

*"AM" on the contrary, provides a "fixed" installation, but can install and manage apps both locally and at the system level.*

*I recommend "AM" to privileged users who want to install and manage apps at multiple levels, and "AppMan" to non-privileged users who do not have large needs.*

------------------------------------------------------------------------

### AM installation structure

*The classic "AM" installation has the following structure:*
```
/opt/am/APP-MANAGER ==> /usr/local/bin/am
/opt/am/modules
/opt/am/remove
```
*Where the command `/usr/local/bin/am` is just a symbolic link to `/opt/am/APP-MANAGER`. The directory `/opt/am/modules` contains the modules "not vital" for "AM" but necessary for managing the apps. The script `/opt/am/remove` is instead necessary for removing "AM".*

------------------------------------------------------------------------

### How are apps installed

*The system-wide AppImage integration has the following structure:*
```
/opt/$PROGRAM/
/opt/$PROGRAM/$PROGRAM
/opt/$PROGRAM/AM-updater
/opt/$PROGRAM/remove
/opt/$PROGRAM/icons/$ICON-NAME
/usr/local/bin/$PROGRAM
/usr/local/share/applications/$PROGRAM-AM.desktop
```
*Locally installed apps can have a directory of your choice, depending on what you decided when you first started `am -i --user {PROGRAM}` or when you started `appman` (if you chose [AppMan](#what-is-appman)) or by using the `am --user` command.*

*In fact, the `--user` command can be used as a "flag" for application installation options, allowing you to integrate them locally and without root permissions, as AppMan does.*

*For example, let's say you want to create and use the `/home/USER/Applications` directory, here is the structure of a locally embedded AppImage:*
```
~/Applicazioni/$PROGRAM/
~/Applicazioni/$PROGRAM/$PROGRAM
~/Applicazioni/$PROGRAM/AM-updater
~/Applicazioni/$PROGRAM/remove
~/Applicazioni/$PROGRAM/icons/$ICON-NAME
~/.local/bin/$PROGRAM
~/.local/share/applications/$PROGRAM-AM.desktop
```

------------------------------------------------------------------------

| [Install "AM"/"AppMan"](#installation) | [Back to "Main Index"](#main-index) |
| - | - |

------------------------------------------------------------------------

# What programs can be installed

*"AM" installs, removes, updates and manages only standalone programs, ie those programs that can be run from a single directory in which they are contained.*

*1. **PORTABLE PROGRAMS** from official sources (see Firefox, Thunderbird, Blender, NodeJS, Chromium Latest, Platform Tools...), extracted from official .deb/tar/zip packages.*

*2. **APPIMAGES**, from both official and unofficial sources (I also create unofficial AppImages), or compiled on-the-fly with [pkg2appimage](https://github.com/AppImage/pkg2appimage) and [appimagetool](https://github.com/AppImage/AppImageKit), like an AUR helper, from official archives.*

*3. **FIREFOX PROFILES** to run as webapps, the ones with suffix "ffwa-" in the apps list.*

*4. **THIRD-PARTY LIBRARIES** if they are missing in your repositories.*

*The database aims to be a reference point where you can download all the AppImage packages scattered around the web, otherwise unobtainable, as you would expect from any package manager, through specific installation scripts for each application, as happens with the AUR PKGBUILDs, on Arch Linux. You can see all of them [here](https://github.com/ivan-hc/AM/tree/main/programs), divided by architecture.*

*You can view basic information, site links and sources using the related command `am -a {PROGRAM}`, or visit [**portable-linux-apps.github.io/apps**](https://portable-linux-apps.github.io/apps).*

------------------------------------------------------------------------

| [Back to "Main Index"](#main-index) |
| - |

------------------------------------------------------------------------

# How to update all programs, for real

*Most of the apps managed by "AM" have a script called `AM-updater`. It tells how updates are checked when running the `am -u` command.*

*In most cases, the "version comparison" is used between the installed one (file `version`) and an online source (official or not, depending on how hard or easy it is to find a download URL or just a number, using the terminal). In other cases, AppImages can rely on "`appimageupdatetool`" if they support "delta updates" (install it with the command `am -i appimageupdatetool`). However, there are some programs that update themselves (and among these the most famous is certainly Firefox, all official development builds).*

### How to update all installed apps

*Option `-u` or `update` updates all the installed apps and keeps "AM"/"AppMan" in sync with the latest version and all latest bug fixes.*

*1. To update only the programs, use `am -u --apps` / `appman -u --apps`*

*2. To update just one program, use `am -u $PROGRAM` / `appman -u $PROGRAM`*

*3. To update all the programs and "AM"/"AppMan" itself, just run the command`am -u` / `appman -u`*

*4. To update only "AM"/"AppMan" and the modules use the option `-s` instead, `am -s` / `appman -s`*

### How to update everything using Topgrade

*Keeping your system up to date usually involves invoking multiple package managers. This results in big, non-portable shell one-liners saved in your shell. To remedy this, Topgrade detects which tools you use and runs the appropriate commands to update them.*

*Install the "`topgrade`" package using the command*
```
am -i topgrade
```
*or*
```
am -i --user topgrade
```
*Visit [github.com/topgrade-rs/topgrade](https://github.com/topgrade-rs/topgrade) to learn more.*

------------------------------------------------------------------------

| [Back to "Main Index"](#main-index) |
| - |

------------------------------------------------------------------------
### External links index
------------------------------------------------------------------------
*All the guides listed here are available at [***github.com/ivan-hc/AM***](https://github.com/ivan-hc/AM)*

- [Install applications](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/install.md)
- [Install only AppImages](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/install-appimage.md)
- [Install AppImages not listed in this database but available in other github repos](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/extra.md)
- [List the installed applications](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/files.md)
- [List and query all the applications available on the database](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/list-and-query.md)
- [Update all](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/update.md)
- [Backup and restore installed apps using snapshots](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/backup-and-overwrite.md)
- [Remove one or more applications](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/remove.md)
- [Convert Type2 AppImages requiring libfuse2 to New Generation AppImages](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/nolibfuse.md)
- [Integrate local AppImages into the menu by dragging and dropping them](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/launcher.md)
  - [How to create a launcher for a local AppImage](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/launcher.md#how-to-create-a-launcher-for-a-local-appimage)
  - [How to remove the orphan launchers](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/launcher.md#how-to-remove-the-orphan-launchers)
  - [AppImages from external media](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/launcher.md#appimages-from-external-media)
- [Sandbox an AppImage](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/sandbox.md)
  - [How to enable a sandbox](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/sandbox.md#how-to-enable-a-sandbox)
  - [How to disable a sandbox](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/sandbox.md#how-to-disable-a-sandbox)
  - [Sandboxing example](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/sandbox.md#sandboxing-example)
  - [About Aisap sandboxing](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/sandbox.md#about-aisap-sandboxing)
- [How to update or remove apps manually](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/remove.md#how-to-update-or-remove-apps-manually)
- [Downgrade an installed app to a previous version](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/downgrade.md)
- [How to use multiple versions of the same application](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/backup-and-overwrite.md#how-to-use-multiple-versions-of-the-same-application)
- [Create and test your own installation script](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/template.md)
  - [Option Zero: "AppImages"](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/template.md#option-zero-appimages)
  - [Option One: "build AppImages on-the-fly"](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/template.md#option-one-build-appimages-on-the-fly)
  - [Option Two: "Archives and other programs"](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/template.md#option-two-archives-and-other-programs)
  - [Option Three: "Firefox profiles"](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/template.md#option-three-firefox-profiles)
  - [How an installation script works](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/template.md#how-an-installation-script-works)
  - [How to test an installation script](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/template.md#how-to-test-an-installation-script)
  - [How to submit a Pull Request](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/template.md#how-to-submit-a-pull-request)
- [Third-party databases for applications (NeoDB)](https://github.com/ivan-hc/AM/blob/main/docs/guides-and-tutorials/newrepo.md)

[Instructions for Linux Distro Maintainers](https://github.com/ivan-hc/AM#instructions-for-linux-distro-maintainers)

[Troubleshooting](https://github.com/ivan-hc/AM#troubleshooting)
- [An application does not work, is old and unsupported](https://github.com/ivan-hc/AM/blob/main/docs/troubleshooting.md#an-application-does-not-work-is-old-and-unsupported)
- [Cannot download or update an application](https://github.com/ivan-hc/AM/blob/main/docs/troubleshooting.md#cannot-download-or-update-an-application)
- [Cannot mount and run AppImages](https://github.com/ivan-hc/AM/blob/main/docs/troubleshooting.md#cannot-mount-and-run-appimages)
- [Failed to open squashfs image](https://github.com/ivan-hc/AM/blob/main/docs/troubleshooting.md#failed-to-open-squashfs-image)
- [Spyware, malware and dangerous software](https://github.com/ivan-hc/AM/blob/main/docs/troubleshooting.md#spyware-malware-and-dangerous-software)
- [Stop AppImage prompt to create its own launcher, desktop integration and doubled launchers](https://github.com/ivan-hc/AM/blob/main/docs/troubleshooting.md#stop-appimage-prompt-to-create-its-own-launcher-desktop-integration-and-doubled-launchers)
- [The script points to "releases" instead of downloading the latest stable](https://github.com/ivan-hc/AM/blob/main/docs/troubleshooting.md#the-script-points-to-releases-instead-of-downloading-the-latest-stable)
- [Ubuntu mess](https://github.com/ivan-hc/AM/blob/main/docs/troubleshooting.md#ubuntu-mess)
- [Wrong download link](https://github.com/ivan-hc/AM/blob/main/docs/troubleshooting.md#wrong-download-link)

------------------------------------------------------------------------

| [Back to "Main Index"](#main-index) |
| - |

------------------------------------------------------------------------
# Related projects
#### External tools and forks used in this project
- [aisap](https://github.com/mgord9518/aisap), sandboxing solutions for AppImages
- [appimagetool/go-appimage](https://github.com/probonopd/go-appimage), get rid of libfuse2 from your AppImages
- [pkg2appimage](https://github.com/AppImage/pkg2appimage), create AppImages on the fly from existing .deb packages
- [repology](https://github.com/repology), the encyclopedia of all software versions

#### My other projects
- [AppImaGen](https://github.com/ivan-hc/AppImaGen), easily create AppImages from Ubuntu PPAs or Debian using pkg2appimage and appimagetool;
- [ArchImage](https://github.com/ivan-hc/ArchImage), create AppImages for all distributions using Arch Linux packages. Powered by JuNest;
- [Firefox for Linux scripts](https://github.com/ivan-hc/Firefox-for-Linux-scripts), easily install the official releases of Firefox for Linux;
- [My AppImage packages](https://github.com/ivan-hc#my-appimage-packages) the complete list of packages managed by me and available in this database;
- [Snap2AppImage](https://github.com/ivan-hc/Snap2AppImage), try to convert Snap packages to AppImages.

------------------------------------------------------------------------

###### *You can support me and my work on [**ko-fi.com**](https://ko-fi.com/IvanAlexHC) and [**PayPal.me**](https://paypal.me/IvanAlexHC). Thank you!*

--------

*© 2020-present Ivan Alessandro Sala aka 'Ivan-HC'* - I'm here just for fun! 

------------------------------------------------------------------------

| [**ko-fi.com**](https://ko-fi.com/IvanAlexHC) | [**PayPal.me**](https://paypal.me/IvanAlexHC) | [Install "AM"/"AppMan"](#installation) | ["Main Index"](#main-index) |
| - | - | - | - |

------------------------------------------------------------------------

