#!/usr/bin/env bash
# Verify a machine (or chroot/VM) after install.sh. Run as root:
#   sudo tests/install-check.sh [user]
# Checks packages, configs (with each program's own validator where one
# exists), agents, and a full forge new → run → theme cycle as the user.
set -uo pipefail

user="${1:-${SUDO_USER:-$(getent passwd 1000 | cut -d: -f1)}}"
home="$(getent passwd "$user" | cut -d: -f6)"
pass=0 failed=0 warned=0
ok()   { pass=$((pass + 1)); printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { failed=$((failed + 1)); printf '  \033[31m✗\033[0m %s\n' "$1"; }
warn() { warned=$((warned + 1)); printf '  \033[33m!\033[0m %s\n' "$1"; }
check() {
  local name="$1" out; shift
  if out="$("$@" 2>&1)"; then ok "$name"; else bad "$name"; printf '%s\n' "$out" | tail -5 | sed 's/^/      /'; fi
}
as_user() { sudo -u "$user" -H env XDG_RUNTIME_DIR="/tmp/forge-check-$user" "$@"; }
mkdir -p "/tmp/forge-check-$user" && chown "$user" "/tmp/forge-check-$user"

echo "Paket"
missing=()
while read -r p; do
  dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
done < <(sed 's/#.*//; s/[[:space:]]*$//; /^[[:space:]]*$/d' "$home/Forge/system/packages/apt.list")
if ((${#missing[@]})); then bad "saknas: ${missing[*]}"; else ok "alla paket i apt.list är installerade"; fi
check "Nerd Font-symboler" test -f /usr/local/share/fonts/nerd-symbols/SymbolsNerdFont-Regular.ttf

echo "Konfiguration"
hc="$home/.config/hypr/hyprland.conf"
if out="$(as_user Hyprland --verify-config -c "$hc" 2>&1)"; then
  ok "Hyprland godkänner hyprland.conf ($(Hyprland --version 2>/dev/null | head -1 | cut -c1-40))"
else
  bad "Hyprland underkänner hyprland.conf:"; printf '%s\n' "$out" | grep -iE 'error|invalid|unknown' | head -15 | sed 's/^/      /'
fi
check "fuzzel godkänner sin konfig" as_user fuzzel --check-config
check "Waybar-konfig är giltig JSON" python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$home/.config/waybar/config.jsonc"
check "Alacritty-konfig är giltig TOML" python3 -c 'import tomllib,sys; tomllib.load(open(sys.argv[1],"rb"))' "$home/.config/alacritty/alacritty.toml"
check "låsskärm och färger renderade" test -s "$home/.config/hypr/hyprlock.conf" -a -s "$home/.config/hypr/colors.conf"
check "bakgrundsbild finns" test -f "$(cat "$home/.config/forge/wallpaper-path")"
check "greetd startar Hyprland" grep -q 'cmd Hyprland' /etc/greetd/config.toml
for u in greetd NetworkManager bluetooth; do
  check "tjänst aktiverad: $u" systemctl is-enabled "$u.service"
done

echo "Agenter"
check "Claude Code ($(claude --version 2>/dev/null | head -1))" claude --version
check "Codex ($(codex --version 2>/dev/null | head -1))" codex --version
if command -v ollama >/dev/null; then ok "Ollama ($(ollama --version 2>&1 | tail -1))"; else warn "Ollama saknas (lokal AI)"; fi
check "skills för Claude Code" test -e "$home/.claude/skills/forge-new-app/SKILL.md"
check "skills för Codex" test -e "$home/.codex/skills/forge-new-app/SKILL.md"
if grep -qs '"rea"' "$home/.claude.json" "$home/.codex/config.toml" || grep -qs 'rea' "$home/.codex/config.toml"; then
  ok "REA registrerad som MCP"
else
  warn "REA inte registrerad (körs igen vid nästa inloggning)"
fi

echo "Forge som användaren"
check "forge doctor" as_user forge doctor
check "appfönster (GTK 4 + WebKitGTK 6)" /usr/bin/python3 -c 'import gi; gi.require_version("Gtk","4.0"); gi.require_version("WebKit","6.0"); from gi.repository import WebKit'
fake="$(mktemp)"; chmod 755 "$fake"
cat >"$fake" <<'EOF'
#!/usr/bin/env bash
cd "$1" && sed -i 's|<h1>.*</h1>|<h1>Installationstest</h1>|' index.html
EOF
as_user env FORGE_AGENT_CMD="$fake" forge new "installationstest" >/dev/null 2>&1
check "forge new" test -f "$home/Apps/installationstest/forge.json"
# timeout inside sudo: sudo does not relay signals from its own process group.
as_user env FORGE_NO_WINDOW=1 timeout 30 forge run installationstest >"$fake.url" 2>/dev/null &
for _ in $(seq 50); do [[ -s "$fake.url" ]] && break; sleep 0.2; done
url="$(cat "$fake.url" 2>/dev/null)"
if curl -fs --noproxy '*' "$url" 2>/dev/null | grep -q Installationstest; then
  ok "forge run serverar appen i sandlådan"
else
  bad "forge run ($url)"
fi
kill %1 2>/dev/null; wait 2>/dev/null
check "forge theme gruvbox" as_user forge theme gruvbox
check "temat slog igenom" grep -q 282828 "$home/.config/waybar/style.css"
as_user forge theme forge >/dev/null 2>&1
as_user forge rm installationstest >/dev/null 2>&1 <<<"j"
rm -f "$fake" "$fake.url"

echo
printf '%d ok, %d fel, %d varningar\n' "$pass" "$failed" "$warned"
((failed == 0))
