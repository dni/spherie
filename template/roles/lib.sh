# Shared helpers for role scripts. The host gives every sphere NIC a MAC of
# 52:54:00:5e:<cid>:<index>, index 00 = uplink, 01 = the LAN it serves.

iface_by_mac_suffix() {
  local dev
  for dev in /sys/class/net/*; do
    if [[ $(<"$dev/address") == 52:54:00:5e:*:$1 ]]; then
      basename "$dev"
      return
    fi
  done
}

# Keep NetworkManager off the LAN side; this role configures it statically.
unmanage() {
  install -d /etc/NetworkManager/conf.d
  cat >/etc/NetworkManager/conf.d/spherie-lan.conf <<CONF
[keyfile]
unmanaged-devices=interface-name:$1
CONF
}
