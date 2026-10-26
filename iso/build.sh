#!/usr/bin/env bash
# Build a Forge OS installer ISO from an Ubuntu Server LTS ISO.
#
#   iso/build.sh [ubuntu.iso] [forge.iso]
#
# Needs: xorriso, curl. Adds an autoinstall config and this repo to the
# ISO; packages, desktop and AI agents install on first boot.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/.." && pwd)"
UBUNTU_ISO_URL="${UBUNTU_ISO_URL:-https://releases.ubuntu.com/26.04/ubuntu-26.04.1-live-server-amd64.iso}"
# AUTOINSTALL_DIR=tests/iso builds the unattended test variant.
autoinstall="${AUTOINSTALL_DIR:-$here/autoinstall}"
in="${1:-$here/ubuntu.iso}"
out="${2:-$here/forge-os.iso}"

command -v xorriso >/dev/null || { echo "installera xorriso: sudo apt install xorriso" >&2; exit 1; }
if [[ ! -f "$in" ]]; then
  echo "Laddar ner $UBUNTU_ISO_URL"
  curl -fL -o "$in" "$UBUNTU_ISO_URL"
fi

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
mkdir -p "$work/forge"
git -C "$repo" archive HEAD | tar -x -C "$work/forge"

xorriso -osirrox on -indev "$in" -extract /boot/grub/grub.cfg "$work/grub.cfg" >/dev/null 2>&1
chmod u+w "$work/grub.cfg"
# Boot straight into autoinstall with our config, and call it Forge OS.
# grub needs the ; escaped: ds=nocloud\;s=... (sed needs the backslash doubled).
sed -i 's|---| autoinstall ds=nocloud\\;s=/cdrom/nocloud/ ---|; s|Try or Install Ubuntu Server|Installera Forge OS|' "$work/grub.cfg"

xorriso -indev "$in" -outdev "$out" \
  -map "$autoinstall" /nocloud \
  -map "$work/forge" /forge \
  -map "$work/grub.cfg" /boot/grub/grub.cfg \
  -boot_image any replay

echo "Klar: $out"
