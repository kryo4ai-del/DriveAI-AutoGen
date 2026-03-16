# 020 TrendAnalyzer Trailing-Closure Ambiguity Fix

**Status**: pending
**Ziel**: Swift trailing-closure Ambiguity in TrendAnalyzer.swift beheben

## Auftrag

1. Lies `Models/TrendAnalyzer.swift` komplett
2. Finde die Stelle um Zeile 18 mit dem Fehler:
   `cannot call value of non-function type 'Question?'`
3. Das Problem ist vermutlich:
   ```swift
   // Fehlerhaft (trailing closure auf Optional-Ergebnis):
   questions.first(where: { $0.id == someId })?.category
   // oder:
   questions.first { $0.id == someId }?.category
   ```
4. Fix: Explizite Klammern statt trailing closure:
   ```swift
   // Korrekt:
   questions.first(where: { $0.id == someId })?.category
   ```
   Oder Zwischenvariable:
   ```swift
   let question = questions.first(where: { $0.id == someId })
   let category = question?.category
   ```
5. Policy: `explicit-call-over-trailing-closure` — bei Optional-Chaining immer explizite Klammern

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

Ergebnis in `_commands/020_trendanalyzer_syntax_result.md`:
- Exakte fehlerhafte Zeile (vorher)
- Fix (nachher)
- Typecheck-Ergebnis
- Naechster Blocker falls vorhanden

## Git

```bash
git add -A
git commit -m "fix: TrendAnalyzer trailing-closure ambiguity (Report 61-0)

- Explicit call syntax statt trailing closure bei Optional chain
- Policy: explicit-call-over-trailing-closure"
git push
```
