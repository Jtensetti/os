---
name: forge-packages
description: Find and add software to Forge OS the right way (apt, Flatpak, npm/pipx tools). Use when the user wants a program installed or removed.
---
# Programvara

Prioritetsordning:
1. **apt** (Ubuntu-paket) → `packages/apt.list`. Sök: `apt-cache search <ord>`, kolla: `apt-cache policy <paket>`.
2. **Flatpak** (Flathub) för skrivbordsappar som saknas eller är gamla i apt → `packages/flatpak.list`
   med app-id, t.ex. `com.spotify.Client`.
3. Utvecklarverktyg via npm/pipx: lägg en idempotent `hooks/user/NN-<verktyg>.sh` som kollar
   om verktyget redan finns innan det installeras.

Lägg aldrig till tredjeparts-apt-källor utan att säga det tydligt till användaren; gör det
i så fall via `rootfs/etc/apt/sources.list.d/` + nyckel i `rootfs/etc/apt/keyrings/`.
Finns redan ett program för behovet? Föreslå det i stället för att bygga en ny app.
