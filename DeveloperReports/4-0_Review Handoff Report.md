# Review Handoff Report

**Datum**: 2026-03-14
**Scope**: Structured Review Findings Preservation across Passes
**Problem**: Review-Ergebnisse gehen bei team.reset() verloren — jeder Pass startet ohne Wissen über vorherige Findings

---

## 1. Problem-Analyse

### Pipeline-Reihenfolge (Pass 2–8)
```
Bug Hunter → Creative Director → UX Psychology → Refactor → Test Gen → Fix Executor
```

### Informationsverlust
- Bug Hunter findet 5 Bugs → team.reset()
- Creative Director sieht **keine Bug-Findings** → doppelte Arbeit oder widersprüchliche Empfehlungen
- UX Psychology sieht **weder Bug noch CD Findings**
- Refactor sieht **nichts** von den 3 vorherigen Reviews
- Fix Executor erhielt nur 234 Chars generische Instruktion

---

## 2. Lösung: Review Digest Accumulation

### Neue Funktion: `_extract_review_digest(messages, pass_name, max_chars=600)`
**Datei**: `main.py`

```python
_AGENT_MAP = {
    "bug_review": "bug_hunter",
    "creative_review": "creative_director",
    "ux_psychology": "ux_psychology",
    "refactor": "refactor_agent",
}
```

- Sucht zuerst nach dem Target-Agent, dann Fallback auf erste Non-User Message
- Extrahiert max 600 Chars pro Digest
- Strukturierte Extraktion statt Raw-Dump

### Neue Funktion: `_build_review_context(review_digests)`
**Datei**: `main.py`

```python
_LABELS = {
    "bug_review": "Bug Hunter Findings",
    "creative_review": "Creative Director Assessment",
    "ux_psychology": "UX Psychology Findings",
    "refactor": "Refactor Suggestions",
}
```

- Baut `[Prior Review Findings]` Block aus allen bisherigen Digests
- Jeder Pass sieht alle vorherigen Findings mit Label

### Accumulation Flow
```
review_digests = {}

After Bug Hunter:     review_digests["bug_review"] = "..."
After CD:             review_digests["creative_review"] = "..."
After UX Psych:       review_digests["ux_psychology"] = "..."
After Refactor:       review_digests["refactor"] = "..."

→ Jeder nachfolgende Pass erhält _build_review_context(review_digests) im Task
→ Fix Executor erhält review_context + impl_summary
```

---

## 3. Fix Executor Enhancement

**Datei**: `tasks/fix_executor.py`

### Vorher
```python
def build_fix_task(self, user_task, bug_messages, refactor_messages):
    # 234 Chars generische Instruktion
```

### Nachher
```python
def build_fix_task(self, user_task, bug_messages, refactor_messages,
                   review_context="", impl_summary=""):
    parts = []
    if impl_summary: parts.append(impl_summary)        # API Skeleton
    if review_context: parts.append(review_context)      # All review findings
    parts.append("Apply the highest-priority bug fixes...")
    if bug_excerpt: parts.append(f"\nKey bug findings:\n{bug_excerpt}")
    if refactor_excerpt: parts.append(f"\nKey refactor suggestions:\n{refactor_excerpt}")
    return "\n\n".join(parts)
```

### Ergebnis
```
Vorher:  234 Chars  — generische "fix bugs" Instruktion
Nachher: 2000+ Chars — impl_summary + 4 Review Digests + spezifische Excerpts
```

---

## 4. Token-Budget

| Komponente | Max Chars |
|---|---|
| impl_summary (API Skeleton) | ~6000 |
| bug_review digest | 600 |
| creative_review digest | 600 |
| ux_psychology digest | 600 |
| refactor digest | 600 |
| bug_excerpt (direct) | 600 |
| refactor_excerpt (direct) | 600 |
| **Total Maximum** | **~9600** |

~9600 Chars ≈ ~2400 Tokens — gut innerhalb des Context Budgets.

---

## 5. Impact

- Downstream-Agents sehen jetzt alle vorherigen Findings
- Kein doppeltes Identifizieren der gleichen Issues
- Fix Executor hat spezifischen, grounded Kontext
- Review-Qualität steigt signifikant durch kumulative Information
