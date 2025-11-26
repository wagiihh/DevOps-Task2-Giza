#!/bin/bash
set -euo pipefail

BASE="${HOME}/nagios"
DOWNLOADS_DIR="${BASE}/downloads"
SRC_DIR="${BASE}/src"

NAGIOS_VERSION="4.4.6"
NAGIOS_URL="https://github.com/NagiosEnterprises/nagioscore/archive/refs/tags/nagios-${NAGIOS_VERSION}.tar.gz"

NAGIOS_ARCHIVE="${DOWNLOADS_DIR}/nagios-${NAGIOS_VERSION}.tar.gz"
NAGIOS_BUILD_DIR="${SRC_DIR}/nagioscore-nagios-${NAGIOS_VERSION}"
NAGIOS_CFG="${BASE}/etc/nagios.cfg"

log() { echo "[INFO] $*"; }

require_bin() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] Missing required binary: $1" >&2
    exit 1
  fi
}

log "Checking host toolchain requirements"
for bin in curl tar make gcc; do
  require_bin "$bin"
done

log "Preparing directories"
mkdir -p "$BASE" "$DOWNLOADS_DIR" "$SRC_DIR"

log "Downloading Nagios Core"
curl -L "$NAGIOS_URL" -o "$NAGIOS_ARCHIVE"

log "Extracting Nagios Core"
rm -rf "$NAGIOS_BUILD_DIR"
tar -xzf "$NAGIOS_ARCHIVE" -C "$SRC_DIR"

log "Configuring & Building Nagios Core (NO plugins)"
pushd "$NAGIOS_BUILD_DIR" >/dev/null

./configure \
  --prefix="$BASE" \
  --with-nagios-user="$USER" \
  --with-nagios-group="$(id -gn)" \
  --without-init-groups

make all
make install
make install-config

popd >/dev/null

log "Ensuring servers include directory"
mkdir -p "$BASE/etc/servers"

if ! grep -q "^cfg_dir=" "$NAGIOS_CFG"; then
  echo "cfg_dir=${BASE}/etc/servers" >> "$NAGIOS_CFG"
fi


log "Core-Only Nagios installation complete."
