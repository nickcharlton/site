---
title: "Fixing unsupported SFP+ modules/\"no carrier\" errors with Intel X520 cards on Debian & FreeBSD"
tags: debian freebsd networking
---

I've been reconfiguring a router I built at the end of last year to be a
[transparent firewall (or filtering bridge) using Opnsense][1]. On the router,
I've got a Dell-branded Intel X520-DA2 NIC, along with some [Flypro 10GBase-T
SFP+ modules][2] which I picked up on offer last year. But … they don't work.

Intel — like a lot of other vendors — restricts the SFP+ modules
to those which have been approved, regardless of whether they may pose a
problem and so you can't just use any SFP+ module which isn't programmed for
that vendor's hardware. I'd not actually considered that this was going to be a
problem (even knowing about the vendor restriction with some cards), so it
derailed the project whilst I tried to debug what was going wrong, as at least
in Opnsense this wasn't that clear.

You might see disconnected interfaces which list "no carrier" even when modules
are inserted, or just no interfaces at all (if you booted with them in, the
driver won't use them). The screenshot below shows when the interfaces _do_
show up, but this required booting up with no SFP+ modules, then inserting them
afterwards.

{% picture url: "resources/images/unsupported-sfp-intel-x520.png"
           alt: "Screenshot from Opnsense's interface section, showing no 
           carrier (even though there is)."
%}
  Screenshot from Opnsense's interface section, showing no carrier (even though
  there is).
{% endpicture %}

After reconfiguring a few times, I noticed the interface was always
disconnected, regardless of what was physically plugged in or what I'd set up.
I'm not so familiar with Opnsense/FreeBSD, so booted up a Debian live image to
try out something I was familiar with. I'd originally thought that maybe it was
a platform driver issue, but booting Debian left me with the following error:

```
ixgbe 0000:04:00.0: failed to load because an unsupported SFP+ or QSFP module type was detected.
ixgbe 0000:04:00.0: Reload the driver after installing a supported module.
```

(You can find it later in `dmesg`.)

[Some third-party vendors supply tools to re-programme the boards][3], but
these Flypro modules don't support that (nor do I have one), but there are
options.

## Debian workaround

On Debian, [we can disable the check in the driver module][8]:

```
root@debian:~# rmmod ixgbe
root@debian:~# modprobe ixgbe allow_unsupported_sfp=1
```

Then bring the interfaces up (with a module in/remove and reinsert if already
there):

```
ip link set dev ens2f0 up
```

If we wanted to persist, it we could do:

```
root@debian:~# echo "options ixgbe allow_unsupported_sfp=1" > /etc/modprobe.d/ixgbe.conf
root@debian:~# depmod -a
root@debian:~# update-initramfs -u -k `uname -r` # if you're not running a live system
```

We can then reload the module to bring up the new configuration:

```
root@debian:~# rmmod ixgbe
root@debian:~# modprobe ixgbe
```

## FreeBSD workaround

On [FreeBSD (and so Opnsense, pfSense, etc), we see a similar log message][6]
and [can work around it similarly][7]. On boot, we'll see (and also in
`/var/log/dmesg.today`):

```
ix2: Unsupported SFP+ module detected!
```

We can then [set a tunable][9] to allow unsupported modules:

```
echo "hw.ix.unsupported_sfp=1" > /boot/loader.conf.d/ix.conf
```

After a reboot, the interface should be usable. I did this on Opnsense and it
persists between reboots, and also when resetting to factory defaults.

## Disabling the check on the card

These workarounds were really helpful to isolate my problem to the restriction
and not any other hardware or software configuration, but it'd be much better
to just not have to think about this problem again, especially as this
workaround is reportedly not possible with something like Windows or ESXi, both
of which I use elsewhere.

[Over on the ServeTheHome forums, _NathanA_][4] figured out exactly how to do
this after digging into various data sheets and support threads. [Raymond
Douglas then distilled this down into the steps][5] required. It relies on
using `ethtool` (I used a ["standard" (without desktop environment) live CD
image][10]) to compare a bit (`IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP`, in the Linux
ixgbe driver) on the device's EEPROM before writing a new version.

### 1. Identify the current value

```
root@debian:~# ethtool -e enp4s0f0 offset 0x58 length 1
Offset             Values
------             -------
0x0058:            fc
```

### 2. Write the new value

```
root@debian:~# ethtool -E enp4s0f0 magic 0x10fb8086 offset 0x58 value 0xfd
```

### 3. Verify by reading back

```
root@debian:~# ethtool -e enp4s0f0 offset 0x58 length 1
Offset             Values
------             -------
0x0058:            fd
```

After a reboot, the Debian live environment then used the new module without
any further configuration.

I'd really recommend reading the original ServeTheHome post, as it explains in
much more depth what's going on, why this works and why you need to be careful
not to modify or set incorrect values, as you risk bricking the card.

[1]: https://docs.opnsense.org/manual/how-tos/transparent_bridge.html
[2]: https://www.flypro.com/p423.html
[3]: https://www.fs.com/uk/c/fs-box-3389
[4]: https://forums.servethehome.com/index.php?threads/patching-intel-x520-eeprom-to-unlock-all-sfp-transceivers.24634/
[5]: https://rymnd.net/blog/2020/unsupported-sfp-intel-x520/
[6]: https://forums.freebsd.org/threads/status-no-carrier-for-ethernet-port.67721/
[7]: https://forums.freebsd.org/threads/intel-sfp-card-not-compatible.85348/
[8]: https://blog.route1.ph/2019/09/27/stretch-ixgbe-driver-allow-unsupported-sfp-modules-on-intel-x520-cards/
[9]: https://wiki.freebsd.org/sysctl
[10]: https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/
