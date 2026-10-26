#!/usr/bin/env bash
# Desktop programs (fuzzel, Waybar, the agents) need a UTF-8 locale. Minimal
# Ubuntu installs have none; use C.UTF-8 then, never override a chosen one.
set -euo pipefail
[[ -n "${FORGE_ROOT:-}" ]] && exit 0
if ! grep -qs '^LANG=' /etc/default/locale; then
  printf 'LANG=C.UTF-8\n' >>/etc/default/locale
  echo "locale satt till C.UTF-8"
fi
