# 014 LocalDataServiceProtocol Dedup

**Status**: pending
**Ziel**: Duplikat-Protocol aufloesen mit `dedicated-file-wins` Policy

## Auftrag

1. Finde beide Definitionen:
   - `Services/LocalDataService.swift:3` (mit Sendable)
   - `Models/LocalDataServiceProtocol.swift:3` (mit AnyObject)
2. Kanonisch = `Models/LocalDataServiceProtocol.swift` (dedicated file wins)
3. Entferne die Protocol-Definition aus `Services/LocalDataService.swift`
   - Behalte dort nur die Klasse `LocalDataService` (falls vorhanden)
   - Falls die Klasse das Protocol conformt, stelle sicher dass der Import/Referenz stimmt
4. Pruefe ob die kanonische Definition alle Methoden hat die Consumer erwarten
5. Falls Konflikte zwischen Sendable und AnyObject: Sendable bevorzugen (moderner Swift)

## Policy

`dedicated-file-wins` aus `config/residual_compile_policy.json` — gleiche Policy wie WeakArea (Report 49-0)

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

Ergebnis in `_commands/014_localdataservice_dedup_result.md`:
- Welche Definition kanonisch + warum
- Was entfernt/geaendert
- Typecheck-Ergebnis nach Fix
- Naechster Blocker falls vorhanden

## Git

```bash
git add -A
git commit -m "fix: LocalDataServiceProtocol dedup — dedicated-file-wins (Report 55-0)

- Duplikat aus Services/LocalDataService.swift entfernt
- Kanonisch: Models/LocalDataServiceProtocol.swift"
git push
```
