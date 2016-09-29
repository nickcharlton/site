---
title: "Building Virtual Machines with Packer on ESXi 6"
published: 2016-12-03T12:29:46-05:00
tags: packer esxi virtualization
---

Over the past couple of weeks, I've been building up a box running ESXi 6 to
host a bunch of virtual machines. I [documented the initial configuration in a
previous post][hetzner_post], but this goes further and attempts to automate
much of this using [Packer][]. My end goal is to have the complete
configuration held in a repository to make rebuilding (or adding new boxes) as
painless as possible and also to provide an example for others implementing
something similar.

I've put together a [(public) repository][repo] which contains templates for
set of base images which can be cloned to speed up provisioning new VMs. These 
templates assume you're able to acquire an IP via DHCP.

## Configuring the ESXi Host

Our ESXi host needs a little bit of configuration to allow Packer to work.
Packer communicates over SSH, so first we need to open that. Secondly, we'll
enable an option to discover Guest IPs from the Host and then finally allow VNC
connections remotely.

### Enable SSH

Inside the web UI, navigate to "Manage", then the "Services" tab. Find the
entry called: "TSM-SSH", and enable it.

You may wish to enable it to start up with the host by default. You can do this
inside the "Actions" dropdown (it's nested inside "Policy").

### Enable "Guest IP Hack"

Run the following command on the ESXi host:

```sh
esxcli system settings advanced set -o /Net/GuestIPHack -i 1
```

This allows Packer to infer the guest IP from ESXi, without the VM needing to
report it itself.

### Open VNC Ports on the Firewall

Packer connects to the VM using VNC, so we'll [open a range of
ports][vmware_firewall] to allow it to connect to it.

First, ensure we can edit the firewall configuration:

```sh
chmod 644 /etc/vmware/firewall/service.xml
chmod +t /etc/vmware/firewall/service.xml
```

Then append the range we want to open to the end of the file:

```xml
<service id="1000">
  <id>packer-vnc</id>
  <rule id="0000">
    <direction>inbound</direction>
    <protocol>tcp</protocol>
    <porttype>dst</porttype>
    <port>
      <begin>5900</begin>
      <end>6000</end>
    </port>
  </rule>
  <enabled>true</enabled>
  <required>true</required>
</service>
```

Finally, restore the permissions and reload the firewall:

```sh
chmod 444 /etc/vmware/firewall/service.xml
esxcli network firewall refresh
```

## Running Packer

A Packer template for running on ESXi is very similar to one which runs
locally, but we're not able to use the built-in HTTP server and we specify the
host on which it runs. Here's an example using Ubuntu 16.04, with a
`preseed.cfg` provided by mounting a floppy:

`variables.json`:

```json
{
  "esxi_host": "",
  "esxi_datastore": "primary",
  "esxi_username": "",
  "esxi_password": ""
}
```

`ubuntu-1604-base.json`:

```json
{
  "builders": [{
    "name": "ubuntu-1604-base",
    "vm_name": "ubuntu-1604-base",
    "type": "vmware-iso",
    "guest_os_type": "ubuntu-64",
    "tools_upload_flavor": "linux",
    "headless": false,

    "iso_url": "http://releases.ubuntu.com/xenial/ubuntu-16.04-server-amd64.iso",
    "iso_checksum": "b8b172cbdf04f5ff8adc8c2c1b4007ccf66f00fc6a324a6da6eba67de71746f6",
    "iso_checksum_type": "sha256",

    "ssh_username": "nullgrid",
    "ssh_password": "nullgrid",
    "ssh_timeout": "15m",

    "disk_type_id": "thin",

    "floppy_files": [
      "preseed/ubuntu.cfg"
    ],

    "boot_command": [
      "<enter><wait><f6><esc><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
      "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
      "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
      "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
      "/install/vmlinuz noapic ",
      "preseed/file=/floppy/ubuntu.cfg ",
      "debian-installer=en_US auto locale=en_US kbd-chooser/method=us ",
      "hostname={{ .Name }} ",
      "fb=false debconf/frontend=noninteractive ",
      "keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA ",
      "keyboard-configuration/variant=USA console-setup/ask_detect=false ",
      "grub-installer/bootdev=/dev/sda ",
      "initrd=/install/initrd.gz -- <enter>"
    ],

    "shutdown_command": "echo 'shutdown -P now' > shutdown.sh; echo 'nullgrid'|sudo -S sh 'shutdown.sh'",

    "remote_type": "esx5",
    "remote_host": "{{user `esxi_host`}}",
    "remote_datastore": "{{user `esxi_datastore`}}",
    "remote_username": "{{user `esxi_username`}}",
    "remote_password": "{{user `esxi_password`}}",
    "keep_registered": true,

    "vmx_data": {
      "ethernet0.networkName": "VM Network"
    }
  }]
}
```

`preseed.cfg`:

```conf
#
# Based upon: https://help.ubuntu.com/12.04/installation-guide/example-preseed.txt
#

# localisation
d-i debian-installer/locale string en_US.utf8
d-i console-setup/ask_detect boolean false
d-i keyboard-configuration/layoutcode string us

# networking
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string unassigned-hostname
d-i netcfg/get_domain string unassigned-domain
d-i netcfg/wireless_wep string

# apt mirrors
d-i mirror/country string manual
d-i mirror/http/hostname string archive.ubuntu.com
d-i mirror/http/directory string /ubuntu
d-i mirror/http/proxy string

# clock and time zone
d-i clock-setup/utc boolean true
d-i time/zone string GMT
d-i clock-setup/ntp boolean true

# partitioning
d-i partman-auto/method string lvm
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
# fix: http://serverfault.com/questions/189328/ubuntu-kickstart-installation-using-lvm-waits-for-input
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto-lvm/guided_size string max
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# users
d-i passwd/user-fullname string Null Grid
d-i passwd/username string nullgrid
d-i passwd/user-password password nullgrid
d-i passwd/user-password-again password nullgrid
d-i user-setup/allow-password-weak boolean true
d-i user-setup/encrypt-home boolean false

# packages
tasksel tasksel/first multiselect standard, ubuntu-server
d-i pkgsel/install-language-support boolean false
d-i pkgsel/include string openssh-server nfs-common curl git-core
d-i pkgsel/upgrade select full-upgrade
d-i pkgsel/update-policy select none
postfix postfix/main_mailer_type select No configuration

# boot loader
d-i grub-installer/only_debian boolean true

# hide the shutdown notice
d-i finish-install/reboot_in_progress note
```

It can be run like so:

```sh
packer build -var-file variables.json ubuntu-1604-base.json
```

The [packer-esxi][repo] repo contains a much more comprehensive example, which
I'd suggest cloning and using. The Debian example foregoes the floppy and
instead fetches a file from [Amazon S3][] as the installer no longer supports
fetching the preseed from a floppy.

I'm using these templates to provide a base image, which I clone and configure
to their needs. This is pretty similar to cloud providers like [AWS EC2][] or
[Digital Ocean][].

[hetzner_post]: https://nickcharlton.net/posts/configuring-esxi-6-on-hetzner.html
[Packer]: https://packer.io
[repo]: https://github.com/nickcharlton/packer-esxi
[vmware_firewall]: https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2008226
[Amazon S3]: http://aws.amazon.com/s3
[AWS EC2]: https://aws.amazon.com/ec2/
[Digital Ocean]: https://m.do.co/c/6ff4dddb5e9d
