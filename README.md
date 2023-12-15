# PORTABLE LINUX APPS: the KINGDOM of APPIMAGES!
#### Welcome to the most complete database of all AppImage packages and portable applications for GNU/Linux.
-------
## [*GO TO THE APPLICATION'S LIST*](https://portable-linux-apps.github.io/apps.html)
--------

##### This site lists **1839** Appimage packages and standalone applications. From here you can download them, install them, update them (for real), get more information about the sources and their developers... and if you want, you can contribute yourself by adding the missing information, because this site is **open source**!

--------

- [What are the portable linux apps?](#what-are-the-portable-linux-apps)
- [How is this site different from other sites that list AppImage packages?](#how-is-this-site-different-from-other-sites-that-list-appimage-packages)
- [Is there a centralized repository for AppImage packages?](#is-there-a-centralized-repository-for-appimage-packages)
- [How it works?](#how-it-works)
  - [AM: System integration as Super User](#am-system-integration-as-super-user)
  - [AppMan: Portable mode for non-sudo users](#appman-portable-mode-for-non-sudo-users)
- [Features of the command line clients AM and AppMan](#features-of-the-command-line-clients-am-and-appman)
  - [Manage local AppImages](#manage-local-appimages)
  - [Rollback](#rollback)
  - [Sandbox using Firejail](#sandbox-using-firejail)
  - [Snapshots: backup your app and restore to a previous version](#snapshots-backup-your-app-and-restore-to-a-previous-version)
- [Are the applications managed safe?](#are-the-applications-managed-safe)
- [I've not understand, what should I install to manage all these applications?](#ive-not-understand-what-should-i-install-to-manage-all-these-applications)
- [The app Pippo is not available in the database, how can I upload it?](#the-app-pippo-is-not-available-in-the-database-how-can-i-upload-it)
- [Troubleshoot](#troubleshoot)
  - [During an update or an installation the app is not downloaded](#during-an-update-or-an-installation-the-app-is-not-downloaded)
  - [The downloaded AppImage does not work](#the-downloaded-appimage-does-not-work)
- [Contributions to the code](#contributions-to-the-code)

--------

### What are the portable linux apps?
Portable Linux Apps are standalone applications for GNU/Linux that can (theorically) run everywhere, also on a USB stick. These applcations can be AppImage packages (see [appimage.org](https://appimage.org/)) or standalone archives (for example Firefox, Blender, Thunderbird...).

--------

### How is this site different from other sites that list AppImage packages?
The main problem with AppImage packages is that many of them couldn't be updated easily because previously there was no centralized repository that could advice users that a new version was available (unlike Snapcraft, FlatHub or the default and more common repositories you can find on your GNU/Linux distro). This gap is filled by this site, since I built one!

--------

## Is there a centralized repository for AppImage packages?
Yes, I've called it "[AM](https://github.com/ivan-hc/AM-Application-Manager)" (Application Manager). All the apps listed on this website can be installed, updated and managed through two CLI (Command Line Interfaces) I wrote in bash (being bash the "base" of our GNU/Linux systems). In fact "AM" is also the name of the main CLI I developed, the code is available at [this link](https://github.com/ivan-hc/AM-Application-Manager/blob/main/APP-MANAGER).

The [database](https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs) of "AM" does not stores packages but installation scripts, the same way the Arch User Repository (AUR) do, but each script points directly to a program ready to be downloaded (more often as AppImage packages, but also TAR/DEB archives containing directories, scripts, binary files that don't need to be compiled), and in some and really rare cases a script can build on-the-fly AppImage packages in a way similar to an AUR helper using [pkg2appimage](https://github.com/AppImageCommunity/pkg2appimage) and/or [appimagetool](https://github.com/AppImage/AppImageKit).

"AM" is also extensible to all the architectures supported by the Linux kernel (and if the app is available for that architecture). There are installation scripts for[aarch64](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/aarch64-apps) (or ARM64), [i686](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/i686-apps) (the old and obsolete 32bit systems) and obviously the more common [x86_64](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/x86_64-apps) (64bit systems). My work on "AM" is mainly focused on the x86_64 architecture being it the one I use normally and the more used in general, so many ARM64 and i686 apps may have been omitted when I wrote the scripts for them.

See "[AM Application Manager](https://github.com/ivan-hc/AM-Application-Manager)" on github for more details.

--------

## How it works?
"[AM](https://github.com/ivan-hc/AM-Application-Manager)" is a tool wrote bash, it works at system level (i.e. for all the users, using `sudo`) or in portable mode (to made it work this way, it must be renamed as "[AppMan](https://github.com/ivan-hc/AppMan)").

### AM: System integration as Super User
"AM" requires the `sudo` privileges but only to install and remove the app, all the other commands can be executed as a normal user.
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
If the distro is immutable instead, the path of the launcher (the last line above) will change like this:

     /usr/local/share/applications/AM-$PROGRAM.desktop
From version 4.3.3-1 there is also an option `--user` to enable local installation of programs in the `$HOME` directory using AppMan (jump to the [next paragraph](#appman-portable-mode-for-non-sudo-users)).

To update all the apps at once just run the following command:

    am -U

To uninstall everything just run:

    am -R $PROGRAM

**SEE IT IN ACTION!**

[video](https://github.com/ivan-hc/AM-Application-Manager/assets/88724353/b2dd8ca6-5ee7-4bb2-8480-9a53f5cfcf56)

### AppMan: Portable mode for non-sudo users
If renamed "[AppMan](https://github.com/ivan-hc/AppMan)", it allows you to choose where to install your applications into your `$HOME` directory. AppMan is also usable as a portable app (i.e. you can download and place it wherever you want) and it is able to update itself, anywhere!

At first start it will ask you where to install the apps and it will create the directory for you (the configuration file is in `~/.config/appman`). For example, suppose you want install everything in "Applicazioni" (the italian of "applications"), this is the structure of what an installation scripts installs with "AppMan" instead:

    ~/Applicazioni/$PROGRAM/
    ~/Applicazioni/$PROGRAM/$PROGRAM
    ~/Applicazioni/$PROGRAM/AM-updater
    ~/Applicazioni/$PROGRAM/remove
    ~/Applicazioni/$PROGRAM/icons/$ICON-NAME
    ~/.local/bin/$PROGRAM
    ~/.local/share/applications/AM-$PROGRAM.desktop

All AppMan does is to convert [all the installation scripts for "AM"](https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs) (that normally must be executed with `sudo`) in normal scripts that can manage applications in the local folder of the current user. This allows more users to be able to better configure their profile.

You can already dowload it from [here](https://raw.githubusercontent.com/ivan-hc/AppMan/main/appman) to give it a try without installation.

Visit the repository of "[AppMan](https://github.com/ivan-hc/AppMan)" on github for more details.

--------

### Features of the command line clients AM and AppMan
#### Manage local AppImages
Since version 4.4.2 you can use the `--launcher` option to integrate your local AppImage packages by simply dragging and dropping them into the terminal (see video).

[video](https://github.com/ivan-hc/AM-Application-Manager/assets/88724353/c4b889f4-8504-4853-8918-44d52084fe6c)

#### Rollback
From version 4.4 it is possible to directly select from a list of URLs the version of the app that interests you most from the main source. Use the `--rollback` option in this mode. This only works with the apps hosted on Github.

#### Sandbox using Firejail
Since version 5.3 you can use the `--firejail` option to run AppImages using a sandbox (requires Firejail installed on the host).

At first start a copy of /etc/firejail/default.profile will be saved in your application's directory, so you're free to launch the AppImage once using the default Firejail profile (option 1) or the custom one (2), you can also patch the .desktop files (if available) to in sandbox-mode always (options 3 and 4). You can handle the custom firejail.profile file of the app using `vim` or `nano` using the option 5 (the first selection is `vim`).

Options 1, 2 and 5 are continuous to let you edit the file and test your changes immediately. Press any key to exit.

NOTE: once patched the .desktop files (options 3 and 4), they will be placed in ~/.local/share/applications, this means that if you have installed apps using AppMan, the original launchers will be overwrited.

##### Snapshots: backup your app and restore to a previous version
Since 2.6.1 release, AM and AppMan can create snapshots of all installed applications. A selected program can be copied locally into your home folder.

- option `-b` or `backup` creates the snapshot
- option `-o` or `overwrite` allows you to roll back to a previous version of the program

All the snapshots are stored into an hidden `/home/$USER/.am-snapshots` folder containing other subfolders, each one has the name of the programs you've done a backup before. Each snapshot is named with the date and time you have done the backup. To restore the application to a previous version, copy/paste the name of the snapshot when the `-o` option will prompt it.

--------

### Are the applications managed safe?
More of them are official programs, others are third-party AppImage packages built from other people (me included), you can see the links to the sources in the application's list ([here](apps.md)) or using the `-a` option of both "AM" and AppMan. If you see an app that steals your data, contains malware or does other bad stuff with your device... please report that app in a [github issue](https://github.com/ivan-hc/AM-Application-Manager/issues) and I'll look into it.

--------

### I've not understand, what should I install to manage all these applications?
- **AppMan** to install applications only locally, at [https://github.com/ivan-hc/AppMan](https://github.com/ivan-hc/AppMan)
- **AM** to install applications system-wide as Super User (with `sudo`), at [https://github.com/ivan-hc/AM-Application-Manager](https://github.com/ivan-hc/AM-Application-Manager)

### The app Pippo is not available in the database, how can I upload it?
You should do a fork of [https://github.com/ivan-hc/AM-Application-Manager](https://github.com/ivan-hc/AM-Application-Manager), if "AM" or AppMan are installed you can use the option `-t` (or `template`) to create your own script. Just follow the instructions on your terminal, in the end a directory containing all the stuff needed to install the app will be saved on your desktop, upload all the content of this directory on your "fork" and try to merge a pull request, I'll check it and (if everything is OK) I'll approve it. "AM" is open source, like this website. I suggest to start so, in this way we can have both installable apps and web pages to spread to the masses. 

--------

# Troubleshoot
Listed here are some of the most common issues related to what is directly linked to the site, for issues related to the clients listed above, please read the reference section in the [AM](https://github.com/ivan-hc/AM-Application-Manager/blob/main/README.md#troubleshooting) and [AppMan](https://github.com/ivan-hc/AppMan/blob/main/README.md#troubleshooting) repositories.

### During an update or an installation the app is not downloaded
This happens because whoever hosted the program to download on their own site changed something on the web page, so commands within the installation scripts are no longer able to intercept the download link. Uninstall the application and report the problem at [github.com/ivan-hc/AM-Application-Manager/issues](https://github.com/ivan-hc/AM-Application-Manager/issues) and I'll try to correct it as far I can.

### The downloaded AppImage does not work
The reasons can be multiple:
- In most cases "FUSE" is needed, see the official guide at https://docs.appimage.org/user-guide/troubleshooting/fuse.html
- Run "AM" or AppMan with the option `-a` (example `am -a $PROGRAM`) and see if this is a know issue
- If the issue is related to the AppImage itself, just contact the developer from the links provided (option `-a` or `-w`)

"AM" and AppMan are only a solution to obtain these standalone packages, not a guarantee of support for those AppImages not maintained by me (the list of Appimage packages I've built and I'm responsible on is [here](https://github.com/ivan-hc#my-appimage-packages)).

-----------------------------------------

# Contributions to the code
Besides me, [Ivan-HC](https://github.com/ivan-hc), other people have participated in the improvement of this site and the clients listed above:
- "AM" Application Manager https://github.com/ivan-hc/AM-Application-Manager/graphs/contributors
- AppMan https://github.com/ivan-hc/AppMan/graphs/contributors
- Portable Linux Apps (this site) https://github.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io/graphs/contributors

I thank all of you who make my work here possible, giving it meaning!

--------

# Contacts
- Ivan-HC on [**GitHub**](https://github.com/ivan-hc)
- AM-Ivan on [**Reddit**](https://www.reddit.com/u/am-ivan)

###### *You can support me and my work on [**ko-fi.com**](https://ko-fi.com/IvanAlexHC) and [**PayPal.me**](https://paypal.me/IvanAlexHC). Thank you!*

--------

*© 2020-present Ivan Alesandro Sala aka "Ivan-HC"* - I'm here just for fun! 
