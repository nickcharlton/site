---
title: Setting up Transparent Proxying VMs for mitmproxy
published: 2015-03-28 22:29:31 +0000
tags: vmware, transparent-proxy, mitmproxy
---

I seem to do a lot with Virtual Machines and this was no different. I'd started
out trying to reverse engineer an otherwise undocumented section of a client
for a hosting service I use and I was keen on configuring an isolated
environment for it.

[mitmproxy][] is a tool for intercepting HTTP and HTTPS traffic and then
allowing you to easily inspect it. In transparent proxy mode, it can sit at the
network level and intercept everything without any other configuration.

There's a few steps to it, and it seemed worth documenting:

## 1. Configure Two VMs

The first thing to do is to configure two VMs. I used a [Ubuntu][] 14.04 LTS
install for the server and an [Xubuntu][] (also 14.04 LTS) for the client. I
wanted a GUI on the client (for a web browser) and I had an Xubuntu ISO lying
around.

You'll want to install the virtual machine tools, too. ([boxes][] has a script
which might help). I named the server `proxy-server` and the client
`proxy-client`. Otherwise they're very standard configurations.

## 2. Setup the Proxy Server

The proxy server will need two network interfaces, one to the outside world
(the default `eth0`) and another for clients to connect on (`eth1`).

You'll need to add a second network interface to the VM itself, with the new
one configured to be "internal only". This sets up an isolated network on the
host machine which the VMs are able to communicate through.

Once the virtual adaptor is added, we'll configure that with a static IP:

Edit `/etc/network/interfaces`:

```
# Proxy Server network interface
auto eth1
iface eth1 inet static
address 192.168.3.1
netmask 255.255.255.0
gateway 0.0.0.0
```

Then bring it up: `sudo ifup eth1`. You can verify it worked by checking the
response of `ifconfig -a`. To understand what's going on, you might find the
[Ubuntu Documentation article on Network Configuration][doc_net_config]
helpful.

The next step is to configure `dnsmasq` to provide us with DHCP and DNS on our
internal network. First install it: `sudo apt-get install dnsmasq`

Then replace `/etc/dnsmasq.conf` with:

```
# Listen for DNS requests on the internal network
interface=eth1
# Act as a DHCP server, assign IP addresses to clients
dhcp-range=192.168.3.10,192.168.3.100,96h
# Broadcast gateway and dns server information
dhcp-option=option:router,192.168.3.1
dhcp-option=option:dns-server,192.168.3.1
```

The final step is to configure `iptables` to forward incoming traffic on ports
80 and 443 to our `mitmproxy` instance:

```
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 \
    -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 443 \
    -j REDIRECT --to-port 8080
```

Then we can install and open `mitmproxy` in transparent mode:

```
$ mitmproxy -T --host
```

(`-T` enables transparent proxy mode, `--host` infers the hostname of the
request and displays that instead of the IP.)

## 3. Configure the Client

The client will need pointing to the correct network, and then the `mitmproxy`
certificates installed. Technically, installing the root CA for `mitmproxy` is
optional, but without it you'll get a lot of SSL warnings you need to jump
through.

First, the network:

1. Reconfigure the client's network adaptor to be "internal only".
2. Set the network configuration to look like (through either the GUI or a
   similar method to above):

```
Address: 192.168.3.10
Subnet: 255.255.255.0
Gateway: 192.168.3.1
DNS: 192.168.3.1
```

You'll then want to test it all works. A non-HTTPS web page is likely the
easiest.

Finally, add the generated `mitmproxy` CA root certificate. `mitmproxy`
generates these on first run, so you'll want to take these from the
`~/.mitmproxy` directory on the host. You're looking for
`mitmproxy-ca-cert.cer`.

Take this from the proxy server and place it on the client. You'll then want to
[make the certificate known to the OS][se_ubuntu_ca]:

```sh
sudo mitmproxy-ca-cert.cer /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt
sudo update-ca-certifcates
```

(Note, as part of this, it's renamed to have more usual `crt` extension, which
`update-certificates` will pick up.)

In the response you should see that a certificate was added. You can test this
all worked by doing something like: `wget https://nickcharlton.net`. The
response should show up in your `mitmproxy` window.

Firefox maintains it's own certificate store and so you'll want to add this in
in Preferences → Advanced → Certificates. Just add the `mitmproxy-ca-cert.cer`
file as an authority.

## 4. Begin Making Requests

You'll now be able to make requests, both through a terminal or in a browser.

For example, `wget https://nickcharlton.net` should give you something that
looks like the next two screenshots:

<figure>
  <img src="/resources/images/mitmproxy-host-list.png" alt="mitmproxy Host
  List" max-width="500px">
  <figcaption>mitmproxy Host List.</figcaption>
</figure>

<figure>
  <img src="/resources/images/mitmproxy-response.png" alt="mitmproxy Response"
  max-width="500px">
  <figcaption>mitmproxy Response.</figcaption>
</figure>

Some of the details of this post [comes from the `mitmproxy`
documentation][docs], but threaded out with a bit more detail that I'd needed
to understand to get it all working. Now hopefully you'll be able to replicate
a similar setup.

[mitmproxy]: http://mitmproxy.org
[Ubuntu]: http://www.ubuntu.com
[Xubuntu]: http://xubuntu.org
[boxes]: https://github.com/nickcharlton/boxes
[doc_net_config]: https://help.ubuntu.com/lts/serverguide/network-configuration.html
[se_ubuntu_ca]: http://askubuntu.com/a/377570
[docs]: http://mitmproxy.org/doc/tutorials/transparent-dhcp.html
