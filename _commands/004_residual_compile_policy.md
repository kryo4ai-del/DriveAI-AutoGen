# Command: Residual Compile Outlier Policy + Fix

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Definiere eine zentrale Policy fuer residuale Compile-Outlier und wende sie auf die 2 verbleibenden Files an.

## Kontext

Nach FK-019 Sanitizer sind 225/227 Files sauber. 2 Files bleiben:
- `ReadinessScore+Extension.swift` (3 Errors — Code-Fragment ohne umschliessende Struktur)
- `PreviewDataFactory.swift` (1 Error — fehlendes #endif)

Beide sind Debug/Preview-only Code.

## Aufgaben

### 1. Policy definieren

Erstelle `config/residual_compile_policy.json` mit:
- Klassifizierungs-Schema: release-critical vs debug-only
- Dispositions: quarantine / manual-fix / ignore-for-release
- Aktueller Status der 2 Files

### 2. Die 2 Files fixen (manuell, auf dem Mac)

**ReadinessScore+Extension.swift**: Pruefen ob der Inhalt sinnvoll ist. Wenn Code-Fragment: quarantinieren oder in korrekte Extension wrappen.

**PreviewDataFactory.swift**: `#endif` am Ende anfuegen.

### 3. Compile recheck

```bash
cd /Users/andreasott/DriveAI-AutoGen
git pull origin main

# Fix anwenden, dann:
find projects/askfin_v1-1 -name "*.swift" \
  -not -path "*/quarantine/*" \
  -not -path "*/generated/*" \
  > /tmp/askfin_files.txt

swiftc -parse $(cat /tmp/askfin_files.txt) 2>&1 | head -50
echo "Exit code: $?"
swiftc -parse $(cat /tmp/askfin_files.txt) 2>&1 | grep "error:" | wc -l
```

### 4. Report schreiben

Report in `DeveloperReports/CodeAgent/45-0_Residual Compile Policy Report.md` mit:
1. Policy definiert
2. Klassifizierung beider Files
3. Welche Disposition gewaehlt wurde
4. Compile-Ergebnis nach Fix
5. Ob 0 Errors erreicht wurde

### 5. Commit + Push

```bash
git add -A
git commit -m "factory: residual compile policy + fix last 2 parse errors

- config/residual_compile_policy.json: classification schema
- ReadinessScore+Extension.swift: [quarantined/fixed]
- PreviewDataFactory.swift: #endif added
- Report 45-0

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push
```

Ergebnis in `_commands/004_residual_compile_policy_result.md` speichern.
