# JUNEST

 JuNest (Jailed User Nest) is a lightweight Arch Linux based distribution that allows the creation of disposable and partially isolated GNU/Linux environments within any generic GNU/Linux host OS and without requiring root privileges to install packages.
 
 JuNest is built around pacman, the Arch Linux package manager, which allows access to a wide range of packages from the Arch Linux repositories.
 
 The main advantages of using JuNest include:

 - Install packages without root privileges.
 - Create partially isolated environments in which you can install packages without risking mishaps on production systems.
 - Access a wider range of packages, particularly on GNU/Linux distros with comparatively limited repositories (such as CentOS and Red Hat).
 - Run on a different architecture from the host OS via QEMU.
 - Available for x86_64 and arm architectures but you can build your own image from scratch too!
 - All Arch Linux lovers can enjoy their favourite distro everywhere!
 
 NOTE: by installing "Junest" using "AM" you're installing it the same way of
 the official PKGBUILD "junest-git", available on the Arch User Repository (AUR) so if you want to use the wrappers to run commands installed in JuNest directly from host, you only need to add this line in your ~/.bashrc:
 
 `export PATH="$PATH:~/.junest/usr/bin_wrappers"`
 
 No other steps are needed. The installation script already creates the links
 for "junest" and "sudoj" in `/usr/local/bin` (or `~/.local/bin` if you install
 Junest with AppMan).
 
 For more info go to the main page of the repository of Junest, on GitHub.
 
 SITE & SOURCE: https://github.com/fsquillace/junest

 | [Applications](https://portable-linux-apps.github.io/apps.html) | [Home](https://portable-linux-apps.github.io)
 | --- | --- |
