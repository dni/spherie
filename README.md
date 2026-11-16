# Spherie

Spherie is an Arch Linux desktop that keeps the parts of your life in separate virtual machines called **spheres**. It is a fork of [Omarchy](https://omarchy.org), so you get the same Hyprland desktop, themes, hotkeys and tools, with Qubes-style isolation built in. It does not use Qubes or Xen: the host is Arch with KVM, and every sphere is a small Arch VM.

Each sphere's windows open on the same desktop as everything else. Every window carries its sphere's name in the title and its sphere's color in the border. A compromised browser in `personal` can't read your files in `vault`, see your `work` windows, or read what you copied somewhere else.

> **Status: pre-alpha.** The design and the code are in place, but no sphere has booted on real hardware yet, and the waypipe isolation patch has not been compiled. Don't trust it with anything yet. See [Status](#status).

## Spheres

| Sphere | Border | Network | For |
| --- | --- | --- | --- |
| `net` | red | owns the physical network card | Wi-Fi and Ethernet; routes for everyone else |
| `personal` | yellow | through `net` | your own browsing, mail, chat |
| `work` | blue | through `net` | work apps and accounts |
| `vault` | black | **none** | passwords, keys, documents |
| `anon` | purple | **only through Tor** | Tor Browser |
| `tor` | (hidden) | through `net` | Tor gateway for `anon`; has no windows |

Spheres are defined in plain files in `/etc/spherie/spheres/*.conf`: color, memory, CPUs, network and apps. The defaults live in [`spheres/`](spheres/).

## How it works

```
Host: Arch + Hyprland. No IP address, no browser, no user apps.
 │
 ├─ KVM ── net ───── physical NIC (VFIO) ── internet
 │          │ br-net (isolated ports: spheres only reach net)
 │          ├── personal
 │          ├── work
 │          └── tor ─── br-anon ── anon     (only Tor gets out)
 │
 ├─ KVM ── vault     (no network device)
 │
 └─ vsock ── windows from every sphere → Hyprland, labeled [sphere] with a colored border
```

- **Hardware isolation.** Each sphere is a KVM virtual machine. At install, the network card is handed to the `net` sphere through VFIO. After that the host has no network device, so a network attack lands in `net`, not in the machine that draws your screen.
- **One template, throwaway roots.** Every sphere boots the same Arch template. A sphere's system files reset on each boot, while its `/home` lives on its own disk and persists. `omarchy sphere update` updates the template once for all spheres.
- **Isolated networks.** The two virtual networks have no host address, and every port is isolated, so spheres can't reach each other, only their gateway. `tor` sends all of `anon`'s TCP and DNS through Tor and drops everything else.
- **Windows over vsock.** Apps in a sphere draw through [waypipe](https://gitlab.freedesktop.org/mstoeckl/waypipe) over vsock. A small router on the host identifies each connection by the VM ID the host assigned, so a sphere can't pose as another one. The host-side waypipe then labels every window with that sphere's name.
- **Wayland isolation.** Stock waypipe forwards everything, including screenshots, clipboard snooping and keystroke injection. Spherie ships a patched waypipe that only exposes an allowlist of safe protocols to spheres, labels every window from the moment it's created, and keeps each sphere's clipboard to itself.

The full design is in [`docs/spheres.md`](docs/spheres.md).

## Using it

| Hotkey | |
| --- | --- |
| `Super + D` | Launch an app in a sphere ("work: chromium", "vault: keepassxc"…) |
| `Super + Alt + C` | Copy the focused sphere's clipboard to the host |
| `Super + Alt + V` | Offer that copy to the focused sphere, once; then paste with `Ctrl + V` |

Everything else is Omarchy's: `Super + Space` opens the Spherie menu, `Super + K` shows every hotkey.

From a terminal (`spherie` is short for `omarchy sphere`):

```sh
spherie list                            # spheres and whether they're running
spherie run work chromium               # start work if needed, open Chromium in it
spherie run vault keepassxc
spherie copy personal ~/Downloads/a.pdf work   # lands in work:~/Incoming/personal/
spherie stop personal
spherie update                          # pacman -Syu the shared template
```

Copy and paste work normally inside a sphere. To move text between spheres, use `Super + Alt + C` in one and `Super + Alt + V` in the other. Files go through `spherie copy`, which asks for confirmation first. Neither sphere can reach the other directly.

## Trying it

You need a spare x86 machine with VT-x/AMD-V and VT-d/AMD-Vi enabled in the firmware. Its network card must sit alone in its IOMMU group. It can't run inside another VM.

1. Install [Omarchy](https://omarchy.org) on the machine.
2. Build and install the patched waypipe:
   ```sh
   cd packaging/waypipe-spherie && makepkg -si
   ```
3. Put the checkout outside `/home`, because the sphere VMs run as a locked service user that can't see it, and point Omarchy at it:
   ```sh
   sudo git clone <this repo> /opt/spherie && sudo chown -R "$USER" /opt/spherie
   omarchy dev link /opt/spherie --no-reboot
   ```
4. Set up spheres:
   ```sh
   omarchy sphere install
   ```
   This creates the `spherie` service user, installs the units, turns on the IOMMU, and builds the sphere template while the host still has network. It also hands the network card to `net` after the next boot. Set `SPHERIE_NET_PASSTHROUGH=0` to keep the network on the host while developing.
5. Reboot, then `Super + D`.

## Status

Done:
- sphere definitions
- template build
- VM launcher
- isolated networks with `net` and `tor` gateways
- the vsock window router
- the waypipe isolation patch
- explicit clipboard and file copy
- Hyprland labels, colors and hotkeys
- installer steps
- user-visible branding

Not yet verified:
- **No sphere has booted on hardware.** Spherie was written inside a VM without nested KVM.
- **The waypipe patch is uncompiled and untested.** It still needs protocol tests and a published `waypipe-spherie` package. The base package list already expects that package, so a fresh install fails until it's published.

Known gaps:
- Menus and tooltips from a sphere have no colored border.
- Spheres have no GPU acceleration.
- There is no USB sphere and there are no disposable spheres yet.

Details are in [`docs/spheres.md`](docs/spheres.md#known-gaps).

## Relationship to Omarchy

Spherie tracks Omarchy upstream (the `upstream` git remote). Everything users see says Spherie, but internal names stay Omarchy's on purpose: `omarchy-*` commands, `OMARCHY_PATH`, `/usr/share/omarchy` and package names. That keeps upstream merges easy and Omarchy's package repository usable. The Spherie-specific parts are:

- `spheres/` - default sphere definitions
- `template/` - sphere template build, guest agent, `net` and `tor` roles
- `bin/omarchy-sphere-*`, `bin/spherie` - commands
- `default/spherie/`, `default/hypr/spheres.lua`, `default/systemd/*/spherie*`, `default/udev/spherie.rules` - runtime config
- `install/spheres/` - host setup
- `packaging/waypipe-spherie/` - the waypipe isolation patch

## Manual

The desktop itself works as in Omarchy. Its manual lives in [`manual/`](manual/). The chapters on networking and security describe Omarchy's single-host setup, not spheres. For those, read [`docs/spheres.md`](docs/spheres.md).

- **The basics:** [Welcome](manual/01-welcome-to-omarchy.md) · [Getting Started](manual/02-getting-started.md) · [Coming From Mac or Windows](manual/03-coming-from-mac-or-windows.md) · [Navigation](manual/04-navigation.md) · [The Top Bar](manual/05-the-top-bar.md) · [Themes](manual/06-themes.md) · [Hotkeys](manual/07-hotkeys.md) · [Clipboard & History](manual/08-unified-clipboard-history.md) · [Reminders](manual/09-reminders.md) · [Notices](manual/10-notices.md) · [Text Extraction & Dictation](manual/11-text-extraction-dictation.md) · [Screenshots & Recording](manual/12-screenshots-recording.md) · [Toggles, Idle & the Screensaver](manual/13-toggles-idle-screensaver.md) · [CLI](manual/14-omarchy-cli.md)
- **Applications:** [Terminal](manual/15-terminal.md) · [Neovim](manual/16-neovim.md) · [AI](manual/17-ai.md) · [Development Tools](manual/18-development-tools.md) · [Shell Tools](manual/19-shell-tools.md) · [Shell Functions](manual/20-shell-functions.md) · [TUIs](manual/21-tuis.md) · [GUIs](manual/22-guis.md) · [Browsers](manual/23-browsers.md) · [Commercial apps/services](manual/24-commercial-apps-services.md) · [Web Apps](manual/25-web-apps.md) · [Gaming](manual/26-gaming.md) · [Filling out PDFs](manual/27-filling-out-pdfs.md) · [Windows VM](manual/28-windows-vm.md) · [Other Packages](manual/29-other-packages.md)
- **Configuration:** [Updates](manual/30-updates.md) · [Dotfiles](manual/31-dotfiles.md) · [Shell Plugins](manual/32-shell-plugins.md) · [Monitors](manual/33-monitors.md) · [Keyboard, Mouse, Trackpad](manual/34-keyboard-mouse-trackpad.md) · [Networking](manual/35-networking.md) · [System Sleep](manual/36-system-sleep.md) · [Hardware Authentication](manual/37-hardware-authentication.md) · [Fonts](manual/38-fonts.md) · [Backgrounds](manual/39-backgrounds.md) · [Prompt](manual/40-prompt.md) · [Branding](manual/41-branding.md) · [Common Tweaks](manual/42-common-tweaks.md) · [Making Your Own Theme](manual/43-making-your-own-theme.md)
- **The rest:** [Mac Support](manual/44-mac-support.md) · [Troubleshooting](manual/45-troubleshooting.md) · [FAQ](manual/46-faq.md) · [System Snapshots](manual/47-system-snapshots.md) · [Security](manual/48-security.md) · [Spherie on…](manual/49-omarchy-on.md) · [Dual Boot Install](manual/50-dual-boot-install.md) · [Unattended Installs](manual/51-unattended-installs.md)

## License

MIT, like Omarchy. See [`LICENSE`](LICENSE). Omarchy is copyright (c) David Heinemeier Hansson. The waypipe patch in `packaging/waypipe-spherie/` is under waypipe's GPL-3.0-or-later.
