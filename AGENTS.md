# Forge OS — utveckling av distrot

Läs `docs/ARCHITECTURE.md` och skillen `skills/forge-distro-dev/SKILL.md`.

- Kärnan är Bash: `bin/forge`, `bin/forge-prompt`, `libexec/*`. Håll den beroendesnål
  (bash, git, jq, python3-standardbibliotek).
- Användartext är på svenska; kodkommentarer på engelska.
- Innan commit: `shellcheck -x bin/* libexec/* install.sh iso/build.sh tests/*.sh system/hooks/*/*.sh`
  och `tests/run.sh`. Nya funktioner i `forge` ska ha ett test i `tests/run.sh`.
- `system/` är standardsystemet som alla nya installationer får. `skills/` installeras för både
  Claude Code (`~/.claude/skills`) och Codex (`~/.codex/skills`) — skriv dem agentneutralt.
