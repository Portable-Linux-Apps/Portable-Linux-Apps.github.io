# Portable-Linux-Apps.github.io

Database of all AppImage packages and other portable applications for GNU/Linux.



## How to add a your app to this store

To add your app you need to create an file that describes it.
That file should have the name `[app id].yml` and be located in the `apps` folder.

the app id is the app reversed, for example:
'firefox' is going to be 'xoferif' 

You can copy and fill out `example/app.template.yml`,
look at the other apps to see how the format works.

For storing/serving your opensource app we recommend github or gitlab releases.


## Abuse

If you see an app that
- steals your data
- contains malware
- or does other bad stuff with your device...

Please report that app in a github issue and we'll look into it.

## Clients

### AppMan (to install applications only locally)
- https://github.com/ivan-hc/AppMan

### AM (to install applications as root user)
- https://github.com/ivan-hc/AM-Application-Manager
