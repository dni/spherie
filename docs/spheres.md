# Spheres

Spherie is Omarchy with Qubes-style isolation built from plain KVM. The host runs Hyprland and nothing else. Every part of your life runs in its own sphere: a small Arch VM whose windows show up on the host desktop with the sphere's border color and a `[sphere]` title prefix.

| Sphere | Network | Purpose |
| --- | --- | --- |
| `net` | owns the physical NIC (VFIO) | routes and NATs for everyone, Wi-Fi setup |
| `tor` (hidden) | through `net` | transparent Tor gateway for `anon` |
| `personal` | through `net` | personal browsing, mail |
| `work` | through `net` | work apps |
| `vault` | none | passwords, keys, documents |
| `anon` | only through `tor` | Tor Browser |

## Layout

- `spheres/*.conf` - default sphere definitions, installed once to `/etc/spherie/spheres/`
- `template/build.sh` - builds the shared Arch template (`/var/lib/spherie/template.qcow2`, `vmlinuz`, `initramfs.img`)
- `template/rootfs/` - files copied into the template: the vsock agent, the GUI bridge and the role unit
- `template/roles/` - per-role setup run at boot (`net.sh`, `tor.sh`)
- `default/spherie/lib.sh` - shared shell helpers for `omarchy-sphere-*`
- `default/systemd/system/spherie@.service` - one VM per sphere, run as the `spherie` user
- `default/systemd/user/spherie-guid.service`, `spherie-gui@.service` - GUI routing on the desktop
- `default/hypr/spheres.lua` - border colors, tags and `Super + D` for the sphere app menu
- `install/spheres/` - host setup leaves sourced by `omarchy-apply-system`

## Disks

Every sphere boots the same template with `snapshot=on`, so its root filesystem resets on every boot. `/home` is the sphere's own `home/<sphere>.qcow2`, which persists and is formatted on first boot. To install software for every sphere, add it to a sphere's `APPS` (or `template/build.sh`) and rebuild, or run `omarchy sphere update` for upgrades.

`omarchy sphere update` boots the template writable, as the `template` sphere on `br-net`, runs `pacman -Syu`, copies the kernel and initramfs out, and renames the new image into place. Running spheres keep the image they opened until they restart.

## Network

`br-net` and `br-anon` are host bridges with no address and IPv6 disabled. Every sphere's port is isolated, so spheres can only talk to the gateway port (`net` on `br-net`, `tor` on `br-anon`), never to each other. NIC MACs encode the CID: `52:54:00:5e:<cid>:00` is a sphere's uplink and `:01` is the LAN it serves.

At install, `install/spheres/net-passthrough.sh` binds every physical NIC to `vfio-pci` and writes its PCI address into `net.conf`. After the reboot the host has no network device. Each NIC must sit alone in its IOMMU group (or with devices you're willing to pass along). Install with `SPHERIE_NET_PASSTHROUGH=0` to keep the NIC on the host. `net` then gets a NATed tap (`10.136.0.0/30`). This mode is for development only, and Omarchy's ufw forward policy may need opening for it.

## GUI

Windows travel over waypipe on vsock:

1. In the sphere, an app runs as `waypipe server`, which connects to `/run/spherie/gui.sock`. `spherie-gui-bridge` forwards that socket to host vsock port 7000.
2. On the host, `omarchy-sphere-guid` accepts the connection, looks up the sphere by the peer CID the kernel reports (the host assigned it), and splices it into that sphere's own `waypipe client` (`omarchy-sphere-gui`).
3. That client adds `[<sphere>] ` to every title, from the moment a window is created, and `default/hypr/spheres.lua` matches the prefix for the border color.

The host talks to a sphere's agent on vsock port 7001: `run`, `file-send`, `file-recv`, `update`, `ping`. Spheres can't open a channel to the host's agent side or to each other.

## Wayland isolation (waypipe-spherie)

Stock waypipe is not a security boundary. Its man page says so: it forwards every protocol the compositor offers, and it forwards messages for protocols it doesn't know about without inspecting them. Through stock waypipe, a sphere could read the clipboard at any time (data-control), screenshot the whole desktop including other spheres (screencopy, image-copy-capture), type into other windows (virtual keyboard), draw unlabeled overlays or fake lock screens (layer-shell, session-lock), and list every window title (foreign-toplevel).

`packaging/waypipe-spherie/` patches waypipe's display side (the host, which is trusted) with three options. `omarchy-sphere-gui` refuses to start without them:

- `--allow-globals` - only the globals in `default/spherie/allowed-globals` are advertised. Binding any other one disconnects the app. Interface names are checked on bind, which is sound because the compositor rejects a bind whose interface doesn't match the global.
- `--title-prefix` now also sets the prefix as the title when a toplevel is created, so a window that never sets a title can't appear unlabeled.
- `--clipboard-owner <sphere>` - every clipboard and drag source a sphere creates gets a hidden `application/x-waypipe-owner-<sphere>` mime type, and markers a sphere supplies itself are stripped. A sphere only receives selections and drags carrying its own marker. Others are delivered as empty, and reading a hidden offer disconnects the app. So copy and paste work inside a sphere, and nothing crosses spheres by focusing a window.
- `--clipboard-arm <file>` - unmarked (host-owned) selections are delivered only while the file contains the sphere's name.

Crossing spheres is explicit, like Qubes, with `omarchy-sphere-clip`:

1. `Super + Alt + C` in the source sphere: the host checks that the selection carries that sphere's marker and stores its text in `$XDG_RUNTIME_DIR/spherie/clipboard`.
2. `Super + Alt + V` in the target sphere: the host arms only the target, takes the selection with `wl-copy`, and deletes its buffer. The target can paste once with `Ctrl + V`.

The focused sphere is found from the window's process, the sphere's waypipe client carrying `--clipboard-owner`, not from its title.

The patch targets waypipe 0.11.3 (commit 2dd232c). It has not been compiled yet, see below.

## Known gaps

- **The waypipe patch is untested.** Building it was not permitted in the environment it was written in. Next: `makepkg` in `packaging/waypipe-spherie`, run waypipe's `meson test`, add protocol tests for the three options in `src/test_proto.rs`, then publish the `waypipe-spherie` package that `install/omarchy-base.packages` now expects.
- Text written to the host clipboard by host-native apps can reach a sphere that was armed earlier. The host is meant to run no user apps.
- Popups (menus, tooltips) have no title and no border. A sphere could draw a large popup, positioned relative to its own window.
- Nothing here has booted on hardware yet. It was written inside a Qubes VM without nested KVM.
- No GPU acceleration in spheres (`--no-gpu`). No USB sphere, no disposable spheres.

## Branding

User-visible text says Spherie: i18n catalogs (all locales), the manual, the menu, hotkey descriptions, CLI help, the boot splash and login theme names, and `logo.txt`. Internal names stay Omarchy's on purpose (`omarchy-*` commands, `OMARCHY_PATH`, `/usr/share/omarchy`, package names, window classes, desktop-file keys), so upstream merges and Omarchy's package repository keep working. The _Learn > Omarchy_ menu entry keeps its name because it opens Omarchy's own online manual. Image assets (`logo.svg`, `icon.png`, Plymouth `logo.png`) and the manual's ISO download link still point to Omarchy.
