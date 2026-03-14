# Knowledge Writeback Report

**Datum**: 2026-03-14
**Scope**: Factory Knowledge Feedback Loop schliessen
**Ziel**: Factory kann validierte Erkenntnisse ueber Runs hinweg speichern und wiederverwenden

---

## 1. Current Knowledge Feedback Gap (Vorher)

### Wissensfluss war Einbahnstrasse

```
knowledge.json (17 Entries)
    |
    v
knowledge_reader.py
    |
    v
CD Pass (injected as context block)
    |
    v
Pipeline Output
    |
    v
proposal_generator.py → proposals/proposal_<run_id>.json
    |
    X  ← HIER ENDET DER FLUSS
```

### Was fehlte

| Schritt | Status | Problem |
|---|---|---|
| Knowledge → Agent injection | Funktioniert | OK |
| Run → Proposal generation | Funktioniert | OK |
| Proposal → Knowledge promotion | **Fehlt komplett** | 11 Proposals liegen ungelesen in proposals/ |
| Run History → Pattern extraction | **Fehlt komplett** | Recurring failures werden nicht erfasst |
| Recovery outcomes → Knowledge | **Fehlt komplett** | Erfolge/Fehler fliessen nie zurueck |

### Konsequenz
- Factory wiederholt dieselben Fehler in jedem Run
- 6x "File duplication" Proposal generiert — nie in Knowledge uebernommen
- CD Review bekommt nie Feedback aus realen Run-Ergebnissen
- Wissen akkumuliert nicht

---

## 2. Minimal Fix Implemented

### Neues Modul: `factory_knowledge/knowledge_writeback.py`

Schliesst den Feedback Loop mit 2 Mechanismen:

#### Mechanismus 1: Proposal Auto-Promotion
- Liest alle Proposals aus `proposals/`
- Gruppiert nach normalisiertem Titel
- Proposals mit 2+ Beobachtungen → auto-promoted zu `validated`
- Idempotent: ueberspringt Entries deren Titel bereits existiert
- Nie auto-promoted zu `proven` (erfordert manuelle Cross-Project Bestaetigung)

#### Mechanismus 2: Run-Pattern Extraction
- Liest Run History aus `factory/memory/run_history.json`
- Erkennt 3 Pattern-Typen:
  1. **Recurring missing files** — gleiche Files fehlen in 2+ Runs
  2. **Repeated recovery failures** — gleicher Fingerprint ueber Runs
  3. **Successful recovery** — Recovery hat Problem geloest

### Trust Levels (explizit)

| Level | Bedeutung | Auto-setzbar? |
|---|---|---|
| `hypothesis` | Einzelbeobachtung, unbestaetigt | Ja (Proposals) |
| `observed` | In Runs beobachtet, nicht in Production getestet | Ja (Pattern Extraction) |
| `validated` | In 2+ Runs/Proposals bestaetigt | Ja (Auto-Promotion) |
| `proven` | Cross-Project bestaetigt | **Nein (nur manuell)** |
| `disproven` | Invalidiert, als Warnung behalten | **Nein (nur manuell)** |

### Provenance (Auditable)
Jeder auto-generierte Entry enthaelt:
```json
{
  "writeback_source": "proposal_promotion",
  "writeback_evidence": {
    "observation_count": 6,
    "run_ids": ["20260313_021528", "..."],
    "source_files": ["proposals/proposal_20260313_021528.json", "..."]
  }
}
```

---

## 3. Files Changed

| Datei | Aenderung |
|---|---|
| `factory_knowledge/knowledge_writeback.py` | **NEU** — Writeback-Modul (Proposal Promotion + Run Pattern Extraction) |
| `main.py` (`_run_operations_layer`) | Writeback-Aufruf nach Run Memory, vor Return |
| `factory_knowledge/knowledge.json` | FK-018 auto-promoted (File duplication) |
| `factory_knowledge/index.json` | Automatisch rebuilt (18 Entries) |

---

## 4. Before vs After Knowledge Flow

### VORHER (Open Loop)
```
knowledge.json → CD Injection → Pipeline → Proposals → /dev/null
                                              ↑
                                         Run History → /dev/null
```

### NACHHER (Closed Loop)
```
knowledge.json → CD Injection → Pipeline → Proposals
       ↑                                       |
       |                                       v
       +←── knowledge_writeback.py ←── Proposal Auto-Promotion
       |         (nach jedem Run)              (2+ observations)
       |
       +←── knowledge_writeback.py ←── Run Pattern Extraction
                                           (recurring failures,
                                            recovery outcomes)
```

### Konkretes Ergebnis der ersten Writeback-Ausfuehrung

```
VORHER: 17 Entries, 11 ungelesene Proposals
NACHHER: 18 Entries (FK-018 auto-promoted)

FK-018: "File duplication in code generation output"
  - 6 identische Beobachtungen aus 6 verschiedenen Runs
  - confidence: validated
  - writeback_source: proposal_promotion
  - Sofort in CD-Injection verfuegbar (Platz 1, hoechste Confidence)
```

### Wie spaetere Runs das nutzen

```python
# Naechster Factory Run — CD Pass
knowledge_block = get_cd_knowledge_block(template)
# → Enthaelt jetzt FK-018 als erstes Entry
# → CD weiss: "File duplication ist ein bekanntes Problem"
# → CD kann das in seinem Review adressieren
```

---

## 5. Remaining Limits

1. **Cross-Run Pattern Extraction braucht mehr Daten**: Aktuell nur 2 Runs in History, keine recurring patterns. Wird automatisch effektiver mit mehr Runs.
2. **Proposal Matching ist title-based**: Fuzzy matching (aehnliche aber nicht identische Titel) wird nicht erkannt. Bewusste Einschraenkung — false positives waeren schaedlicher als missed matches.
3. **Keine automatische Disproven-Setzung**: Wenn ein Pattern sich als falsch herausstellt, muss das manuell auf `disproven` gesetzt werden.
4. **Proven bleibt manuell**: Auto-Promotion endet bei `validated`. `proven` erfordert bewusste Cross-Project Bestaetigung.
5. **Knowledge nur fuer CD**: Aktuell wird Knowledge nur in den CD-Pass injiziert. Bug Hunter, Refactor etc. erhalten noch kein Knowledge.

---

## 6. Verdict

Die Factory hat jetzt einen **materiell funktionierenden Cross-Run Learning Loop**:

- **Closed Loop**: Proposals → Writeback → Knowledge → CD Injection → naechster Run
- **Evidence-based**: Nur Proposals mit 2+ Beobachtungen werden promoted
- **Auditable**: Jeder Entry hat `writeback_source` + `writeback_evidence`
- **Trust-explicit**: Klare Trennung hypothesis/observed/validated/proven
- **Safe**: Idempotent, append-only, nie auto-proven, nie auto-disproven
- **Integrated**: Laeuft automatisch nach jedem Pipeline-Run (in Operations Layer)

### Validierungsergebnisse
```
Proposal loading:        PASS (15 proposals aus 11 Dateien)
Similarity grouping:     PASS (6x "file duplication" korrekt gruppiert)
Auto-promotion:          PASS (FK-018 mit confidence=validated)
Idempotenz:              PASS (2. Lauf = 0 neue Entries)
CD Injection:            PASS (FK-018 an Platz 1 in CD knowledge block)
Run pattern extraction:  PASS (korrekt 0 patterns bei zu wenig Daten)
Index rebuild:           PASS (18 Entries, Typen + Confidence korrekt)
```
