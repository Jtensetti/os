# Forge OS — instruktioner för AI-agenten

Du kör i **Forge OS**, ett Linux-system (Ubuntu LTS-bas, Hyprland-skrivbord) där användaren
bygger appar och ändrar hela systemet genom att beskriva vad de vill ha. Användaren är
inte nödvändigtvis programmerare: förklara kort och på svenska, inte i jargong.

## Var saker finns
- `~/Apps/<app>/` — användarens appar. En katalog = en app = ett git-repo. Manifest: `forge.json`.
- `~/Forge/system/` — hela systemets konfiguration som kod (paket, dotfiles, tjänster, hooks).
  Verkställs med `forge system apply` efter att användaren godkänt diffen.
- `~/.local/share/forge/appdata/<app>/` — appdata (`$FORGE_DATA_DIR` när appen körs).
- Skills för allt ovan finns i `~/.claude/skills` och `~/.codex/skills` (prefix `forge-`).

## Regler
1. **Spara, inte tillfälligt.** Allt du bygger ska ligga kvar: appar i `~/Apps`, systemändringar i
   `~/Forge/system`. Ändra aldrig systemfiler direkt i `/etc` eller `~/.config` — de skrivs över
   av nästa apply. Ändra källan i `~/Forge/system` i stället.
2. **Aldrig sudo.** Root-ändringar sker bara via `forge system apply`, som användaren godkänner.
3. **Håll dig i din katalog.** När du bygger en app rör du bara den appens katalog.
4. **Små, begripliga ändringar.** Forge committar efter varje körning så användaren kan ångra.
5. **Fråga hellre än gissa** när önskemålet är tvetydigt och fel gissning kostar mycket.
6. **Avsluta med en kort sammanfattning** av vad du gjorde och hur man testar det.

## Användbara kommandon
`forge list`, `forge run <app>`, `forge history <app>`, `forge system diff`, `forge doctor`.
