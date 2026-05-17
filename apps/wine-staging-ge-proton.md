# WINE-STAGING-GE-PROTON

 WINE - Compatibility layer to run MS Windows apps and games on GNU/Linux.
 
 "Staging" is the most recent testing wine version. This version is for both x86 and x64 MS Windows programs.
 
 Proton GE is a sister project of Proton. The latter is a Valve project based on WINE that is bringing a lot of joy to Linux gamers. Thanks to this fantastic software integrated into the Steam Play client, Windows video games can be played as if they were native. And the truth is, the list of compatible titles continues to grow and improve.
 
 Proton GE is a Proton build with the latest versions of the vanilla version of the WINE. Additionally, it has FFmpeg and FAduio enabled by default, as well as all Proton patches applied, as well as VKD3D. Therefore, Proton GE can be considered as a "vitaminized" version of the basic design.
 
 USAGE: wine-staging-ge-proton winecfg (this will launch WINE Config)
        wine-staging-ge-proton uninstaller (this will launch Install/remove)
        wine-staging-ge-proton notepad (this will launch Notepad)
        wine-staging-ge-proton <program>.exe (to launch a any Windows program)
        
 NOTE that Q4wine and other profile managers for WINE may not recognize this command, to solve this problem AM automatically creates a symbolic link to this AppImage called /opt/wine-staging-ge-proton/wine which can be used by the above profile managers.
 
 The "mmtrt" repository always provides the latest version for each of the three development branches of WINE and additional variants of WINE AppImage.
 
 SITE: https://www.winehq.org

 SOURCE: https://github.com/mmtrt/WINE_AppImage

 | [Applications](https://portable-linux-apps.github.io/apps.html) | [Home](https://portable-linux-apps.github.io)
 | --- | --- |
