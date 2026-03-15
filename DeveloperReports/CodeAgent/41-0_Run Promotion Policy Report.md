# Run Promotion Policy Report

**Datum**: 2026-03-15
**Scope**: Budget-Governance fuer Run-Eskalation
**Ziel**: Teure Runs nur wenn noetig, billigere Alternativen bevorzugen

---

## 1. Current Run-Decision Problem

Bisher wurde das Run-Profil (dev/standard/premium) manuell gewaehlt ohne formales Gate. Ergebnis:
- 14 Runs in einer Session, davon mindestens 3 unnoetig (gleicher Output wie vorher)
- Sonnet-Runs kosten ~4x mehr als Haiku-Runs (200k vs 50k Tokens)
- Kein Mechanismus um zu pruefen ob ein LLM-Run ueberhaupt noetig ist
- Statische Validierung (CompileHygiene, CompletionVerifier) kostet 0 Tokens

---

## 2. Promotion-Gate Policy

### Tier-Hierarchie (billigste zuerst)

| Tier | Kosten | Modell | Wann nutzen |
|---|---|---|---|
| **static_validation** | 0 Tokens | keins | CompileHygiene/CompletionVerifier ausfuehren, Reports lesen |
| **dev** | ~50k Tokens | Haiku | Pipeline-Flow testen, Agents debuggen, Ops Layer validieren |
| **standard** | ~200k Tokens | Sonnet | Echten Code generieren, Qualitaet messen, Compile unter Last |
| **premium** | ~500k Tokens | Opus | Architektur-Review, tiefe Refactoring-Entscheidungen |

### Promotion-Regeln

```
static -> dev:     Wenn statische Validierung die Frage nicht beantworten kann
                   (z.B. neuer Agent, neuer Pipeline-Pass, Code-Extraktion testen)

dev -> standard:   Wenn dev-Runs stabil (MOSTLY_COMPLETE) aber Output unzureichend
                   (Haiku generiert zu wenig Code, Qualitaetsfrage offen)

standard -> premium: Nur wenn standard-Output kompiliert aber Architektur/Design
                     verbessert werden muss. Erfordert explizite Budget-Freigabe.

any -> static:     Immer wenn die aktuelle Frage durch CompileHygiene,
                   CompletionVerifier oder Lesen bestehender Reports beantwortbar ist.
```

---

## 3. Exact Central Artifacts

### `config/run_promotion_policy.json`
- Tier-Definitionen (cost, model, preconditions, what it answers)
- Promotion-Rules
- Current-State-Assessment (manuell aktualisierbar)

### `factory/promotion_advisor.py`
- Deterministischer Advisor (kein LLM)
- Liest CompileHygiene + CompletionVerifier Reports
- Entscheidungsbaum: billigste ausreichende Aktion empfehlen
- CLI: `python -m factory.promotion_advisor --project askfin_v1-1`

---

## 4. How the Policy Classifies Current State (Post Run 14)

```
Run Promotion Advisor
  Project:          askfin_v1-1
  Hygiene blocking: 0
  Health:           mostly_complete
  Completeness:     95%
  ---
  Recommendation:   NO_ACTION
  Cost:             ZERO
  Reason:           Baseline is clean. No open question requires a new LLM run.
```

**Kein neuer Run noetig.** Die offenen Optionen sind:
- (a) Anderes Feature-Template testen (z.B. `--name LearningProgress`)
- (b) Auf Mac mit swiftc echten Compile-Check durchfuehren
- (c) Auf neue Anforderungen warten

---

## 5. Cost-Discipline / Safety Benefits

| Situation | Vorher | Nachher |
|---|---|---|
| "Nur schnell testen" | Sonnet-Run (200k Tokens) | **Advisor: static_validation (0 Tokens)** |
| "Pipeline debuggen" | Sonnet-Run | **Advisor: dev (50k Tokens)** |
| "Baseline sauber?" | Sonnet-Run | **Advisor: CompileHygiene (0 Tokens)** |
| "Code-Qualitaet?" | Haiku-Run | **Advisor: standard (korrekt, 200k)** |

### Geschaetzte Einsparung

Von den 14 Runs in dieser Session haetten ~5 durch statische Validierung oder "no_action" ersetzt werden koennen. Das waere ~250k Tokens Einsparung (~$3-5 bei aktuellen Preisen).

---

## 6. Risks / Limits

### Der Advisor ist reaktiv, nicht proaktiv
Er empfiehlt basierend auf dem letzten Report-Stand. Wenn sich die Situation geaendert hat (Code manuell bearbeitet), sind die Reports veraltet. Loesung: Immer `static_validation` zuerst.

### Keine automatische Run-Blockierung
Der Advisor empfiehlt, blockiert aber nicht. Ein `--profile standard` Run kann jederzeit manuell gestartet werden. Das ist bewusst — der Operator (Master Lead) hat das letzte Wort.

### Premium-Tier noch nicht getestet
Opus wurde nie in einem Factory-Run genutzt. Die Preconditions und Kosten-Schaetzungen sind theoretisch.

---

## 7. Single Next Recommended Step

**Keine neue Run noetig.** Der Advisor empfiehlt `NO_ACTION`.

Wenn du weitermachen willst:
1. **Anderes Feature**: `python main.py --template feature --name LearningProgress --profile dev` (Haiku, billig, testet Breadth)
2. **Mac Compile**: Projekt auf Mac synchronisieren, `swiftc` Compile-Check ausfuehren
3. **Docs + Commit**: Alle Aenderungen dieser Session committen und pushen
