# 013 ExamReadinessServiceProtocol Contract Fix

**Status**: pending
**Ziel**: Fehlende 4 Methoden im Protocol ergaenzen + Service-Implementierung anpassen

## Auftrag

1. Lies `ExamReadinessServiceProtocol` (Models/ExamReadinessServiceProtocol.swift oder wo es liegt)
2. Lies `ExamReadinessViewModel.swift` — dort werden diese 4 Methoden aufgerufen:
   - `calculateOverallReadiness()`
   - `getCategoryReadiness()`
   - `getWeakCategories(limit:)`
   - `getTrendData(days:)`
3. Pruefe ob `ExamReadinessService` (die Klasse) diese Methoden schon implementiert
4. Falls nicht: Ergaenze die Methoden sowohl im Protocol als auch in der Service-Klasse
5. Falls Return-Types unklar: Schau dir die Aufrufstellen im ViewModel an um die erwarteten Typen abzuleiten
6. Policy: `consumer-declares-need` — der Consumer (ViewModel) definiert den Contract, das Protocol muss nachziehen

## Typische Signatur-Muster (aus ViewModel abzuleiten)

```swift
protocol ExamReadinessServiceProtocol {
    // ... bestehende Methoden ...
    func calculateOverallReadiness() async throws -> /* Typ aus ViewModel ableiten */
    func getCategoryReadiness() async throws -> /* [CategoryReadiness] oder aehnlich */
    func getWeakCategories(limit: Int) async throws -> /* [WeakCategory] oder aehnlich */
    func getTrendData(days: Int) async throws -> /* [ReadinessTrendPoint] oder aehnlich */
}
```

## Residual Compile Policy

Erweitere `config/residual_compile_policy.json` v1.5+:
- Pattern-Familie: `protocol_method_gap`
- Policy: `consumer-declares-contract` — Protocol wird an Consumer-Erwartungen angepasst

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

Ergebnis in `_commands/013_protocol_contract_fix_result.md`:
- Root cause
- Welche Methoden ergaenzt (Protocol + Service)
- Return-Types gewaehlt + Begruendung
- Typecheck-Ergebnis nach Fix
- Naechster Blocker falls vorhanden

## Git

```bash
git add -A
git commit -m "fix: ExamReadinessServiceProtocol contract completion (Report 54-0)

- 4 fehlende Methoden in Protocol + Service ergaenzt
- Policy: consumer-declares-contract
- Residual compile policy v1.5"
git push
```
