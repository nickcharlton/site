---
title: "Installing Debian 12 on a Dell Wyse 3040 Thin Client"
tags: debian hardware
---

The [Dell Wyse 3040][1] is a little thin client device that's surprisingly
powerful and also very low power. I picked one up last year, new in box, for
about £30 for a project. Unfortunately, getting Debian running on it is not so
straightforward [because it has a buggy EFI implementation which means that
whilst you can complete the install, you can't boot it afterwards][2].

The Wyse 3040 only uses UEFI and doesn't support a legacy BIOS mode. Usually, a
boot variable is defined which points to the bootloader for each vendor's
operating system. In Debian's case, this should be `\EFI\debian\grubx64.efi`.
But, the Wyse 3040 firmware is missing this. Instead, [we need to force the
bootloader to exist at another known path &mdash; originally intended for
removable media: `\EFI\boot\bootx64.efi`][3].

[Fortunately, there's an option in the Debian installer][4] to do this which is
much more robust than doing it ourselves (which the Debian wiki also describes)
as it could be broken with updates.

I'll be installing Debian on an otherwise empty USB flash drive to maintain the
original install, and booting from another USB drive with the latest Debian
netinst on. You can disable booting from the internal drive, if you want.
Nothing else in the firmware needs changing from the defaults.

{% picture url: "resources/images/wyse-3040-firmware-internal-drive.png"
           alt: "A screen capture of a Dell Wyse 3040 firmware (BIOS) showing
           the boot sequence. The UEFI: Hard Drive, Partition 1 option has been
           disabled."
%}
  A screenshot of the EFI firmware, showing the internal drive disabled.
{% endpicture %}

Some things which are helpful:

* F2 for setup
* F12 for the boot menu
* The default password is "Fireport"

## Installing Debian

Boot from the USB drive, once you're at the Debian installer, go into _Advanced
options_ and select _Expert install_.

{% picture url: "resources/images/wyse-3040-debian-installer-expert-install.png"
           alt: "A screen capture from the Debian installer, showing that we're
           in Advanced options. Expert install has been selected."
%}
  Debian installer ready to start an "Expert install"
{% endpicture %}


You can then proceed through each section of the install. In the _Expert
install_ mode, you're asked many more questions, but it's broadly the same as
the normal installer. You just have to select each stage of the installer
yourself. I didn't need to select any additional locales or components for my
install and preselected values (for the NIC, kernel, drivers, etc) were all
fine.

Eventually, you'll proceed through the setup until you're ready to select
_Install the GRUB boot loader_:

{% picture url: "resources/images/wyse-3040-debian-installer-grub.png"
           alt: "A screen capture showing the Debian installer main menu whilst
           in Expert install. Install the GRUB boot loader has been selected."
%}
  Debian installer showing the next installation step
{% endpicture %}


Then look out for _Force extra installation to the EFI removable media path?_.
We'll select _Yes_.

{% picture url: "resources/images/wyse-3040-debian-installer-force-efi.png"
           alt: "A screen capture showing the Debian installer during
           installation of the GRUB boot loader. It is asking whether to Force
           GRUB installation to the EFI removable media path. Yes has been
           selected."
%}
  During the Debian install, we select "yes" to work around the buggy EFI
  implementation
{% endpicture %}


I also selected _No_ to _Update NVRAM variables to automatically boot into
Debian?_ to preserve the existing boot behaviour.

{% picture url: "resources/images/wyse-3040-debian-installer-update-nvram.png"
           alt: "A screen capture showing the Debian installer during
           installation of the GRUB boot loader. It is asking whether to update
           NVRAM variables to automatically boot into Debian. No has been
           selected."
%}
  During the Debian install, we select "no" to not have Debian automatically
  boot.
{% endpicture %}

Once this stage of the installation is finished, you'll be prompted to _Finish
the installation_ and then to reboot.

Debian should then successfully boot.

{% picture url: "resources/images/wyse-3040-debian-installed.png"
           alt: "A screen capture showing the Debian login prompt after
           successfully booting."
%}
  Finally, we can boot into a login prompt.
{% endpicture %}


You will see errors about an invalid parameter on boot, and also some Intel
firmware warnings. For the former, Grub launches soon after and for the second
this seems to be harmless (so far).

[1]: https://www.parkytowers.me.uk/thin/wyse/3040/
[2]: https://www.parkytowers.me.uk/thin/wyse/3040/linux.shtml
[3]: https://wiki.debian.org/UEFI
[4]: https://wiki.debian.org/UEFI#Force_grub-efi_installation_to_the_removable_media_path
