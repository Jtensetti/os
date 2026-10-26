---
name: forge-rebuild-from-reference
description: Rebuild the behavior of an existing program or website as a new Forge app by studying it with REA (reverse engineering MCP). Use for requests like "make an app that works like X".
---
# Bygg om "som X"

Forge OS levereras med **REA** (`rea-agents`, MCP-servern `rea`) som låter dig undersöka
program, binärer, Electron-appar, APK:er och webbplatser lokalt.

## Arbetsgång
1. Fråga vad användaren gillar med X — oftast är det 2–3 funktioner, inte hela programmet.
2. Undersök **beteendet**: använd REA:s statiska analys för struktur (moduler, IPC-routes,
   dataformat) och körtidsobservation för flöden. Notera vad du hittat och vad som är okänt.
3. Bygg en **egen** implementation i Forge-format. Kopiera aldrig kod, grafik, varumärken
   eller text från X — återskapa funktionen med egen kod och Forge-design.
4. Är målet att läsa X:s filformat (interoperabilitet), skriv en ren läsare/konverterare.

## Gränser
- Bara program användaren äger eller har rätt att undersöka. Inga försök att kringgå
  licenskontroller, DRM, betalväggar eller kopieringsskydd.
- Inga inloggningsuppgifter eller andras data i analysen.
- Saknas REA: `npx rea-agents setup` (installeras normalt av Forge).
