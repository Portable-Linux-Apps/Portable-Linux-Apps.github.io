# Premise

The purpose of this catalog is closely related to the distribution of portable apps and AppImages via the AM package manager. To add an app, open an issue or a pull request at https://github.com/ivan-hc/AM

This catalog is updated every half hour and is based entirely on this list: https://github.com/ivan-hc/AM/blob/main/programs/x86_64-apps

If an app is added to this list, it means that an installation script has also been added here: https://github.com/ivan-hc/AM/tree/main/programs/x86_64

## If an app is **added** to AM
  - All lists will be automatically updated via https://github.com/ivan-hc/AM/blob/main/tools/am2pla-site
  - A new .md page will be created. It will use the description in that list and the URL specified in the installation script ("SITE" variable).
  - A new generic icon will be created using https://github.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io/blob/main/no-icon.png

## If an app is **removed** from AM
  - All references to it in the lists will be removed
  - The .md page will be removed
  - The icon will be removed

## This project is powered by github actions, so...
**...any attempt to add apps not listed in AM will be automatically overwritten!**

However, you are allowed to add the correct icons and edit the pages of existing apps.

------------------------------------

# Contributing

This catalog is for everyone, so anyone can make a [pull request](https://github.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io/pulls).

## Add icons
  - Icons must be in PNG format and have the name of the referenced app (for example, the app `tizio` will have the icon `tizio.png`, all lowercase)
  - Icons must be 128x128 or smaller

## Update app's pages
  - Write whatever you want, but leave the header (first line, the one starting with #) as is.
  - You can add buttons to the ones at the bottom, including a donation link.
  - You can add screenshots or GIFs.

------------------------------------

# Conclusion

If you are able to open an issue here, it means you have a GitHub account, and therefore you can make a pull request yourself.

**You are strongly encouraged to actively participate in this project!**
