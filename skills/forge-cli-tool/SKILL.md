---
name: forge-cli-tool
description: Build a terminal tool as a Forge app (kind cli). Use when the user asks for a command, script or automation rather than a window.
---
# Terminalverktyg

- `forge.json`: `"kind": "cli"`, `"entry": "bin/<namn>"` (körbar, med shebang).
- Bash för limkod, Python (standardbibliotek) för logik. Inga externa beroenden om det går.
- `--help` ska alltid fungera och visa exempel på svenska.
- Läs från stdin / skriv till stdout så verktyget går att kombinera med andra.
- Kör med `forge run <app> [argument]`. Vill användaren ha ett kort kommando: föreslå ett alias
  via skillen forge-system-edit (`home/.bashrc.d/forge-aliases.sh`).
- Data under `$FORGE_DATA_DIR`. Filer utanför kräver `permissions.files`.
