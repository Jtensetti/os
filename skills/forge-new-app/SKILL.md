---
name: forge-new-app
description: Build a new Forge app from a plain-language description. Use whenever you are inside ~/Apps/<app> with a fresh template, or the user asks for a new app.
---
# Bygga en ny Forge-app

Du står i `~/Apps/<app>/` med en mall: `forge.json`, `index.html`, `app.js`, `forge.css`, `icon.svg`.

## Arbetsgång
1. Tolka beskrivningen. Välj den **enklaste** apptypen som räcker:
   - `web` utan server (förval): HTML/CSS/JS, data i `localStorage`. Räcker för de flesta verktyg.
   - `web` med `"server"`: när appen behöver läsa/skriva filer, köra program eller prata med
     lokala tjänster. Servern startas med `$PORT` satt och ska lyssna på `127.0.0.1:$PORT`.
     Använd Python-standardbiblioteket (`http.server`) eller Node utan beroenden om det går.
   - `cli`: ett terminalverktyg. `entry` pekar på ett körbart skript.
2. Uppdatera `forge.json`: `name` (snyggt visningsnamn), `description` (en mening),
   `entry`, `kind`, ev. `server`, och **minsta möjliga** `permissions` (se forge-app-permissions).
3. Bygg appen. Använd `forge.css`-tokens (se forge-app-design). Inga CDN:er om appen
   ska fungera offline — lägg in bibliotek lokalt i appkatalogen om de behövs.
4. Rita en egen `icon.svg` (64×64, enkel symbol på färgad rundad ruta).
5. Testa det du kan: öppna inte fönster, men kör t.ex. `node --check app.js`, starta servern
   kort och `curl` den, eller kör cli-skriptet med `--help`.

## Manifest
```json
{
  "name": "Pomodoro",
  "description": "Fokustimer med statistik",
  "kind": "web",
  "entry": "index.html",
  "icon": "icon.svg",
  "server": "python3 server.py",
  "permissions": { "network": false, "files": ["~/Documents:ro"], "display": false }
}
```
`server` och `permissions` är valfria. `entry` måste vara en relativ sökväg som finns.

## Kvalitet
- Fungerar direkt, utan inställningar. Vettiga tomma lägen ("Inga anteckningar än").
- Tangentbordsvänlig (Forge-användare lever i tangentbordet): Enter skickar, Esc stänger.
- Svensk text i gränssnittet om användaren skrev på svenska.
- Inga hemligheter i koden. Behöver appen en API-nyckel: se forge-app-ai.
