#!/usr/bin/env bash
# Icon glyphs for Waybar: Nerd Font symbols (MIT), shipped with Forge because
# Ubuntu has no package for them and first boot may be offline.
set -euo pipefail
[[ -n "${FORGE_ROOT:-}" ]] && exit 0
src="${FORGE_SHARE:-/usr/share/forge}/assets/fonts/nerd-symbols"
dir=/usr/local/share/fonts/nerd-symbols
[[ -f "$src/SymbolsNerdFont-Regular.ttf" ]] || exit 0
if ! cmp -s "$src/SymbolsNerdFont-Regular.ttf" "$dir/SymbolsNerdFont-Regular.ttf" 2>/dev/null; then
  mkdir -p "$dir"
  cp "$src/SymbolsNerdFont-Regular.ttf" "$src/LICENSE" "$dir/"
  command -v fc-cache >/dev/null && fc-cache -f "$dir" >/dev/null
fi
