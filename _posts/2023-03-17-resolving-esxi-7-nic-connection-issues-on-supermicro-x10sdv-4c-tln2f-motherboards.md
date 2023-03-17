---
title: "Resolving ESXi 7.0 NIC connection issues on Supermicro X10SDV-4C-TLN2F motherboards"
tags: supermicro motherboard server
---

I have a few [Supermicro X10SDV-4C-TLN2F motherboards][1] that I've been
setting up to run [VMware ESXi][2] on. The first board was fine, but when
setting up another I could never get ESXi to acquire an IP over DHCP. The
hardware was happy the connection was valid, and both Debian 11 and Windows
Server 2019 were fine …but not ESXi:

{% picture url: "resources/images/supermicro-nic-waiting-for-dhcp.png"
           alt: "A screenshot showing ESXi with 'waiting for DHCP'"
%}
  A screenshot showing ESXi with 'waiting for DHCP'
{% endpicture %}

{% picture url: "resources/images/supermicro-nic-adapters-disconnected.png"
           alt: "A screenshot showing the ESXi network adaptors dialog, with
           adaptor state as disconnected."
%}
  A screenshot showing the adaptors as disconnected.
{% endpicture %}

I'd been using a slightly older version of ESXi (7.0U3D/19482537), so I tried a
newer version (7.0U3g/20328353) that I've upgraded to on one of the other
boards, but this didn't help. Both of my boards were running the same BIOS
version (2.1) and build date (2019-11-22), so that seemed an unlikely cause.

After more head-scratching, I came across _[Workaround and fix for intermittent
Intel X552/X557 10GbE/1GbE network link-down outages on Xeon D-1500
Series][3]_. I didn't have the exact boards they were talking about in the
start of the post nor the intermittent issues mentioned, but the one I have
_does_ have an Intel X552 so I thought this was promising. After going through
the whole post (and most of the more recent comments), it seemed like it might
be a NIC firmware difference between the two of my boards. I'm using a basic
gigabit switch too, and not a 10GbE one.

## Investigating the current NIC & firmware

[Using the console, we can find out more about the hardware.][14] When
connected directly (or using IPMI), [Alt+F1 will switch to the console][5].

```sh
$ esxcli network nic list

Name    PCI Device    Driver   Admin Status  Link Status  Speed  Duplex  MAC Address         MTU  Description
------  ------------  -------  ------------  -----------  -----  ------  -----------------  ----  -----------
vmnic0  0000:03:00.0  ixgben   Up            Down             0  Half    ac:1f:6b:12:f8:6e  1500  Intel(R) Ethernet Connection X552/X557-AT 10GBASE-T
vmnic1  0000:03:00.1  ixgben   Up            Down             0  Half    ac:1f:6b:12:f8:6f  1500  Intel(R) Ethernet Connection X552/X557-AT 10GBASE-T

$ esxcli network nic get -n vmnic0
  Advertised Auto Negotiation: true
  Advertised Link Modes: Auto, 1000BaseT/Full, 10000BaseT/Full
  Auto Negotiation: false
  Cable Type: Twisted Pair
  Current Message Level: -1
  Driver Info:
      Bus Info: 0000:03:00:0
      Driver: ixgben
      Firmware Version: 0x800005ad
      Version: 1.7.1.35
  Link Detected: true
  Link Status: Up
  Name: vmnice0
  PHYAddress: 0
  Pause Autonegotiate: true
  Pause RX: true
  Pause TX: true
  Supported Ports: TP
  Supports Auto Megotiation: true
  Supports Pause: true
  Supports Hakeon: false
  Transceiver:
  Virtual Address: 00:50:56:56:62:7
  Hakeon: None
```

On the board with issues, the firmware version is `0x800005ad`. But the working
board is `0x800003e7`, which is curious.

## A Temporary Solution

I then tried the [suggestion from Bruno Zeidan][4], who had the same board:

```sh
esxcli network nic set --speed 1000 --duplex full -n vmnic0
```

This worked — and continues to do so after a reboot. Unfortunately, if the
network cable is unplugged it won't come back up again.

## Upgrading the BIOS

My next thought was to try [the new BIOS release][9]. Supermicro put out 2.3 on
2021-06-04 and upgrading the BIOS is enough of a faff I didn't bother
previously.

I wrote a [FreeDOS 1.3 LiveCD][6] using [Rufus][7] to a USB drive and dropped
in the BIOS Zip contents. I'd originally tried to use the FreeDOS bundled with
Rufus, but this gave me an out of memory error ([like mentioned in this blog
post][8]).

After booting back into ESXi after flashing completed, it did immediately get
an IP, which was encouraging. Post upgrade, the firmware version was
`0x800005ad` still and unplugging the cable ended up with the same situation as
before.

## Trying to flash the NIC

Knowing that a difference between NIC firmware versions was the most likely
explanation for the different behaviour on each board, I was curious to see
what would happen if I tried to flash them. I also wasn't convinced about the
hex values of the version number — Intel didn't have those listed anywhere.

I got a copy of the [most recent driver CD][12] and moved the Intel NIC
`BOOTUTIL` over to the FreeDOS USB drive from earlier. [Calvin Bui's post about
flashing the NIC firmware][10] enabled me to figure out what was needed. From
reading around, [it seems like Supermicro likely have their own firmware
specifically for the onboard NIC][11], so I stuck to the [available (two)
driver CDs][12].

On the problematic board, it turned out that the version was `2.3.58`:

```
C:\BOOTUTIL\DOS\bootutil.exe

Intel(R) Ethernet Flash Firmware Utility
BootUtil version 1.6.40.1
Copyright (C) 2003-2017 Intel Corporation

Type BootUtil -? for help

Port Network Address Location Series  WOL Flash Firmware     Version
==== =============== ======== ======= === ================== =======
  1   AC1F6B12F86E     3:00.0 10GbE   YES UEFI,PXE Enabled   2.3.58
  1   AC1F6B12F86F     3:00.0 10GbE   YES UEFI,PXE Enabled   2.3.58
```

But the working board was `2.3.53`:

```
C:\BOOTUTIL\DOS\bootutil.exe

Intel(R) Ethernet Flash Firmware Utility
BootUtil version 1.6.40.1
Copyright (C) 2003-2017 Intel Corporation

Type BootUtil -? for help

Port Network Address Location Series  WOL Flash Firmware     Version
==== =============== ======== ======= === ================== =======
  1   OCC47A95BE18     3:00.0 10GbE   YES UEFI,PXE Enabled   2.3.53
  1   OCC47A95BE19     3:00.0 10GbE   YES UEFI,PXE Enabled   2.3.53
```


`NVMUpdate` is the tool to flash the NIC firmware and the easiest way to run
this was to create a [Debian Live][13] USB drive and copy over the versions
from the driver ISO images.

Once you're booted into Debian, you can:

1. Find the drive: `sudo fdisk -l`,
2. Create a mount point: `sudo mkdir /media/usb-drive`,
3. Then mount it, e.g.: `sudo mount /dev/sdb1 /media/usb-drive`)

But running `./nvmupdate64e` would always give a device access error on all
available Supermicro versions (and the [most recent Intel version available
from their site][15]):

```
$ sudo ./nvmupdate64e

Intel(R) Ethernet NVM Update Tool
NVMUpdate version 1.38.3.3
Copyright(C) 2013 - 2023 Intel Corporation.

WARNING: To avoid damage to your device, do not stop the update or reboot or
poweroff the system during this update.
Inventory in process. Please wait [...|******]

Num Description                          Ver.(hex)  DevId S:B    Status
=== ================================== ============ ===== ====== ==============
01) Intel(R) Ethernet Connection          N/A(N/A)   15AD 00:003 Access error
    X552/X557-AT 10GBASE-T

Tool execution completed with the following status: Device not found.
Press any key to exit.
```

Now I was stumped. The next best option is to get in touch with Supermicro
support, but I'd love to hear from anyone who gets further than me!

For now, I'm using the temporary fix mentioned above as I need to get on and
get it setup.

[1]: https://www.supermicro.com/en/products/motherboard/X10SDV-4C-TLN2F
[2]: https://www.vmware.com/products/esxi-and-esx.html
[3]: https://tinkertry.com/how-to-work-around-intermittent-intel-x557-network-outages-on-12-core-xeon-d#may-06-2018-update
[4]: https://tinkertry.com/how-to-install-esxi-on-xeon-d-1500-supermicro-superserver#comment-3869415400
[5]: https://kb.vmware.com/s/article/2148363
[6]: https://freedos.org/download/
[7]: https://rufus.ie/en/
[8]: https://www.bytesizedalex.com/supermicro-server-bios-update/
[9]: https://www.supermicro.com/en/support/resources/downloadcenter/firmware/MBD-X10SDV-4C-TLN2F/BIOS
[10]: https://calvin.me/how-to-update-intel-nic-firmware/
[11]: https://community.intel.com/t5/Ethernet-Products/Intel-Ethernet-Connection-X552-x557-AT-Can-t-drive/m-p/1302105
[12]: https://www.supermicro.com/wdl/CDR_Images/CDR-X10-UP/
[13]: https://www.debian.org/CD/live/
[14]: https://tinkertry.com/how-to-check-which-network-driver-your-esxi-server-is-currently-using
[15]: https://www.intel.com/content/www/us/en/download/15084/intel-ethernet-adapter-complete-driver-pack.html?wapkw=x557-at
