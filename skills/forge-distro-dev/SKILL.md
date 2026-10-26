---
name: forge-distro-dev
description: Work on the Forge OS distribution itself (the os repo — forge CLI, skills, defaults, installer, ISO). Use when improving Forge for everyone rather than one machine.
---
# Utveckla Forge OS

Repot `Jtensetti/os` innehåller:
- `bin/forge`, `bin/forge-prompt`, `libexec/forge-apply`, `libexec/forge-sandbox` — kärnan.
- `templates/` — appmallar. `skills/` — skills som installeras för Claude Code och Codex.
- `system/` — standardsystemet som kopieras till `~/Forge/system` vid installation, inklusive
  `system/theme/` (teman + mallar). `wallpapers/` — inbyggda bakgrundsbilder.
- `libexec/forge-theme` (renderar teman), `libexec/forge-serve` (appserver med `/_forge/theme.css`).
- `install.sh` — gör en vanlig Ubuntu till Forge. `iso/` — bygger en installations-ISO.
- `tests/` — kör `tests/run.sh` (använder en låtsasagent, kräver inget konto).

En bra systemändring på en maskin (`~/Forge/system`) kan lyftas hit som standard för alla:
kopiera filen till `system/`, kör testerna, öppna en PR.
