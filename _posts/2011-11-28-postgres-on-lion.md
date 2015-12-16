---
title: Postgres on Lion
published: 2011-11-28 23:07:46 +0000
tags: lion, mac, osx, postgres, database
---

I've recently been picking up [PostgreSQL](http://www.postgresql.org/). It's very nice. Unfortunately, I had a few issues with it and Lion. Lion Server now uses Postgres as its default database (replacing MySQL), and consequently it looks like Apple included a bunch of tools in standard Lion, too. 

Unfortunately, these clash a if you attempt to install and use the database daemon.

## Install & Configure

To start with, install Postgres from [Homebrew](http://mxcl.github.com/homebrew/):

    brew install postgres

Then (as told) initialise the database:

    initdb /usr/local/var/postgres

But ignore the rest (as in, don't add the LaunchAgent).

Next, it is necessary to adjust your `$PATH` slightly. On OS X, this is stored in `/etc/paths`. You need to push `/usr/local/bin` to be searched before `/usr/bin`. This will ensure that the homebrew compiled binaries are used instead of the system ones.

## Control

The LaunchAgent step that was skipped is so that you can control Postgres yourself. If this is setup, it will interfere with the `pg_ctl` command. Usually, the LaunchAgent would be used to manage it all for you.

### Starting/Stopping Postgres

    pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start

    pg_ctl -D /usr/local/var/postgres stop -s -m fast

These commands will start and stop Postgres, respectively. The `-m fast` flag on the stop command ignores the presence of other clients as it goes down. 

### Aliases

As these are a little long, I have these aliased to `pgstart` and `pgstop`. [Done like this](https://github.com/nickcharlton/dotfiles/blob/master/_bash_aliases):

    export PGDATA='/usr/local/var/postgres'
    alias pgstart='pg_ctl -l $PGDATA/server.log start'
    alias pgstop='pg_ctl stop -m fast'

---

So, there you go. That's how to setup Postgres properly on Lion. My next challenge is to make libpq (the C library for Postgres) up and running.

