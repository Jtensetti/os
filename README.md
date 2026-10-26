# Forge OS

**Ett Linux-system där du beskriver vad du vill ha — och AI:n bygger det.**
Appar *och* själva operativsystemet. Allt sparas, versioneras och går att ångra.

![Forge OS-skrivbordet](docs/img/desktop.png)

<sub>Skärmdump från en riktig Wayland-session med Forges egna konfigfiler, temat `forge`,
Waybar, Alacritty, fuzzel, mako och exempelappen Fokus. Den här testmiljön kör sway i stället för
Hyprland, så rundade hörn, blur och animationer syns inte här — dem får du på en riktig installation.</sub>

> Arbetsnamn. Byggt på Ubuntu LTS (stabilt), med ett Omarchy-inspirerat Hyprland-skrivbord
> (snyggt, tangentbordet först) och Claude Code + Codex inbyggda (vibe) — i molnet eller lokalt.

```
Super+A          "en timer som pausar Spotify när jag fokuserar"   → ny app i appmenyn
Super+E          "lägg till statistik per vecka"                  → ändrar appen du tittar på
Super+Shift+A    "gör allt mörkare och byt Super+W till Super+Q"  → ändrar själva systemet
Super+Shift+T    nästa tema                                        → hela systemet + alla appar
```

## Teman

![De tio inbyggda temana](docs/img/themes.jpg)

Tio teman från start — `forge`, `tokyo-night`, `catppuccin`, `catppuccin-latte`, `gruvbox`, `nord`,
`everforest`, `kanagawa`, `rose-pine`, `matte-black` — var och en med egen bakgrundsbild.
`forge theme <namn>` byter färg på Hyprland-ramar (gradient), panel, terminal, appstartare, notiser,
låsskärm **och alla dina appar** på en gång. Säg "gör ett tema som känns som en höstskog" så skriver
agenten ett nytt. Effekterna — blur, skuggor, rundade hörn, animationer — ligger i Hyprland-konfigen.

## Idén: tre saker ihop

| Inspiration | Vad vi tar | Hur det blir i Forge |
|---|---|---|
| **vibeOS** (vibeos.sh) | "Mjukvara du ändrar genom att be om det", även skrivbordet | Hela systemet är ett git-repo (`~/Forge/system`) som agenten redigerar. Du ser diffen, godkänner, `forge system apply` verkställer. Skillnad: riktig installation på riktig hårdvara, inte en VM i en flik. |
| **Google Play — vibe-kodade appar** (okt 2026) | Personligt bibliotek, privat delning med säkerhetsgranskning, väg till publicering | `forge sync` = ditt bibliotek i privata git-repon. `forge share`/`forge install` = privat delning, där agenten säkerhetsgranskar appen innan den installeras. Flatpak/Flathub som väg ut. |
| **REA** (morluto/rea) | Låt agenten förstå befintliga program | Förinstallerad MCP. "Gör en app som funkar som X" → agenten undersöker X:s beteende och bygger en *egen* version (skill: `forge-rebuild-from-reference`). |

Plus: **18 skills** som följer med distrot och laddas i både Claude Code och Codex — appbygge, design,
data, behörigheter, AI i appar, systemändringar, Hyprland, teman, lokal AI, paket, tjänster, delning,
säkerhetsgranskning, felsökning m.m. Se [`skills/`](skills/).

## Lokal AI — samma verktyg

```
forge agent local                                   # gpt-oss:20b via Codex
forge agent local qwen3-coder:30b --engine claude   # Claude Code mot en lokal modell
forge agent claude                                  # tillbaka till molnet
```
Agenten är fortfarande Claude Code eller Codex — samma verktyg för filer, terminal, MCP (REA) och
skills — bara modellen körs på din dator via Ollama. Inget lämnar maskinen.

## Så funkar det

- **Appar** = `~/Apps/<namn>/`, ett git-repo per app med `forge.json`. Sparas för alltid, syns i
  appmenyn, varje ändring är en commit (`forge undo`). Appar får använda internet; deras filåtkomst
  är begränsad av en bubblewrap-sandlåda. Webbappar följer systemtemat automatiskt.
- **Systemet** = `~/Forge/system/` — paketlistor, dotfiles, `/etc`-filer, tjänster, teman, hooks.
  Agenten får bara ändra där och aldrig köra sudo. Det du tar bort ur repot tas bort från datorn.
  Ångra med `forge system rollback` (och btrfs-snapshots via snapper om du kör btrfs).
- **Agenten** = Claude Code, Codex eller lokal modell (`forge agent …`).

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
forge theme [namn|next]         forge agent claude|codex|local [modell]
forge chat                      forge doctor
```

## Utveckla

`tests/run.sh` kör hela flödet med en låtsasagent (inget konto, ingen root behövs).
Status: tidig MVP — se [roadmap](docs/ARCHITECTURE.md#roadmap).
