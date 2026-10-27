#!/usr/bin/env bash
# shellcheck disable=SC2015
# End-to-end tests for the forge CLI with a fake agent. No accounts or root needed.
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
t="$(mktemp -d)"; trap 'kill $(jobs -p) 2>/dev/null || true; rm -rf "$t"' EXIT

export HOME="$t/home" XDG_CONFIG_HOME="$t/home/.config" XDG_DATA_HOME="$t/home/.local/share" XDG_STATE_HOME="$t/home/.local/state"
export FORGE_AGENT_CMD="$repo/tests/fake-agent" FORGE_YES=1 FORGE_NO_SANDBOX=1 FORGE_WITH_REA=0 FORGE_SKIP_SERVICES=1
mkdir -p "$HOME"
forge() { "$repo/bin/forge" "$@"; }
pass=0
ok()   { pass=$((pass + 1)); printf '  ✓ %s\n' "$1"; }
fail() { printf '  ✗ %s\n' "$1" >&2; exit 1; }

echo "Appar"
forge new "En enkel anteckningsapp med taggar" 2>/dev/null
app="enkel-anteckningsapp-taggar"
[[ -f "$HOME/Apps/$app/forge.json" ]] && ok "new skapar appen" || fail "new"
grep -q "Byggd av agenten" "$HOME/Apps/$app/index.html" && ok "agenten körs i appkatalogen" || fail "agent"
[[ -f "$XDG_DATA_HOME/applications/forge-$app.desktop" ]] && ok "desktop-fil skapas" || fail "desktop"
grep -q '^Name=Testapp$' "$XDG_DATA_HOME/applications/forge-$app.desktop" && ok "namn från forge.json" || fail "name"
forge list | grep -q "$app" && ok "list" || fail "list"

forge new --name "Väder" "visa vädret" 2>/dev/null
[[ -d "$HOME/Apps/vader" ]] && ok "--name och å/ä/ö i slug" || fail "slug: $(ls "$HOME/Apps")"
forge new "visa vädret" 2>/dev/null
[[ -d "$HOME/Apps/visa-vadret" ]] && forge new "visa vädret" 2>/dev/null && [[ -d "$HOME/Apps/visa-vadret-2" ]] \
  && ok "unika namn" || fail "unique"

forge edit "$app" "byt rubrik" 2>/dev/null
grep -q "Ändrad" "$HOME/Apps/$app/index.html" && ok "edit" || fail "edit"
[[ "$(forge history "$app" | wc -l)" -eq 3 ]] && ok "history" || fail "history"
forge undo "$app" 2>/dev/null
grep -q "Byggd av agenten" "$HOME/Apps/$app/index.html" && ok "undo" || fail "undo"

forge edit "../etc" "x" 2>/dev/null && fail "path traversal" || ok "ogiltiga appnamn avvisas"
count_apps() { find "$HOME/Apps" -mindepth 1 -maxdepth 1 | wc -l; }
before="$(count_apps)"
# "local" needs ollama, which is not installed here: the agent is missing.
FORGE_AGENT_CMD='' FORGE_AGENT=local forge new "en app som visar dagens agenda" >/dev/null 2>&1 && fail "missing agent" || true
[[ "$(count_apps)" == "$before" ]] && ok "saknad agent: inget skapas" || fail "dir created without agent"
forge new "En app som visar dagens agenda" >/dev/null 2>&1
[[ -d "$HOME/Apps/visar-dagens-agenda" ]] && ok "bra appnamn utan utfyllnadsord" || fail "slug: $(ls "$HOME/Apps")"

forge share "$app" "$t/a.forgeapp" 2>/dev/null
[[ -f "$t/a.forgeapp" ]] && ok "share" || fail "share"
forge rm "$app" 2>/dev/null
[[ ! -d "$HOME/Apps/$app" ]] && ok "rm" || fail "rm"
forge install "$t/a.forgeapp" >/dev/null 2>&1
[[ -d "$HOME/Apps/testapp" && ! -f "$HOME/Apps/testapp/REVIEW.md" ]] && ok "install med granskning" || fail "install"

FORGE_NO_WINDOW=1 "$repo/bin/forge" run testapp >"$t/url" 2>/dev/null &
for _ in $(seq 50); do [[ -s "$t/url" ]] && break; sleep 0.1; done
url="$(cat "$t/url")"
curl -fs "$url" | grep -q "Byggd av agenten" && ok "run serverar appen ($url)" || fail "run"
base="${url%index.html}"
curl -fs "${base}_forge/theme.css" >/dev/null && ok "systemtemat serveras till appen" || fail "theme.css"
! curl -fs "${base}.git/HEAD" >/dev/null && ok ".git syns inte utåt" || fail ".git exposed"
kill %1 2>/dev/null || true; wait 2>/dev/null || true
FORGE_NO_WINDOW=1 "$repo/bin/forge" run testapp >"$t/url2" 2>/dev/null &
for _ in $(seq 50); do [[ -s "$t/url2" ]] && break; sleep 0.1; done
[[ "$(cat "$t/url2")" == "$url" ]] && ok "samma port varje gång (data finns kvar)" || fail "stable port"
kill %1 2>/dev/null || true; wait 2>/dev/null || true
sleep 0.3
! curl -fs "$url" >/dev/null && ok "servern stängs när appen stängs" || fail "server left running"

echo "Systemet"
sys="$HOME/Forge/system"
mkdir -p "$HOME/Forge"
"$repo/libexec/forge-sync-defaults" "$repo/system" "$sys" 2>/dev/null
git -C "$sys" rev-parse -q --verify upstream >/dev/null && ok "systemrepo med upstream-gren" || fail "sync init"
export FORGE_ROOT="$t/root" FORGE_SKIP_PACKAGES=1 FORGE_SHARE="$repo"
mkdir -p "$FORGE_ROOT"
forge system "installera htop" >/dev/null 2>&1 || true
# Root part needs sudo in real life; run it directly against FORGE_ROOT here.
"$repo/libexec/forge-apply" --root "$sys" 2>/dev/null
grep -q '^htop$' "$sys/packages/apt.list" && ok "agenten ändrar systemrepot" || fail "system edit"
[[ "$(git -C "$sys" log --oneline | wc -l)" -eq 2 ]] && ok "ändringen committas" || fail "system commit"
[[ -f "$HOME/.config/forge-test/greeting" ]] && ok "dotfiles speglas till ~" || fail "home sync"
[[ -f "$HOME/.config/hypr/hyprland.conf" ]] && ok "Hyprland-konfig på plats" || fail "hypr"
[[ -L "$HOME/.claude/skills/forge-new-app" && -L "$HOME/.codex/skills/forge-new-app" ]] && ok "skills till Claude Code och Codex" || fail "skills"
[[ -L "$HOME/.claude/CLAUDE.md" ]] && ok "globala instruktioner" || fail "agents.md"
[[ -f "$FORGE_ROOT/etc/forge-test/file" ]] && ok "rootfs speglas" || fail "rootfs"

grep -q "#0f0e17" "$HOME/.config/waybar/style.css" && ok "temat renderas (forge)" || fail "theme render"
grep -q "forge.jpg" "$HOME/.config/forge/wallpaper-path" && ok "bakgrundsbild hittas" || fail "wallpaper"
forge theme nord >/dev/null 2>&1
grep -q "#2e3440" "$HOME/.config/waybar/style.css" && grep -q "#2e3440" "$HOME/.config/forge/app.css" \
  && grep -q "2e3440" "$HOME/.config/alacritty/alacritty.toml" && ok "forge theme byter allt" || fail "theme switch"
[[ "$(git -C "$sys" log -1 --format=%s)" == "forge theme: nord" ]] && ok "temabyte committas" || fail "theme commit"
forge theme next >/dev/null 2>&1
[[ "$(cat "$sys/theme/active")" == "rose-pine" ]] && ok "theme next" || fail "theme next: $(cat "$sys/theme/active")"
forge theme finns-inte >/dev/null 2>&1 && fail "unknown theme" || ok "okänt tema avvisas"
[[ "$(forge theme | wc -l)" -ge 10 ]] && ok "minst 10 teman" || fail "theme count"
git -C "$sys" reset -q --hard HEAD~2

FORGE_SKIP_ROOT=1 forge system rollback >/dev/null 2>&1
"$repo/libexec/forge-apply" --root "$sys" 2>/dev/null
[[ ! -f "$HOME/.config/forge-test/greeting" && ! -f "$FORGE_ROOT/etc/forge-test/file" ]] && ok "rollback tar bort filerna igen" || fail "rollback"
! grep -q '^htop$' "$sys/packages/apt.list" && ok "rollback återställer paketlistan" || fail "rollback list"

echo "Uppdateringar av Forge"
defaults="$t/defaults"; cp -r "$repo/system" "$defaults"
echo "neovim" >>"$defaults/packages/apt.list"                       # Forge ändrar en fil
echo "# mitt eget" >>"$sys/home/.config/hypr/hyprland.conf"         # användaren en annan
git -C "$sys" -c user.name=t -c user.email=t@t commit -qam "mitt"
"$repo/libexec/forge-sync-defaults" "$defaults" "$sys" 2>/dev/null
grep -q '^neovim$' "$sys/packages/apt.list" && grep -q '# mitt eget' "$sys/home/.config/hypr/hyprland.conf" \
  && ok "nya standardinställningar + egna ändringar slås ihop" || fail "merge"
"$repo/libexec/forge-sync-defaults" "$defaults" "$sys" 2>/dev/null && ok "ingen ändring andra gången" || fail "idempotent"
sed -i 's/^gaps_in = .*/  gaps_in = 2/; s/  gaps_in = 6/  gaps_in = 2/' "$sys/home/.config/hypr/hyprland.conf"
git -C "$sys" -c user.name=t -c user.email=t@t commit -qam "tätare"
sed -i 's/  gaps_in = 6/  gaps_in = 12/' "$defaults/home/.config/hypr/hyprland.conf"
before="$(git -C "$sys" rev-parse HEAD)"
rc=0; "$repo/libexec/forge-sync-defaults" "$defaults" "$sys" 2>/dev/null || rc=$?
[[ $rc == 3 && "$(git -C "$sys" rev-parse HEAD)" == "$before" && -z "$(git -C "$sys" status --porcelain)" ]] \
  && ok "krock: inget ändras, användarens version behålls" || fail "conflict rc=$rc"
grep -q 'gaps_in = 2' "$sys/home/.config/hypr/hyprland.conf" && ok "användarens värde kvar" || fail "user value"
FORGE_SKIP_ROOT=1 forge update >/dev/null 2>&1 && ok "forge update (Forges egen standard)" || fail "forge update"

echo "Lokal AI"
unset FORGE_AGENT_CMD
bin="$t/fakebin"; mkdir -p "$bin" "$t/ollama/api"
echo '{"version":"0.20.0"}' >"$t/ollama/api/version"
python3 "$repo/libexec/forge-serve" "$t/ollama" 28111 & sleep 0.5
cat >"$bin/ollama" <<'SH'
#!/usr/bin/env bash
[[ "$1" == list ]] && printf 'NAME ID\ngpt-oss:20b x\nqwen3-coder:30b y\n'
exit 0
SH
cat >"$bin/codex" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$*" >"$FAKE_LOG"
SH
cat >"$bin/claude" <<'SH'
#!/usr/bin/env bash
printf '%s|%s|%s\n' "$ANTHROPIC_BASE_URL" "$ANTHROPIC_MODEL" "$*" >"$FAKE_LOG"
SH
chmod +x "$bin"/*
export PATH="$bin:$PATH" FAKE_LOG="$t/agent.log" FORGE_OLLAMA_URL="http://127.0.0.1:28111"
forge agent local >/dev/null 2>&1
[[ "$(forge agent)" == "local (gpt-oss:20b via codex)" ]] && ok "forge agent local" || fail "agent local: $(forge agent)"
forge chat "$HOME" >/dev/null 2>&1
grep -q -- "--oss --local-provider ollama -m gpt-oss:20b" "$t/agent.log" && ok "Codex körs med lokal modell" || fail "codex oss: $(cat "$t/agent.log")"
forge agent local qwen3-coder:30b --engine claude >/dev/null 2>&1
FORGE_HEADLESS=1 forge new "lokal app" >/dev/null 2>&1 || true
grep -q "^http://127.0.0.1:28111|qwen3-coder:30b|.*--permission-mode acceptEdits" "$t/agent.log" \
  && ok "Claude Code körs mot Ollama med samma verktyg" || fail "claude local: $(cat "$t/agent.log")"
forge agent claude >/dev/null 2>&1
[[ "$(forge agent)" == "claude" ]] && ok "tillbaka till molnet" || fail "agent claude"

echo "Alla $pass tester gick igenom."
