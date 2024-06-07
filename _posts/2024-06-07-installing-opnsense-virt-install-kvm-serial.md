---
title: "Installing Opnsense with virt-install on KVM"
tags: opnsense kvm
---

I was trying to setup a quick (…foreshadowing) VM to run a VPN on a host I use 
for a few VMs with KVM. But getting it setup was surprisingly painful until I 
tried the "nano" install image.

As the host is headless, I wanted a disk image I could import on the host with 
[Opnsense][2] already installed to avoid trying to redirect VNC over the 
network, or something similarly daft. A serial terminal was ideal (and how 
[`virt-install`][3] and the rest of `libvirt` works nicest). Alas, I [couldn't 
get a serial terminal configured correctly with the `dvd` image (it'd output 
boot logs, but when I got to the stage of interacting with the console it would 
stop outputting anything)][5], [the docs only mention using the Web UI][4] 
which I couldn't do at that stage of the install, and then the USB `serial` 
image just wouldn't boot.

But the `nano` image provided the eventual solution: it's designed to be 
written to a disk and then just booted where it expands to fill the new volume 
and serial is already configured. Perfect, but it wasn't clear how to do it. 
So:

1. Fetch and extract the [image from the download page][1]:

```
wget https://mirror.ams1.nl.leaseweb.net/opnsense/releases/24.1/OPNsense-24.1-nano-amd64.img.bz2
bunzip2 OPNsense-24.1-nano-amd64.img.bz2
```

2. Convert to a `qcow2` disk image: `qemu-img convert -f raw -O qcow2 OPNsense-24.1-nano-amd64.img OPNsense-24.1-nano-amd64.qcow2`
3. Resize to give us more space for logs, etc: `qemu-img resize OPNsense-24.1-nano-amd64.qcow2 +8G`
4. Rename/put the disk somewhere helpful: `cp OPNsense-24.1-nano-amd64.qcow2 opnsense.qcow2`
5. Use `virt-install` to import into a new VM:

```
virt-install --connect qemu:///system \
  --name opnsense \
  --os-variant freebsd12.2 \
  --memory 4096 \
  --disk opnsense.qcow2 \
  --network default \
  --graphics none \
  --console pty,target_type=serial \
  --import
```

Hopefully this saves someone some future bother!

[1]: https://opnsense.org/download/
[2]: https://opnsense.org
[3]: https://manpages.debian.org/stable/virtinst/virt-install.1.en.html
[4]: https://docs.opnsense.org/manual/how-tos/serial_access.html
[5]: https://forums.freebsd.org/threads/installing-freebsd-over-serial-console.62005/#post-357713
