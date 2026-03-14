# CD Gate Policy Report

**Datum**: 2026-03-14
**Scope**: CD Gate policy profile-aware machen — dev/fast advisory, standard/premium blocking
**Ziel**: Dev-Runs laufen durch die volle Pipeline auch wenn CD `fail` gibt

---

## 1. Current CD Gate Policy Root Cause

### Problem

Die CD Gate Policy war profil-blind: `fail` stoppte die Pipeline **immer** (ausser `--no-cd-gate` Flag).

```python
# VORHER: Profil-blind — fail stoppt immer
if _cd_rating == "fail" and not no_cd_gate:
    skipped_phases.extend(["refactor", "test_generation", "fix_execution"])
    gate_ctx["cd_gate_stop"] = True
```

### Auswirkung

- Dev-Profile (`--profile dev`, Modell: claude-haiku-4-5) generiert Code der den Premium-Standards des CD nicht genuegt
- CD gibt konsistent `fail` (Run 3 + Run 4)
- Pipeline stoppt → UX Psychology, Refactor, Test Gen, Fix Execution werden uebersprungen
- Die Pipeline erreicht nie ihren vollen technischen Validierungspfad
- CD-Findings (die wertvoll sind) gehen nicht verloren, aber nachgelagerte Passes koennen sie nicht nutzen

### Warum Dev-Profile anders behandelt werden sollten

| Profil | Modell | Zweck | CD Gate sinnvoll? |
|---|---|---|---|
| dev | Haiku | Entwicklung, Tests, Iteration | **Nein** — Haiku-Code ist per Definition nicht premium |
| fast | Haiku | Schnelle Prototypen | **Nein** — Speed over polish |
| standard | Sonnet | Normaler Betrieb | **Ja** — Sonnet sollte Premium liefern koennen |
| premium | Opus | High-End Projekte | **Ja** — Hoechste Qualitaetserwartung |

---

## 2. Minimal Policy Fix Implemented

### Aenderung: 1 Kontrollpunkt, 5 Zeilen Kernlogik

```python
# NACHHER: Profil-aware — dev/fast advisory, standard/premium blocking
_cd_blocking = profile in ("standard", "premium")

if _cd_rating == "fail" and not no_cd_gate and _cd_blocking:
    # BLOCKING: Pipeline stoppt (standard/premium)
    gate_ctx["cd_gate_stop"] = True
    skipped_phases.extend(...)

elif _cd_rating == "fail" and not no_cd_gate and not _cd_blocking:
    # ADVISORY: Pipeline laeuft weiter (dev/fast/None)
    # CD findings bleiben in review_digests verfuegbar
    pass  # kein gate_ctx["cd_gate_stop"], kein skipped_phases
```

### Verhalten nach Profil

| Profil | CD fail | Gate | Pipeline | Downstream Passes |
|---|---|---|---|---|
| dev | fail | advisory | **CONTINUES** | UX Psych, Refactor, Test Gen, Fix — alle laufen |
| fast | fail | advisory | **CONTINUES** | alle laufen |
| standard | fail | blocking | STOPS | uebersprungen (wie bisher) |
| premium | fail | blocking | STOPS | uebersprungen (wie bisher) |
| any | conditional_pass | continue | CONTINUES | alle laufen (wie bisher) |
| any | pass/None | continue | CONTINUES | alle laufen (wie bisher) |
| any + `--no-cd-gate` | fail | overridden | CONTINUES | alle laufen (wie bisher) |

### CD Findings bleiben verfuegbar

Die CD-Digest-Erfassung passiert **vor** der Gate-Entscheidung (main.py Zeile 571-573):

```python
# Zeile 571: Digest wird IMMER erfasst
_cd_digest = _extract_review_digest(cd_result_msgs, "creative_review")
review_digests["creative_review"] = _cd_digest  # ← verfuegbar fuer alle Downstream-Passes

# Zeile 601: Gate-Entscheidung DANACH
_cd_blocking = profile in ("standard", "premium")
```

Downstream-Passes die `_build_review_context(review_digests)` nutzen:
- UX Psychology (Zeile 647)
- Refactor (Zeile 682)
- Fix Execution (Zeile 741)

Alle erhalten die CD-Findings als Prior-Context — unabhaengig von der Gate-Entscheidung.

### Logging

Console-Output bei Dev-Profile + CD fail:
```
[CD GATE] Product quality FAIL — advisory only, continuing.
  Profile: dev (advisory mode — fail is non-blocking)
  Source: creative_director (last creative_director rating (msg #2, 1 CD rating(s) found, 1 total candidate(s)))
  CD findings remain available for downstream passes.
```

Logger-Output:
```
[CD GATE] FAIL — ADVISORY (profile=dev). Pipeline continues. source=creative_director
```

---

## 3. Files Changed

| Datei | Aenderung |
|---|---|
| `main.py` Zeilen 601-624 | Gate-Logik: `_cd_blocking = profile in ("standard", "premium")` + advisory-Pfad |
| `tests/test_cd_gate_policy.py` | NEU: 10 Validierungstests fuer alle Profil-Kombinationen |

---

## 4. Before vs After Gate Behavior

### Run 4 Szenario (dev + CD fail)

| | Vorher | Nachher |
|---|---|---|
| CD Rating | fail | fail (identisch) |
| CD Source | creative_director | creative_director (identisch) |
| Gate Decision | **BLOCKING** | **ADVISORY** |
| UX Psychology | SKIPPED | **RUNS** |
| Refactor | SKIPPED | **RUNS** |
| Test Generation | SKIPPED | **RUNS** |
| Fix Execution | SKIPPED | **RUNS** |
| CD Findings downstream | In digest (unused) | In digest (**fed to all passes**) |
| Pipeline coverage | 3/8 Passes | **8/8 Passes** |

### Standard-Profile Szenario (standard + CD fail)

| | Vorher | Nachher |
|---|---|---|
| Gate Decision | BLOCKING | **BLOCKING** (identisch) |
| Downstream Passes | SKIPPED | **SKIPPED** (identisch) |

---

## 5. Remaining Limits

### 5.1 CD Kalibrierung unveraendert

Der CD gibt weiterhin `fail` fuer Haiku-generierten Code. Das ist kein Problem mehr fuer Dev-Runs (advisory), aber bei Standard-Runs koennte der CD zu streng sein. Ggf. braucht der CD eine profil-aware Prompt-Anpassung ("for this profile, focus on structural issues, not premium polish").

### 5.2 Keine granulare Gate-Steuerung

Das Gate ist binary: blocking oder advisory. Es gibt keinen Modus "soft-blocking" (z.B. "continue but mark run as quality-degraded"). Fuer den aktuellen Stand ist binary ausreichend.

### 5.3 Profile `None` ist advisory

Wenn kein Profil gesetzt ist (edge case), ist `_cd_blocking = None in ("standard", "premium")` → False → advisory. Das ist ein sicherer Default (fail-open), aber nicht explizit dokumentiert.

---

## 6. Verdict: Dev-Profile Runs sind materiell weniger blockiert

### Quantitativ

| Metrik | Vorher | Nachher |
|---|---|---|
| Pipeline Passes bei Dev + CD fail | **3 von 8** | **8 von 8** |
| Uebersprungene Passes | 5 (UX, Refactor, TestGen, Fix, Recovery) | **0** |
| CD Findings downstream | Erfasst aber ungenutzt | **Aktiv in 3 Downstream-Passes** |

### Qualitativ

- Dev-Runs durchlaufen jetzt den **vollen technischen Validierungspfad** (Refactor, Tests, Fix)
- CD-Findings werden nicht verworfen sondern fliessen als Prior-Context in nachfolgende Passes
- Standard/Premium-Runs behalten strikte Quality-Gates
- `--no-cd-gate` bleibt als expliziter Override verfuegbar
- 19 Tests validieren Parser (9) + Policy (10)

### Was der naechste Run zeigen wird

Ein Dev-Profile Run mit dem gleichen ExamReadiness-Template sollte jetzt:
1. Implementation → Bug Hunter → **CD (fail, advisory)** → UX Psychology → Refactor → Test Gen → Operations
2. Refactor/Test-Passes erhalten CD-Findings als Context
3. Operations Layer laeuft mit mehr generierten Dateien (Refactor + Tests)
4. CompletionVerifier und CompileHygiene pruefen einen vollstaendigeren Output
