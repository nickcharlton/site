---
title: "Configuring a serial console on Debian 12"
tags: debian serial
---

I’m a fan of serial consoles for out-of-band access, since having used them a
lot for network equipment. Recently, I was trying to figure out a graphics
incompatibility on a system using Wayland on Debian and wanted to set up a
serial console to try to stop part of the debugging process being so painful.

Since `systemd` has rolled out to Debian though, there are a lot of outdated
articles, and now it’s quite a bit easier to get going. [According to the
Debian Wiki][1], we can now start a service to do this on demand:

```sh
systemctl enable serial-getty@ttyS0.service
systemctl start serial-getty@ttyS0.service
```

But if we configure the bootloader (`grub`) instead, we can get serial console
output from much earlier in the boot process.

## Determining the correct serial device

Most of the time, you can likely assume it's going to be `ttyS0`, but it's
worth checking:

```sh
$ sudo dmesg | grep tty
[    0.066243] printk: console [tty0] enabled
[    0.685110] 00:01: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    0.686459] 00:02: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
[   18.042511] systemd[1]: Created slice system-getty.slice - Slice /system/getty.
```

This motherboard has a built-in serial port, plus another is configured [using
a header cable][2].

## Configure Grub

We open up `/etc/default/grub`, and modify `GRUB_CMDLINE_LINUX` to set a
console on the serial port, followed by updating the live Grub configuration:

```
$ sudo vim /etc/default/grub
```

```diff
-GRUB_CMDLINE_LINUX=""
+GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0"
```

```
$ sudo update-grub
```

By default, this will be 9600 baud. But we can configure that, for example,
setting 115200:

```
GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200n8"
```

{% picture url: "resources/images/debian-serial-console-gtkterm.png"
           alt: "A screenshot showing gtkterm, a serial console client, which
           is displaying the Debian login prompt."
%}
  A Debian login screen in gtkterm
{% endpicture %}

## Fun aside: Firmware Console Redirection

Whilst I was configuring this board (a [Supermicro X11SSH-LN4F][3]), I noticed
that it supports console redirect inside the firmware (BIOS). If we configure
the same settings from the firmware through to `grub`, we can keep the same
console session through the whole boot process. This also works with
[FreeDOS][4], which is handy if you're doing a firmware upgrade.

{% picture url: "resources/images/debian-serial-console-bios.png"
           alt: "A screenshot showing the firmware (BIOS) of a Supermicro
           motherboard, through a serial console."
%}
  We can configure the BIOS even inside a serial console
{% endpicture %}

As long as you know the correct command to get into the firmware (delete, in
this case) when the screen goes blank you can just keep hitting the combination
to get into setup.

Of note, I found that less than 115200 baud made the firmware incredibly slow
to redraw. It also doesn't draw elements under the cursor, so you might need to
move around a bunch to see what's being selected.

{% picture url: "resources/images/debian-serial-console-redirection-one.png"
           alt: "A screenshot showing the firmware (BIOS) where COM1 Console
           Redirection has been enabled."
%}
  We can configure COM1 (which matches to `ttyS0`) for console redirection.
{% endpicture %}

{% picture url: "resources/images/debian-serial-console-redirection-two.png"
           alt: "A screenshot showing the firmware (BIOS) where COM1 Console
           Redirection has been configured with 115200 baud."
%}
  We can also configure the speed, in this case, 115200, to match Debian once
  it's booted.
{% endpicture %}


{% picture url: "resources/images/debian-serial-console-ascii-art.png"
           alt: "A screenshot showing the boot process of a Supermicro
           motherboard. It is showing some fun ASCII art of the Supermicro
           logo."
%}
  And get this fun ASCII art too
{% endpicture %}

[1]: https://wiki.debian.org/systemd#Virtual_and_serial_console_changes
[2]: https://www.startech.com/en-gb/cables/pnl9m16
[3]: https://www.supermicro.com/en/products/motherboard/X11SSH-LN4F
[4]: https://freedos.org
