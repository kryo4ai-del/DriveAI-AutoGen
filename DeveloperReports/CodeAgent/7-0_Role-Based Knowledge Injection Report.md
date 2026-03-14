# Role-Based Knowledge Injection Report

**Datum**: 2026-03-14
**Scope**: Cross-Run Knowledge an alle kritischen Review/Fix Passes verteilen
**Ziel**: Nicht nur CD, sondern auch Bug Hunter, Refactor, Fix Executor profitieren von Factory Knowledge

---

## 1. Current Knowledge Injection Scope (Vorher)

### Nur CD bekam Knowledge

| Pass | impl_summary | review_digests | factory_knowledge |
|---|---|---|---|
| Bug Hunter | ja | nein | **NEIN** |
| Creative Director | ja | ja (Bug) | **JA** (5 Entries) |
| UX Psychology | ja | ja (Bug+CD) | NEIN |
| Refactor | ja | ja (Bug+CD+UX) | **NEIN** |
| Test Generator | ja | nein | NEIN |
| Fix Executor | ja | ja (alle) | **NEIN** |

### Problem
- Bug Hunter kannte keine bekannten Error Patterns (FK-011 bis FK-017)
- Refactor wusste nichts ueber wiederkehrende Duplication-Probleme (FK-018)
- Fix Executor hatte kein Cross-Run Wissen ueber bewaehrte Fix-Patterns
- Nur CD profitierte von Factory Knowledge — alle technischen Passes arbeiteten ohne historisches Wissen

---

## 2. Minimal Fix Implemented

### 2.1 Role-Based Knowledge Profiles

Neuer `_ROLE_PROFILES` Dict in `knowledge_reader.py`:

| Rolle | Relevante Typen | Max Entries | Min Confidence |
|---|---|---|---|
| `creative_director` | ux_insight, design_insight, motivational_mechanic, failure_case, success_pattern | 5 | hypothesis |
| `bug_hunter` | error_pattern, failure_case, technical_pattern | 4 | validated |
| `refactor_agent` | error_pattern, technical_pattern, failure_case, success_pattern | 4 | validated |
| `fix_executor` | error_pattern, failure_case, technical_pattern, success_pattern | 5 | validated |
| `reviewer` | error_pattern, failure_case, technical_pattern | 3 | validated |

### Design-Entscheidungen

1. **CD behaelt hypotheses** — Advisory Pass, profitiert von explorativen Hinweisen
2. **Technische Passes nur validated+** — Muessen praezise sein, hypotheses wuerden zu Rauschen
3. **Unterschiedliche Entry-Sets** — Bug Hunter braucht error_patterns, CD braucht ux_insights
4. **Rolle-spezifische CTAs** — "Watch for these known patterns when hunting bugs" vs "Apply these learnings"
5. **Confidence sichtbar** — Jeder Entry zeigt `(validated)` im Block

### 2.2 Neue Funktionen

```python
select_for_role(role: str) -> list[dict]     # Generic role-based selection
format_for_role(role: str, entries) -> str    # Role-aware formatting with CTA
get_knowledge_block(role: str) -> str         # One-call convenience
```

### 2.3 Injection Points

```python
# Bug Hunter (main.py)
_bug_knowledge = get_knowledge_block("bug_hunter")
bug_review_task = f"{_bug_knowledge}\n\n{bug_review_task}"

# Refactor (main.py)
_refactor_knowledge = get_knowledge_block("refactor_agent")
refactor_task = f"{_refactor_knowledge}\n\n{refactor_task}"

# Fix Executor (fix_executor.py — neuer Parameter)
fix_task = fix_executor.build_fix_task(..., knowledge_block=get_knowledge_block("fix_executor"))
```

---

## 3. Files Changed

| Datei | Aenderung |
|---|---|
| `factory_knowledge/knowledge_reader.py` | +_ROLE_PROFILES, +select_for_role(), +format_for_role(), +get_knowledge_block() |
| `main.py` | +import get_knowledge_block, injection in Bug Hunter + Refactor + Fix Executor |
| `tasks/fix_executor.py` | +knowledge_block Parameter in build_fix_task() |

---

## 4. Before vs After Role-Based Knowledge Flow

### VORHER
```
knowledge.json (18 Entries)
    |
    v
knowledge_reader.py
    |
    +→ select_for_creative_director() → CD Pass ONLY
    |
    X  (alle anderen Passes: kein Knowledge)
```

### NACHHER
```
knowledge.json (18 Entries)
    |
    v
knowledge_reader.py
    |
    +→ select_for_role("creative_director") → CD Pass
    |     Types: ux_insight, design_insight, motivational_mechanic, failure_case, success_pattern
    |     Min confidence: hypothesis, Max: 5 entries
    |
    +→ select_for_role("bug_hunter") → Bug Hunter Pass
    |     Types: error_pattern, failure_case, technical_pattern
    |     Min confidence: validated, Max: 4 entries
    |
    +→ select_for_role("refactor_agent") → Refactor Pass
    |     Types: error_pattern, technical_pattern, failure_case, success_pattern
    |     Min confidence: validated, Max: 4 entries
    |
    +→ select_for_role("fix_executor") → Fix Executor Pass
    |     Types: error_pattern, failure_case, technical_pattern, success_pattern
    |     Min confidence: validated, Max: 5 entries
    |
    +→ select_for_role("reviewer") → Reviewer Pass (prepared, not yet wired)
          Types: error_pattern, failure_case, technical_pattern
          Min confidence: validated, Max: 3 entries
```

### Concrete Injection Example (Bug Hunter)

```
[Factory Knowledge -- Known Patterns]
- [FK-004] (validated) Reset SelectorGroupChat between pipeline passes to prevent context explosion. Without reset, accumu...
- [FK-005] (validated) Compact implementation summary restores review quality after context reset. After team.reset(), rev...
- [FK-011] (validated) AI review text embedded inside generated source files. Agent commentary appears as Swift code when ...
- [FK-012] (validated) Duplicate type definitions across multiple generated files. Same struct/class defined in multiple f...
Watch for these known patterns when hunting bugs.
```

---

## 5. Token Impact

| Pass | Knowledge Block | Token Estimate |
|---|---|---|
| Bug Hunter | 752 chars | ~188 tokens |
| Creative Director | 1105 chars | ~276 tokens |
| Refactor | 896 chars | ~224 tokens |
| Fix Executor | 981 chars | ~245 tokens |
| **Total new** | **3734 chars** | **~933 tokens** |

~933 Tokens total ueber alle Passes — minimal im Verhaeltnis zu den 50k+ Token Kontexten.

---

## 6. Remaining Limits

1. **Reviewer nicht verdrahtet**: Profil existiert (`reviewer`), aber Reviewer-Pass wird in main.py nicht mit Knowledge injiziert (Reviewer hat eigene Logik).
2. **UX Psychology kein Knowledge**: Bekommt weiterhin kein Factory Knowledge — sein Profil muesste ux_insight + motivational_mechanic enthalten, ist aber bewusst ausgelassen (zu nah an CD).
3. **Test Generator kein Knowledge**: Koennte error_patterns bekommen fuer bessere Edge-Case Tests — Prioritaet niedrig.
4. **Entries wachsen**: Mit jedem Writeback-Cycle kommen neue Entries dazu. Die Max-Caps (3-5 pro Rolle) verhindern Prompt Bloat.
5. **Keine tag-basierte Filterung**: Aktuell nur type-basiert. Tag-Filterung (z.B. nur "swiftui" Tags fuer Swift-Passes) waere ein moegliches Upgrade.

---

## 7. Verdict

Cross-Run Knowledge ist jetzt **materiell breiter nutzbar**:

- **4 Passes** statt 1 empfangen Factory Knowledge
- **Role-appropriate**: Jede Rolle bekommt nur relevante Entry-Typen
- **Trust-explicit**: Technical Passes sehen nur `validated+`, CD sieht auch `hypothesis`
- **Token-diszipliniert**: ~933 Tokens total, keine Prompt-Aufblaehung
- **Auditable**: Confidence Level sichtbar in jedem injizierten Block
- **Erweiterbar**: Neue Rollen durch Eintrag in `_ROLE_PROFILES` hinzufuegbar

### Validierungsergebnisse
```
Role-based selection:      PASS (5 Rollen, unterschiedliche Entry-Sets)
Confidence filtering:      PASS (technical passes: nur validated+)
CD backwards-compatible:   PASS (get_cd_knowledge_block() unveraendert)
Fix Executor integration:  PASS (knowledge_block an Position 0 im Task)
Unknown role safety:       PASS (leerer String zurueck)
Token impact:              PASS (~933 Tokens total, unter 1000)
Idempotent:                PASS (gleiche Entries bei wiederholtem Aufruf)
```
