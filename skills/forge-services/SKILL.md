---
name: forge-services
description: Run things in the background on Forge OS with systemd (user services, timers). Use for scheduled jobs, sync, watchers and app backends that should always run.
---
# Bakgrundstjänster

- Användartjänst: unit-fil i `~/Forge/system/home/.config/systemd/user/<namn>.service`,
  aktiveras genom att lägga `<namn>.service` i `services/user.list`.
- Schemalagt: `<namn>.timer` + `<namn>.service`, lägg timern i `user.list`.
- Systemtjänst (root): `rootfs/etc/systemd/system/<namn>.service` + `services/system.list`.
- Kör en Forge-app som tjänst: `ExecStart=/usr/bin/forge run <app>` funkar för cli-appar.
- Felsök: `systemctl --user status <namn>`, `journalctl --user -u <namn> -n 50`.
