#!/usr/bin/env bash
# Register REA (reverse engineering MCP) with the installed agents, once.
set -euo pipefail
marker="${XDG_STATE_HOME:-$HOME/.local/state}/forge/rea-setup-done"
[[ -f "$marker" || "${FORGE_WITH_REA:-1}" == 0 ]] && exit 0
command -v npx >/dev/null || exit 0
command -v claude >/dev/null || command -v codex >/dev/null || exit 0
if npx -y rea-agents setup </dev/null; then
  mkdir -p "$(dirname "$marker")" && touch "$marker"
else
  echo "REA-installationen misslyckades, försöker igen vid nästa apply"
fi
