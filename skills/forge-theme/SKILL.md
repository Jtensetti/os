---
name: forge-theme
description: Create, change or switch Forge OS themes (colors, wallpaper, bar, terminal, launcher, notifications, lock screen and all apps). Use for "make it darker", "new theme", "nicer bar", wallpaper and color requests.
---
# Teman

Allt utseende styrs från `~/Forge/system/theme/`:

```
theme/active                 namnet på aktivt tema (en rad)
theme/themes/<namn>.theme    palett: mode, bg, bg_alt, surface, fg, muted, accent, accent2,
                             red, green, yellow, blue, magenta, cyan, border, wallpaper
theme/templates/**.tmpl      mallar som renderas till ~ med {{nyckel}} utbytt
theme/wallpapers/            egna bakgrundsbilder (valfritt)
```

Mallarna täcker Hyprland-färger (`.config/hypr/colors.conf`), låsskärm, Waybar-stil,
Alacritty, fuzzel, mako och `.config/forge/app.css` (som alla Forge-appar läser som
`/_forge/theme.css`). Byt tema: `forge theme <namn>`; nästa: `forge theme next` (Super+Shift+T).

## Nytt tema
1. Skapa `theme/themes/<namn>.theme` (färger som `rrggbb`, utan `#`). Utgå från ett befintligt.
2. Kontrast: `fg` mot `bg` minst 7:1, `muted` mot `bg` minst 4.5:1. `accent` ska synas mot både
   `bg` och `surface`. `mode=light` för ljusa teman.
3. Bakgrund: lägg en bild i `theme/wallpapers/` och sätt `wallpaper=<fil>`. Utan egen bild:
   använd en av de inbyggda (`/usr/share/forge/wallpapers/*.jpg`).
4. Sätt `theme/active` till det nya namnet.

## Ändra stilen (inte bara färger)
Redigera mallen, t.ex. `theme/templates/.config/waybar/style.css.tmpl` för en högre panel eller
`.config/alacritty/alacritty.toml.tmpl` för annat typsnitt. Använd bara nycklar som finns i
temafilerna. Hyprland-effekter (rundning, blur, animationer, luft) ligger i
`home/.config/hypr/hyprland.conf`.

Undvik "Noto Color Emoji" i GTK-typsnittslistor (Waybar): siffror ritas då med emoji-typsnittet.
