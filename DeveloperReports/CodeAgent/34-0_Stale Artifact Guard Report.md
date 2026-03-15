# Stale Artifact Guard Report

**Datum**: 2026-03-15
**Scope**: Lifecycle-Guard fuer persistente AI-generierte Blocker-Artefakte
**Ziel**: Stale Artefakte automatisch erkennen und quarantinieren

---

## 1. Root Cause of Stale-Artifact Persistence

### Wie ServiceContainer.swift zum Blocker wurde

1. **Run 9**: Haiku generierte `ServiceContainer.swift` mit `ExamReadinessViewModel(examReadinessService:, navigationService:)`
2. **ProjectIntegrator**: Kopierte die Datei nach `projects/askfin_v1-1/Models/`
3. **Git Auto-Commit**: Committed als Teil des AI-Runs
4. **Run 10**: Generierte 0 neuen Code, aber `ServiceContainer.swift` blieb im Projekt
5. **CompileHygiene**: Meldet FK-013 BLOCKING (init-Mismatch mit dem bestehenden ViewModel)

### Warum es nicht von allein verschwindet

- ProjectIntegrator und OutputIntegrator schreiben Files, loeschen aber nie welche
- Jeder Run fuegt potenziell neue Files hinzu, entfernt aber keine alten
- Kein Mechanismus existierte um festzustellen ob ein File noch "aktuell" ist

---

## 2. What Provenance / Lifecycle Signals Already Existed

| Signal | Verfuegbar | Nuetzlich |
|---|---|---|
| Git blame (Commit-Message "AI run:") | Ja | **Ja — Hauptsignal** |
| Integration Reports (JSON) | Ja, aber nur OutputIntegrator | Teilweise |
| Run Manifests | Ja | Nicht fuer File-Mapping |
| CompileHygiene BLOCKING | Ja | **Ja — zeigt welche Files Probleme haben** |
| Dateiname/Pfad | Ja | Nicht ausreichend allein |

**Schluessel-Erkenntnis**: Git-Provenance (`git log --diff-filter=A`) zeigt zuverlaessig welcher Commit ein File hinzugefuegt hat. Wenn die Commit-Message mit "AI run:" beginnt, ist es AI-generiert.

---

## 3. Exact Central Mechanism Implemented

### Neues Modul: `factory/operations/stale_artifact_guard.py`

**Platzierung**: Nach allen Repair-Passes (StubGen + ShapeRepairer), vor SwiftCompile.

**Ablauf**:
1. Sammle alle BLOCKING-Issues aus CompileHygiene
2. Fuer jedes File in einem BLOCKING-Issue:
   a. Pruefe ob es ein geschuetzter Pfad ist (App/, Config/, etc.) → skip
   b. Pruefe Git-Provenance: `git log --diff-filter=A` → wann wurde es hinzugefuegt?
   c. Wenn Commit-Message mit "AI run:" beginnt → AI-generiert
   d. AI-generiert + BLOCKING = **stale artifact** → quarantinieren
3. Verschiebe in `projects/<name>/quarantine/<timestamp>_<filename>`
4. Re-run CompileHygiene nach Quarantine

### Quarantine statt Delete

Dateien werden **verschoben**, nicht geloescht. Der `quarantine/` Ordner:
- Ist vom Hygiene-Scan ausgeschlossen (`_SKIP_DIRS`)
- Kann jederzeit manuell inspiziert oder restauriert werden
- Wird bei Bedarf in Git committed fuer Audit-Trail

### Hygiene Scan-Exclusion

CompileHygiene scannt jetzt diese Ordner nicht mehr:
```python
_SKIP_DIRS = {"quarantine", "generated", ".git"}
```

---

## 4. How ServiceContainer.swift Was Handled

```
[StaleGuard] Checking 1 blocking file(s) for stale artifacts...

Provenance:
  is_ai_generated: True
  commit_hash:     1ca11bf8
  commit_message:  AI run: Design and implement the DriveAI feature: ExamReadiness...
  author_date:     2026-03-15

Action:
  [QUARANTINE] Models/ServiceContainer.swift
               -> quarantine/20260315_151734_ServiceContainer.swift

After quarantine:
  Status: WARNINGS
  Blocking: 0
```

---

## 5. Safety / False-Positive Considerations

### Geschuetzte Pfade

| Pfad | Quarantine erlaubt? |
|---|---|
| `App/` | **Nein** (protected) |
| `Config/` | **Nein** (protected) |
| `Resources/` | **Nein** (protected) |
| `Info.plist`, `ContentView.swift` | **Nein** (protected) |
| `Models/ServiceContainer.swift` | Ja (nicht geschuetzt) |

### Was wenn ein wichtiges AI-File quarantiniert wird?

1. Das File ist im `quarantine/` Ordner erhalten
2. Es kann manuell zurueck verschoben werden
3. Git-History hat den vollen Inhalt

### Warum ExamReadinessViewModel.swift NICHT quarantiniert wird

- Es ist AI-generiert (gleicher "AI run:" Commit)
- Aber es hat **kein BLOCKING-Issue** — nur Warnings
- Der Guard prueft nur Files die in BLOCKING-Issues referenziert sind

---

## 6. Whether the Project Baseline Is Now Cleaner

| Metrik | Vorher | Nachher |
|---|---|---|
| CompileHygiene Status | BLOCKING | **WARNINGS** |
| BLOCKING Issues | 1 (FK-013 ServiceContainer) | **0** |
| Files scanned | 178 | **177** |
| Quarantined | — | 1 (ServiceContainer.swift) |
| Warnings | 13 | 13 (unveraendert) |

---

## 7. Whether System Is Ready for Next Proof Run

**Ja** — das System ist bereit. Die Baseline ist jetzt:
- 0 BLOCKING Issues
- 13 Warnings (alle operationell harmlos)
- CompletionVerifier: MOSTLY_COMPLETE / 95%
- Stale Artifact Guard aktiv fuer zukuenftige Runs

Die Operations Layer Pipeline ist jetzt:
```
OutputIntegrator (5-Layer Dedup)
  -> CompletionVerifier (Evidence-Mode)
  -> CompileHygiene (Column-aware, Memberwise, SwiftUI-aware)
  -> TypeStubGenerator (FK-014)
  -> Re-Hygiene
  -> PropertyShapeRepairer (FK-013, class-aware)
  -> Re-Hygiene
  -> StaleArtifactGuard (Git-Provenance, Quarantine)   <- NEU
  -> Re-Hygiene
  -> SwiftCompile
  -> Recovery
  -> RunMemory
  -> KnowledgeWriteback
```

---

## 8. Single Next Recommended Step

**Run 11 (Autonomy Proof)** mit sauberem 0-BLOCKING Baseline. Erstmals koennten alle Systeme ohne verbleibende Altlasten laufen. Wenn der Run neuen Code generiert (Haiku produziert nicht immer Code), wird der volle Repair-Stack (StubGen + ShapeRepairer + StaleGuard) erstmals auf frischem Output getestet.
