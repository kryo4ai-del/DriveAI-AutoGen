# Factory Knowledge — Seed Round 1

Date: 2026-03-12

---

## What Was Added

6 knowledge entries seeded into `factory_knowledge/knowledge.json`, derived from real AskFin work and factory pipeline improvements completed 2026-03-12.

| ID | Type | Title | Confidence |
|---|---|---|---|
| FK-001 | failure_case | Functional-only learning app provides no retention hook | hypothesis |
| FK-002 | ux_insight | Emotional micro-copy outperforms data-only feedback | hypothesis |
| FK-003 | motivational_mechanic | Domain-specific progress tracking beats generic gamification | hypothesis |
| FK-004 | technical_pattern | Reset SelectorGroupChat between passes to prevent context explosion | validated |
| FK-005 | technical_pattern | Compact implementation summary restores review quality after context reset | validated |
| FK-006 | success_pattern | New review agents should start as advisory-only passes | validated |

---

## Why These Were Chosen

### Selection Criteria

Each entry had to pass all four checks:

1. **Grounded in evidence** — derived from actual work, not speculation
2. **Reusable** — applicable beyond AskFin to future factory projects
3. **Not a vague slogan** — includes concrete context, actionable lesson, and when-to-use guidance
4. **Not a duplicate** — teaches something not already captured in existing docs

### Category Rationale

**Product/UX entries (FK-001 to FK-003)**: Marked as `hypothesis` because they are grounded in product analysis (AskFin premium reframing), not in shipped user-facing validation. They represent design convictions based on domain research, not measured outcomes. They should be promoted to `validated` when a factory project ships with these patterns and receives positive feedback.

**Technical/process entries (FK-004 to FK-006)**: Marked as `validated` because they were implemented, tested in multiple pipeline runs, and produced measurable improvements (zero rate limit crashes, file-specific review output, stable CD pass). They can be promoted to `proven` when a second project benefits from the same patterns.

---

## What Was Deliberately Excluded

| Candidate | Reason for Exclusion |
|---|---|
| "Reset between passes stabilizes runs" | Redundant with FK-004 — same lesson, different wording |
| "Early quality gates should wait until knowledge exists" | Speculative — proposed in gates doc but never tested in execution |
| "Model routing should be a service, not an agent" | Design recommendation from roles proposal, not validated by failed implementation |
| "Generic gamification is low value" | Overlaps with FK-003 — FK-003 is the actionable version of this insight |
| Design-specific entries (color coding, dark theme, swipe vs. tap) | No user-testing evidence. These are design preferences documented in product strategy, not validated patterns |
| "Rate limit retry with exponential backoff" | Implementation detail, not a reusable insight — the code speaks for itself |
| "AutoGen has two error propagation paths" | Too implementation-specific. Useful as documentation (see pipeline_reliability_fix.md) but not as cross-project knowledge |

---

## How This Seed Should Influence Future Projects

### For the next factory project

1. **Product scoping**: Read FK-001 and FK-003 before defining features. Ask: does this project have a domain-specific progress metric, or are we defaulting to generic gamification?

2. **UX writing**: Read FK-002 when designing feedback screens. Write contextual micro-copy, not data labels.

3. **Pipeline setup**: Apply FK-004 and FK-005 from the start. Don't discover context explosion on the first large run.

4. **New agent introduction**: Follow FK-006. Start advisory, prove value, then promote.

### Confidence promotion path

- FK-001/002/003: `hypothesis` → `validated` when a shipped project implements these patterns and receives positive user feedback
- FK-004/005/006: `validated` → `proven` when a second project uses these patterns successfully

---

## Metrics

- Entries added: 6
- Categories covered: 4 of 6 (failure_case, ux_insight, motivational_mechanic, technical_pattern, success_pattern)
- Categories empty: design_insight (no validated visual patterns yet)
- Confidence distribution: 3 hypothesis, 3 validated, 0 proven
- Source projects: askfin (sole source — first project)
