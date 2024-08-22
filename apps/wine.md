# WINE

 WINE - Compatibility layer to run MS Windows apps and games on GNU/Linux.
 
 This script allows you to download one of the many versions available from the mmtrt/WINE_AppImage repository, on Github.

 NOTE: this will create two symlinks in $PATH, "wine" and "wine64", needed to made this AppImage work with other frontends, like Bottles AppImage.
 
 As a result, symbolic links may overwrite those created by installations not managed by "AM" (in /usr/local/bin) and "AppMan" (in ~/.local/bin).
 
 The need to create this script is given by the fact that the mmtrt/WINE_AppImage's repository is constantly evolving. The AppImages provided are of high quality and reflect the needs of the most demanding users.
 
 It could happen (as happened to me, with the transition from WINE v8 to WINE v9) to request a previous version because the new one is not compatible with the system in use, and to be used as a "fallback" while the author performs other tests to fix any bugs.
 
 The other already existing scripts for this repository ("wine-stable", "wine-staging", "wine-devel" and "wine-staging-ge-proton") may be "inaccurate" if, for example, they are available two "stable" releases for two different versions, being all artifacts released as continuous builds.

 To change the release use the option "--rollback" of "AM" and "AppMan".
 
 IT IS STRONGLY RECOMMENDED TO USE THIS SCRIPT TO INSTALL WINE.
 
 USAGE: wine winecfg (this will launch WINE Config)
        wine uninstaller (this will launch Install/remove)
        wine notepad (this will launch Notepad)
        wine <program>.exe (to launch a any Windows program)

 SITE: https://github.com/mmtrt/WINE_AppImage

 | [Applications](https://portable-linux-apps.github.io/apps.html) | [Home](https://portable-linux-apps.github.io)
 | --- | --- |
