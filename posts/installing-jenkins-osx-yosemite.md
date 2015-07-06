---
title: Installing Jenkins on OS X Yosemite
published: 2015-07-07T11:00:00Z
tags: osx, server, jenkins, ci
---

[Jenkins][] is a [continuous integration][] (CI) server written in Java. It's
a pretty common solution for self-hosted CI servers.

A lot of the documentation for installing on OS X is a little old (OS X has
changed a lot when it comes to say, Java, in the last few years) and it seemed
a good plan to write up something a bit newer.

I host a Jenkins instance on a hosted Mac mini with [Macminicolo][]. In
addition to Yosemite, it's also got the [OS X Server][] package installed,
Open Directory (which is Apple's name for [LDAP][]) configured and a few other
tools. It's typically used for [boxes][] builds.

I'm assuming you'll be installing Jenkins via [Homebrew][] as the Jenkins
installer does some odd things around how the user is handled. I'm also
assuming you’re connected via VNC/Screen Sharing, as often it requires a GUI.

### 1. Install Java

You likely don't have Java installed yet, so open a terminal and enter `java`
to request the install. Follow the instructions.

### 2. Create a user for Jenkins

It's best to run Jenkins as it's own user (it can then be limited in the
permissions it has), and you'll want to create a standard (full) user for it.

You can do this through System Preferences, the Server Manager or the command
line.

For a local user:

```sh
# create an applications group
dseditgroup -o create -n . -u username -p -r ‘Applications’ applications
# get the id for that group
sudo dscl . -read /Groups/applications
# find a unique identifier to give the user
sudo dscl . -list /Users UniqueID
# create the jenkins user
sudo dscl . -create /Users/jenkins
sudo dscl . -create /Users/jenkins PrimaryGroupID 505
sudo dscl . -create /Users/jenkins UniqueID 1026
sudo dscl . -create /Users/jenkins UserShell /bin/bash
sudo ddcl . -create /Users/jenkins RealName "Jenkins"
sudo dscl . -create /Users/jenkins NFSHomeDirectory /Users/jenkins
sudo dscl . -passwd /Users/jenkins
# create and set the owner of the home directory
sudo mkdir /Users/jenkins
sudo chown -R jenkins /Users/jenkins
```

(Replace `username` with the username of an admin user).

For an Open Directory user (replace the IP with the location of the relevant OD
tree):

```sh
# create an applications group
dseditgroup -o create -n /LDAPv3/127.0.0.1 -u diradmin -p -r ‘Applications’ applications
# get the id for that group
sudo dscl -u diradmin -p /LDAPv3/127.0.0.1 -read /Groups/applications
# find a unique identifier to give the user
sudo dscl -u diradmin -p /LDAPv3/127.0.0.1 -list /Users UniqueID
# create the jenkins user
sudo dscl -u diradmin -p /LDAPv3/127.0.0.1 -create /Users/jenkins
sudo dscl -u diradmin -p /LDAPv3/127.0.0.1 -create /Users/jenkins PrimaryGroupID 505
sudo dscl -u diradmin -p /LDAPv3/127.0.0.1 -create /Users/jenkins UniqueID 1026
sudo dscl -u diradmin -p /LDAPv3/127.0.0.1 -create /Users/jenkins UserShell
/bin/bash
sudo dscl -u diradmin -p /LDAPv3/127.0.0.1 -create /Users/jenkins RealName "Jenkins"
sudo dscl -u diradmin -p /LDAPv3/127.0.0.1 -create /Users/jenkins NFSHomeDirectory /Users/jenkins
sudo dscl -u diradmin -p /LDAPv3/127.0.0.1 -passwd /Users/jenkins
# create and set the owner of the home directory
sudo mkdir /Users/jenkins sudo chown -R jenkins /Users/jenkins
```

You’ll now able to login as the Jenkins user by doing something like: `sudo -u
jenkins -i` (this will login as Jenkins with a full user session).

### 3. Install Jenkins

Run `brew install jenkins` as the user you'd normally use `brew` with.

### 4. Configure the Launch Item

OS X handles services using `launchd` and has a few different types for where
they should be placed:

+--------------+---------+
| Type         | Context |
+==============+=========+
| LaunchDaemon | System  |
+--------------+---------+
| LaunchAgent  | User    |
+--------------+---------+

More detail can be found in the [Daemons and Services Programming Guide][].

In our case, we want to run Jenkins as a `LaunchDaemon` as our newly created
`jenkins` user, so create a `plist` file as
`/Library/LaunchDaemons/homebrew.mxcl.jenkins.plist` with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>homebrew.mxcl.jenkins</string>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/bin/java</string>
      <string>-Dmail.smtp.starttls.enable=true</string>
      <string>-jar</string>
      <string>/usr/local/opt/jenkins/libexec/jenkins.war</string>
      <string>--httpListenAddress=127.0.0.1</string>
      <string>--httpPort=8080</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>UserName</key>
    <string>jenkins</string>
  </dict>
</plist>
```

And then load it: `sudo launchctl load
/Library/LaunchDaemons/homebrew.mxcl.jenkins.plist`.

(I'm sticking with the convention for naming as recommended by Hombrew.)

### 5. Test it out

Now you'll be able to go to `http://127.0.0.1:8080` (locally) and see Jenkins.
You’ll want to verify that it's launched with the correct user, which can be
found under "System Info".

The Launch Daemon specifies that it'll only listen on `127.0.0.1`, so it's not
possible to access it outside the local machine.

(I'd recommend keeping Jenkins inside an internal network, as it's executing
code on the local machine. Maybe by restricting it like below…)

### 6. (Optional) Reverse Proxying Apache & Restricting by Networks

It's likely that you'll want to access Jenkins at a specific domain and not
have to use a separate port. This can be accomplished in lots of ways, but here
I'm going to explain [Apache][] as that's what OS X Server uses by default. If
you're not using OS X Server, either install Apache or another Web Server such
as [nginx][]. The steps below configure this using SSL
([using this guide][ssl_guide]), you can cut out much of this if you'd prefer
not to.

First, enable "Websites" in Server. It doesn't need any special configuration
for what we’ll be doing.

Next, create a new site from within Server. This will ensure it's all working
in the manner it expects. Here, I've restricted it to internal only IPs:

<figure>
  <img src="/resources/images/osx_server_jenkins_website.png"
  alt="Jenkins Website Configuration" max-width="500px">
  <figcaption>Jenkins Website Configuration</figcaption>
</figure>

The configuration for "Websites" is held in:
`/Library/Server/Web/Config/apache2`. There's a `README` which might be helpful
to read.

Next, reconfigure the configuration file for the new site (which is an Apache
virtualhost):

```conf
# /Library/Server/Web/Config/apache2/sites/0000_10.0.0.1_443_jenkins.example.com.conf
<VirtualHost 10.0.0.1:443>
    ServerName jenkins.example.com
    ServerAdmin admin@example.com
    DocumentRoot "/Library/Server/Web/Data/Sites/jenkins.example.com"
    DirectoryIndex index.html index.php /wiki/ /xcode/ default.html
    CustomLog /var/log/apache2/access_log combinedvhost
    ErrorLog /var/log/apache2/error_log
    <IfModule mod_ssl.c>
        SSLEngine On
        SSLCipherSuite "ALL:!aNULL:!ADH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH:+MEDIUM"
        SSLProtocol -ALL +TLSv1
        SSLProxyEngine On
        SSLCertificateFile "/etc/certificates/certificate_name.cert.pem"
        SSLCertificateKeyFile "/etc/certificates/certificate_name.key.pem"
        SSLCertificateChainFile "/etc/certificates/certificate_name.chain.pem"
        SSLProxyProtocol -ALL +TLSv1
        SSLProxyCheckPeerCN off
        SSLProxyCheckPeerName off
    </IfModule>
    <Directory "/Library/Server/Web/Data/Sites/jenkins.example.com">
        Options All -Indexes -ExecCGI -Includes +MultiViews
        AllowOverride None
        <IfModule mod_dav.c>
            DAV Off
        </IfModule>
        <IfDefine !WEBSERVICE_ON>
            Require all denied
            ErrorDocument 403 /customerror/websitesoff403.html
        </IfDefine>
    </Directory>

    <proxy>
        Order Deny,Allow
        Deny from all
        Allow from 127.0.0.1
        Allow from 10.0.0.1/8
        Allow from 199.19.86.77
    </proxy>

    ProxyPass / http://127.0.0.1:8080/ nocanon
    ProxyPassReverse / http://127.0.0.1:8080/
    ProxyRequests Off
    AllowEncodedSlashes NoDecode
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"
</VirtualHost>
```

Much of this is the default configuration, with the bottom two additions being
the important bit:

```
<proxy>
    Order Deny,Allow
    Deny from all
    Allow from 127.0.0.1
    Allow from 10.0.0.1/8
</proxy>

ProxyPass / http://127.0.0.1:8080/ nocanon
ProxyPassReverse / http://127.0.0.1:8080/
ProxyRequests Off
AllowEncodedSlashes NoDecode
RequestHeader set X-Forwarded-Proto "https"
RequestHeader set X-Forwarded-Port "443"
```

…which [configures it as a reverse proxy][jenkins_reverse_proxy].

Next, restart Apache:

```sh
sudo /Applications/Server.app/Contents/ServerRoot/usr/sbin/serveradmin stop web
sudo /Applications/Server.app/Contents/ServerRoot/usr/sbin/serveradmin start web
```

### 7. (Optional) Configure Users with LDAP

The final step I took was to configure Jenkins' user support against OS X
Server's Open Directory. This is just LDAP with a different name, and it's easy
to get working.

Under "Manage Jenkins" &rarr; "Configure Global Security", configure the server
to the correct name and then fill in the root DN like so:

```
dc=server,dc=example,dc=com
```

…where `server`, `example`, `com` make up the hostname of the configured LDAP
tree (`server.example.com`). This screenshot might help:

<figure>
  <img src="/resources/images/osx_server_jenkins_ldap.png"
  alt="Jenkins LDAP Configuration" max-width="500px">
  <figcaption>Jenkins LDAP Configuration</figcaption>
</figure>

Jenkins will be able to configure the rest itself.

### Closing Steps

Before configuring your first set of builds, you'll likely want to install a
set of plugins. I use:

* [Git][git_plugin], to support Git as a SCM type
* [GitHub][github_plugin], for deeper integration
* [AnsiColor][ansicolor_plugin], to support colours in terminal output
* [Ruby][ruby_plugin], to support Ruby as a script type
* [Python][python_plugin], to support Python as a script type

[Apache]: https://httpd.apache.org
[nginx]: http://nginx.org
[Daemons and Services Programming Guide]: https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html
[Jenkins]: https://jenkins-ci.org
[continuous integration]: http://en.wikipedia.org/wiki/Continuous_integration
[Macminicolo]: http://macminicolo.net
[OS X Server]: http://www.apple.com/uk/osx/server/
[LDAP]: http://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol
[boxes]: https://github.com/nickcharlton/boxes
[Homebrew]: http://brew.sh
[jenkins_reverse_proxy]: https://wiki.jenkins-ci.org/display/JENKINS/Running+Jenkins+behind+Apache
[git_plugin]: https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin
[github_plugin]: https://wiki.jenkins-ci.org/display/JENKINS/Github+Plugin
[ansicolor_plugin]: https://wiki.jenkins-ci.org/display/JENKINS/AnsiColor+Plugin
[ruby_plugin]: https://wiki.jenkins-ci.org/display/JENKINS/Ruby+Plugin
[python_plugin]: https://wiki.jenkins-ci.org/display/JENKINS/Python+Plugin
