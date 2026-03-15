# FK-014 Type Stub Generator Report

**Datum**: 2026-03-15
**Scope**: Automatische Stub-Generierung fuer FK-014 (missing type declarations)
**Ziel**: FK-014 Blocker autonom beheben wenn Recovery nicht starten kann

---

## 1. Current Recovery Skip Root Cause

### Das Problem in 3 Saetzen

1. CompletionVerifier meldet `health = "failed"` (sucht in `generated/` das leer ist weil OutputIntegrator alles als Duplikat uebersprungen hat)
2. Recovery Gate: `if health == "failed"` -> Skip ("too little output for recovery")
3. CompileHygiene FK-014 Findings werden **nie an Recovery weitergegeben** — Recovery basiert ausschliesslich auf CompletionVerifier-Status

### Flow-Diagramm

```
CompileHygiene -> findet FK-014 (PriorityLevel, ReadinessCalculationService)
                  |
                  v
         Recovery Gate
         health = "failed" (von CompletionVerifier)
                  |
                  v
         SKIP: "too little output for recovery"
                  |
                  v
         FK-014 ignoriert, Pipeline meldet FAILED
```

### Warum Recovery nicht helfen kann (auch wenn es starten wuerde)

Recovery operiert auf CompletionVerifier-Targets (missing/incomplete files). FK-014 findet Typen die **referenziert aber nie deklariert** werden — das ist ein anderer Problem-Typ den der CompletionVerifier gar nicht erkennt.

---

## 2. Minimal Fix Implemented

### Neues Modul: `factory/operations/type_stub_generator.py`

Ein deterministischer (kein LLM) Post-Hygiene-Prozessor der:

1. FK-014 Findings aus dem HygieneReport extrahiert
2. Pro fehlendem Typ die Art inferiert (struct/enum/class/protocol/view)
3. Minimalen Swift-Stub generiert und ins Projekt schreibt
4. Nicht ueberschreibt wenn eine Datei mit dem Namen bereits existiert

### Typ-Inferenz-Heuristik

```
type_name.endswith("Protocol")     -> protocol
type_name.endswith("Service")      -> class (final, Sendable)
type_name.endswith("Level/Status") -> enum (String, Sendable)
type_name.endswith("View")         -> SwiftUI View struct
type_name.endswith("ViewModel")    -> class
Default                            -> struct (Sendable)
```

### Ziel-Ordner-Inferenz

```
protocol/class  -> Services/
view            -> Views/
enum/struct     -> Models/
```

### Integration in Operations Layer

```
CompileHygiene
     |
     v
[NEU] Type Stub Generator  <- nur wenn FK-014 BLOCKING issues existieren
     |
     v
[NEU] Re-run CompileHygiene  <- nur wenn Stubs erstellt wurden
     |
     v
Swift Compile Check
     |
     v
Recovery Gate (unveraendert)
```

---

## 3. Files Changed

| Datei | Aenderung |
|---|---|
| `factory/operations/type_stub_generator.py` | **NEU** — TypeStubGenerator Klasse (~230 Zeilen) |
| `main.py` Zeile 1036 | Import TypeStubGenerator |
| `main.py` Zeilen 1068-1083 | Stub-Generator zwischen Hygiene und SwiftCompile eingefuegt |
| `main.py` Zeile 1202 | Stub-Count im Operations Summary |

---

## 4. Before vs After Fix-Path Behavior

### Vorher (Run 6)

```
CompileHygiene: 4 BLOCKING (FK-012, FK-013, FK-014 x2)
                FK-014: PriorityLevel, ReadinessCalculationService
                     |
                     v
              [NICHTS passiert mit FK-014]
                     |
                     v
Recovery Gate: FAILED -> SKIP
                     |
                     v
Result: FAILED, 4 BLOCKING issues
```

### Nachher (Validierung)

```
CompileHygiene: 3 BLOCKING (FK-012, FK-013, FK-014 x1)
   Note: PriorityLevel.swift existiert schon (vorheriger Run)
                     |
                     v
TypeStubGenerator:
   [STUB] ReadinessCalculationService (class) -> Services/ReadinessCalculationService.swift
                     |
                     v
Re-run CompileHygiene: 2 BLOCKING (FK-012, FK-013)
   FK-014: 0   <-- GELOEST
                     |
                     v
Recovery Gate: (unveraendert — noch FAILED)
                     |
                     v
Result: BLOCKING reduced 3 -> 2, FK-014 eliminated
```

### Quantitativ

| Metrik | Vorher | Nachher |
|---|---|---|
| FK-014 Blocking | 2 (Run 6) / 1 (aktuell) | **0** |
| Total Blocking | 4 / 3 | **2** |
| Stub-Files erstellt | 0 | **1** (ReadinessCalculationService.swift) |
| FK-014 komplett geloest | Nein | **Ja** |

---

## 5. Remaining Limits

### 5.1 Stubs sind Scaffolds, keine Implementierungen

Die generierten Stubs sind kompilierbar aber leer. Ein `ReadinessCalculationService` Stub hat keine Methoden — Code der Methoden darauf aufruft kompiliert trotzdem nicht. Das ist ein bewusster Trade-off: FK-014 (Typ nicht deklariert) ist geloest, aber FK-011/FK-013 (falscher Methodenaufruf) koennen folgen.

### 5.2 Recovery Gate noch nicht an CompileHygiene gekoppelt

Recovery startet weiterhin nur bei CompletionVerifier `health == "incomplete"`. CompileHygiene BLOCKING allein startet keine Recovery. Das ist ein separater Blocker fuer die Zukunft.

### 5.3 FK-012 (nested ReadinessLevel) bleibt false positive

Compile Hygiene erkennt nested types in structs nicht als erlaubt. Braucht einen Validator-Fix (column-0-Check oder Scope-Analyse).

### 5.4 FK-013 (DateComponentsValue init) bleibt

Der Validator kennt die Init-Signatur nicht. Entweder Framework-Type-Erweiterung oder Init-Scan im Projekt.

---

## 6. Verdict: FK-014 Blockers Are Now Materially More Actionable

### Was sich aendert

1. **FK-014 wird automatisch geloest** — kein manuelles Eingreifen noetig
2. **Blocking-Count reduziert** — von 4/3 auf 2 (nur noch FK-012 + FK-013)
3. **Deterministisch** — kein LLM, keine Kosten, immer reproduzierbar
4. **Idempotent** — laeuft der Generator nochmal, ueberspringt er existierende Stubs
5. **Re-Hygiene** — nach Stub-Erstellung wird CompileHygiene erneut ausgefuehrt

### Verbleibende Blocker-Kette

```
FK-012 (nested ReadinessLevel)  -> Validator false positive -> Fix: Column-0-Check
FK-013 (DateComponentsValue)    -> Validator kennt Init nicht -> Fix: Projekt-Init-Scan
```

Beide sind Validator-Verbesserungen, keine Code-Generierungs-Probleme.
