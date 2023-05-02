#### Welcome to the database of all AppImage packages and portable applications for GNU/Linux.
-------
# [*GO TO THE APPLICATION'S LIST*](apps.md)
--------

- [What are the portable linux apps?](#what-are-the-portable-linux-apps)
- [How is this site different from other sites that list AppImage packages?](#how-is-this-site-different-from-other-sites-that-list-appimage-packages)
- [Is there a centralized repository for AppImage packages?](#is-there-a-centralized-repository-for-appimage-packages)
- [How it works?](#how-it-works)
- [Is there a version of "AM" that does not require root privileges?](#is-there-a-version-of-am-that-does-not-require-root-privileges)
- [Are the applications managed safe?](#are-the-applications-managed-safe)
- [I've not understand, what should I install to manage all these applications?](i-ve-not-understand-what-should-i-install-to-manage-all-these-applications)
- [The app "Pippo" is not available in the database, how can I upload it?](#the-app-pippo-is-not-available-in-the-database-how-can-i-upload-it)
- [What about a Gui client?](#what-about-a-gui-client)

### What are the portable linux apps?
Portable Linux Apps are standalone applications for GNU/Linux that can (theorically) run everywhere, also on a USB stick. These applcations can be AppImage packages (see [appimage.org](https://appimage.org/)) or standalone archives (for example Firefox, Blender, Thunderbird...).

### How is this site different from other sites that list AppImage packages?
The main problem with AppImage packages is that many of them cannot be updated easily because there is no centralized repository. I've built one.

### Is there a centralized repository for AppImage packages?
Yes, I've called it "AM" (Application Manager), the following lists represent all applications currently managed by the "AM" project (see "[AM Application Manager](https://github.com/ivan-hc/AM-Application-Manager)" on github), by architecture:
- [aarch64](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/aarch64-apps)
- [i686](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/i686-apps)
- [x86_64](https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/x86_64-apps)

### How it works?
"[AM](https://github.com/ivan-hc/AM-Application-Manager)" is a tool wrote in bash, it downloads the desired application and creates launchers and symlinks to made them usable normally, easilly, the way you expect from a package manager like APT, PacMan or DNF, and in some rare cases it can build on-the-fly AppImage packages in a way similar to an AUR helper. To see all the installation scripts, visit [https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs](https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs)

### Is there a version of "AM" that does not require root privileges?
Yes, it is named "[AppMan](https://github.com/ivan-hc/AppMan)", it allows you to choose where to install your applications into your `$HOME` directory.

### Are the applications managed safe?
More of them are official programs, others are third-party AppImage packages built from other people (me included), you can see the links to the sources in the application's list ([here](apps.md)) or using the `-a` option of both "AM" and AppMan. If you see an app that steals your data, contains malware or does other bad stuff with your device... please report that app in a [github issue](https://github.com/ivan-hc/AM-Application-Manager/issues) and I'll look into it.

### I've not understand, what should I install to manage all these applications?
- AppMan (to install applications only locally), at [https://github.com/ivan-hc/AppMan](https://github.com/ivan-hc/AppMan)
- AM (to install applications as root user), at [https://github.com/ivan-hc/AM-Application-Manager](https://github.com/ivan-hc/AM-Application-Manager)

### The app "Pippo" is not available in the database, how can I upload it?
You should do a fork of [https://github.com/ivan-hc/AM-Application-Manager](https://github.com/ivan-hc/AM-Application-Manager), if "AM" or AppMan are installed you can use the option `-t` (or `template`) to create your own script. Just follow the instructions on your terminal, in the end a directory containing all the stuff needed to install the app will be saved on your desktop, upload all the content of this directory on your "fork" and try to merge a pull request, I'll check it and (if everything is OK) I'll approve it. "AM" is open source, like this website. Each page of this website related to an application is a modified version of the files hosted at [https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs/.about](https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs/.about), here are edited as .md files to create these pages. I suggest to start so, in this way we can have both installable apps and web pages to spread to the masses. 

### What about a GUI client?
This would be a great idea, to do so with this website the client should have "AM" or AppMan (or a similar tool) as "engine", in this way it will be connected to the scripts available on the [database](https://github.com/ivan-hc/AM-Application-Manager/tree/main/programs). I always dreamed about something like this, but I had not much time due to my real job, I'm not a developer, I'm just an amateur playng with the BASH... and now with the Markdown too.

### So are you not a developer?
Nope. I love GNU/Linux and I use it as my daily OS since 2009. If I developed "AM" and AppMan it was only because I was fed up with so many divisive solutions, I was looking for something that works well and everywhere like a Flatpak but using less disk space in a compressed archive format like a Snap... and AppImage was perfect for that! It just needs a centralized repository to keep everything up to date and with the latest security bug fixes. So I wrote "AM" for myself first, and being a product that works well for me I want to spread it to the masses, maybe there is another user with my same needs and the same desire to change the rules. I wrote [all this](https://github.com/ivan-hc) just for fun, because Linux is fun!

-----------------------------------------
