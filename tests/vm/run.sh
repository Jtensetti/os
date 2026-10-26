#!/usr/bin/env bash
# Full-system test: install Forge OS on Ubuntu 26.04, boot it in QEMU with
# systemd, log in to Hyprland and take screenshots. No KVM or GPU needed
# (software rendering), so it runs in CI and in containers — slowly.
#
#   sudo tests/vm/run.sh [workdir]         build + boot + screenshot
#   STEP=boot sudo tests/vm/run.sh         only boot an existing image
#
# Output: <workdir>/install.log, install-check.log, serial.log, shot-*.png
set -euo pipefail

repo="$(cd "$(dirname "$0")/../.." && pwd)"
work="$(realpath -m "${1:-$repo/tests/vm/work}")"
root="$work/root"
user=testare
UBUNTU_BASE="${UBUNTU_BASE:-https://cdimage.ubuntu.com/ubuntu-base/releases/26.04.1/release/ubuntu-base-26.04.1-base-amd64.tar.gz}"
STEP="${STEP:-all}"
mkdir -p "$work"
say() { printf '\033[1;35m✦\033[0m %s\n' "$*"; }

in_root() {
  chroot "$root" /usr/bin/env -i HOME=/root TERM=xterm LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    ${HTTPS_PROXY:+HTTPS_PROXY=$HTTPS_PROXY https_proxy=$HTTPS_PROXY} \
    ${CA:+SSL_CERT_FILE=$CA NODE_EXTRA_CA_CERTS=$CA CURL_CA_BUNDLE=$CA} \
    NO_PROXY=localhost,127.0.0.1 no_proxy=localhost,127.0.0.1 bash -c "$*"
}

mount_root() {
  local m
  for m in proc sys dev dev/pts; do mountpoint -q "$root/$m" || mount --bind "/$m" "$root/$m"; done
}
umount_root() {
  local m
  for m in dev/pts dev sys proc; do mountpoint -q "$root/$m" && umount -l "$root/$m"; done
  return 0
}

build() {
  if [[ ! -x "$root/usr/bin/apt-get" ]]; then
    say "Hämtar Ubuntu 26.04 base"
    curl -fsSL -o "$work/base.tar.gz" "$UBUNTU_BASE"
    mkdir -p "$root" && tar -xzf "$work/base.tar.gz" -C "$root"
  fi
  cp /etc/resolv.conf "$root/etc/resolv.conf"
  # Behind a TLS-inspecting proxy (like CI sandboxes), trust its CA inside too.
  if [[ -n "${SSL_CERT_FILE:-}" && -f "$SSL_CERT_FILE" ]]; then
    mkdir -p "$root/etc/ssl/forge-test" && cp "$SSL_CERT_FILE" "$root/etc/ssl/forge-test/ca.crt"
    CA=/etc/ssl/forge-test/ca.crt
  fi
  mount_root
  trap umount_root EXIT

  say "Grundsystem, kärna och testanvändare"
  in_root "apt-get update -qq && apt-get install -y -qq sudo git jq curl ca-certificates python3 \
    linux-image-virtual systemd-sysv udev kmod dbus-user-session iproute2 >/dev/null"
  in_root "id $user >/dev/null 2>&1 || useradd -m -u 1000 -s /bin/bash -G sudo,video,render,input $user; echo '$user:forge' | chpasswd"

  say "Kör install.sh (loggas till install.log)"
  rm -rf "$root/opt/forge-src" && mkdir -p "$root/opt/forge-src"
  (cd "$repo" && git ls-files -z --cached --others --exclude-standard | xargs -0 cp --parents -t "$root/opt/forge-src")
  in_root "cd /opt/forge-src && FORGE_USER=$user ./install.sh" >"$work/install.log" 2>&1 \
    || { tail -30 "$work/install.log"; say "install.sh misslyckades"; exit 1; }

  say "Kontrollerar installationen (install-check.log)"
  in_root "/opt/forge-src/tests/install-check.sh $user" | tee "$work/install-check.log" || true

  say "Testinställningar: automatisk inloggning och demo-fönster"
  cat >>"$root/etc/greetd/config.toml" <<EOF

[initial_session]
command = "sh -c 'Hyprland >/var/tmp/hyprland.log 2>&1'"
user = "$user"
EOF
  in_root "sudo -u $user -H bash -s" <<'EOF'
cd ~/Forge/system
grep -q 'VM-test' home/.config/hypr/hyprland.conf && exit 0
cat >> home/.config/hypr/hyprland.conf <<'CONF'

# --- VM-test: öppna några fönster så att skärmdumpen visar skrivbordet
exec-once = sleep 8 && alacritty -e bash -c 'forge list; echo; forge theme; echo; forge agent; exec bash'
exec-once = sleep 12 && forge run fokus
CONF
git -c user.name=t -c user.email=t@t commit -qam "VM-test"
EOF
  mkdir -p "$root/home/$user/Apps"
  [[ -d "$root/home/$user/Apps/fokus" ]] || \
    in_root "sudo -u $user -H env FORGE_AGENT_CMD=/opt/forge-src/tests/vm/demo-agent forge new --name Fokus 'fokustimer' >/dev/null"
  printf '/dev/vda / ext4 defaults 0 1\n' >"$root/etc/fstab"
  printf 'forge-vm\n' >"$root/etc/hostname"
  umount_root
  trap - EXIT

  say "Skapar diskavbild"
  rm -f "$work/disk.img"
  mkfs.ext4 -q -L forge -d "$root" "$work/disk.img" 20G
}

boot() {
  local kernel initrd
  kernel="$(printf '%s\n' "$root"/boot/vmlinuz-* | sort -V | tail -1)"
  initrd="$(printf '%s\n' "$root"/boot/initrd.img-* | sort -V | tail -1)"
  say "Startar VM (programvarurendering, tar några minuter)"
  rm -f "$work/mon.sock" "$work"/shot-*.png
  qemu-system-x86_64 -accel tcg,thread=multi -smp "${VM_CPUS:-4}" -m "${VM_MEM:-6G}" \
    -kernel "$kernel" -initrd "$initrd" \
    -append "root=/dev/vda rw console=ttyS0 quiet systemd.show_status=1" \
    -drive "file=$work/disk.img,format=raw,if=virtio" \
    -device virtio-vga -display none -nic user,model=virtio-net-pci \
    -serial "file:$work/serial.log" -monitor "unix:$work/mon.sock,server,nowait" &
  local qpid=$! i
  for i in $(seq "${VM_SHOTS:-12}"); do
    sleep "${VM_SHOT_EVERY:-60}"
    printf 'screendump %s/shot-%02d.ppm\n' "$work" "$i" | socat - "UNIX-CONNECT:$work/mon.sock" >/dev/null 2>&1 || true
    [[ -f "$work/shot-$(printf %02d "$i").ppm" ]] && say "skärmdump $i"
  done
  printf 'system_powerdown\n' | socat - "UNIX-CONNECT:$work/mon.sock" >/dev/null 2>&1 || true
  sleep 20; kill "$qpid" 2>/dev/null || true
  # Pull logs out of the disk image for debugging.
  debugfs -R "cat /var/tmp/hyprland.log" "$work/disk.img" >"$work/hyprland.log" 2>/dev/null || true
  for f in "$work"/shot-*.ppm; do
    [[ -f "$f" ]] && python3 - "$f" <<'PY'
import sys, zlib, struct
src = sys.argv[1]
data = open(src, "rb").read()
parts = data.split(b"\n", 3)
w, h = map(int, parts[1].split()); px = parts[3]
raw = b"".join(b"\0" + px[y * w * 3:(y + 1) * w * 3] for y in range(h))
def chunk(t, d): return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(raw, 6)) + chunk(b"IEND", b"")
open(src[:-4] + ".png", "wb").write(png)
PY
    rm -f "$f"
  done
  say "Klart: $work"
}

[[ $EUID -eq 0 ]] || { echo "kör med sudo" >&2; exit 1; }
case "$STEP" in
  build) build ;;
  boot) boot ;;
  all) build; boot ;;
esac
