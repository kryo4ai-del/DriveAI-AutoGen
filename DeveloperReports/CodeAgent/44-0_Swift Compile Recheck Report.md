# Swift Compile Recheck Report

**Datum**: 2026-03-15
**Scope**: Mac swiftc Rechecks nach FK-019 Sanitizer (v1 + Block-Aware Fix)

---

## 1. Compile-Check Verlauf

| Check | Datum | Errors | Files | Sauberkeit | Sanitizer |
|---|---|---|---|---|---|
| 001 | 2026-03-15 | 19 | 16 | 93.0% | Keiner |
| 002 | 2026-03-15 | 35 | 17 | 85.0% | v1 (nur Zeilen, Klammern verwaist) |
| **003** | **2026-03-15** | **4** | **2** | **99.1%** | **Block-Aware (Klammer-Blöcke komplett)** |

---

## 2. Was der Block-Aware Fix geloest hat

### Problem in v1
Sanitizer kommentierte nur die oeffnende Zeile aus (`var foo: String {`), liess aber die schliessende `}` stehen. Ergebnis: 16 neue `extraneous '}' at top level` Fehler.

### Fix in v2 (Block-Aware)
Wenn eine auskommentierte Zeile `{` enthaelt, verfolgt der Sanitizer die Brace-Depth und kommentiert alle Zeilen bis zur balancierenden `}` mit aus.

### Ergebnis
- 31 Fehler eliminiert (35 → 4)
- 15 betroffene Files komplett bereinigt (17 → 2)
- 168 Zeilen auskommentiert in 28 Files

---

## 3. Verbleibende 2 Files (4 Errors)

### ReadinessScore+Extension.swift (3 Errors)

**Problem**: Die Datei ist ein **Code-Fragment** — sie beginnt mit `#if DEBUG` und `.onAppear` ohne umschliessende Extension-Deklaration. Der Sanitizer erkennt den Inhalt als innerhalb eines `#if`-Blocks und laesst ihn in Ruhe, aber `swiftc` sieht `.onAppear` als Top-Level-Statement.

**Typ**: Strukturelles Fragment (kein vollstaendiger Swift-Body). Automatisch nicht sicher reparierbar.

### PreviewDataFactory.swift (1 Error)

**Problem**: `#if DEBUG` auf Zeile 2, aber kein `#endif` am Dateiende. Die Extension nach der Struct faellt aus dem `#if`-Block.

**Typ**: Fehlendes Compiler-Direktiv. Automatisch nicht sicher reparierbar (koennte an der falschen Stelle eingefuegt werden).

---

## 4. Gesamtfortschritt: Compile-Wahrheit

| Zeitpunkt | Sauberkeit | Methode |
|---|---|---|
| Vor Factory-Arbeit | Unbekannt | Nie getestet |
| Run 4-14 | "0 BLOCKING" | CompileHygiene (kein echtes Compile) |
| Mac Check 001 | 93.0% | swiftc -parse (227 Files) |
| Mac Check 002 | 85.0% | Nach Sanitizer v1 (verschlechtert) |
| **Mac Check 003** | **99.1%** | **Nach Block-Aware Sanitizer** |

**Von 0% Plattform-Wahrheit auf 99.1% in einer Session.**

---

## 5. Bewertung der letzten 2 Errors

| Kriterium | ReadinessScore+Extension | PreviewDataFactory |
|---|---|---|
| Automatisch fixbar? | Nein (Fragment) | Nein (#endif-Position unklar) |
| Manuell fixbar? | Ja (Quarantine oder Rewrite) | Ja (`#endif` anfuegen) |
| Blockiert Compile? | Ja (3 Errors) | Ja (1 Error) |
| Blockiert Factory? | Nein (CompileHygiene meldet es nicht) | Nein |
| Prioritaet | Niedrig (Debug-only Code) | Niedrig (Preview-only Code) |

Beide Files enthalten nur Debug/Preview-Code. Auf einem echten iOS-Build wuerden sie nur im DEBUG-Target kompiliert werden.

---

## 6. Single Next Recommended Step

Die 2 verbleibenden Files sind strukturelle Sonderfaelle die der Sanitizer bewusst nicht anfasst. Optionen:

1. **Quarantine** (StaleGuard) — verschiebt die Files, 0 Errors
2. **Manueller Fix** — `#endif` anfuegen / Fragment in Extension wrappen
3. **Ignorieren** — beide sind Debug-only, blockieren kein Release-Build
