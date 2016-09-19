---
title: "Persistent SSH Keys with ESXi 6"
published: 2016-11-30T10:15:18-05:00
tags: esxi ssh linux
---

ESXi is a funny beast when it comes to SSH keys, and there's a lot of
misinformation about on how to configure them persistently, not to mention
security FUD.

ESXi uses an in-memory only filesystem for the bootable portion of it, so
following the [published guide][] will only get you so far. You'll find that
after rebooting, your changes will no longer be there.

You can work around this limitation by rebuilding the keys on boot using
`/etc/rc.local.d/local.sh`. Somewhere before the `exit 0`, add a modified
version of the following:

```sh
mkdir -p /etc/ssh/keys-<username>
echo "ssh-rsa AAAAB3..." > /etc/ssh/keys-<username>/authorized_keys
chmod 700 -R /etc/ssh/keys-<username> && chmod 600 /etc/ssh/keys-<username>/authorized_keys
chown -R <username> /etc/ssh/keys-<username>
```

where `<username` and the value of the public key are replaced with actual
values.

Once you've done this, ensure it's backed up by running:
`/sbin/auto-backup.sh`.

`auto-backup.sh` [runs every hour][backup_frequency] and backs up certain known
files which are marked with the "sticky bit" (`chmod +t file`). These are then
restored on reboot. `auto-backup.sh` only knows about certain files, so we're
adding this to one it knows about.

This pattern can used in a similar way for other settings which need to stay
around after reboots.

VMware seem to not recommend enabling SSH by default, and that's fine.
If you disagree with that, you can enable it inside the Web UI by going to
"Manage", "Services" finding "TM-SSH" and selecting "Actions",
"Policy", enable "Start and stop with host".

[published guide]: https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1002866
[backup_frequency]: http://blogs.vmware.com/vsphere/2011/09/how-often-does-esxi-write-to-the-boot-disk.html
