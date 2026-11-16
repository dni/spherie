# Turn the IOMMU on so devices (the NIC first) can be handed to a sphere.

if omarchy-hw-x86; then
  sudo mkdir -p /etc/limine-entry-tool.d
  sudo tee /etc/limine-entry-tool.d/spherie-iommu.conf >/dev/null <<'CONF'
# Spherie: IOMMU for VFIO device passthrough to spheres
KERNEL_CMDLINE[default]+=" intel_iommu=on amd_iommu=on iommu=pt"
CONF
fi
