---
title: Configuring Apache &amp; PHP on Lion
tags: lion mac apache php
---

There are too many terrible articles on configuring Apache and PHP on the Mac, especially for Lion. Even worse are the suggestions of using other versions, or overly complex configuration methods. 

Apache & PHP are included with Lion by default, but various parts are disabled. This will show you how to enable them without breaking the local install.

### Configuration Files

The Apache config files are located in `/etc/apache2` (the standard place.)

The most important part of this directory is `httpd.conf`. This is the main configuration file. In the `users/` subdirectory are the configurations for local users (accessible through `http://localhost/~<username>`.) 

The PHP configuration file (`php5.conf`) is held under `other/`.

The global virtual-hosts config file is held under `extra/httpd-vhosts.conf`. Although, by default this is commented out in `httpd.conf`.

The rest is mostly Apple specifics, including some of the tools included with Lion Server, and other areas of the config you are unlikely to need to change.

### Permissions

By default, the main `httpd.conf` file is set to only be readable by all (444.) I would assume this is so users do not inadvertantly break the defaults.

To change it to be writeable by it's own user (root), change it to 644 (readable by all, readable by it's owner.) like so:

	chmod 644 httpd.conf

You can then edit it using sudo, in your favourite editor.

### Enabling PHP

Apple have always shipped with PHP disabled by default (even in Lion Server, you need to select a checkbox to specifically enable it.)

In `httpd.conf`, it is located somewhere around line 111, towards the end of the other `LoadModule` statements. This line is commented out. You need to remove the hash to it looks something like this:

	LoadModule alias_module libexec/apache2/mod_alias.so
	LoadModule rewrite_module libexec/apache2/mod_rewrite.so
	LoadModule php5_module libexec/apache2/libphp5.so                                    
 
	#Apple specific modules
	LoadModule apple_userdir_module libexec/apache2/mod_userdir_apple.so

After doing this, you will need to restart Apache. You can do that from System Preferences/Sharing, or like so:

	sudo apachectl restart

### Virtual Hosts

For local development (for PHP this isn't so often), I usually add a virtual host for the project I'm working on, and then adjust `/etc/hosts` to give it a usable domain.

You'll need to edit `httpd.conf` again. There is an include for `httpd-vhosts.conf` quite a way in, somewhere around line 623.

You'll find you'll want to remove most of the default example content from `extras/httpd-vhost.conf` (by default accessing anything will give you a 403: Forbidden error.)

From there, each project/application/etc will need a VirtualHost block configured for it. This allows Apache to respond to a given domain. 

The logging entries inside the block are optional, but recommended. Console.app is useful to keep an eye on the logs (it will automatically refresh when it changes.)

	<VirtualHost *:80>
		DocumentRoot /path/to/files
		ServerName project.example.com
		
		ErrorLog /path/to/files/logs/error.log
		LogLevel warn
	</VirtualHost>

To get the domain working, you need to edit `/etc/hosts` and add a line something like this (below the comments, before the rest.):

	127.0.0.1	project.example.com

Now, you should be able to navigate to that domain and access it. 

---

This is probably the most elegant way of running PHP applications locally. It keeps the already present tools, but makes them work as expected - which is far nicer than hacking other tools and configurations in place.

