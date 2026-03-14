# Factory Error Pattern Seed — Round 1

**Datum:** 2026-03-14
**Quelle:** `projects/askfin_v1-1/fix_report_20260313.md` (35 Bugs, BUILD SUCCEEDED)
**Entries erstellt:** 7 (FK-011 bis FK-017)

---

## Warum diese Runde

Die AskFin Premium App (askfin_v1-1) wurde von der Factory generiert und hatte beim ersten Xcode-Build 50+ Compile Errors. Ein manueller Fix-Pass auf dem Mac hat 35 Bugs behoben. Diese Bugs sind nicht einmalige Zufaelle — sie repraesentieren **systematische Fehlerklassen**, die bei jedem kuenftigen Factory-Run wieder auftreten werden, wenn sie nicht als Wissen kodifiziert werden.

---

## Welche Patterns wurden hinzugefuegt

| ID | Titel | Kategorie | Evidenz (Bugs) |
|---|---|---|---|
| FK-011 | AI review text in source files | generation_safety | BUG-CR-001, FIX-BUILD-001 bis 004 (5 Dateien) |
| FK-012 | Duplicate type definitions | type_consistency | BUG-CR-002/004/005/008, FIX-BUILD-005/006/013 (8+ Redeclarations) |
| FK-013 | Wrong parameter names at call sites | compile_hygiene | FIX-BUILD-014 (4 Views), FIX-BUILD-015 |
| FK-014 | Referenced types never generated | type_consistency | BUG-CR-003, FIX-BUILD-007/009/010/016 |
| FK-015 | Bundle.module in regular Xcode targets | xcode_integration | FIX-BUILD-012 (5 Dateien) |
| FK-016 | Custom init suppresses memberwise init | compile_hygiene | FIX-BUILD-017 |
| FK-017 | Feature-layer type name collisions | architecture_pattern | FIX-BUILD-006 (3 Typen, ~15 Dateien) |

---

## Warum genau diese 7

**Auswahlkriterien:**
1. **Haeufigkeit** — Wie oft trat das Muster im Report auf?
2. **Schwere** — Wie viele Compile Errors verursacht ein einzelnes Vorkommen?
3. **Wiederholbarkeit** — Wird das bei jedem Factory-Run wieder passieren?
4. **Vermeidbarkeit** — Gibt es eine klare Prevention Rule?

**FK-011 (AI-Text):** 5 von 75 Dateien betroffen = 6.7% Korruptionsrate. Hoechste Prioritaet weil die Dateien komplett unbrauchbar werden.

**FK-012 (Duplikate):** 8+ Vorkommen. Entsteht zwangslaeufig wenn mehrere Agents unabhaengig Typen erzeugen.

**FK-013 (Parameter Mismatch):** 4 Views betroffen. Entsteht wenn Producer und Consumer in verschiedenen Passes generiert werden.

**FK-014 (Fehlende Typen):** Breitestes Impact — betrifft Types, Protocols, Service-Methoden. Hauptursache: MAX_FILES_PER_RUN Limit und Timeouts.

**FK-015 (Bundle.module):** Betrifft jedes Projekt das kein Swift Package ist. Einfach zu erkennen, einfach zu verhindern.

**FK-016 (Memberwise Init):** Swift-spezifische Falle. Ueberraschend fuer AI-Generatoren die die Swift-Regel nicht kennen.

**FK-017 (Namespace-Kollision):** Betrifft jedes Projekt mit mehreren Feature-Layern. Wird schlimmer je groesser das Projekt wird.

---

## Bewusst ausgeschlossene Entries

| Kandidat | Grund fuer Ausschluss |
|---|---|
| Fehlende import Statements (FIX-BUILD-020) | Zu spezifisch, trivial zu fixen, kein systematisches Muster |
| Fehlende await (FIX-BUILD-021) | Einzelfall, kein wiederkehrendes Factory-Problem |
| Nicht-existierendes SF Symbol (BUG-CR-010) | Zu spezifisch fuer iOS, kein generisches Muster |
| weightedAccuracy nie aktualisiert (BUG-CR-006) | Logik-Bug, kein Compile-Error — anderer Entry-Typ noetig |
| String vs LocalizedStringKey (FIX-BUILD-019) | Abgedeckt durch FK-015 (gleiche Root Cause) |
| Self vor Initialisierung (FIX-BUILD-018) | Einzelfall, Swift-Compiler gibt klare Fehlermeldung |

---

## Wie diese Entries kuenftige Factory-Runs verbessern

### Sofort nutzbar (ohne Pipeline-Aenderung):
- Agents koennen die Patterns als System-Prompt-Kontext erhalten
- Bug Hunter kann gezielt nach FK-011 bis FK-017 Mustern suchen
- Code Review Checkliste fuer Post-Generation Validation

### Mit Pipeline-Aenderung (empfohlen):
- **Post-Generation Validator:** Automatisches Script das FK-011 (Markdown in .swift), FK-012 (Duplikate), FK-015 (Bundle.module) prueft
- **Type Registry:** Waehrend der Generation eine Liste aller definierten Typen fuehren (verhindert FK-012, FK-014, FK-017)
- **Signature Cross-Reference:** Consumer-Code gegen Producer-Signaturen validieren (verhindert FK-013)

---

## Naechster Schritt

**Empfohlen:** Round 2 — Pipeline Integration
- Post-Generation Validator als Python-Script implementieren
- Die 3 automatisch pruefbaren Patterns (FK-011, FK-012, FK-015) als Hard Gates einbauen
- Bug Hunter System-Prompt um FK-011 bis FK-017 erweitern
