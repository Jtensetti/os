---
name: forge-hyprland
description: Hyprland configuration conventions in Forge OS (keybindings, window rules, monitors, animations). Use when changing desktop behavior.
---
# Hyprland i Forge

Konfig: `~/Forge/system/home/.config/hypr/hyprland.conf`. Laddas om automatiskt vid apply.

- Modifierare: `$mod = SUPER`. Forge-tangenter är reserverade: `Super+A` (ny app),
  `Super+E` (ändra app i fokus), `Super+Shift+A` (ändra systemet), `Super+/` (agent).
- Kortkommando: `bind = $mod, T, exec, kommando`. Musknapp: `bindm`. Upprepning: `binde`.
- Fönsterregler: `windowrulev2 = float, class:^(forge-<app>)$`. Forge-appar har klassen `forge-<app>`.
- Skärmar: `monitor = NAMN, 2560x1440@144, 0x0, 1` (`hyprctl monitors` visar namn).
- Färger kommer från `~/.config/forge/theme.conf` (`$accent`, `$border`, `$bg`, `$fg`).
- Autostart: `exec-once = program`.
- Kontrollera att ett nytt kortkommando inte krockar med ett befintligt (sök i filen först).
