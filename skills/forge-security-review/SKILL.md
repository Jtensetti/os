---
name: forge-security-review
description: Review a Forge app someone else made before it is installed. Use when running inside a staged app from 'forge install', or when asked whether an app is safe.
---
# Säkerhetsgranskning av en delad app

Läs **all** kod i katalogen (inklusive dolda filer och git-historiken: `git log -p | head -500`).
Kör ingenting. Bedöm:

1. **Behörigheter** i `forge.json`: rimliga för vad appen säger att den gör?
   Nätverk + filåtkomst samtidigt är den farliga kombinationen (kan läcka filer).
2. **Nätverk:** vart skickas data? Hårdkodade URL:er, IP-adresser, webhooks.
3. **Kodkörning:** `eval`, `child_process`, `subprocess`, `curl | sh`, nedladdning av kod,
   obfuskerad eller minifierad kod utan källa.
4. **Uthållighet:** försök att skriva utanför appkatalogen, autostart, cron, `~/.bashrc`.
5. **Hemligheter:** läser appen nycklar, SSH-filer, webbläsardata?

Skriv `REVIEW.md` på svenska: en mening om vad appen gör, behörigheter, fynd (med fil:rad),
och sist exakt en rad `VERDICT: OK` eller `VERDICT: RISK`. Hellre RISK vid tvekan.
