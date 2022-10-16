---
title: Configuring an SSH banner on Debian
tags: debian ssh
---

_**Note:** I've since come up with something much better, which dynamically generates
the content. You can see it in the post: [Debian/Ubuntu: Dynamic MOTD][post]._

Configuring a "Welcome Banner" is a great way to notify your users about the 
machine they are about to login to. I personally use this to inform the user of the 
IP, Hostname, OS version and someone to contact.

Edit the file under "/etc/motd".

Change this to something informative such as the below:

```
========================================
=         Welcome to Hitchcock         =
=  IP: 10.10.10.10                     =
=  Hostname: hitchcock.example.com     =
=  OS: Debian 5.01/Lenny               =
========================================
```
Just a short one this, but useful to know.

[post]: /posts/debian-ubuntu-dynamic-motd.html

