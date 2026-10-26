#!/usr/bin/env bash
# Give Claude Code and Codex the Forge skills and global instructions.
set -euo pipefail
share="${FORGE_SHARE:-/usr/share/forge}"
[[ -d "$share/skills" ]] || exit 0
for agent_dir in "$HOME/.claude" "$HOME/.codex"; do
  mkdir -p "$agent_dir/skills"
  for s in "$share"/skills/*/; do
    name="$(basename "$s")"
    ln -sfn "${s%/}" "$agent_dir/skills/$name"
  done
done
# Global instructions: link if the user has none; never overwrite their own.
link_if_free() { [[ -e "$2" && ! -L "$2" ]] || ln -sfn "$1" "$2"; }
link_if_free "$share/agent/AGENTS.md" "$HOME/.claude/CLAUDE.md"
link_if_free "$share/agent/AGENTS.md" "$HOME/.codex/AGENTS.md"
