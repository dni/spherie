#!/bin/bash

# tor: uplink is a DHCP client of net. The LAN side (br-anon) gets
# 10.138.0.1/24. Every TCP connection from anon goes into Tor's TransPort,
# DNS into Tor's DNSPort, and everything else is dropped. No IP forwarding.

set -euo pipefail
source /usr/local/lib/spherie/roles/lib.sh

lan=$(iface_by_mac_suffix 01)
[[ -n $lan ]] || { echo "tor: no LAN interface" >&2; exit 1; }

unmanage "$lan"
ip link set "$lan" up
ip addr replace 10.138.0.1/24 dev "$lan"
sysctl -q -w net.ipv4.ip_forward=0
sysctl -q -w net.ipv6.conf.all.disable_ipv6=1

cat >/etc/tor/torrc <<CONF
User tor
DataDirectory /var/lib/tor
TransPort 10.138.0.1:9040 IsolateClientAddr IsolateDestAddr
DNSPort 10.138.0.1:5353
VirtualAddrNetworkIPv4 10.192.0.0/10
AutomapHostsOnResolve 1
CONF

# DHCP only (port=0 disables dnsmasq's DNS); DNS answers come from Tor.
cat >/etc/dnsmasq.d/spherie.conf <<CONF
interface=$lan
bind-interfaces
port=0
dhcp-range=10.138.0.10,10.138.0.250,12h
dhcp-option=option:router,10.138.0.1
dhcp-option=option:dns-server,10.138.0.1
CONF
grep -q '^conf-dir=/etc/dnsmasq.d' /etc/dnsmasq.conf || echo 'conf-dir=/etc/dnsmasq.d/,*.conf' >>/etc/dnsmasq.conf

nft -f - <<NFT
flush ruleset
table inet spherie {
  chain prerouting {
    type nat hook prerouting priority -100;
    iifname "$lan" udp dport 53 redirect to :5353
    iifname "$lan" tcp dport 53 redirect to :5353
    iifname "$lan" meta l4proto tcp redirect to :9040
  }
  chain input {
    type filter hook input priority 0; policy drop;
    iif lo accept
    ct state established,related accept
    iifname "$lan" tcp dport 9040 accept
    iifname "$lan" udp dport { 5353, 67 } accept
  }
  chain forward {
    type filter hook forward priority 0; policy drop;
  }
}
NFT

systemctl start tor.service dnsmasq.service --no-block
