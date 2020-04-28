---
title: "Automating Ubuntu 20.04 installs with Packer"
published: 2020-04-26 23-02-57 +01:00
tags: packer ubuntu
---

Ubuntu 20.04 — which was released few days ago (23rd April) — brings with it a
new installer, replacing the previous [Debian installer][1] with
[`subiquity`][2]. This means that any of the previous approaches for
automated/unattended installs no longer work and need to be replaced.

No one seemed to have documented doing this successfully yet with [Packer][3],
so I set out to figure it out. But first, here's a working unattended
configuration:

`ubuntu-2004.json`:

{% raw %}
```json
{
  "builders": [
    {
      "name": "focal64-vmware",
      "type": "vmware-iso",
      "guest_os_type": "ubuntu-64",
      "headless": false,

      "iso_url": "http://releases.ubuntu.com/20.04/ubuntu-20.04-live-server-amd64.iso",
      "iso_checksum": "caf3fd69c77c439f162e2ba6040e9c320c4ff0d69aad1340a514319a9264df9f",
      "iso_checksum_type": "sha256",

      "ssh_username": "ubuntu",
      "ssh_password": "ubuntu",
      "ssh_timeout": "25m",

      "http_directory": "templates/ubuntu",

      "memory": 2048,

      "boot_wait": "5s",
      "boot_command": [
        "<enter><enter><f6><esc><wait> ",
        "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
        "<enter>"
      ]
    }
  ],

  "provisioners": [
    {
      "type": "shell",
      "inline": ["ls /"]
    }
  ]
}
```
{% endraw %}

`user-data`:

```yaml
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ubuntu-server
    password: '$6$wdAcoXrU039hKYPd$508Qvbe7ObUnxoj15DRCkzC3qO7edjH0VV7BPNRDYK4QR8ofJaEEF2heacn0QgD.f8pO8SNp83XNdWG6tocBM1'
    username: ubuntu
  network:
    network:
      version: 2
      ethernets:
        ens33:
          dhcp4: true
          dhcp-identifier: mac
  ssh:
    install-server: true
  late-commands:
    - sed -i 's/^#*\(send dhcp-client-identifier\).*$/\1 = hardware;/' /target/etc/dhcp/dhclient.conf
    - 'sed -i "s/dhcp4: true/&\n      dhcp-identifier: mac/" /target/etc/netplan/00-installer-config.yaml'
```

We also need the presence of the file `meta-data`: `touch meta-data` in the
directory available to the Packer HTTP server. The password is `ubuntu`.

The [new unattended installation is well documented][4] and I started from the
[Quick Start guide][5].

There were three things that need solving on top of the basic configuration.
The first was to ensure that there's enough memory to run the installer with.
512MB caused a kernel panic, 2GB seems to work fine. The other two are
enabling `SSH`, and ensuring that we have a persistent IP address after the
installation is completed.

The typical way to do this is to restore the DHCP identifier used back to the
MAC address of the device, rather than the _device identifier_ which is now
common. [This is the same problem as I've seen previously with Debian Buster
(10)][6], and I've reused the late command here to set the DHCP client to do
that. We also seem to need to do this with [netplan][7] too, to reliably get
the same IP back that Packer is expecting.

Interestingly, [subiquity does not seem to support `dhcp-identifier`][8] and
so we need to do this ourselves after the installation is completed. We need to
quote the `sed` line, as otherwise we [fall into a trap when loading
`cloud-init` configuration, as it seems to think it's YAML][9].

This took quite a bit of time to get working right (and this configuration
could perhaps do with a little bit of tidying up, too). To solve issues along
the way, I:

* Used Alt + F2 to get a working `tty`,
* Read the output of `/var/log/installer/subiquity-debug.log` to get the
  network configuration correct,
* and `/var/log/syslog` to debug the YAML parsing issues around the
  `late-commands`.

[1]: https://www.debian.org/devel/debian-installer/
[2]: https://github.com/CanonicalLtd/subiquity
[3]: https://www.packer.io
[4]: https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls
[5]: https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls/QuickStart
[6]: https://github.com/nickcharlton/boxes/commit/5b5d18ba146d081fe4eb4657b246aa6dd544455b
[7]: https://netplan.io/
[8]: https://github.com/CanonicalLtd/subiquity/blob/95c20226fdb74eef6cd780981299a5bbbaa426d2/subiquitycore/controllers/network.py
[9]: https://git.launchpad.net/cloud-init/tree/cloudinit/util.py#n954
