---
title: Providing Internal DNS with OS X Server
published: 2015-07-06T14:20:00Z
tags: osx, server, dns
---

Picture the scene: You've got a hosted Mac somewhere on the internet, you
connect to it via a VPN to access the services you host on it, but you'd like
to use domains to refer to these and have them look up correctly.

The solution to this (and to a bunch of similar problems) is to configure a DNS
server internally to handle look ups for you. It'll return internal-relevant
IPs for domains (which could in this case be anything).

This is basically a much more specific version of [Apple's "Provide DNS
service" article][apple_dns_docs].

During these steps, you'll need to:

* Configure a forwarding server to route requests outside of the local network.
* Set the lookup behavior to serve the local network.
* Configure the VPN to provide the DNS server in it's configuration.
* Add a relevant zone.
* Add the names and aliases needed to that zone.

### Configure Forwarding Servers

It's assumed you'll configure this with whichever the upstream ISP provides.
You can do this in Server.app's DNS section under forwarding servers. They
might well already be pre-populated.

### Configure Lookup Behavior

The lookup behavior defines which networks the DNS server will be available to.
You'll want to configure both "The server itself" and "Clients on the local
network" as the screenshot below shows:

<figure>
  <img src="/resources/images/osx_server_dns_lookups.png"
  alt="DNS Server Lookup Behavior" max-width="500px">
  <figcaption>DNS Server Lookup Behavior</figcaption>
</figure>

### Configure the VPN DNS Settings

Next, switch to the VPN service and configure the local DNS server:

<figure>
  <img src="/resources/images/osx_server_vpn_dns_settings.png"
  alt="VPN DNS Settings" max-width="500px">
  <figcaption>VPN DNS Settings</figcaption>
</figure>

(Assuming `10.0.0.1` is the local server IP.)

### Create a Zone & Configure it

Switch back to the DNS Service. First, check "Show All Records" in the cog
dropdown. Then, "Add Primary Zone":

<figure>
  <img src="/resources/images/osx_server_dns_primary_zone.png"
  alt="Adding the Primary Zone" max-width="500px">
  <figcaption>Adding the Primary Zone</figcaption>
</figure>

Next, add an A record by selecting "Add Machine Record":

<figure>
  <img src="/resources/images/osx_server_dns_a_record.png"
  alt="Adding an A record" max-width="500px">
  <figcaption>Adding an A record</figcaption>
</figure>

### Testing

Finally, you can test that this all worked by using `dig`. On a device
connected to the VPN you should get a result like the following:

```
$ dig test.example.com

; <<>> DiG 9.8.3-P1 <<>> test.example.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 42105
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 0

;; QUESTION SECTION:
;test.example.com.      IN  A

;; ANSWER SECTION:
test.example.com.   10800   IN  A   10.0.0.1

;; AUTHORITY SECTION:
example.com.        10800   IN  NS  test.example.com.

;; Query time: 153 msec
;; SERVER: 10.0.0.1#53(10.0.0.1)
;; WHEN: Mon Jul  6 10:34:46 2015
;; MSG SIZE  rcvd: 64
```

If you get no result (or it forwards up to the external `example.com` zone, you
won't see your internal IP listed. This would suggest that the DNS server isn't
specified correctly, or one of the other steps didn't quite work right.

[apple_dns_docs]: https://help.apple.com/advancedserveradmin/mac/4.0/#/apd1E0474ED-5AD9-4463-A37C-0307042475D7
