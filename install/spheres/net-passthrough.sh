# Hand every physical NIC to the net sphere: vfio-pci claims them at boot,
# so after the next reboot the host has no network device of its own.
# Set SPHERIE_NET_PASSTHROUGH=0 to keep the NIC on the host (dev fallback).

if [[ ${SPHERIE_NET_PASSTHROUGH:-1} == "1" ]]; then
  pci_addrs=()
  pci_ids=()

  for dev in /sys/class/net/*/device; do
    [[ -e $dev ]] || continue
    [[ $(readlink -f "$dev/subsystem") == */bus/pci ]] || continue
    addr=$(basename "$(readlink -f "$dev")")
    pci_addrs+=("$addr")
    pci_ids+=("$(<"$dev/vendor"):$(<"$dev/device")")
  done

  if (( ${#pci_addrs[@]} )); then
    pci_ids=("${pci_ids[@]//0x/}")
    ids=$(printf '%s\n' "${pci_ids[@]}" | sort -u | paste -sd,)

    sudo tee /etc/modprobe.d/spherie-vfio.conf >/dev/null <<CONF
# Spherie: physical NICs belong to the net sphere.
options vfio-pci ids=$ids
CONF

    # Load vfio-pci from the initramfs so it claims the NICs before their drivers.
    sudo tee /etc/mkinitcpio.conf.d/spherie-vfio.conf >/dev/null <<'CONF'
MODULES+=(vfio_pci vfio vfio_iommu_type1)
CONF

    sudo sed -i "s|^VFIO=.*|VFIO=\"${pci_addrs[*]}\"|" /etc/spherie/spheres/net.conf
  fi
fi
