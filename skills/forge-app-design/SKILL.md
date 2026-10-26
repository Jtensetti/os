---
name: forge-app-design
description: Visual design rules so every Forge app looks like part of one system. Use when building or restyling any app UI.
---
# Forge-design

Alla appar delar `forge.css`. Använd dess variabler i stället för egna färger:
`--bg --surface --text --muted --accent --accent-text --border --radius --gap --font --mono`.

- Ljust och mörkt läge följer systemet automatiskt (`prefers-color-scheme`). Hårdkoda inga färger.
- Klasser som finns: `.app` (sidlayout), `.card`, `.muted`, `button`, `button.secondary`.
- Layout: en kolumn, max 960px, 24px luft. Tät men inte trång. Inga skuggor, tunna kanter.
- Typografi: en storlek för brödtext (15px), en för rubriker (22px). Undvik fler.
- Ikoner: inline SVG, `currentColor`. Inga ikonbibliotek från nätet.
- Fönstret kan vara litet (tiling): testa att layouten håller ned till 360px bredd.
- Animationer: korta (150ms), bara för att förklara vad som hände.
