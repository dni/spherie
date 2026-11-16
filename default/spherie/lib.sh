# Sourced by omarchy-sphere-* commands. Loads sphere definitions from
# /etc/spherie/spheres (root-owned, trusted) and names the shared paths.

SPHERIE_CONF="${SPHERIE_CONF:-/etc/spherie/spheres}"
SPHERIE_DATA="${SPHERIE_DATA:-/var/lib/spherie}"
SPHERIE_RUN="${SPHERIE_RUN:-/run/spherie}"

sphere_names() {
  local conf
  for conf in "$SPHERIE_CONF"/*.conf; do
    [[ -e $conf ]] && basename "$conf" .conf
  done
}

# Load a sphere into NAME COLOR CID MEM CPUS ROLE NET SERVES VFIO APPS HIDDEN AUTOSTART.
sphere_load() {
  local name="$1"

  if [[ ! $name =~ ^[a-z0-9-]+$ ]]; then
    echo "Invalid sphere name: $name" >&2
    return 1
  fi

  NAME="" COLOR="888888" CID="" MEM=1024 CPUS=1 ROLE=app NET=none SERVES="" VFIO="" APPS="" HIDDEN=0 AUTOSTART=0

  if [[ $name == "template" ]]; then
    # The template boots writable for updates, networked through net.
    NAME=template CID=9 MEM=2048 CPUS=2 NET=br-net
    return 0
  fi

  if [[ ! -f $SPHERIE_CONF/$name.conf ]]; then
    echo "Unknown sphere: $name" >&2
    return 1
  fi

  # shellcheck source=/dev/null
  source "$SPHERIE_CONF/$name.conf"
  [[ $NAME == "$name" ]] || { echo "$name.conf: NAME must be $name" >&2; return 1; }
  (( CID > 2 )) || { echo "$name.conf: CID must be > 2" >&2; return 1; }
}

sphere_name_for_cid() {
  local name
  for name in $(sphere_names) template; do
    sphere_load "$name" 2>/dev/null || continue
    if (( CID == $1 )); then
      echo "$name"
      return 0
    fi
  done
  return 1
}

# NICs: 52:54:00:5e:<cid>:00 is the uplink, :01 the LAN the sphere serves.
sphere_mac() {
  printf '52:54:00:5e:%02x:%02x' "$1" "$2"
}

sphere_tap() {
  # Interface names are capped at 15 characters.
  echo "sph${1:0:8}$2"
}

sphere_running() {
  systemctl is-active --quiet "spherie@$1.service"
}

# Send one agent request to a running sphere; stdin is forwarded.
sphere_agent() {
  local cid="$1"
  shift
  { printf '%s\n' "$*"; cat; } | socat -t 30 - "VSOCK-CONNECT:$cid:7001"
}
