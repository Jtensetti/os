#!/usr/bin/env bash
# Icon glyphs for Waybar (Nerd Font symbols; Ubuntu has no package for them).
set -euo pipefail
[[ -n "${FORGE_ROOT:-}" ]] && exit 0
dir=/usr/local/share/fonts/nerd-symbols
[[ -f "$dir/SymbolsNerdFont-Regular.ttf" ]] && exit 0
command -v curl >/dev/null || exit 0
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
if curl -fsSL -o "$tmp/nf.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.zip; then
  mkdir -p "$dir"
  python3 -c 'import sys, zipfile; z = zipfile.ZipFile(sys.argv[1]); [z.extract(n, sys.argv[2]) for n in z.namelist() if n.endswith(".ttf")]' "$tmp/nf.zip" "$dir"
  command -v fc-cache >/dev/null && fc-cache -f "$dir" >/dev/null
else
  echo "kunde inte hämta Nerd Font-symboler (ikoner i panelen)"
fi
