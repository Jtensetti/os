---
name: forge-hyprland
description: Hyprland configuration conventions in Forge OS (keybindings, window rules, monitors, animations). Use when changing desktop behavior.
---
# Hyprland i Forge

Konfig: `~/Forge/system/home/.config/hypr/hyprland.conf`. Laddas om automatiskt vid apply.

- Modifierare: `$mod = SUPER`. Forge-tangenter är reserverade: `Super+A` (ny app),
  `Super+E` (ändra app i fokus), `Super+Shift+A` (ändra systemet), `Super+/` (agent).
- Kortkommando: `bind = $mod, T, exec, kommando`. Musknapp: `bindm`. Upprepning: `binde`.
- Forge-appars fönster har klassen `forge.app.<app>` (bindestreck blir `_`). Kolla aktuell syntax för fönsterregler med `Hyprland --verify-config` — den ändrades i Hyprland 0.53.
- Skärmar: `monitor = NAMN, 2560x1440@144, 0x0, 1` (`hyprctl monitors` visar namn).
- Färger kommer från temat via `~/.config/hypr/colors.conf` (`$accent`, `$accent2`, `$border`, `$bg`, `$fg`),
  som renderas från `theme/templates/.config/hypr/colors.conf.tmpl`. Ändra inte colors.conf direkt.
- Super+Shift+T byter tema. Effekter (blur, rundning, skuggor, animationer) finns i hyprland.conf.
- Autostart: `exec-once = program`.
- Kontrollera att ett nytt kortkommando inte krockar med ett befintligt (sök i filen först).
