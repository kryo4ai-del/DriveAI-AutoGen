# CompletionVerifier Evidence Mode Report

**Datum**: 2026-03-15
**Scope**: Project-Evidence Mode wenn kein specs/ Verzeichnis existiert
**Ziel**: Ehrliche Completion-Bewertung ohne kuenstliches FAILED

---

## 1. Root Cause in Old CompletionVerifier Logic

### Hard-Failure Kette

```python
# _discover_expected(): Kein specs/ -> return []
# total_expected = 0

# classify_health():
if total_expected == 0:
    return ProjectHealth.FAILED  # <-- sofort FAILED

# Recovery Gate in main.py:
# health == "failed" -> "too little output for recovery"
```

### Auswirkung

AskFin hat 173 Swift-Files, alle Core-Ordner, 0 Compile-Hygiene-Blockers — aber CompletionVerifier meldet `FAILED` weil kein `specs/` Verzeichnis existiert. Das blockiert Recovery und produziert eine false `0% completeness`.

---

## 2. Exact Central Fix Implemented

### Neuer Verdict: `INSUFFICIENT_EVIDENCE`

```python
class ProjectHealth(str, Enum):
    COMPLETE = "complete"
    MOSTLY_COMPLETE = "mostly_complete"
    INCOMPLETE = "incomplete"
    FAILED = "failed"
    INSUFFICIENT_EVIDENCE = "insufficient_evidence"  # NEU
```

### Zwei Modi in `verify()`

```python
def verify(self):
    expected_names = self._discover_expected()
    has_specs = len(expected_names) > 0

    if has_specs:
        # Original spec-based mode (unveraendert)
        ...
    else:
        # NEW: Project-evidence mode
        self._verify_from_project_evidence()
```

### Project-Evidence Mode

Wenn kein `specs/` existiert, sammelt der Verifier Evidenz aus:
1. **Projekt-Dateien**: Zaehlt Swift-Files im Projekt (ausserhalb generated/)
2. **Core-Ordner**: Prueft ob Models/, Views/, ViewModels/, Services/ vorhanden
3. **Generated Artifacts**: Was hat diese Run produziert?
4. **Compile Hygiene**: Liest den letzten Hygiene-Report (blocking count)

### Verdikt-Logik

```
project_files == 0                        -> FAILED
project_files < 10                        -> INSUFFICIENT_EVIDENCE
3+ core folders missing                   -> INCOMPLETE
hygiene_blocking > 0                      -> INCOMPLETE (80%)
hygiene_blocking == 0 + all folders       -> MOSTLY_COMPLETE (95%)
hygiene_blocking == 0 + some missing      -> INCOMPLETE (70%)
hygiene unknown + files >= 50 + folders   -> MOSTLY_COMPLETE (85%)
else                                      -> INSUFFICIENT_EVIDENCE
```

---

## 3. New Verdict / Evidence Model

| Verdict | Bedeutung | Recovery-Verhalten |
|---|---|---|
| `COMPLETE` | Alle Specs erfuellt, keine Luecken | Kein Recovery |
| `MOSTLY_COMPLETE` | >= 80% oder starke Evidenz | **Kein Recovery (NEU: nicht mehr FAILED)** |
| `INCOMPLETE` | 40-79% oder fehlende Struktur | Recovery Loop (max 2 Versuche) |
| `FAILED` | < 40% oder kein Output | Recovery Skip |
| `INSUFFICIENT_EVIDENCE` | Zu wenig Daten fuer Urteil | **Recovery Skip (ehrlich)** |

---

## 4. What Sources of Evidence Are Now Used

| Evidenz-Quelle | Vorher | Nachher |
|---|---|---|
| specs/*.md | Einzige Quelle | Primaere Quelle (wenn vorhanden) |
| Projekt Swift-Files | Nicht genutzt | **Gezaehlt (173 bei AskFin)** |
| Core-Ordner Struktur | Nur in generated/ | **Im Projekt-Root** |
| Compile Hygiene Report | Nicht genutzt | **Blocking-Count gelesen** |
| Generated Artifacts | Gezaehlt | Weiterhin gezaehlt |

---

## 5. Validation on Current Project

### AskFin (askfin_v1-1)

```
Spec source:    project-evidence
Health status:  MOSTLY_COMPLETE
Completeness:   95%
Project files:  173
Blocking:       0
Missing folders: []
```

### Vorher vs Nachher

| Metrik | Vorher | Nachher |
|---|---|---|
| Health | FAILED | **MOSTLY_COMPLETE** |
| Completeness | 0% | **95%** |
| Spec source | none | **project-evidence** |
| Recovery | SKIP ("too little output") | **SKIP ("no recovery needed")** |
| Ehrlichkeit | Falsch negativ | **Korrekt** |

---

## 6. Whether Recovery Is Still Blocked for the Old Reason

**Nein** — Recovery wird nicht mehr fuer den alten Grund blockiert.

| Situation | Vorher | Nachher |
|---|---|---|
| 173 Files, 0 blocking | FAILED -> Skip | **MOSTLY_COMPLETE -> No recovery needed** |
| 173 Files, 3 blocking | FAILED -> Skip | **INCOMPLETE -> Recovery Loop** |
| 0 Files, kein Projekt | FAILED -> Skip | FAILED -> Skip (korrekt) |
| < 10 Files | FAILED -> Skip | **INSUFFICIENT_EVIDENCE -> Skip (ehrlich)** |

---

## 7. Risks or Limitations

### 7.1 Project-Evidence ist keine Spec-Validierung
Der Verifier kann nicht pruefen ob *bestimmte* erwartete Features fehlen. Er misst nur "ist das Projekt strukturell gesund?". Fuer Feature-Completeness braucht man echte Specs.

### 7.2 Hygiene-Report kann veraltet sein
Der Verifier liest den letzten gespeicherten Hygiene-Report. Wenn der veraltet ist, koennte das Verdikt falsch sein. Im normalen Pipeline-Ablauf laeuft Hygiene aber immer vor dem Verifier.

### 7.3 95% ist geschaetzt, nicht gemessen
Die Completeness-Prozentzahl im Evidence-Mode ist eine heuristische Schaetzung basierend auf Ordner-Struktur und Hygiene-Status, nicht auf einem File-fuer-File-Vergleich.

### 7.4 MOSTLY_COMPLETE bei Hygiene blocking=0 ist optimistisch
Wenn der Hygiene-Validator keine Probleme findet, heisst das nur "keine bekannten Muster erkannt". Echte Swift-Compile-Fehler koennte es trotzdem geben (swiftc laeuft nicht auf Windows).

---

## 8. Single Next Recommended Step

**Run ein neuntes Autonomy Proof** um zu validieren dass die gesamte Pipeline — inklusive CompletionVerifier MOSTLY_COMPLETE + kein falsches Recovery — im Live-Run funktioniert.

Das System ist jetzt strukturell komplett:
- Auto-Inferenz (Projekt)
- 6 Pipeline-Passes
- CD Gate (profile-aware)
- OutputIntegrator (5-Layer Dedup)
- CompileHygiene (column-aware, memberwise, SwiftUI-aware)
- TypeStubGenerator (FK-014 auto-fix)
- PropertyShapeRepairer (FK-013 auto-fix, SwiftUI-aware)
- CompletionVerifier (project-evidence mode)
- RunMemory + KnowledgeWriteback
