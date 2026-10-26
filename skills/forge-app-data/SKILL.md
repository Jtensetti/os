---
name: forge-app-data
description: Where and how Forge apps persist data so it survives restarts, edits and reinstalls. Use whenever an app stores anything.
---
# Data i Forge-appar

- **Webbapp utan server:** `localStorage` / IndexedDB. Varje app har en egen webbläsarprofil
  i `~/.local/share/forge/appdata/<app>/browser`, så data delas inte mellan appar.
  Använd en versionerad nyckel, t.ex. `app:v1:state`, och migrera vid formatbyte.
- **App med server eller cli:** skriv under `$FORGE_DATA_DIR` (satt av `forge run`).
  Föredra SQLite (`python3 -m sqlite3` finns) eller en JSON-fil som skrivs atomiskt
  (skriv till `.tmp`, sedan `rename`).
- Spara **aldrig** data i appkatalogen — den är källkod och versioneras med git.
- Erbjud export/import (JSON) i större appar så användaren kan flytta sin data.
