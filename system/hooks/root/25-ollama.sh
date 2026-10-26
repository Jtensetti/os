#!/usr/bin/env bash
# Install Ollama for local AI (forge agent local). Models are pulled on first use.
set -euo pipefail
[[ -n "${FORGE_ROOT:-}" || "${FORGE_WITH_OLLAMA:-1}" == 0 ]] && exit 0
command -v ollama >/dev/null && exit 0
command -v curl >/dev/null || exit 0
curl -fsSL https://ollama.com/install.sh | sh || echo "kunde inte installera Ollama"
