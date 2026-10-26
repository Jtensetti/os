# Forge OS-ISO

`./build.sh` tar en Ubuntu Server LTS-ISO och lägger till:
- en autoinstall-konfig (`autoinstall/`) som bara frågar om språk, tangentbord, användare, nätverk och disk,
- det här repot, som installeras med `FORGE_DEFER=1` i slutet av installationen.

Vid första uppstarten installerar `forge-firstboot.service` skrivbordet (Hyprland), Claude Code,
Codex och resten av paketlistan. Sedan loggar man in och trycker **Super+A**.

Status: experimentell. Testa i en VM först (t.ex. `qemu-system-x86_64 -m 4G -cdrom forge-os.iso -enable-kvm`).
För btrfs + snapper-ögonblicksbilder: välj btrfs som filsystem för `/` i diskvyn.
