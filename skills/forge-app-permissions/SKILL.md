---
name: forge-app-permissions
description: How the Forge sandbox works and how to request the minimum permissions in forge.json.
---
# Behörigheter och sandlåda

Server- och cli-processer körs i bubblewrap (`forge-sandbox`). De ser:
- systemet skrivskyddat (`/usr`, `/etc`), sin appkatalog och `$FORGE_DATA_DIR` med skrivrätt,
- ett tomt `$HOME` — inga andra filer om de inte begärs.

Begär i `forge.json` under `permissions`:
- Internet är **på som standard** — appar får hämta data, anropa API:er osv.
  Sätt `"network": false` för appar som inte behöver nätet (t.ex. en lokal dagbok);
  då kan server- och cli-processen inte nå internet.
- `"files": ["~/Documents", "~/Music:ro"]` — extra kataloger, `:ro` = skrivskyddat.
- `"display": true` — för cli/native-appar som öppnar egna fönster (Wayland/GPU).

Begär så lite som möjligt och förklara varför i sammanfattningen. Användaren ser behörigheterna
när appen delas och installeras av någon annan.
