# PORTABLE LINUX APPS
#### Welcome to the database of all AppImage packages and portable applications for GNU/Linux.
-------
## [*GO TO THE APPLICATION'S LIST*](https://portable-linux-apps.github.io/apps.html)
--------

##### This site lists **1775** Appimage packages and standalone applications. From here you can download them, install them, update them (for real), get more information about the sources and their developers... and if you want, you can contribute yourself by adding the missing information, because this site is **open source**!

--------

- [What are the portable linux apps?](#what-are-the-portable-linux-apps)
- [How is this site different from other sites that list AppImage packages?](#how-is-this-site-different-from-other-sites-that-list-appimage-packages)
- [Is there a centralized repository for AppImage packages?](#is-there-a-centralized-repository-for-appimage-packages)
- [How it works?](#how-it-works)
- [Is there a version of "AM" that does not require root privileges?](#is-there-a-version-of-am-that-does-not-require-root-privileges)
- [Are the applications managed safe?](#are-the-applications-managed-safe)
- [I've not understand, what should I install to manage all these applications?](i-ve-not-understand-what-should-i-install-to-manage-all-these-applications)
- [The app "Pippo" is not available in the database, how can I upload it?](#the-app-pippo-is-not-available-in-the-database-how-can-i-upload-it)
- [Troubleshoot](#troubleshoot)
  - [During an update or an installation the app is not downloaded](#during-an-update-or-an-installation-the-app-is-not-downloaded)
  - [The downloaded AppImage does not work](#the-downloaded-appimage-does-not-work)

### What are the portable linux apps?
Portable Linux Apps are standalone applications for GNU/Linux that can (theorically) run everywhere, also on a USB stick. These applcations can be AppImage packages (see [appimage.org](https://appimage.org/)) or standalone archives (for example Firefox, Blender, Thunderbird...).

### How is this site different from other sites that list AppImage packages?
The main problem with AppImage packages is that many of them couldn't be updated easily because previously there was no centralized repository that could advice users that a new version was available (unlike Snapcraft, FlatHub or the default and more common repositories you can find on your GNU/Linux distro). This gap is filled by this site, since I built one!

## Is there a centralized repository for AppImage packages?
Yes, I've called it "[AM](https://github.com/ivan-hc/AM-Application-Manager)" (Application Manager). All the apps listed on this website can be installed, updated and managed through two CLI (Command Line Interfaces) I wrote in bash (being bash the "base" of our GNU/Linux systems). In fact "AM" is also the name of the main CLI I developed, the code is available at [this link](https://github.com/ivan-hc/AM-Application-Manager/blob/main/APP-MANAGER)).

The [database](https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs) of "AM" does not stores packages but installation scripts, the same way the Arch User Repository (AUR) do, but each script points directly to a program ready to be downloaded (more often as AppImage packages, but also TAR/DEB archives containing directories, scripts, binary files that don't need to be compiled), and in some and really rare cases a script can build on-the-fly AppImage packages in a way similar to an AUR helper using [pkg2appimage](https://github.com/AppImageCommunity/pkg2appimage) and/or [appimagetool](https://github.com/AppImage/AppImageKit).

"AM" is also extensible to all the architectures supported by the Linux kernel (and if the app is available for that architecture). There are installation scripts for[aarch64](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/aarch64-apps) (or ARM64), [i686](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/i686-apps) (the old and obsolete 32bit systems) and obviously the more common [x86_64](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/x86_64-apps) (64bit systems). My work on "AM" is mainly focused on the x86_64 architecture being it the one I use normally and the more used in general, so many ARM64 and i686 apps may have been omitted when I wrote the scripts for them.

See "[AM Application Manager](https://github.com/ivan-hc/AM-Application-Manager)" on github for more details.

## How it works?
"[AM](https://github.com/ivan-hc/AM-Application-Manager)" is a tool wrote in bash and works at system level (i.e. for all the users). "AM" requires the `sudo` privileges but only to install and remove the app, all the other commands can be executed as a normal user.
To install a program, launch the command:

    am -i $PROGRAM

the program will be installed into a dedicated directory in `/opt` (according to the [Linux Standard Base](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s13.html)). This is what an installation script installs with "AM":

    /opt/$PROGRAM/
    /opt/$PROGRAM/$PROGRAM
    /opt/$PROGRAM/AM-updater
    /opt/$PROGRAM/remove
    /opt/$PROGRAM/icons/$ICON-NAME
    /usr/local/bin/$PROGRAM
    /usr/share/applications/AM-$PROGRAM.desktop

To update all the apps at once just run the following command:

    am -U

To uninstall everything just run:

    am -R $PROGRAM

### Is there a version of "AM" that does not require root privileges?
Yes, it is named "[AppMan](https://github.com/ivan-hc/AppMan)", it allows you to choose where to install your applications into your `$HOME` directory. AppMan is also usable as a portable app (i.e. you can download and place it wherever you want) and it is able to ubdate itself, anywhere! At first start it will ask you where to install the apps and it will create the directory for you (the configuration file is in `~/.config/appman`). For example, suppose you want install everything in "Applicazioni" (the italian of "applications"), this is the structure of what an installation scripts installs with "AppMan" instead:

    ~/Applicazioni/$PROGRAM/
    ~/Applicazioni/$PROGRAM/$PROGRAM
    ~/Applicazioni/$PROGRAM/AM-updater
    ~/Applicazioni/$PROGRAM/remove
    ~/Applicazioni/$PROGRAM/icons/$ICON-NAME
    ~/.local/bin/$PROGRAM
    ~/.local/share/applications/AM-$PROGRAM.desktop

All AppMan does is to convert [all the installation scripts for "AM"](https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs) (that normally must be executed with ROOT privileges) in normal scripts that can manage applications in the local folder of the current user. This allows more users to be able to better configure their profile.

You can already dowload it from [here](https://raw.githubusercontent.com/ivan-hc/AppMan/main/appman) to give it a try without installation.

Visit the repository of "[AppMan](https://github.com/ivan-hc/AppMan)" on github for more details.

### Are the applications managed safe?
More of them are official programs, others are third-party AppImage packages built from other people (me included), you can see the links to the sources in the application's list ([here](apps.md)) or using the `-a` option of both "AM" and AppMan. If you see an app that steals your data, contains malware or does other bad stuff with your device... please report that app in a [github issue](https://github.com/ivan-hc/AM-Application-Manager/issues) and I'll look into it.

### I've not understand, what should I install to manage all these applications?
- AppMan (to install applications only locally), at [https://github.com/ivan-hc/AppMan](https://github.com/ivan-hc/AppMan)
- AM (to install applications as root user), at [https://github.com/ivan-hc/AM-Application-Manager](https://github.com/ivan-hc/AM-Application-Manager)

### The app "Pippo" is not available in the database, how can I upload it?
You should do a fork of [https://github.com/ivan-hc/AM-Application-Manager](https://github.com/ivan-hc/AM-Application-Manager), if "AM" or AppMan are installed you can use the option `-t` (or `template`) to create your own script. Just follow the instructions on your terminal, in the end a directory containing all the stuff needed to install the app will be saved on your desktop, upload all the content of this directory on your "fork" and try to merge a pull request, I'll check it and (if everything is OK) I'll approve it. "AM" is open source, like this website. I suggest to start so, in this way we can have both installable apps and web pages to spread to the masses. 

# Troubleshoot
### During an update or an installation the app is not downloaded
This happens because whoever hosted the program to download on their own site changed something on the web page, so commands within the installation scripts are no longer able to intercept the download link. Uninstall the application and report the problem at [github.com/ivan-hc/AM-Application-Manager/issues](https://github.com/ivan-hc/AM-Application-Manager/issues) and I'll try to correct it as far I can.
### The downloaded AppImage does not work
Run "AM" or AppMan with the option `-a` (example `am -a $PROGRAM`) and see if this is a know issue. If the issue is related to the AppImage itself, just contact the developer from the link provided. "AM" is only a way to obtain these standalone packages, not a guarantee of support for those AppImages not maintained by me (the list of Appimage packages I've built and I'm responsible on is [here](https://github.com/ivan-hc#my-appimage-packages)).

-----------------------------------------
