# Arkitektur

```
┌──────────── Skrivbord (Hyprland, Waybar, fuzzel) ─────────────┐
│ Super+A / Super+E / Super+Shift+A  →  forge-prompt (popup)    │
└───────────────────────────┬───────────────────────────────────┘
                            ▼  flytande terminal: du ser agenten jobba
┌──────────────────────── forge (CLI) ──────────────────────────┐
│ new/edit → agent i ~/Apps/<app>  → validera → commit → .desktop│
│ system   → agent i ~/Forge/system → diff → OK? → forge-apply   │
│ install  → agent granskar (forge-security-review) → OK? → in   │
└───────┬───────────────────────────────┬───────────────────────┘
        ▼                               ▼
  Claude Code / Codex  ◄── skills (/usr/share/forge/skills) + AGENTS.md + REA (MCP)
```

## Appar
- Format: katalog + `forge.json` (`name`, `description`, `kind: web|cli|native`, `entry`,
  `icon`, valfri `server`, `permissions: {network, files, display}`).
- `forge run`:
  - **web**: en lokal server på en *fast* port per app (räknas fram från namnet), så att
    `localStorage` m.m. finns kvar mellan körningar. Statiska appar serveras av
    `libexec/forge-serve`; appar med `server` startar sitt eget kommando med `$PORT`.
    Fönstret är Chromium i `--app`-läge med en egen profil per app på adressen `http://<app>.localhost:<port>`
    (så Super+E vet vilken app som har fokus).
  - **cli/native**: körs direkt i sandlådan.
- Sandlåda (`libexec/forge-sandbox`, bubblewrap): systemet skrivskyddat, tomt `$HOME`,
  bara appkatalogen och `$FORGE_DATA_DIR` skrivbara, extra mappar enligt manifestet.
  Internet är på som standard; `"network": false` stänger av det.
- Data: `~/.local/share/forge/appdata/<app>/` — separerat från koden, så `undo` och
  uppdateringar aldrig rör data.

## Teman
`~/Forge/system/theme/`: `active`, `themes/<namn>.theme` (palett), `templates/**.tmpl`.
`libexec/forge-theme render` byter ut `{{nyckel}}` och skriver filerna till `~` (Hyprland-färger,
låsskärm, Waybar, Alacritty, fuzzel, mako, `~/.config/forge/app.css`). Hooken
`hooks/user/08-theme.sh` renderar och laddar om allt live; GTK:s `color-scheme` sätts efter
`mode` så att appfönster följer ljust/mörkt. `forge-serve` levererar `app.css` som
`/_forge/theme.css` till varje webbapp. Bakgrundsbilder: `/usr/share/forge/wallpapers/`.

## Lokal AI
`forge agent local [modell] [--engine codex|claude]`. Samma agentprogram, lokal modell via Ollama:
Codex med `--oss --local-provider ollama`, Claude Code med `ANTHROPIC_BASE_URL` mot Ollamas
Anthropic-kompatibla API. Ollama installeras av `hooks/root/25-ollama.sh`; modellen hämtas vid
första användning.

## Systemet som kod
`~/Forge/system` (kopierat från `system/` vid installation):
```
packages/apt.list  packages/flatpak.list
rootfs/   → /         home/   → ~
services/system.list  services/user.list
hooks/root/*.sh       hooks/user/*.sh
```
`libexec/forge-apply` är idempotent och kommer ihåg vad den har lagt dit
(`/var/lib/forge`, `~/.local/state/forge`): filer, paket och tjänster som försvinner ur repot
tas bort igen. Användardelen körs som användaren; root-delen via sudo först när
användaren godkänt diffen. Agenten startas med sudo blockerat (Claude Code: `--disallowedTools`,
Codex: `--full-auto` = skrivrätt bara i arbetskatalogen).

## Installation
- `install.sh`: kopierar repot till `/usr/share/forge`, skapar `~/Forge/system` och `~/Apps`,
  kör apply (paket, Hyprland, greetd, Claude Code, Codex, skills, REA).
- ISO (`iso/build.sh`): Ubuntu Server LTS + autoinstall. Installationen kör `install.sh` med
  `FORGE_DEFER=1`; paket och agenter installeras av `forge-firstboot.service` vid första uppstart.

## Säkerhetsmodell (kort)
- Agenten kan skriva i app- eller systemrepot, men inte verkställa systemändringar själv.
- Allt agenten gör är en git-commit → går att granska och ångra.
- Delade appar granskas av agenten innan installation, och du ser behörigheterna.
- Appar har internet som standard (det är poängen med många appar). Filåtkomst utanför
  appen är det som kräver uttrycklig behörighet.

## Roadmap
1. Testa install.sh och ISO:n i en VM på Ubuntu 26.04, rätta paketnamn. Skärmdump från riktig Hyprland.
2. `network: false` även för webbappars JavaScript (CSP-header från Forge-servern).
3. "Forge Store": bläddra bland delade appar (git-baserat index), med granskningsrapport.
4. Systemändringar som förslag-grenar: prova en ändring, behåll eller kasta.
5. Fler mallar: Tauri (native-känsla), Python+GTK, spel (canvas).
6. Röst: håll in Super+A och prata.
7. Sync av hela `~/Forge/system` mellan datorer.
