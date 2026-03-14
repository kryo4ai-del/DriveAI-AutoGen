# Stateful Recovery Report

**Datum**: 2026-03-14
**Scope**: Recovery stateful machen — Failure Context, Fingerprinting, Repeated Failure Detection
**Ziel**: Factory wiederholt nicht blind den gleichen fehlgeschlagenen Recovery-Versuch

---

## 1. Current Recovery Context Loss Points (Vorher)

### Was Recovery bekam
```
RecoveryRunner(project_name, env_profile, dry_run)
```
- Null Kontext uber WARUM der Run fehlgeschlagen ist
- Kein Wissen uber vorherige Versuche
- Kein Vergleich ob dieselben Files wieder fehlen

### Was verloren ging
| Information | Verfuegbar? | An Recovery weitergereicht? |
|---|---|---|
| Failed stage | Ja (in ops-layer) | Nein |
| Health status | Ja (completion report) | Nur indirekt |
| Missing file list | Ja | Nur als Targets, ohne Vergleich |
| Error details | Ja (in logs) | Nein |
| Prior attempt count | Nein (nicht getrackt) | Nein |
| Fingerprint Vergleich | Nein (nicht implementiert) | Nein |

### MAX_RECOVERY_ATTEMPTS = 1 (dekorativ)
- Definiert als Konstante, aber **nirgends im Code geprueft**
- Tatsaechliche Limitierung: ein `if`-Block in `_run_operations_layer` (genau 1 Versuch)
- Erhoehung auf z.B. 3 haette keinen Effekt gehabt

### Run Memory (vorher)
```python
"recovery_triggered": bool  # basierend auf File-Alter, nicht auf tatsaechlichem Outcome
```
- Kein Attempt Count, kein Outcome, kein Fingerprint

---

## 2. Minimal Fix Implemented

### 2.1 RecoveryState Dataclass (NEU)
```python
@dataclass
class RecoveryState:
    project_name: str
    attempt_number: int
    failed_stage: str           # "completion_verifier", "compile_hygiene"
    failure_status: str         # "incomplete", "failed"
    failure_summary: str        # "3 missing, 1 incomplete (health: incomplete)"
    error_excerpt: str          # first 400 chars of concrete error detail
    failure_fingerprint: str    # SHA-256 hash of sorted target filenames
    prior_fingerprints: list    # fingerprints from all prior attempts
    repeated_failure: bool
    timestamp: str
```

### 2.2 Failure Fingerprinting
```python
def _build_failure_fingerprint(targets: list[RecoveryTarget]) -> str:
    parts = sorted(f"{t.filename}:{t.reason}" for t in targets)
    raw = "|".join(parts)
    return hashlib.sha256(raw.encode()).hexdigest()[:16]
```
- Deterministisch: gleiche fehlende Files = gleicher Fingerprint
- Ordnungsunabhaengig: `[A, B]` == `[B, A]`
- 16-Char Hex = ausreichend fuer Kollisionsfreiheit in diesem Kontext

### 2.3 Repeated Failure Detection
Im `RecoveryRunner.run()`:
```python
if fingerprint in prior_fps:
    self.summary.repeated_failure = True
    self.summary.outcome = "repeated_failure"
    return self.summary  # STOP — nicht nochmal das Gleiche versuchen
```

### 2.4 MAX_RECOVERY_ATTEMPTS Enforcement
- Erhoehung auf 2 (war 1 dekorativ)
- `_run_operations_layer` hat jetzt eine echte Loop: `for attempt in range(1, MAX_RECOVERY_ATTEMPTS + 1)`
- `RecoveryRunner.run()` prueft `attempt > MAX_RECOVERY_ATTEMPTS` als Guard
- Bei Exhaustion: `outcome = "terminal_stop"`

### 2.5 Failure Context in Recovery Prompt
```
---------------------------------------------
PRIOR FAILURE CONTEXT (attempt 1)
---------------------------------------------
Failed stage: completion_verifier
Status: incomplete
Reason: 1 missing, 1 incomplete (health: incomplete)
Error excerpt: Missing: TopicPickerView.swift; Incomplete: QuizService.swift
```
Recovery-Agents sehen jetzt den Grund des Failures.

### 2.6 Run Memory Enrichment
```python
# Vorher
"recovery_triggered": bool

# Nachher
"recovery_attempts": int,        # 0, 1, 2
"recovery_outcome": str,         # "none", "recovered", "repeated_failure", "terminal_stop"
"recovery_fingerprint": str,     # fuer Cross-Run Vergleich
"repeated_failure": bool,
```

---

## 3. Files Changed

| Datei | Aenderungen |
|---|---|
| `factory/operations/recovery_runner.py` | +RecoveryState, +fingerprinting, +repeated detection, +failure context in prompt, +state persistence, +outcome tracking |
| `main.py` (`_run_operations_layer`) | Recovery Loop mit MAX_RECOVERY_ATTEMPTS, failure context Aufbau, state threading, enriched return dict |
| `factory/operations/run_memory.py` | `record_run()` neue Params, enriched run record, summary shows recovery details |

---

## 4. Before vs After Recovery State Flow

### VORHER
```
Completion Verifier → health="incomplete"
    ↓
_run_operations_layer: if incomplete → RecoveryRunner(project, profile, dry_run=False)
    ↓
RecoveryRunner.run():
    - load completion report
    - build targets (missing/incomplete files)
    - build generic prompt (no failure context)
    - execute subprocess
    ↓
Re-verify → record_run(recovery_triggered=True/False based on file age)
```
**Lost**: WHY it failed, prior attempts, fingerprint comparison

### NACHHER
```
Completion Verifier → health="incomplete"
    ↓
_run_operations_layer: for attempt in 1..MAX_RECOVERY_ATTEMPTS:
    - build RecoveryState(failed_stage, status, summary, error_excerpt, fingerprint)
    - RecoveryRunner(project, profile, dry_run=False, failure_context=state)
    ↓
RecoveryRunner.run():
    - check attempt <= MAX_RECOVERY_ATTEMPTS (guard)
    - load completion report
    - build targets → compute fingerprint
    - CHECK: fingerprint in prior_fingerprints? → STOP (repeated_failure)
    - build prompt WITH failure context section
    - execute subprocess
    - save RecoveryState to disk
    ↓
Re-verify → still incomplete?
    - update prior_state with new fingerprint
    - next loop iteration (or exhausted → terminal_stop)
    ↓
record_run(recovery_attempts=N, recovery_outcome="recovered"|"repeated_failure"|"terminal_stop")
```

---

## 5. Remaining Limits

1. **Failure stage granularity**: Currently only tracks "completion_verifier" as the stage. Could be enriched with compile_hygiene or swift_compile failures in future.
2. **Cross-run fingerprint comparison**: Fingerprints are compared within one ops-layer run. Cross-run comparison (via run_history.json) is stored but not yet used for auto-blocking.
3. **Recovery strategy variation**: When a repeated failure is detected, recovery stops entirely. A future enhancement could try a different strategy (e.g., simplified prompt, different template).
4. **MAX_RECOVERY_ATTEMPTS = 2**: Conservative. Could be raised once the fingerprint guard proves reliable in production.

---

## 6. Verdict

Recovery is now **materially more stateful and less repetitive**:

- **Stateful**: Each attempt receives structured failure context (stage, status, summary, excerpt)
- **Fingerprinted**: Identical failure sets are detected via deterministic hash
- **Bounded**: MAX_RECOVERY_ATTEMPTS is enforced in both the loop and the runner
- **Visible**: Run Memory records attempt count, outcome, fingerprint, and repeated-failure flag
- **Prompt-aware**: Recovery agents receive prior failure context in their prompt

### Validation Results
```
Fingerprint determinism:     PASS (order-independent, content-dependent)
State serialization:         PASS (save/load/clear roundtrip)
Repeated failure detection:  PASS (same targets → detected, different → not)
Different targets:           PASS (new fingerprint, no false positive)
MAX_RECOVERY_ATTEMPTS:       PASS (enforced in runner + ops-layer loop)
Prompt context injection:    PASS (PRIOR FAILURE CONTEXT section present)
```
