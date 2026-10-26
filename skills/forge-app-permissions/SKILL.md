---
name: forge-app-permissions
description: How the Forge sandbox works and how to request the minimum permissions in forge.json.
---
# Behörigheter och sandlåda

Server- och cli-processer körs i bubblewrap (`forge-sandbox`). De ser:
- systemet skrivskyddat (`/usr`, `/etc`), sin appkatalog och `$FORGE_DATA_DIR` med skrivrätt,
- ett tomt `$HOME` — inga andra filer om de inte begärs.

Begär i `forge.json` under `permissions`:
- `"network": true` — internetåtkomst (krävs för API-anrop, nedladdningar).
  Appar med `server` får nätverk automatiskt eftersom fönstret måste nå servern.
- `"files": ["~/Documents", "~/Music:ro"]` — extra kataloger, `:ro` = skrivskyddat.
- `"display": true` — för cli/native-appar som öppnar egna fönster (Wayland/GPU).

Begär så lite som möjligt och förklara varför i sammanfattningen. Användaren ser behörigheterna
när appen delas och installeras av någon annan.
