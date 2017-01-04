---
title: "Debian/Ubuntu: Dynamic MOTD"
published: 2013-08-01 14:00:00 +0000
tags: debian, ubuntu, sysadmin
---

In doing some client work recently, I noticed that Ubuntu now has a dynamically
generated MOTD (Message of the Day) &mdash; the message shown on login, through SSH
or locally.

It turns out that this has existed for a quite a while. It works by a hook in PAM
(Linux's authentication system), that runs a set of scripts to generate the MOTD
which is then passed along to the client. (Before this, it was generated using a
cron job that ran every 10 or so minutes.) Because it is part of PAM (`pam_motd.so`,
specifically) it also has worked with Debian since Squeeze.

I had tried to do something similar before. Back in mid-2009, I [posted something
about configuring the "SSH Banner"][sshbanner]. I had tried to do something dynamic
before posting that, but without a cronjob it wasn't possible to do and constantly
regenerating a text file for a not-often seen login banner seemed silly.

Out of the box with Ubuntu, a set of provided scripts exist in `/etc/update-motd.d/`,
which are run in ascending order to produce a static `/etc/motd` file. As the
functionality is handled by PAM, on Debian, we just need to create the directory
and populate with a set of scripts.

Like most `config.d/` style configurations, the files are executed in ascending
order, and so prefixing each script with 00-99 will arrange the order of the final
output. Also, the scripts could be in any language but these are mostly shell apart
from where it becomes complex enough to be better off in Python.

## Final Result

```
 _          _          _      _
| | ___   _| |__  _ __(_) ___| | __
| |/ / | | | '_ \| '__| |/ __| |/ /
|   <| |_| | |_) | |  | | (__|   <
|_|\_\\__,_|_.__/|_|  |_|\___|_|\_\

Welcome to Debian 7.0 (3.2.0-3-amd64).

System information as of Mon Jul 29 22:13:06 UTC 2013:

System load:  0.0       Memory usage: 20.0%
Usage of /:   1.6%      Swap usage:   0.0%
Local users:  1

34 updates to install.
0 are security updates.

No mail.
Last login: Fri Jul 26 12:05:11 2013 from localhost
```

My goal here was to have something that could quickly tell me which machine I was
using and some specifics of it, an understanding of the current state and any
actions that should be taken. But, at the same time it should be as concise as is
practical and, importantly be fast to execute.

Another addition I'll make soon is to add configuration manager status, so in my
case it will show the Chef last run, environment and roles applied. (This will also
help remind me which boxes are using Chef before I change things which will
automatically be reverted.)

The following is broadly based upon the version provided by Canonical in Ubuntu
12.04, which is Copyright 2009-2010 Canonical Ltd. and licensed under the GPL. And
so this lot is also[^licensetext].

## Header (`00-header`)

The first part is the header. This comprises of the ASCII art hostname and the
"Welcome…" text. I'm dynamically generating the ASCII art using the short version
of the hostname, but you may wish to hard code it (obviously, this will need
`figlet` installed.)

```bash
#!/bin/sh
#
#    00-header - create the header of the MOTD
#    Copyright (c) 2013 Nick Charlton
#    Copyright (c) 2009-2010 Canonical Ltd.
#
#    Authors: Nick Charlton <hello@nickcharlton.net>
#             Dustin Kirkland <kirkland@canonical.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

[ -r /etc/lsb-release ] && . /etc/lsb-release

if [ -z "$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
        # Fall back to using the very slow lsb_release utility
        DISTRIB_DESCRIPTION=$(lsb_release -s -d)
fi

figlet $(hostname)
printf "\n"

printf "Welcome to %s (%s).\n" "$DISTRIB_DESCRIPTION" "$(uname -r)"
printf "\n"
```

## System Information (`10-sysinfo`)

This is slightly more complicated. Using a mix of standard utilities, `/proc` and
some text parsing, it's quite easy to assemble the system information section. As
I'm only targetting Debian/Ubuntu, it's quite easy to get this working.

In the original implementation, Canonical use their "Landscape" product to generate
the statistics which provides a bit more functionality than this does.

```bash
#!/bin/bash
#
#    10-sysinfo - generate the system information
#    Copyright (c) 2013 Nick Charlton
#
#    Authors: Nick Charlton <hello@nickcharlton.net>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

date=`date`
load=`cat /proc/loadavg | awk '{print $1}'`
root_usage=`df -h / | awk '/\// {print $(NF-1)}'`
memory_usage=`free -m | awk '/Mem/ { printf("%3.1f%%", $3/$2*100) }'`
swap_usage=`free -m | awk '/Swap/ { printf("%3.1f%%", $3/$2*100) }'`
users=`users | wc -w`

echo "System information as of: $date"
echo
printf "System load:\t%s\tMemory usage:\t%s\n" $load $memory_usage
printf "Usage on /:\t%s\tSwap usage:\t%s\n" $root_usage $swap_usage
printf "Local users:\t%s\n" $users
echo
```

## Updates (`20-updates`)

This is much more complicated than the other sections. Canonical achieves this in
Ubuntu by using the same mechanism the GUI software updater works (the notifer,
not synaptic). This implements the same requirement, but using the upstream
dependency that &mdash; `python-apt` &mdash; which allows us to interact with
`apt`'s internals.

This is quite closely based upon the version in Ubuntu, but is simplified[^aptcheck].

```python
#!/usr/bin/python
#
#   20-updates - create the system updates section of the MOTD
#   Copyright (c) 2013 Nick Charlton
#
#   Authors: Nick Charlton <hello@nickcharlton.net>
#   Based upon prior work by Dustin Kirkland and Michael Vogt.
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program; if not, write to the Free Software Foundation, Inc.,
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

import sys
import subprocess
import apt_pkg

DISTRO = subprocess.Popen(["lsb_release", "-c", "-s"],
                          stdout=subprocess.PIPE).communicate()[0].strip()

class OpNullProgress(object):
    '''apt progress handler which supresses any output.'''
    def update(self):
        pass
    def done(self):
        pass

def is_security_upgrade(pkg):
    '''
    Checks to see if a package comes from a DISTRO-security source.
    '''
    security_package_sources = [("Ubuntu", "%s-security" % DISTRO),
                               ("Debian", "%s-security" % DISTRO)]

    for (file, index) in pkg.file_list:
        for origin, archive in security_package_sources:
            if (file.archive == archive and file.origin == origin):
                return True
    return False

# init apt and config
apt_pkg.init()

# open the apt cache
try:
    cache = apt_pkg.Cache(OpNullProgress())
except SystemError, e:
    sys.stderr.write("Error: Opening the cache (%s)" % e)
    sys.exit(-1)

# setup a DepCache instance to interact with the repo
depcache = apt_pkg.DepCache(cache)

# take into account apt policies
depcache.read_pinfile()

# initialise it
depcache.init()

# give up if packages are broken
if depcache.broken_count > 0:
    sys.stderr.write("Error: Broken packages exist.")
    sys.exit(-1)

# mark possible packages
try:
    # run distro-upgrade
    depcache.upgrade(True)
    # reset if packages get marked as deleted -> we don't want to break anything
    if depcache.del_count > 0:
        depcache.init()

    # then a standard upgrade
    depcache.upgrade()
except SystemError, e:
    sys.stderr.write("Error: Couldn't mark the upgrade (%s)" % e)
    sys.exit(-1)

# run around the packages
upgrades = 0
security_upgrades = 0
for pkg in cache.packages:
    candidate = depcache.get_candidate_ver(pkg)
    current = pkg.current_ver

    # skip packages not marked as upgraded/installed
    if not (depcache.marked_install(pkg) or depcache.marked_upgrade(pkg)):
        continue

    # increment the upgrade counter
    upgrades += 1

    # keep another count for security upgrades
    if is_security_upgrade(candidate):
        security_upgrades += 1

    # double check for security upgrades masked by another package
    for version in pkg.version_list:
        if (current and apt_pkg.version_compare(version.ver_str, current.ver_str) <= 0):
            continue
        if is_security_upgrade(version):
            security_upgrades += 1
            break

print "%d updates to install." % upgrades
print "%d are security updates." % security_upgrades
print "" # leave a trailing blank line
```

This is reasonably well commented, if you wished to delve into the implementation,
but at a higher level it:

1. Opens up the `apt` cache.
2. Does the equivalent of `apt-get dist-upgrade`.
3. Then the equivalent of `apt-get upgrade`.
4. Counts the possible packages which are marked to be installed or upgraded.
5. Reports, closes the cache and exits.

It's important to note that whilst it does get a list of packages, it doesn't
commit any changes and so no state will change (and I'm pretty sure I didn't do
anything stupid).

I tested this on a Ubuntu 12.04 (Precise) install, Debian Squeeze and then Wheezy.
That's enough for me to be confident that it works well enough, but I couldn't test
all possible package and so it's quite possible that the reported number will be
incorrect.

Also, Ubuntu has the ability to show distro upgrades. I couldn't work out how to
replicate this. It's less important with Debian &mdash; the major releases are
hardly a common event.

You could do something similar with just bash and some text processing:

```bash
apt-get -s -o Debug::NoLocking=true upgrade | grep ^Inst | wc -l
```

But, this would lose the 'security updates' section. It's also slightly slower, my
Python came in at 0.732s, versus 0.762s on the shell command above. Not that that's
a very significant difference.

[^aptcheck]: To be more specific, this is based upon `apt-check.py`, which can be
    found in `/usr/lib/update-notifier/` in recent Ubuntu releases.

## Footer (`99-footer`)

The default behaviour of `motd` is to present a combination of `/etc/motd` (which is
regenerated on reboot) and `/etc/motd.tail` which is designed to append a sys admin
message or similar. This just replicates the original functionality:

```bash
#!/bin/sh
#
#    99-footer - write the admin's footer to the MOTD
#    Copyright (c) 2013 Nick Charlton
#    Copyright (c) 2009-2010 Canonical Ltd.
#
#    Authors: Nick Charlton <hello@nickcharlton.net>
#             Dustin Kirkland <kirkland@canonical.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

[ -f /etc/motd.tail ] && cat /etc/motd.tail || true
```

## Configuration

All of these files (my filenames are in brackets around the section title) should
be placed in `/etc/update-motd.d/` and then made executable
(`chmod +x /etc/update-motd.d/`). When you login, PAM will regenerate the `motd`
file, which on Debian is located in `/var/run/motd`. The file `/etc/motd` is just a
symlink to this location.

Finally, to replicate the manner in which Ubuntu presents the `motd`, you need to
set the following in `/etc/ssh/sshd_config`:

```
PrintMotd no
PrintLastLog yes

#Banner /etc/issue
```

It seems conterintuitive, but PAM will post the `motd` anyway, so it should be
turned off here. `PrintLastLog` gives you the last login host and time. Then, the
banner can be commented out because our dynamically generated `motd` includes the
same information.

Now I just need to turn it into a Chef cookbook…

[^licensetext]: It also, sadly, means often there's more license text than actual
    code. But, I know people will blindly copy/paste the contents of the text boxes
    and it seems wrong to not include it.

[sshbanner]: /posts/ssh-banner-debian.html
[motdcookbook]: https://github.com/opscode-cookbooks/motd-tail
