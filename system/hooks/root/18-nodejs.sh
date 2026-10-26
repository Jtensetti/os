#!/usr/bin/env bash
# Ubuntu 26.04 ships Node 22.22, but REA needs >= 22.23.4 / 24.22.1. Install the
# latest Node 24 LTS from nodejs.org (checksum-verified) into /opt/forge/node
# and put it first on PATH via /usr/local/bin. Global npm installs go to /usr/local.
set -euo pipefail
[[ -n "${FORGE_ROOT:-}" ]] && exit 0
command -v curl >/dev/null || exit 0
dest=/opt/forge/node

need_version() {
  python3 - "$1" <<'PY'
import sys
v = tuple(int(x) for x in sys.argv[1].lstrip("v").split("."))
ok = (v[0] == 22 and v >= (22, 23, 4)) or (v[0] == 24 and v >= (24, 22, 1)) or v >= (26, 12, 1)
sys.exit(0 if ok else 1)
PY
}
current="$(node --version 2>/dev/null || echo v0.0.0)"
need_version "$current" && exit 0

case "$(uname -m)" in x86_64) arch=x64 ;; aarch64) arch=arm64 ;; *) echo "okänd arkitektur för Node"; exit 0 ;; esac
version="$(curl -fsSL https://nodejs.org/dist/index.json | python3 -c '
import json, sys
print(next(r["version"] for r in json.load(sys.stdin) if r["version"].startswith("v24.") and r["lts"]))')"
file="node-$version-linux-$arch.tar.xz"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/$file" "https://nodejs.org/dist/$version/$file"
curl -fsSL -o "$tmp/SHASUMS256.txt" "https://nodejs.org/dist/$version/SHASUMS256.txt"
(cd "$tmp" && grep " $file\$" SHASUMS256.txt | sha256sum -c --quiet)
rm -rf "$dest.new" && mkdir -p "$dest.new"
tar -xJf "$tmp/$file" -C "$dest.new" --strip-components=1
rm -rf "$dest" && mv "$dest.new" "$dest"
# npm's builtin config: global installs (Claude Code, Codex) land in /usr/local.
echo "prefix=/usr/local" >"$dest/lib/node_modules/npm/npmrc"
for b in node npm npx; do ln -sfn "$dest/bin/$b" "/usr/local/bin/$b"; done
echo "Node $version installerad"
