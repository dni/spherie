# Build the sphere template now, while the host still has network. If this
# fails (offline install), run `omarchy sphere build-template` later.

if [[ ! -f /var/lib/spherie/template.qcow2 ]]; then
  sudo SPHERIE_DATA=/var/lib/spherie "$OMARCHY_PATH/template/build.sh" ||
    echo "Sphere template not built; run: omarchy sphere build-template"
  sudo chown spherie:spherie /var/lib/spherie/template.qcow2 /var/lib/spherie/vmlinuz /var/lib/spherie/initramfs.img 2>/dev/null || true
fi
