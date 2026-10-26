---
name: forge-troubleshoot
description: Diagnose and fix problems on Forge OS (app won't start, broken config after a system change, no sound/wifi, slow machine). Use when something is broken.
---
# Felsökning

Börja alltid med att ta reda på vad som ändrats senast:
- Appar: `forge history <app>` — ångra med `forge undo <app>`.
- Systemet: `forge system log` / `forge system diff` — ångra med `forge system rollback`.
- Snapshots (btrfs): `snapper list` (be användaren köra `sudo snapper rollback` om det behövs).

Sedan:
- App startar inte: `forge doctor`, kör `forge run <app>` i terminal och läs felet;
  kontrollera `forge.json` med `jq . forge.json`.
- Hyprland-fel: `hyprctl configerrors`.
- Tjänster: `systemctl --failed`, `journalctl -b -p err -n 50`.
- Ljud: `wpctl status`. Nätverk: `nmcli device status`. Disk: `df -h`, `du -sh ~/* | sort -h`.

Förklara orsaken enkelt, föreslå fixen som en ändring i `~/Forge/system` (inte direkt i systemet),
och säg hur man ångrar.
