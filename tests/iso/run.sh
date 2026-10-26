#!/usr/bin/env bash
# End-to-end ISO test: build the installer ISO (unattended test variant),
# install it onto an empty disk in QEMU, boot the installed system and
# take screenshots of the first boot. Slow without KVM (an hour or more).
#
#   sudo tests/iso/run.sh [workdir]
set -euo pipefail

repo="$(cd "$(dirname "$0")/../.." && pwd)"
work="$(realpath -m "${1:-$repo/tests/iso/work}")"
mkdir -p "$work"
say() { printf '\033[1;35m✦\033[0m %s\n' "$*"; }
accel=tcg; [[ -w /dev/kvm ]] && accel=kvm

shots() {  # shots <prefix> <count> <every-seconds> <pid>
  local i
  for i in $(seq "$2"); do
    sleep "$3"
    kill -0 "$4" 2>/dev/null || return 0
    printf 'screendump %s/%s-%02d.ppm\n' "$work" "$1" "$i" | socat - "UNIX-CONNECT:$work/mon.sock" >/dev/null 2>&1 || true
    say "$1 skärmdump $i"
  done
}

say "Bygger test-ISO"
AUTOINSTALL_DIR="$repo/tests/iso" "$repo/iso/build.sh" "$work/ubuntu.iso" "$work/forge-test.iso"

say "Installerar på tom disk (autoinstall)"
rm -f "$work/disk.qcow2" "$work"/*.ppm "$work/mon.sock"
qemu-img create -q -f qcow2 "$work/disk.qcow2" 30G
qemu-system-x86_64 -accel "$accel" -smp "${VM_CPUS:-4}" -m "${VM_MEM:-6G}" \
  -cdrom "$work/forge-test.iso" -boot d -drive "file=$work/disk.qcow2,if=virtio" \
  -device virtio-vga -display none -nic user,model=virtio-net-pci \
  -serial "file:$work/install-serial.log" -monitor "unix:$work/mon.sock,server,nowait" &
qpid=$!
shots install "${INSTALL_SHOTS:-40}" "${SHOT_EVERY:-180}" "$qpid" &
wait "$qpid" || true
say "Installationen klar (maskinen stängde av sig)"

say "Startar det installerade systemet"
rm -f "$work/mon.sock"
qemu-system-x86_64 -accel "$accel" -smp "${VM_CPUS:-4}" -m "${VM_MEM:-6G}" \
  -drive "file=$work/disk.qcow2,if=virtio" \
  -device virtio-vga -display none -nic user,model=virtio-net-pci \
  -serial "file:$work/boot-serial.log" -monitor "unix:$work/mon.sock,server,nowait" &
qpid=$!
shots boot "${BOOT_SHOTS:-15}" "${SHOT_EVERY:-120}" "$qpid"
printf 'system_powerdown\n' | socat - "UNIX-CONNECT:$work/mon.sock" >/dev/null 2>&1 || true
sleep 30; kill "$qpid" 2>/dev/null || true
say "Klart: skärmdumpar i $work"
