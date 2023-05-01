#### Welcome to the database of all AppImage packages and portable applications for GNU/Linux.
-------
# *GO TO THE APPLICATION'S LIST*
| [**click here for more**](apps.md) |
| ----- |

--------

- [What are the portable linux apps?](#what-are-the-portable-linux-apps)
- [How is this site different from other sites that list AppImage packages?](#how-is-this-site-different-from-other-sites-that-list-appimage-packages)
- [Is there a centralized repository for AppImage packages?](#is-there-a-centralized-repository-for-appimage-packages)
- [How it works?](#how-it-works)
- [Is there a version of "AM" that does not require root privileges?](#is-there-a-version-of-am-that-does-not-require-root-privileges)
- [Are the applications managed safe?](#are-the-applications-managed-safe)
- [I've not understand, what should I install to manage all these applications?](i-ve-not-understand-what-should-i-install-to-manage-all-these-applications)
- [The app "Pippo" is not available in the database, how can I upload it?](#the-app-pippo-is-not-available-in-the-database-how-can-i-upload-it)

### What are the portable linux apps?
Portable Linux Apps are standalone applications for GNU/Linux that can (theorically) run everywhere, also on a USB stick. These applcations can be AppImage packages (see [appimage.org](https://appimage.org/)) or standalone archives (for example Firefox, Blender, Thunderbird...).

### How is this site different from other sites that list AppImage packages?
The main problem with AppImage packages is that many of them cannot be updated easily because there is no centralized repository. I built one.

### Is there a centralized repository for AppImage packages?
Yes, I've called it "AM" (Application Manager), the following lists represent all applications currently managed by the "AM" project (see "[AM Application Manager](https://github.com/ivan-hc/AM-Application-Manager)" on github), by architecture:
- [aarch64](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/aarch64-apps)
- [i686](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/i686-apps)
- [x86_64](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/x86_64-apps)

### How it works?
"[AM](https://github.com/ivan-hc/AM-Application-Manager)" is a tool wrote in bash, it downloads the desired application and creates launchers and symlinks to made them usable normally, easilly, the way you expect from a package manager like APT, PacMan or DNF, and sometime it can build on the fly appimage packages in a way similar to an AUR helper. To see all the installation scripts, visit [https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs](https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs)

### Is there a version of "AM" that does not require root privileges?
Yes, it is named "[AppMan](https://github.com/ivan-hc/AppMan)", it allows you to choose where to install your applications into your `$HOME` directory.

### Are the applications managed safe?
More of them are official programs, others are third-party AppImage packages built from other people (me included), you can see the links to the sources in the application's list ([here](apps.md)) or using the `-a` option of both "AM" and AppMan. If you see an app that steals your data, contains malware or does other bad stuff with your device... please report that app in a [github issue](https://github.com/ivan-hc/AM-Application-Manager/issues) and I'll look into it.

### I've not understand, what should I install to manage all these applications?
- AppMan (to install applications only locally), at [https://github.com/ivan-hc/AppMan](https://github.com/ivan-hc/AppMan)
- AM (to install applications as root user), at [https://github.com/ivan-hc/AM-Application-Manager](https://github.com/ivan-hc/AM-Application-Manager)

### The app "Pippo" is not available in the database, how can I upload it?
Sadly I'm the only developer of these tools and I had not much time to check all the standalone applications and the AppImages available on the web, all you can do is to clone [https://github.com/ivan-hc/AM-Application-Manager](https://github.com/ivan-hc/AM-Application-Manager), using the `-t` option (available for both AM and AppMan), upload all the files created and trying to merge a pull request, I'll check and approve it. "AM" is open source, like this website.

-----------------------------------------
