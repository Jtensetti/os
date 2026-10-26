---
name: forge-local-ai
description: Run the Forge agent on a local model (Ollama) instead of the cloud, with the same tools as Claude Code and Codex. Use when the user wants offline/private AI, asks about local models, or about which model fits their hardware.
---
# Lokal AI

Forge kör alltid samma agentprogram — Claude Code eller Codex — så verktygen är desamma
(filer, terminal, MCP som REA, skills). Med lokal AI byts bara *modellen* ut mot en som körs
på datorn via Ollama.

```
forge agent local                          # gpt-oss:20b via Codex (standard)
forge agent local qwen3-coder:30b          # annan modell
forge agent local qwen3-coder:30b --engine claude   # Claude Code mot Ollama
forge agent claude | codex                 # tillbaka till molnet
```

- Codex körs med `--oss --local-provider ollama -m <modell>`.
- Claude Code körs med `ANTHROPIC_BASE_URL=http://localhost:11434` och alla modellnivåer
  satta till den lokala modellen (Ollama ≥ 0.14 talar Anthropics Messages API).
- Modellen laddas ner automatiskt första gången.

## Välja modell (tumregel)
| Minne (VRAM/RAM) | Förslag |
|---|---|
| 16 GB | `gpt-oss:20b` |
| 24–32 GB | `qwen3-coder:30b` |
| 64 GB+ | större kodmodeller, t.ex. `gpt-oss:120b` |

Agentarbete behöver lång kontext (minst 32k, gärna 64k tokens) och bra stöd för verktygsanrop.
Sätt kontexten i Ollama (`OLLAMA_CONTEXT_LENGTH=65536` i tjänstens miljö via
`rootfs/etc/systemd/system/ollama.service.d/forge.conf`). Lokala modeller är långsammare och
svagare än de bästa molnmodellerna: för stora appar, föreslå molnet; för små ändringar och
privat data passar lokalt bra.
