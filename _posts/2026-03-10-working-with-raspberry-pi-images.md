---
title: "Working with Raspberry Pi images"
tags: raspberry-pi linux
---

I've found myself working with the [Raspberry Pi][1] frequently recently. It's
a nice platform, and I appreciate the software tooling for making it easy to
get going and allowing you to focus on what you're trying to make, rather than
the embedded platform itself. But every guide points to using the [Raspberry Pi
Imager][2], which isn't a satisfying answer for what the process actually is,
which would help for figuring out how to automate the process.

## `dd` is always our friend

[Raspberry Pi OS][3], their Debian-based distribution, is available as a
compressed image file, a `.img.xz`. Find the device (`fdisk -l`), then we can
write the image:

```sh
$ unxz 2025-12-04-raspios-trixie-arm64-lite.img.xz
$ sudo dd if=2025-12-04-raspios-trixie-arm64-lite.img of=/dev/sda
5832704+0 records in
5832704+0 records out
2986344448 bytes (3.0 GB, 2.8 GiB) copied, 268.014 s, 11.1 MB/s
```

I've been skipping this step for some projects and [using a full image by
buying a pre-installed SD card][4], which is a helpful option.

## Customisation

The disk image is made up of two partitions: a smaller FAT32 partition which is
mounted at `/boot` and a larger Linux partition which holds the operating
system image:

```sh
$ sudo fdisk -l
[ ... snip ... ]
Disk /dev/sda: 58.94 GiB, 63281561600 bytes, 123596800 sectors
Disk model: SD/MMC
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xffc763c1

Device     Boot   Start     End Sectors  Size Id Type
/dev/sda1         16384 1064959 1048576  512M  c W95 FAT32 (LBA)
/dev/sda2       1064960 5832703 4767744  2.3G 83 Linux
```

The `/boot` partition contains files like the `config.txt`, used to configure
hardware options, plus the binaries and relevant device trees for booting the
operating system. In addition, [at the end of 2025, Raspberry Pi released
`cloud-init` support][5]. This allows us to drop a couple of YAML files onto
the `/boot` partition of the image, which are read and processed on boot.

```sh
$ sudo mount /dev/sda1 /media/usb-drive
$ ls /media/usb-drive
bcm2710-rpi-2-b.dtb	  bcm2711-rpi-400.dtb	  bcm2712-rpi-500.dtb	      cmdline.txt   fixup.dat	     kernel8.img       start4.elf
bcm2710-rpi-3-b.dtb	  bcm2711-rpi-4-b.dtb	  bcm2712-rpi-5-b.dtb	      config.txt    fixup_db.dat     LICENCE.broadcom  start4x.elf
bcm2710-rpi-3-b-plus.dtb  bcm2711-rpi-cm4.dtb	  bcm2712-rpi-cm5-cm4io.dtb   fixup4cd.dat  fixup_x.dat      meta-data	       start_cd.elf
bcm2710-rpi-cm0.dtb	  bcm2711-rpi-cm4-io.dtb  bcm2712-rpi-cm5-cm5io.dtb   fixup4.dat    initramfs_2712   network-config    start_db.elf
bcm2710-rpi-cm3.dtb	  bcm2711-rpi-cm4s.dtb	  bcm2712-rpi-cm5l-cm4io.dtb  fixup4db.dat  initramfs8	     overlays	       start.elf
bcm2710-rpi-zero-2.dtb	  bcm2712d0-rpi-5-b.dtb   bcm2712-rpi-cm5l-cm5io.dtb  fixup4x.dat   issue.txt	     start4cd.elf      start_x.elf
bcm2710-rpi-zero-2-w.dtb  bcm2712-d-rpi-5-b.dtb   bootcode.bin		      fixup_cd.dat  kernel_2712.img  start4db.elf      user-data
```

The Pi can be configured like any other using `cloud-init`, but [it's also got
a Raspberry Pi specific module which is handy for configuring hardware][6],
including [support for the fairly new USB gadget mode][7]. Using `cloud-init`
makes for a nice path for future automation.

I'm bootstrapping Pis with something that looks like this as the baseline for
`user-data` (I'm leaving `meta-data` and `network-config` the same as the
default behaviour is fine):

```yaml
#cloud-config

hostname: test-pi
manage_etc_hosts: true

timezone: Europe/London

users:
  - name: pi
    groups: users,adm,dialout,audio,netdev,video,plugdev,cdrom,games,input,gpio,spi,i2c,render,sudo
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$rounds=4096$MwcQMjo1p9YjlEBx$NkyMyUaGVa8hdD33aO/9XS/NoHdJ1a/ekfXOaF2QbYAWyt8eC7weNTAu9N2aS1Uk4zj1BNnD/tRr19nNoe/190
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFypAVlkyYVwdFAUrDnAcZqIM6Lkusv+9J3rRUn7qZzA
    sudo: ALL=(ALL) NOPASSWD:ALL

rpi:
  enable_usb_gadget: true

enable_ssh: true
```

The password used above is `password`, but generated using `mkpasswd
--method=SHA-512 --rounds=4096`, [as recommended by `cloud-init`][8]. If you
set a password, you also need to set `lock_passwd: false`, [otherwise you can
never login][9]. `enable_ssh: true` is a Raspberry Pi-specific option, as
otherwise SSH isn't up when it first boots.

[1]: https://www.raspberrypi.com
[2]: https://www.raspberrypi.com/documentation/computers/getting-started.html#raspberry-pi-imager
[3]: https://www.raspberrypi.com/software/operating-systems/
[4]: https://thepihut.com/products/noobs-preinstalled-sd-card
[5]: https://www.raspberrypi.com/news/cloud-init-on-raspberry-pi-os/
[6]: https://docs.cloud-init.io/en/latest/reference/modules.html#raspberry-pi-configuration
[7]: https://github.com/raspberrypi/rpi-usb-gadget
[8]: https://docs.cloud-init.io/en/latest/reference/examples.html#yaml-examples
[9]: https://raspberrypi.stackexchange.com/a/123700
