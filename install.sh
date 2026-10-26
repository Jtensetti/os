#!/usr/bin/env bash
# Turn an Ubuntu LTS install into Forge OS.
#
#   git clone https://github.com/Jtensetti/os && cd os && sudo ./install.sh
#
# Options (environment):
#   FORGE_USER=<name>     user to set up (default: the one running sudo, else uid 1000)
#   FORGE_DEFER=1         only install files; packages and agents come on first boot
#                         (used by the ISO installer, which runs in a chroot)
#   FORGE_WITH_REA=0      skip the REA reverse engineering MCP

set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Kör med sudo: sudo ./install.sh" >&2; exit 1; }
src="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
dest=/usr/share/forge

user="${FORGE_USER:-${SUDO_USER:-$(getent passwd 1000 | cut -d: -f1)}}"
[[ -n "$user" && "$user" != root ]] || { echo "Hittar ingen vanlig användare, sätt FORGE_USER" >&2; exit 1; }
home="$(getent passwd "$user" | cut -d: -f6)"

say() { printf '\033[1;35m✦\033[0m %s\n' "$*"; }

if [[ -r /etc/os-release ]]; then
  # shellcheck source=/dev/null
  . /etc/os-release
  [[ "${ID:-}" == ubuntu ]] || say "Varning: testat på Ubuntu, det här är ${PRETTY_NAME:-okänt}."
fi

say "Installerar Forge till $dest"
if ! command -v git >/dev/null || ! command -v jq >/dev/null; then
  apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y git jq
fi
rm -rf "$dest.new"
cp -a "$src" "$dest.new"
rm -rf "$dest" && mv "$dest.new" "$dest"
for b in forge forge-prompt; do ln -sfn "$dest/bin/$b" "/usr/local/bin/$b"; done

as_user() { sudo -u "$user" -H env FORGE_SHARE="$dest" FORGE_WITH_REA="${FORGE_WITH_REA:-1}" "$@"; }

say "Skapar ~/Forge/system och ~/Apps för $user"
if [[ ! -d "$home/Forge/system/.git" ]]; then
  as_user mkdir -p "$home/Forge" "$home/Apps"
  as_user cp -r "$dest/system" "$home/Forge/system"
  as_user git -C "$home/Forge/system" init -q
  as_user git -C "$home/Forge/system" add -A
  as_user git -C "$home/Forge/system" -c user.name=Forge -c user.email=forge@localhost commit -q -m "Forge OS standardsystem"
else
  say "$home/Forge/system finns redan — rör den inte"
fi

say "Dotfiles, skills och agentinstruktioner"
as_user "$dest/libexec/forge-apply" --user "$home/Forge/system" || say "En del av användarsteget misslyckades (körs igen vid inloggning)"

if [[ "${FORGE_DEFER:-0}" == 1 ]]; then
  say "Paket och AI-agenter installeras vid första uppstarten"
  install -Dm644 "$dest/system/rootfs/etc/systemd/system/forge-firstboot.service" /etc/systemd/system/forge-firstboot.service
  mkdir -p /etc/systemd/system/multi-user.target.wants
  ln -sfn /etc/systemd/system/forge-firstboot.service /etc/systemd/system/multi-user.target.wants/forge-firstboot.service
else
  say "Paket, tjänster och AI-agenter (kan ta en stund)"
  FORGE_NO_START=1 "$dest/libexec/forge-apply" --root "$home/Forge/system" \
    || say "Några steg misslyckades (se ovan). Kör 'forge system apply' igen senare."
  mkdir -p /var/lib/forge && touch /var/lib/forge/firstboot-done
  as_user "$dest/libexec/forge-apply" --user "$home/Forge/system" || true
fi

say "Klart! Logga ut och välj Hyprland (eller starta om)."
say "Super+A = bygg en app · Super+E = ändra appen · Super+Shift+A = ändra systemet"
