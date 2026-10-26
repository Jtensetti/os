---
name: forge-system-edit
description: Change Forge OS itself (packages, desktop, keybindings, services, themes) by editing the declarative system repo in ~/Forge/system. Use for any request about how the computer behaves or looks.
---
# Ändra själva systemet

Hela systemet beskrivs av `~/Forge/system/`. Du redigerar filerna där; användaren ser diffen
och godkänner; sedan kör `forge system apply` (med sudo) som verkställer. Kör **aldrig** sudo
och ändra **aldrig** direkt i `/` eller `~`.

## Karta
| Vill ändra | Fil |
|---|---|
| Installera/ta bort program | `packages/apt.list`, `packages/flatpak.list` (en per rad) |
| Kortkommandon, fönster, skärmar, tangentbord | `home/.config/hypr/hyprland.conf` |
| Färger, tema, bakgrund | `theme/` — se skillen forge-theme |
| Panelens innehåll | `home/.config/waybar/config.jsonc` (stilen: `theme/templates/.config/waybar/`) |
| Appstartare, notiser, terminal, låsskärm (utseende) | `theme/templates/.config/…` |
| Lokal AI | se skillen forge-local-ai |
| Systemfiler i `/etc` m.m. | `rootfs/<sökväg>` (speglas till `/`) |
| Dotfiles i hemkatalogen | `home/<sökväg>` (speglas till `~`) |
| Tjänster | `services/system.list`, `services/user.list`; unit-filer i `rootfs/etc/systemd/...` eller `home/.config/systemd/user/` |
| Engångs-/efterarbete | `hooks/root/NN-namn.sh`, `hooks/user/NN-namn.sh` (måste vara idempotenta) |

## Regler
- Filer som tas bort ur repot tas också bort från systemet vid apply. Paket som tas bort ur
  listan avinstalleras (bara de som Forge installerat).
- Kolla att paketnamn finns i Ubuntu (`apt-cache policy <paket>` funkar utan sudo).
- Hyprland-syntax: se skillen forge-hyprland. Validera gärna med `Hyprland --verify-config`
  om det finns.
- Gör en sak i taget. Förklara i sammanfattningen vad som händer vid apply (t.ex. "installerar
  3 paket, laddar om Hyprland").
- Riskabla ändringar (bootloader, fstab, nätverk, användare, sudoers): beskriv risken tydligt
  och föreslå hur man återställer (`forge system rollback`, snapper-ögonblicksbild).
