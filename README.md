# Forge OS

**Ett Linux-system där du beskriver vad du vill ha — och AI:n bygger det.**
Appar *och* själva operativsystemet. Allt sparas, versioneras och går att ångra.

> Arbetsnamn. Byggt på Ubuntu LTS (stabilt), med ett Omarchy-inspirerat Hyprland-skrivbord
> (snyggt, tangentbordet först) och Claude Code + Codex inbyggda (vibe).

```
Super+A          "en timer som pausar Spotify när jag fokuserar"   → ny app i appmenyn
Super+E          "lägg till statistik per vecka"                  → ändrar appen du tittar på
Super+Shift+A    "gör allt mörkare och byt Super+W till Super+Q"  → ändrar själva systemet
```

## Idén: tre saker ihop

| Inspiration | Vad vi tar | Hur det blir i Forge |
|---|---|---|
| **vibeOS** (vibeos.sh) | "Mjukvara du ändrar genom att be om det", även skrivbordet | Hela systemet är ett git-repo (`~/Forge/system`) som agenten redigerar. Du ser diffen, godkänner, `forge system apply` verkställer. Skillnad: riktig installation på riktig hårdvara, inte en VM i en flik. |
| **Google Play — vibe-kodade appar** (okt 2026) | Personligt bibliotek, privat delning med säkerhetsgranskning, väg till publicering | `forge sync` = ditt bibliotek i privata git-repon. `forge share`/`forge install` = privat delning, där agenten säkerhetsgranskar appen innan den installeras. Flatpak/Flathub som väg ut. |
| **REA** (morluto/rea) | Låt agenten förstå befintliga program | Förinstallerad MCP. "Gör en app som funkar som X" → agenten undersöker X:s beteende och bygger en *egen* version (skill: `forge-rebuild-from-reference`). |

Plus: **17 skills** som följer med distrot och laddas i både Claude Code och Codex — hur man bygger
appar, design, data, behörigheter, AI i appar, systemändringar, Hyprland, teman, paket, tjänster,
delning, säkerhetsgranskning, felsökning m.m. Se [`skills/`](skills/).

## Så funkar det

- **Appar** = `~/Apps/<namn>/`, ett git-repo per app med `forge.json`. Sparas för alltid, syns i
  appmenyn, varje ändring är en commit (`forge undo`). Webbappar körs i ett eget app-fönster med
  egen lagring; servrar och terminalverktyg körs i en bubblewrap-sandlåda.
- **Systemet** = `~/Forge/system/` — paketlistor, dotfiles, `/etc`-filer, tjänster, hooks.
  Agenten får bara ändra där och aldrig köra sudo. Det du tar bort ur repot tas bort från datorn.
  Ångra med `forge system rollback` (och btrfs-snapshots via snapper om du kör btrfs).
- **Agenten** = Claude Code eller Codex (`forge agent codex`). Du loggar in med ditt eget konto.

Detaljer: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Kom igång

På en Ubuntu 26.04 LTS (desktop eller server):
```bash
git clone https://github.com/Jtensetti/os && cd os
sudo ./install.sh
```
Logga ut, välj Hyprland, tryck **Super+A**. Eller bygg en installations-ISO: [iso/](iso/).

## Kommandon

```
forge new "beskrivning"         forge system "ändring"
forge edit <app> "ändring"      forge system diff | log | apply | rollback
forge run | list | history | undo | rm <app>
forge share <app> / forge install fil.forgeapp / forge sync
forge agent claude|codex        forge doctor
```

## Utveckla

`tests/run.sh` kör hela flödet med en låtsasagent (inget konto, ingen root behövs).
Status: tidig MVP — se [roadmap](docs/ARCHITECTURE.md#roadmap).
