# 015 ReadinessLevel.emoji Contract Fix

**Status**: pending
**Ziel**: Fehlende `emoji` Property auf ReadinessLevel ergaenzen

## Auftrag

1. Finde die kanonische `ReadinessLevel` Definition (vermutlich `Models/ReadinessLevel.swift`)
2. Finde alle Consumer die `.emoji` aufrufen (z.B. `ReadinessLevelBadge.swift:7`)
3. Pruefe ob `ReadinessLevel` ein enum oder struct ist
4. Ergaenze eine `emoji` computed property die zum jeweiligen Level passt:
   - z.B. `.excellent` → "🟢", `.good` → "🟡", `.needsWork` → "🟠", `.critical` → "🔴"
   - Wenn die Case-Namen anders sind: Passende Emoji-Zuordnung ableiten
5. Policy: `consumer-declares-need` — Consumer erwartet Display-Property, Enum muss liefern

## Policy

Erweitere `config/residual_compile_policy.json`:
- Pattern-Familie: `enum_display_contract_gap`
- Policy: `consumer-declares-need` — fehlende Display-Properties (emoji, color, label, icon) werden ergaenzt

## Nach dem Fix

```bash
cd ~/DriveAI-AutoGen
xcrun swiftc -typecheck \
  projects/askfin_v1-1/**/*.swift \
  -sdk $(xcrun --show-sdk-path) \
  -target arm64-apple-macosx15.0 \
  2>&1 | head -60
```

## Report

Ergebnis in `_commands/015_readinesslevel_emoji_result.md`:
- Welche Cases ReadinessLevel hat
- Welche emoji-Zuordnung gewaehlt
- Typecheck-Ergebnis nach Fix
- Naechster Blocker falls vorhanden

## Git

```bash
git add -A
git commit -m "fix: ReadinessLevel.emoji display-contract completion (Report 56-0)

- emoji computed property ergaenzt
- Policy: consumer-declares-need (enum display contract)"
git push
```
