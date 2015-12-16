---
title: Using ruby-oci8 on Ubuntu/Debian
published: 2011-03-02 14:43:36 +0000
tags: ruby, oracle, ruby-oci8, ubuntu, debian
---

With this year's integrating project, we were required to write a web service to integrate Android with the University's Oracle server. After asking to use Ruby (and succeeding), I was then left with the obstacle of hooking up to the Oracle database. These a few notes on getting this working.

_Note: You'll need to follow these steps if you are installing via the [gem](http://rubygems.org/gems/ruby-oci8) or [doing it manually](http://ruby-oci8.rubyforge.org/en/)_

## Prerequisites

Firstly; you'll need to install the `libaio-dev` package, as instant client relies upon it.

	sudo apt-get install libaio-dev

## Oracle Instant Client

After this, you'll need to [pick up the Instant Client Basic and Instant Client SDK packages from Oracle's site](http://www.oracle.com/technetwork/database/features/instant-client/index-097480.html). _Note: You'll need to register to access these._

Jump into `/opt/oracle` and extract them.

You will then end up with a folder such as `instant-client_11_2` (the SDK will end up in the same folder).

Inside this folder, you will want to create a symlink to the current version of the `libclntsh.so.*` library:

	sudo ln -s libclntsh.so.11.1 libclntsh.so

## Add to your PATH

To tell Ruby where to find the instant client libraries, you need to add the newly setup folder into your PATH. You can do this by doing something similar to the following:

	export LD_LIBRARY_PATH=/opt/oracle/instantclient_11_2

If you don't add the libraries to your PATH, Ruby will not be able to access them. If you don't add them to something like your `.bashrc`, they will be forgotten on reboot and when using the OCI8 gem, Ruby will complain at you.

## Install the gem

Next you need to install the Ruby library itself. You can find out about [compiling it yourself here](http://ruby-oci8.rubyforge.org/en/InstallForInstantClient.html).

To install you will need superuser access, however `sudo` will not pass in the library location, to get around this we can deliberately pass in the library path to the gem installer.

	sudo env LD_LIBRARY_PATH=/opt/oracle/instantclient_11_2 gem install ruby-oci8

---

At this point, everything should be working. Shared Library errors are generally caused by an issue with Oracle's instant client, especially when the PATH has been reset. This article was based on a few others, you can [read](http://ruby-oci8.rubyforge.org/en/InstallForInstantClient.html) [those](http://www.it-wikipedia.com/web/how-to-install-ruby-oci8-on-ubuntu-server.html) [here](http://2muchtea.wordpress.com/2007/12/23/installing-ruby-oci8-on-ubuntu/).

