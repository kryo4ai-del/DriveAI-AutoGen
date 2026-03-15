# Command: Swift Compile Recheck 2 — nach Block-Aware FK-019 Fix

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Wiederhole swiftc Parse-Check nach verbessertem FK-019 Sanitizer (Block-Aware: kommentiert jetzt auch schliessende Klammern mit aus).

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

swiftc -parse $(cat /tmp/askfin_files.txt) 2>&1 | grep "error:" | wc -l
```

## Erwartetes Ergebnis

- **Check 001**: 19 Errors, 16 Files
- **Check 002**: 35 Errors, 17 Files (Sanitizer v1 machte es schlimmer)
- **Check 003**: Erwartet ~1-3 Errors (nur PreviewDataFactory.swift #endif)

Ergebnis in `_commands/003_swift_compile_recheck2_result.md` speichern.
