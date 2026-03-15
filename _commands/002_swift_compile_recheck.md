# Command: Swift Compile Recheck nach FK-019 Sanitization

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Wiederhole den swiftc Parse-Check nach der FK-019 Top-Level-Statement-Sanitization.
Ziel: Pruefen ob die 16 Fehler von Check 001 jetzt behoben sind.

## Vorbereitung

```bash
cd /Users/andreasott/DriveAI-AutoGen
git pull origin main
```

## Befehl

```bash
find projects/askfin_v1-1 -name "*.swift" \
  -not -path "*/quarantine/*" \
  -not -path "*/generated/*" \
  > /tmp/askfin_files.txt

echo "Files to check: $(wc -l < /tmp/askfin_files.txt)"

swiftc -parse $(cat /tmp/askfin_files.txt) 2>&1 | head -100
echo "Exit code: $?"

# Auch: Anzahl Errors zaehlen
swiftc -parse $(cat /tmp/askfin_files.txt) 2>&1 | grep "error:" | wc -l
```

## Erwartetes Ergebnis

1. **Exit Code** (0 = clean)
2. **Anzahl verbleibende Errors** (erwartet: 0-2, vorher: 19)
3. **Ob PreviewDataFactory.swift noch Fehler hat** (erwartet: ja, #endif fehlt)
4. **Ob neue Fehler aufgetaucht sind** die vorher nicht da waren

Ergebnis in `_commands/002_swift_compile_recheck_result.md` speichern.
