#!/usr/bin/env bash
# Render the active theme and reload everything that shows it.
set -euo pipefail
share="${FORGE_SHARE:-/usr/share/forge}"
"$share/libexec/forge-theme" render "$FORGE_SYSTEM"

# Apps (Chromium) follow light/dark through the GTK color scheme.
mode="$(sed -n 's/^mode=//p' "$FORGE_SYSTEM/theme/themes/$(cat "$FORGE_SYSTEM/theme/active").theme")"
if command -v gsettings >/dev/null; then
  if [[ "$mode" == light ]]; then scheme=prefer-light; else scheme=prefer-dark; fi
  gsettings set org.gnome.desktop.interface color-scheme "$scheme" 2>/dev/null || true
fi

[[ -n "${WAYLAND_DISPLAY:-}" ]] || exit 0
command -v makoctl >/dev/null && makoctl reload 2>/dev/null || true
pkill -SIGUSR2 -x waybar 2>/dev/null || true
wall="$(cat "$HOME/.config/forge/wallpaper-path" 2>/dev/null || true)"
if [[ -f "$wall" ]] && command -v swaybg >/dev/null; then
  pkill -x swaybg 2>/dev/null || true
  setsid swaybg -m fill -i "$wall" >/dev/null 2>&1 </dev/null &
fi
