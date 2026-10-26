---
name: forge-share
description: Share, back up, sync and publish Forge apps (personal library, .forgeapp bundles, Flatpak publishing). Use when the user wants to give an app to someone or keep it on several machines.
---
# Dela och synka

- **Personligt bibliotek** (som Google Plays "Your personal library"): `forge sync` pushar varje app
  till ett privat git-repo under `FORGE_LIBRARY_REMOTE` (sätts i `~/.config/forge/config`).
  På en ny dator: klona repona till `~/Apps/` och kör `forge edit` eller `forge run`.
- **Dela privat:** `forge share <app>` → `<app>.forgeapp` (git-bundle med hela historiken).
  Mottagaren kör `forge install fil.forgeapp`; appen säkerhetsgranskas av agenten först.
- **Publicera brett:** paketera som Flatpak (manifest med `org.freedesktop.Platform` +
  en liten webview/server-wrapper) och skicka till Flathub. Gör ett separat repo för det.
- Innan delning: kolla att inga hemligheter eller personlig data ligger i git-historiken
  (`git log -p | grep -iE 'key|token|password'`).
