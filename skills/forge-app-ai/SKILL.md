---
name: forge-app-ai
description: Build Forge apps that themselves use an AI model (Claude or OpenAI) without leaking keys. Use when an app needs to summarize, classify, chat or generate.
---
# Appar med AI inuti

- Appen behöver en server (`kind: web` + `server`) eller vara `cli`; anropa aldrig API:et
  direkt från webbsidans JavaScript.
- Nyckeln läses vid körning från `~/.config/forge/secrets.env` (variabler som
  `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`). Lägg den sökvägen som `"~/.config/forge/secrets.env:ro"`
  i `permissions.files` (internet är på som standard). Skriv aldrig in en nyckel i koden.
- Saknas nyckeln: visa ett vänligt meddelande om var man lägger in den.
- Använd senaste modellerna och strömma svar när det är chatt. Begränsa max tokens.
- Skicka bara den data som behövs till modellen, och säg i gränssnittet att den skickas.
