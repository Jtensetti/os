---
name: forge-edit-app
description: Change an existing Forge app in ~/Apps/<app> based on a request, without losing the user's data or features.
---
# Ändra en befintlig Forge-app

1. Läs `forge.json` och skumma koden innan du ändrar. Kolla `git log --oneline` för historiken.
2. Gör den minsta ändringen som uppfyller önskemålet. Behåll allt annat som det var.
3. **Data är helig.** Ändrar du dataformat (localStorage-nycklar, filer i `$FORGE_DATA_DIR`)
   måste du skriva migrering som läser det gamla formatet. Radera aldrig användardata.
4. Uppdatera `description` i `forge.json` om appens syfte har ändrats.
5. Behöver ändringen nya behörigheter: lägg till dem i `permissions` och säg det i sammanfattningen.
6. Committa inte själv — Forge gör det efter körningen så att `forge undo` fungerar.
