---
name: forge-theme
description: Create or switch Forge OS themes (colors for Hyprland, Waybar, fuzzel, mako, terminal and apps). Use for "make it darker", "new theme", wallpaper and color requests.
---
# Teman

Ett tema = `home/.config/forge/themes/<namn>.conf` med `$accent $border $bg $fg` (Hyprland-format,
`rgb(rrggbb)`). Aktivt tema = innehållet i `home/.config/forge/theme.conf`.

Att byta tema helt betyder att uppdatera samma färger i:
`theme.conf`, `waybar/style.css`, `fuzzel/fuzzel.ini`, `mako/config` och ev. terminalens konfig.
Håll kontrasten god (text mot bakgrund minst 4.5:1). Appar följer ljust/mörkt automatiskt.
Bakgrundsbild: lägg filen i `home/.config/forge/wallpaper.*` och peka ut den i
`home/.config/hypr/hyprpaper.conf`.
