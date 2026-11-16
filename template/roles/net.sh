#!/bin/bash

# net: NetworkManager drives the uplink (passed-through NIC or the dev
# fallback tap). The LAN side (br-net) gets 10.137.0.1/24, DHCP + DNS and NAT.

set -euo pipefail
source /usr/local/lib/spherie/roles/lib.sh

lan=$(iface_by_mac_suffix 01)
[[ -n $lan ]] || { echo "net: no LAN interface" >&2; exit 1; }

unmanage "$lan"

# Dev fallback without VFIO: the uplink is a host tap with a fixed /30.
if grep -qw spherie.devuplink=1 /proc/cmdline; then
  uplink=$(iface_by_mac_suffix 00)
  install -d -m 700 /etc/NetworkManager/system-connections
  cat >/etc/NetworkManager/system-connections/spherie-uplink.nmconnection <<CONF
[connection]
id=spherie-uplink
type=ethernet
interface-name=$uplink

[ipv4]
method=manual
address1=10.136.0.2/30,10.136.0.1
dns=9.9.9.9;

[ipv6]
method=disabled
CONF
  chmod 600 /etc/NetworkManager/system-connections/spherie-uplink.nmconnection
fi
ip link set "$lan" up
ip addr replace 10.137.0.1/24 dev "$lan"
sysctl -q -w net.ipv4.ip_forward=1
sysctl -q -w net.ipv6.conf.all.disable_ipv6=1

cat >/etc/dnsmasq.d/spherie.conf <<CONF
interface=$lan
bind-interfaces
dhcp-range=10.137.0.10,10.137.0.250,12h
dhcp-option=option:router,10.137.0.1
dhcp-option=option:dns-server,10.137.0.1
CONF
grep -q '^conf-dir=/etc/dnsmasq.d' /etc/dnsmasq.conf || echo 'conf-dir=/etc/dnsmasq.d/,*.conf' >>/etc/dnsmasq.conf

nft -f - <<NFT
flush ruleset
table inet spherie {
  chain input {
    type filter hook input priority 0; policy drop;
    iif lo accept
    ct state established,related accept
    iifname "$lan" udp dport { 53, 67 } accept
    iifname "$lan" tcp dport 53 accept
  }
  chain forward {
    type filter hook forward priority 0; policy drop;
    ct state established,related accept
    iifname "$lan" oifname != "$lan" accept
  }
  chain postrouting {
    type nat hook postrouting priority 100;
    iifname "$lan" oifname != "$lan" masquerade
  }
}
NFT

systemctl start dnsmasq.service --no-block
