---
title: Fixing Problems with OS X Yosemite Server
published: 2015-07-06T10:51:50Z
tags: osx, yosemite, server
---

I have a hosted Mac mini with [Macminicolo][mmc] that I use for a range of
things, but predominantly as a build server for [boxes][] and other projects
(which require something like Xcode). However, there's two problems which are
slightly outside of the GUI which crop up. Here's a few notes on fixing those…

### Configure Server Manager to use a Custom SSL Certificate

If you've configured a custom SSL certificate, Server Manager will apply it to
all of the services managed by it (Websites, Mail, etc). I've tended to use a
wildcard one as it can then be reused across different places.

Unfortunately, Server Manager doesn't set the certificate for itself and so
you'll end up with a warning when connecting from a remote machine. Like this:

<figure>
  <img src="/resources/images/osx_server_certificate_failure.png"
  alt="Server.app Certificate Failure" max-width="500px">
  <figcaption>Server.app Certificate Failure</figcaption>
</figure>

This is easily fixed in the system keychain where the certificate is defined.

#### 1. Open Keychain Access

Open `Keychain Access` (in `/Applications/Utilities`) and select the System
Keychain on the right-hand side.

#### 2. Find the `com.apple.servermgrd` Identity Preference

This is the setting that defines which certificate is used for `Server.app`.

From the “Preferred Certificate” dropdown, select the correct one. It'll need
to match the domain on which you're connecting to the server on (probably it's
hostname, e.g.: `server.example.com`).

<figure>
  <img src="/resources/images/osx_server_identity_preference.png"
  alt="Keychain Identity Preference" max-width="500px">
  <figcaption>Keychain Identity Preference</figcaption>
</figure>


### Enable Open Directory Users’ Access to Screen Sharing

By default, a new user created on an Open Directory tree isn't able to use
Screen Sharing. This can be a bit of a problem if you've created a new admin
user via OD and then expect to be able to login again. There's a few posts
around explaining this, but they’re all rather old ([like this one on the Apple
Discussion boards][apple_dicussion_thread]).

After an extensive amount of digging, I cornered everything down to two
separate steps.

#### 1. Create Groups for Apple Remote Desktop

The first part comes from Apple's [Remote Desktop documentation][]
(see Chapter 5, Page 63) which details the grid of permissions it relies upon.

You'll want to create all four groups (`ard_admin`, `ard_reports`, `ard_manage`
and `ard_interact`) and then add the relevant users to them. This can be done
on the command line like so (where `username` is the relevant user):

`dseditgroup -o create -n /LDAPv3/127.0.0.1 -u diradmin -p -r 'ard_admin'
ard_admin`

`dseditgroup -o edit -n /LDAPv3/127.0.0.1 -u diradmin -p -a username -t user
ard_admin`

Repeat the above whilst replacing `ard_admin` with the other four groups.

#### 2. Enable Directory Users

The next step is to configure Apple Remote Desktop to allow directory logins.
This can also be done by installing Apple Remote Desktop (locally) and building
a custom client installer  (there's a step midway through to enable Directory
Logins). But the command line is easier:

`sudo
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart
-configure -clientopts -setdirlogins -dirlogins yes`

`sudo
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart
-restart -agent -console`

And now, you should be able to login over VNC using a directory user.

[mmc]: http://macminicolo.net
[boxes]: https://github.com/nickcharlton/boxes
[apple_discussion_thread]: https://discussions.apple.com/thread/1365257?start=0&tstart=0
[Remote Desktop documentation]: https://ssl.apple.com/remotedesktop/pdf/ARD3_AdminGuide.pdf
