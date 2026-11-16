#!/bin/bash

# Build the shared Arch template every sphere boots from.
#
# Output (atomically replaced, so running spheres keep their open copy):
#   $SPHERIE_DATA/template.qcow2   root filesystem (raw ext4 inside qcow2, no partitions)
#   $SPHERIE_DATA/vmlinuz          kernel for direct boot
#   $SPHERIE_DATA/initramfs.img    initramfs for direct boot
#
# Usage: template/build.sh [--size 12G]

set -euo pipefail

SPHERIE_PATH="${SPHERIE_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SPHERIE_DATA="${SPHERIE_DATA:-/var/lib/spherie}"
SPHERIE_CONF="${SPHERIE_CONF:-/etc/spherie/spheres}"
size="12G"

while (($#)); do
  case "$1" in
    --size)
      size="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if ((EUID != 0)); then
  echo "template/build.sh must run as root" >&2
  exit 1
fi

[[ -d $SPHERIE_CONF ]] || SPHERIE_CONF="$SPHERIE_PATH/spheres"

# Base system plus everything a sphere role needs. No compositor: apps render
# into the host's Hyprland through waypipe.
packages=(
  base linux linux-firmware mkinitcpio sudo
  networkmanager wpa_supplicant nftables dnsmasq tor
  waypipe socat wl-clipboard
  mesa vulkan-swrast ttf-dejavu noto-fonts noto-fonts-emoji
  xdg-utils xdg-desktop-portal-gtk adwaita-icon-theme
  torbrowser-launcher
)

# Each sphere's APPS become template packages. Commands that aren't package
# names can be mapped in default/spherie/app-packages.
declare -A app_packages=()
if [[ -f $SPHERIE_PATH/default/spherie/app-packages ]]; then
  while read -r app pkg; do
    [[ -z $app || $app == \#* ]] && continue
    app_packages[$app]="$pkg"
  done <"$SPHERIE_PATH/default/spherie/app-packages"
fi

for conf in "$SPHERIE_CONF"/*.conf; do
  APPS=""
  # shellcheck source=/dev/null
  source "$conf"
  for app in $APPS; do
    packages+=("${app_packages[$app]:-$app}")
  done
done

mapfile -t packages < <(printf '%s\n' "${packages[@]}" | sort -u)

mkdir -p "$SPHERIE_DATA"
work=$(mktemp -d "$SPHERIE_DATA/.build.XXXXXX")
mnt="$work/mnt"
raw="$work/root.raw"
mkdir -p "$mnt"

cleanup() {
  mountpoint -q "$mnt" && umount -R "$mnt"
  rm -rf "$work"
}
trap cleanup EXIT

truncate -s "$size" "$raw"
mkfs.ext4 -q -L spherie-root "$raw"
mount -o loop "$raw" "$mnt"

pacstrap -K -c "$mnt" "${packages[@]}"

# Guest-side spherie files: agent, gui bridge, role setup.
cp -a "$SPHERIE_PATH/template/rootfs/." "$mnt/"
install -d "$mnt/usr/local/lib/spherie/roles"
install -m 755 "$SPHERIE_PATH"/template/roles/*.sh "$mnt/usr/local/lib/spherie/roles/"

arch-chroot "$mnt" /bin/bash -euo pipefail <<'CHROOT'
# One unprivileged user; /home is the sphere's own persistent disk.
useradd -m -u 1000 -G wheel -s /bin/bash user
passwd -d user
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >/etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

# Start user@1000 at boot without a login so /run/user/1000 exists.
install -d /var/lib/systemd/linger
touch /var/lib/systemd/linger/user

cat >/etc/fstab <<FSTAB
/dev/vda  /      ext4  rw,noatime                     0 1
/dev/vdb  /home  ext4  rw,noatime,nofail,x-systemd.makefs,x-systemd.device-timeout=5s  0 2
FSTAB

# Direct kernel boot: only virtio modules are needed in the initramfs.
cat >/etc/mkinitcpio.conf <<MKINIT
MODULES=(virtio_pci virtio_blk virtio_net ext4)
HOOKS=(base udev modconf block filesystems fsck)
MKINIT
cat >/etc/mkinitcpio.d/linux.preset <<PRESET
ALL_kver="/boot/vmlinuz-linux"
PRESETS=('default')
default_image="/boot/initramfs-linux.img"
PRESET
mkinitcpio -P

ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo 'en_US.UTF-8 UTF-8' >/etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' >/etc/locale.conf

systemctl enable spherie-role.service spherie-agent.service spherie-gui-bridge.service NetworkManager.service
systemctl mask systemd-firstboot.service
CHROOT

install -m 644 "$mnt/boot/vmlinuz-linux" "$work/vmlinuz"
install -m 644 "$mnt/boot/initramfs-linux.img" "$work/initramfs.img"
umount -R "$mnt"

qemu-img convert -O qcow2 "$raw" "$work/template.qcow2"

# Rename into place so running spheres keep the inode they opened.
for file in template.qcow2 vmlinuz initramfs.img; do
  mv -f "$work/$file" "$SPHERIE_DATA/$file"
done

echo "Template built in $SPHERIE_DATA"
