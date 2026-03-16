# 016 ReadinessLevelBadge SwiftUI Structure Fix

**Status**: pending
**Ziel**: Kaputte Group/switch View-Struktur reparieren

## Auftrag

1. Lies `Models/ReadinessLevelBadge.swift` komplett
2. Identifiziere die Probleme:
   - `Group { switch level { ... } }` wird als TableColumnBuilder statt ViewBuilder interpretiert
   - `.developing` Case existiert nicht auf ReadinessLevel (Cases: .notReady, .partiallyReady, .ready, .excellent)
   - background-Modifier-Syntax fehlerhaft
3. Korrigiere die View-Struktur:
   - Ersetze `Group { switch ... }` durch direktes switch im body (oder VStack/HStack falls noetig)
   - Ersetze `.developing` durch den passenden existierenden Case
   - Stelle sicher dass jeder switch-Branch genau einen View returniert
   - Kanonisches SwiftUI Pattern:
     ```swift
     var body: some View {
         Text(level.emoji + " " + level.rawValue)
             .padding(.horizontal, 8)
             .padding(.vertical, 4)
             .background(backgroundColor)
             .cornerRadius(8)
     }

     private var backgroundColor: Color {
         switch level {
         case .notReady: return .red.opacity(0.2)
         case .partiallyReady: return .orange.opacity(0.2)
         case .ready: return .green.opacity(0.2)
         case .excellent: return .yellow.opacity(0.2)
         }
     }
     ```
4. Halte die Aenderung minimal — nur das noetige reparieren

## Policy

Erweitere `config/residual_compile_policy.json`:
- Pattern-Familie: `swiftui_viewbuilder_structure`
- Policy: `canonical-pattern-rewrite` — Group/switch → separate computed property fuer branching

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

Ergebnis in `_commands/016_readinesslevel_badge_fix_result.md`:
- Was genau kaputt war (Code vorher)
- Wie repariert (Code nachher)
- Typecheck-Ergebnis nach Fix
- Naechster Blocker falls vorhanden

## Git

```bash
git add -A
git commit -m "fix: ReadinessLevelBadge SwiftUI structure normalization (Report 57-0)

- Group/switch → canonical pattern rewrite
- .developing → korrekter ReadinessLevel Case
- Policy: canonical-pattern-rewrite"
git push
```
