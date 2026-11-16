# Host side of spherie: a locked service user that runs the sphere VMs, the
# sphere definitions, vsock/VFIO device access and the isolated bridges.

id spherie &>/dev/null || sudo useradd --system --home-dir /var/lib/spherie --shell /usr/bin/nologin --groups kvm spherie

sudo install -d -o spherie -g spherie -m 750 /var/lib/spherie /var/lib/spherie/home

# Ship the defaults once; after that /etc/spherie/spheres belongs to the user.
sudo install -d -m 755 /etc/spherie/spheres
for conf in "$OMARCHY_PATH"/spheres/*.conf; do
  [[ -f /etc/spherie/spheres/$(basename "$conf") ]] || sudo install -m 644 "$conf" /etc/spherie/spheres/
done

sudo install -Dm644 "$OMARCHY_PATH/default/udev/spherie.rules" /etc/udev/rules.d/70-spherie.rules
echo vhost_vsock | sudo tee /etc/modules-load.d/spherie.conf >/dev/null

# Units point at the packaged commands; rewrite them for a dev-linked checkout.
for unit in "$OMARCHY_PATH"/default/systemd/system/spherie*.service "$OMARCHY_PATH"/default/systemd/user/spherie*.service; do
  scope=$(basename "$(dirname "$unit")")
  sed -e "s|/usr/bin/omarchy-sphere-|$OMARCHY_PATH/bin/omarchy-sphere-|g" \
    -e "s|OMARCHY_PATH=/usr/share/omarchy|OMARCHY_PATH=$OMARCHY_PATH|g" "$unit" |
    sudo install -Dm644 /dev/stdin "/etc/systemd/$scope/$(basename "$unit")"
done
sudo systemctl daemon-reload
sudo systemctl enable spherie-bridges.service spherie@net.service spherie@tor.service
sudo systemctl --global enable spherie-guid.service
