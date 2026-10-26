#!/usr/bin/env bash
# Install Claude Code and Codex system-wide (idempotent).
set -euo pipefail
[[ -n "${FORGE_ROOT:-}" ]] && exit 0
command -v npm >/dev/null || { echo "npm saknas ännu, hoppar över agenterna"; exit 0; }
command -v claude >/dev/null || npm install -g @anthropic-ai/claude-code || echo "kunde inte installera Claude Code"
command -v codex  >/dev/null || npm install -g @openai/codex || echo "kunde inte installera Codex"
