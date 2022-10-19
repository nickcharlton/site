---
title: "Configuring VMware ESXi 6 on Hetzner"
tags: vmware esxi hetzner
---

[Hetzner][] are a relatively low-cost hosting provider based out of Germany.
They provide a range of powerful but cheap dedicated servers which make a good
platform for experimenting with [VMWare ESXi][] or other virtualisation
software.

However, their networking is based around statically routing MAC addresses
which makes it both a bit different to more common VLAN setups and harder to
get up and running. They do have a [canonical guide to configuring this][], but
I found my knowledge of networking a lacking from what it assumes and so I
found it a little hard to follow and caught myself in a few traps, so I thought
I'd write up some notes.

## Prerequisites

After you've ordered your dedicated server, go into [Robot][] and order your
desired subnet. When doing this, you'll first want to request a standalone
"additional IP" and then have the subnet (of any size you'll use) statically
routed to it. You may wish to mention it's for ESXi here to make this clear.

ESXi doesn't support routing out of the box, so we'll use the additional IP on
a router VM to provide a gateway for our subnet.

## Installing ESXi 6

If you've already done the IP configuration, or whilst you wait you can proceed
to install (or jump to the next section if you've done this).

Using the [LARA][] console, mount the most recent available version of ESXi
that you can. I used
`VMware-VMvisor-Installer-6.0.0.update02-3620759.x86_64.iso`, which is
available under `bootimages/vmware`

I'd recommend avoiding passwords with special characters as these didn't seem
to pass through on my first attempt and I needed to re-install to get root
access.

## Configuring Networking

### IP Addressing

We should now have two standalone IP addresses and a subnet. Let's use these as
an example:

* Main IP: `140.201.25.139`
* Additional IP: `140.201.300.61`
* Subnet: `140.201.2.32/28`

The subnet has usable addresses from: `140.201.2.33` to `140.201.2.47`, so
`.32` defines the network and `.47` is the broadcast address.

I've used the first usable IP as the gateway for all of the VMs (the second IP
configured below in the router). Partly this is because this IP will be
pre-filled out by the Debian installer.

We'll then be able to create 12 VMs with public IP addresses, once we account
for those we'll need to create to get it working.

### Router VM

When you first login to ESXi, you'll find there are two networks. One is the
"Management Network" and the other is the "VM Network". The "Management
Network" relates to the initial IP that was configured with your server. The
"VM Network" is the network available to VMs on this. We'll not quite be able
to use this directly.

To use our subnet, we'll want to create a new vSwitch and Port Group. Under
"Networking", create a new vSwitch (I called mine `subnet0`) and a Port Group
to go with it (I called mine `Subnet 0`). We'll create a router VM which acts
as a gateway between this network and the "VM Network".

<figure>
  <img src="/resources/images/subnet0_network_topology.png"
  alt="Subnet 0 Network Topology" max-width="500px">
  <figcaption>Subnet 0 Network Topology</figcaption>
</figure>

To do this, create a new VM (I'm using Debian 8, configured with 512MB RAM and
a 32GB disk image) using the "VM Network" which came by default. You should
manually set the MAC address to the one provided inside [Robot][] for the
"additional IP". DHCP will work and so the installer should autoconfigure
networking.

Once this is up and running, shut it down and add a new network adapter. This
should be connected to the subnet you created above. All other settings can be
the default. Bring the VM back up and configure `/etc/networks/interfaces` to
look something like this:

```
auto eth0
iface eth0 inet static
  address 140.201.300.61
  gateway 140.201.300.57
  netmask 255.255.255.248
  dns-nameservers 213.133.98.98 213.133.99.99

auto eth1
iface eth1 inet static
  address 140.201.2.33
  netmask 255.255.255.240
```

The `eth1` network needs neither a gateway (because we're the gateway for the
network) or nameservers (we'll be passing packets over without much interest).

Finally for the router VM, configure IP forwarding so that packets will travel
through the router:

```
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
```

You can persist this by adding:

```
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
```

to ` /etc/sysctl.conf`.

Now you can create a VM using one of your subnet IPs. Specify the IP address
and netmask, then the gateway IP as the one on the router connected to our
subnet vSwitch (`140.201.2.33` in this case). Your configuration will look
something like this:

```
auto eth0
iface eth0 inet static
  address 140.201.2.34
  gateway 140.201.2.33
  netmask 255.255.255.240
  dns-nameservers 213.133.98.98 213.133.99.99
```

### Further Subnets

This isn't something I've yet tried, but if you wanted to configure a second
(or third, etc.) subnet you'd go about this in a similar manner.

1. Get the new subnet routed onto the "additional IP".
2. Create another vSwitch and Port Group (perhaps, `subnet1`).
3. Add another network adapter to the router VM.
4. Connect this new network adapter to the new vSwitch.
5. Configure VMs in the same way.

You should now be able to bring up additional VMs and use the rest of your
assigned subnet!

[Hetzner]: https://hetzner.de
[VMware ESXi]: http://www.vmware.com/products/vsphere-hypervisor.html
[canonical guide to configuring this]: https://wiki.hetzner.de/index.php/VMware_ESXi/en
[Robot]: https://robot.your-server.de/server
[LARA]: https://wiki.hetzner.de/index.php/LARA/en
[esxi_wiki]: https://wiki.hetzner.de/index.php/VMware_ESXi/en
[vmware_thread]: https://communities.vmware.com/thread/397755
[dns]: https://wiki.hetzner.de/index.php/Hetzner_Standard_Name_Server/en
