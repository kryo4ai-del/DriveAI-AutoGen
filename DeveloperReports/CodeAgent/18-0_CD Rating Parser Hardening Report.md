# CD Rating Parser Hardening Report

**Datum**: 2026-03-14
**Scope**: CD Gate Rating-Extraktion auf agent-spezifisches Signal haerten
**Ziel**: Pipeline-Gate basiert auf dem echten Creative Director Verdict, nicht auf ambigen Matches

---

## 1. Current CD Rating Parser Root Cause

### Analyse-Ergebnis: Parser war korrekt, Hypothese war falsch

Die Hypothese aus Report 14-0 ("letztes Rating: im GroupChat stammt moeglicherweise von Non-CD Agent") wurde durch Log-Analyse widerlegt:

**Run 3** (20260314_163402):
| Log-Zeile | Agent | Rating | Pass |
|---|---|---|---|
| 3003 | `creative_director` | conditional_pass | Implementation Pass |
| 6229 | `creative_director` | conditional_pass | Bug Hunter Pass |
| 7386 | `creative_director` | fail | **CD Pass** |

**Run 4** (20260314_182358):
| Log-Zeile | Agent | Rating | Pass |
|---|---|---|---|
| 3785 | `creative_director` | conditional_pass | Implementation Pass |
| 7861 | `creative_director` | fail | **CD Pass** |

**Alle Rating-Zeilen in beiden Runs stammen vom `creative_director` Agent.** Kein Non-CD Agent hat jemals ein "Rating:" im richtigen Format produziert.

### Warum der Parser trotzdem verbesserungsbeduerftig war

1. **Kein Audit Trail**: Bei Debugging war nicht nachvollziehbar welche Rating-Zeile gewaehlt wurde und warum
2. **Erster-Match statt Letzter**: Pass 1 nahm den **ersten** CD-Match — aber in GroupChats kann der CD mehrfach sprechen (initial + revised assessment). Das letzte Rating ist das finale Verdict.
3. **Keine Kandidaten-Sichtbarkeit**: Console/Log zeigte nur `CD rating: fail` — nicht ob es Alternativen gab oder welcher Agent das Rating lieferte
4. **Fallback-Risiko**: Pass 2 (alle Non-User) wuerde das erste zufaellige Rating nehmen wenn der CD nie spricht — potentiell von einem Bug-Hunter der zufaellig "Rating: fail" in seinen Findings schreibt

### Architekturbestaetigung

- `team.reset()` zwischen Passes funktioniert korrekt — `cd_result.messages` enthaelt nur CD-Pass-Messages
- `cd_result_msgs` wird korrekt auf den CD-Run beschraenkt (kein Bleed-through von Impl/Bug-Passes)
- Das `fail`-Rating ist das echte CD-Verdict, nicht ein Parser-Artefakt

---

## 2. Minimal Fix Implemented

### Neuer 2-Stufen-Parser mit vollstaendigem Audit Trail

**Vorher** (alter Parser):
```python
def extract_cd_rating(messages) -> str | None:
    # Pass 1: first match from creative_director
    for msg in messages:
        if source == "creative_director":
            match = REGEX.search(content)
            if match: return match.group(1)  # ← FIRST match, return immediately
    # Pass 2: first match from any non-user
    for msg in messages:
        if source != "user":
            match = REGEX.search(content)
            if match: return match.group(1)  # ← FIRST match, return immediately
    return None
```

**Nachher** (neuer Parser):
```python
class CDRatingResult:
    rating: str | None        # selected rating
    candidates: list[dict]    # ALL rating lines found [{source, rating, msg_index}]
    selected_source: str      # agent that provided the rating
    selected_reason: str      # why this candidate was chosen

def extract_cd_rating_detailed(messages) -> CDRatingResult:
    # Collect ALL candidates first
    candidates = [...]
    # Priority: LAST creative_director rating (final verdict after discussion)
    cd_candidates = [c for c in candidates if c["source"] == "creative_director"]
    if cd_candidates:
        return CDRatingResult(cd_candidates[-1], ...)  # ← LAST CD message
    # Fallback: first non-user rating
    return CDRatingResult(candidates[0], ...)
```

### Aenderungen im Detail

1. **Alle Kandidaten gesammelt** statt beim ersten Match abzubrechen
2. **Letzter CD-Match** statt erster (finales Verdict nach GroupChat-Diskussion)
3. **CDRatingResult** Klasse mit strukturiertem Audit Trail
4. **Backward-kompatible Wrapper**: `extract_cd_rating()` gibt weiterhin `str | None` zurueck
5. **Console-Output** zeigt alle Kandidaten + Auswahlgrund:
   ```
   CD rating candidates (2):
     [bug_hunter] msg #1: fail
     [creative_director] msg #3: conditional_pass ←
   Selected: conditional_pass from creative_director
   Reason: last creative_director rating (msg #3, 1 CD rating(s) found, 2 total candidate(s))
   ```
6. **Logger-Output** mit maschinenlesbarem Format fuer Post-Run-Analyse

---

## 3. Files Changed

| Datei | Aenderung |
|---|---|
| `factory_knowledge/knowledge_reader.py` | `CDRatingResult` Klasse + `extract_cd_rating_detailed()` + refactored `extract_cd_rating()` als Wrapper |
| `main.py` Zeile 28 | Import: `+ extract_cd_rating_detailed` |
| `main.py` Zeilen 576-607 | CD Gate: nutzt `extract_cd_rating_detailed()`, loggt Kandidaten + Auswahlgrund |
| `tests/test_cd_rating_parser.py` | NEU: 9 Validierungstests gegen reale Run-Patterns |

---

## 4. Before vs After Rating Extraction Behavior

### Szenario A: Run 4 (CD gibt fail — 1 Kandidat)

| | Vorher | Nachher |
|---|---|---|
| Kandidaten gesammelt | Nein (first-match return) | Ja: `[{creative_director, fail, #2}]` |
| Ausgewaehltes Rating | `fail` | `fail` |
| Quelle sichtbar | Nein | `creative_director` |
| Begruendung sichtbar | Nein | "last creative_director rating (msg #2, 1 CD rating(s), 1 total)" |
| **Gate-Entscheidung** | **FAIL** | **FAIL** (identisch) |

### Szenario B: CD spricht 2x — initial conditional_pass, revised fail

| | Vorher | Nachher |
|---|---|---|
| Ausgewaehltes Rating | `conditional_pass` (erster Match) | **`fail`** (letzter CD-Match) |
| **Gate-Entscheidung** | **CONTINUE** (falsch-positiv) | **FAIL** (korrekt — finales Verdict) |

### Szenario C: Non-CD Agent hat Rating, CD auch — CD gewinnt

| | Vorher | Nachher |
|---|---|---|
| Ausgewaehltes Rating | CD-Rating (erster CD-Match) | CD-Rating (letzter CD-Match) |
| **Gate-Entscheidung** | Identisch | Identisch |

### Szenario D: CD spricht nie (SelectorGroupChat-Edge-Case)

| | Vorher | Nachher |
|---|---|---|
| Ausgewaehltes Rating | Erstes Non-User-Rating | Erstes Non-User-Rating |
| Quelle sichtbar | Nein | `bug_hunter` (oder wer auch immer) |
| Begruendung | Nein | "fallback — no creative_director rating found" |
| **Gate-Entscheidung** | Identisch | Identisch, aber Fallback ist **sichtbar** |

### Zusammenfassung

- **Run 3 + Run 4**: Gate-Entscheidung aendert sich **nicht** (CD Rating war bereits korrekt zugeordnet)
- **Szenario B** (multiple CD messages): Gate-Entscheidung aendert sich **zum Besseren** (letztes = finales Verdict)
- **Szenario D** (CD absent): Gate-Entscheidung identisch, aber Fallback ist jetzt **transparent**

---

## 5. Remaining Limits

### 5.1 CD-Qualitaetserwartungen unveraendert

Der Creative Director gibt `fail` weil Haiku-generierter Code seinen Premium-Standards nicht genuegt. Das ist kein Parser-Problem — das ist ein Kalibrierungsproblem. Die CD-Erwartungen wurden bewusst NICHT angepasst (out of scope).

### 5.2 Fallback bleibt First-Match

Wenn der CD nie spricht (SelectorGroupChat-Edge-Case), nimmt der Fallback das erste Non-User-Rating. In der Praxis ist das selten (der CD wurde in allen bisherigen Runs als Speaker gewaehlt), aber nicht unmoeglich.

### 5.3 Kein Content-Level CD-Verification

Der Parser vertraut `msg.source == "creative_director"` als Agent-Identitaet. In AutoGen v0.4 ist das zuverlaessig (Agent-Name wird vom Framework gesetzt, nicht vom LLM). Aber es gibt keine Content-Level-Verification (z.B. prueft nicht ob die Message tatsaechlich eine CD-Review-Struktur hat).

### 5.4 Proposal Generator nutzt eigenen Parser

`proposal_generator.py` hat eine separate `_extract_cd_rating()` Funktion die auf den CD-Digest-String arbeitet (nicht auf Message-Objekte). Diese wurde nicht geaendert — sie ist unabhaengig und arbeitet auf bereits gefiltertem Text.

---

## 6. Verdict: CD Gate Signal ist jetzt materiell vertrauenswuerdiger

### Was sich verbessert hat

| Aspekt | Vorher | Nachher |
|---|---|---|
| Audit Trail | Keine Sichtbarkeit | Vollstaendig: Kandidaten, Quelle, Begruendung |
| Multiple CD Messages | Erster Match (moeglicherweise vorlaeufig) | **Letzter Match** (finales Verdict) |
| Fallback-Transparenz | Unsichtbar | Explizit geloggt mit Quell-Agent |
| Non-CD Agent Rating | Koennte stillschweigend gewaehlt werden | Nur als Fallback, klar markiert |
| Debugging | "CD rating: fail" — woher? | "fail from creative_director (msg #2, reason: ...)" |

### Was sich NICHT geaendert hat

- Das `fail`-Rating in Run 3 + Run 4 war bereits korrekt vom Creative Director
- Die Gate-Entscheidung fuer diese Runs bleibt identisch (FAIL)
- Der CD gibt weiterhin `fail` fuer Haiku-generierte Features → Pipeline stoppt weiterhin

### Empfehlung fuer naechsten Schritt

Das CD Gate Signal ist jetzt **vertrauenswuerdig und auditierbar**. Der naechste Blocker ist nicht mehr der Parser, sondern die **CD Gate Policy**: Soll `fail` bei Dev-Profile die Pipeline stoppen, oder soll der CD im Dev-Modus Advisory-only sein?

**Optionen**:
1. `--no-cd-gate` als Default fuer Dev-Profile
2. CD Gate nur bei Standard/Premium aktiv
3. CD FAIL triggert Refactor/Fix statt Stop
