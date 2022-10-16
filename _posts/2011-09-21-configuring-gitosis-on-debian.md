---
title: Configuring Gitosis on Debian
tags: git, gitosis, debian
---

Gitosis is a tool for easing the hosting of Git repositories. For pushing to remote [servers], Git uses SSH. Which is great. But, what if you don't want those users to have shell accounts, and you want to be able to control who has access to repositories? Well, that's what Gitosis does.

Gitosis is in Debian's package manager, but I wasn't too keen on the Debian provided configuration, so here's a few steps to sanitise it:

First, install it. You'll obviously need the dependencies.

    $ sudo apt-get install gitosis

Next, we'll change a few settings. You might find the documentation useful for this, you'll find that under: `/usr/share/doc/gitosis`.

Gitosis stores is config in a Git repository. This also means that it doesn't have a configuration until you initialise it. Now, I'd rather use `git` as the user rather than `gitosis`. So first, create a new user:

    $ sudo adduser \
        --system \
        --shell /bin/sh \
        --gecos 'Git' \
        --group \
        --disabled-password \
        --home /home/git \
        git

You can also remove the gitosis user: `sudo userdel gitosis`.

Next, you'll need your public key somewhere. Then, setup the admin repository:

    $ sudo -H -u git gitosis-init < <path to your public key>

Now, on your local machine, you can pull down the newly initialised Gitosis admin repository. 

    $ git clone git@server:gitosis-admin.git

The `gitosis-admin` directory contains the main config file (`gitosis.conf`) and the public keys of all of the users able to access repositories.

A few notes:

* The members line in the config file needs to match up with a user in `keydir`. But without the .pub extension.
* Groups are used to split up users and/or projects. You define a group, which holds a repository and the users with that permission.
* You can set read/write or read only privileges on groups. But, you'll need to create a new group to define the different privileges for different users.
* Members are separated by spaces.
* A group can also be used to define members, which then can be assigned to another group. (You access the members as a variable by prefixing @).
* When you define a repository in Gitosis, it will be created on the server when you push it.

You'll find [Pro Git probably gives you a better explanation of some of the other features](http://progit.org/book/ch4-7.html). But you should (after this) be able to setup Gitosis on Debian quite nicely.

