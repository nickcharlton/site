---
title: "Setting up an Azure Site-to-Site VPN to a Ubiquiti EdgeRouter through NAT"
tags: azure networking vpn terraform
---

I have a Home Lab with a couple of devices for experiments and testing. It's
set up on a separate physical network — using a [Ubiquiti EdgeRouter X][1] —
but I wanted to connect this to the outside world and get access to public IPs
I could proxy to local services.

A while ago, I started using [Azure][8] for other experiments (because I have a
bunch of credits to use). I've also found the cost of the more basic virtual
machines cheaper than other cloud providers. At the time of writing, [a `B1s`
is £3.19/m][2] on pay-as-you-go and down to £1.20/m reserved for three years)
and importantly, allowed me to allocate the most IPs to a single virtual
machine.

On the Azure side, I'm using a [VPN Gateway][4] associated with a [virtual
network][5]. On the Home Lab side, a Ubiquiti EdgeRouter X behind a [Ubiquiti
Security Gateway][6] (which is doing NAT for my home network). I don't have a
static IP, but it changes infrequently, so this shouldn't be too much of a
problem.

To configure a Site-to-Site VPN, both sides of the connection need to know
about each other. We can't do this with NAT — as NAT hides the devices behind
it — but we can work around this by forwarding the necessary ports for IPSec on
the local side. In some ways, this is a bit of a cop-out solution, but
otherwise, we'd need a Point-to-Site that isn't supported on the lower-end VPN
Gateway.

(I initially started this project by trying to build a custom [VyOS][9] image
and do this using a VyOS VM on the Azure side and the EdgeRouter locally. After
months of on-and-off effort, I got the VM working, but it's challenging to
configure when both sides are behind NAT. I also realised that the lowest-tier
[VPN Gateway worked out to be about £22/m][3], which is fine.)

[For the rest of this article, I've based it on this Ubiquiti help guide, but
using Terraform for the configuration][7]. We'll configure an IKEv1/IPSec VPN
using a shared secret and end up being to connect our local network to virtual
machines running in our Azure virtual network.

## Local Network Adjustments

IPSec uses UDP ports 4500 and 500 over UDP. I configured that in the UniFi
controller to point to the EdgeRouter.

{% picture url: "resources/images/site-to-site-vpn-unifi-port-forward.png"
           alt: "A screenshot showing the UniFi controller, forwarding IPSec ports"
%}
  A screenshot showing the UniFi controller, forwarding IPSec ports
{% endpicture %}

## Configuring the Azure Virtual Network Gateway using Terraform

We need to configure a few things to get this up and running (and this assumes
you already have a resource group (named `rg` here):

```terraform
resource "azurerm_local_network_gateway" "home_lab" {
  name                = "HomeLab"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = "LOCAL_NETWORK_PUBLIC_IP"
  address_space       = ["10.1.0.0/24"] # local network subnet
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "gateway" {
  name                = "Gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "gateway" {
  name                = "Gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                = "Vpn"
  vpn_type            = "PolicyBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "Basic"

  ip_configuration {
    name                          = "Gateway"
    public_ip_address_id          = azurerm_public_ip.gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "home_lab" {
  name                = "HomeLab"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.home_lab.id
  shared_key                 = "SHARED_KEY"
}
```

In the `azurerm_local_network_gateway` resource, we define the local network:
the IP we'll be configuring the VPN to use and what the local network looks
like. `azurerm_virtual_network_gateway` represents the primary resource, and
then `azurerm_virtual_network_gateway_connection` builds the connection to the
local network.

I made up the shared key using `openssl rand -base64 20`, removing
non-alphanumeric characters as these caused the connection to fail to
authenticate. I couldn't tell which side had a problem with it. You probably
want to [keep the secret in a Key Vault][10].

The Virtual Network Gateway will take a decent amount of time to be operational
— it took about 25 minutes most times.

## Configuring the EdgeRouter

Connect over SSH and then in configuration mode:

```
configure
```

Followed by configuring the firewall rules, IKE/ESP groups, then setup the
connection on both sides:

```
set vpn ipsec auto-firewall-nat-exclude enable

set vpn ipsec ike-group FOO0 key-exchange ikev1
set vpn ipsec ike-group FOO0 lifetime 28800
set vpn ipsec ike-group FOO0 proposal 1 dh-group 2
set vpn ipsec ike-group FOO0 proposal 1 encryption aes256
set vpn ipsec ike-group FOO0 proposal 1 hash sha1

set vpn ipsec esp-group FOO0 lifetime 3600
set vpn ipsec esp-group FOO0 pfs disable
set vpn ipsec esp-group FOO0 proposal 1 encryption aes256
set vpn ipsec esp-group FOO0 proposal 1 hash sha1

set vpn ipsec site-to-site peer AZURE_GATEWAY_IP authentication mode pre-shared-secret
set vpn ipsec site-to-site peer AZURE_GATEWAY_IP authentication pre-shared-secret SHARED_KEY
set vpn ipsec site-to-site peer AZURE_GATEWAY_IP connection-type respond
set vpn ipsec site-to-site peer AZURE_GATEWAY_IP description ipsec
set vpn ipsec site-to-site peer AZURE_GATEWAY_IP local-address 0.0.0.0

set vpn ipsec site-to-site peer AZURE_GATEWAY_IP ike-group FOO0
set vpn ipsec site-to-site peer AZURE_GATEWAY_IP tunnel 1 esp-group FOO0
set vpn ipsec site-to-site peer AZURE_GATEWAY_IP tunnel 1 local prefix 10.1.0.0/24
set vpn ipsec site-to-site peer AZURE_GATEWAY_IP tunnel 1 remote prefix 10.0.0.0/22
```

Then:

```
commit ; save
```

Setting the EdgeRouter to listen on `0.0.0.0` rather than the public IP allows
us to work around the public IP not being configured — and helpfully means we
wouldn't need to reconfigure the EdgeRouter when the public IP changes.

## Testing the Connection

After some time, the connection should hopefully be established. Azure will
report back if it doesn't work, and it's possible to view the connection status
on the EdgeRouter by using

```
show vpn status
show vpn sa
```

You can see the connection state in the Azure portal, too:

{% picture url: "resources/images/site-to-site-vpn-azure-connection.png"
           alt: "A screenshot showing the Azure portal, showing the connection status"
%}
  A screenshot showing the Azure portal, showing the connection status
{% endpicture %}


VPNs can be notoriously difficult to debug when they go wrong. I'd start by
checking the configuration on either side, then randomly changing things until
it works, if it doesn't eventually come up. Good luck.

[1]: https://store.ui.com/collections/operator-edgemax-routers/products/edgerouter-x
[2]: https://azure.microsoft.com/en-gb/pricing/details/virtual-machines/linux/
[3]: https://azure.microsoft.com/en-gb/pricing/details/vpn-gateway/
[4]: https://learn.microsoft.com/en-us/azure/vpn-gateway/
[5]: https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview
[6]: https://store.ui.com/products/unifi-security-gateway
[7]: https://help.ui.com/hc/en-us/articles/115012221027-EdgeRouter-Policy-Based-Site-to-Site-IPsec-VPN-to-Azure-IKEv1-IPsec-
[8]: https://azure.microsoft.com
[9]: https://vyos.io
[10]: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
