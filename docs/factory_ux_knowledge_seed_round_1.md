# Factory UX Knowledge — Seed Round 1

Date: 2026-03-13

---

## Source

UX Psychology review pass validation run on ExamSimulation screen template.

Run: `driveai_run_20260313_051211.txt`

The UX Psychology agent produced 5 findings grounded in behavioral science principles. This seed round captures the 4 most reusable insights as knowledge entries.

---

## Entries Added

| ID | Type | Title | Principle | Reusable for |
|---|---|---|---|---|
| FK-007 | ux_insight | Answer feedback must explain WHY | Testing Effect + Elaborative Processing | learning_app, education_app, quiz_app |
| FK-008 | motivational_mechanic | Show competence progress between tasks | Self-Determination Theory (Competence) | learning_app, fitness_app, skill_training |
| FK-009 | ux_insight | Visually differentiate task types | Cognitive Load Theory (Sweller) | learning_app, quiz_app, productivity_app |
| FK-010 | ux_insight | Interleave weak topics using spacing | Spacing Effect (Ebbinghaus, Cepeda) | learning_app, language_app, skill_training |

All entries have confidence level `hypothesis` — they are grounded in established research but not yet validated through factory production runs.

---

## Why These Were Selected

### FK-007 — Elaborative explanation at answer reveal
- **Principle**: Testing effect + elaborative processing (Roediger & Butler, 2011)
- **Why reusable**: Every learning product shows answer feedback. Binary correct/incorrect is the most common anti-pattern. Adding a 1-2 sentence explanation is a universal improvement.
- **Lesson**: "Every answer reveal should include a brief explanation connecting the correct answer to the underlying principle."

### FK-008 — Mid-session competence signal
- **Principle**: Self-Determination Theory (Deci & Ryan) — competence as core need
- **Why reusable**: Any app with sequential tasks (learning, fitness, training) benefits from real-time competence feedback rather than only end-of-session summaries.
- **Lesson**: "After each task, show current accuracy + topic + strength/gap indicator."

### FK-009 — Task type differentiation
- **Principle**: Cognitive Load Theory (Sweller, 1988) — extraneous vs. germane load
- **Why reusable**: Any app with multiple task types (recall, application, analysis) benefits from visual schema-activation cues. Not limited to learning apps.
- **Lesson**: "Add a subtle type indicator so users know what kind of thinking is required."

### FK-010 — Spacing and interleaving
- **Principle**: Spacing effect (Ebbinghaus, 1885; Cepeda et al., 2006)
- **Why reusable**: Fundamental to all learning systems. Massed practice creates illusions of competence. Spaced interleaving produces durable retention.
- **Lesson**: "Re-expose weak topics within same session (3-8 questions later) and across sessions (1-3-7 day intervals)."

---

## What Was Excluded

### Timer reframing (Cognitive Appraisal Theory)
- **Finding**: Timer induces anxiety without metacognitive framing; should show pacing rather than raw countdown.
- **Why excluded**: Too specific to timed exam simulations. Not applicable to most product types. The lesson is valid but narrow — would only help products with countdown timers.

---

## Impact on Knowledge Injection

The knowledge reader selects entries by confidence (highest first), capped at 5.

After this seed round:
- 10 total entries (7 hypothesis, 3 validated)
- 5 entries injected into CD prompt: FK-001, FK-002, FK-003, FK-007, FK-008
- FK-009 and FK-010 are in the store but not injected (cap of 5 reached)
- When older entries are promoted to `validated` or `proven`, the selection order may change

The injected knowledge block grew from 706 chars to 1158 chars (~250-300 tokens). Still well within budget.

---

## Knowledge Store Status

| Metric | Before | After |
|---|---|---|
| Total entries | 6 | 10 |
| ux_insight | 1 | 4 |
| motivational_mechanic | 1 | 2 |
| hypothesis | 3 | 7 |
| Injected into CD | 3 entries (706 chars) | 5 entries (1158 chars) |

---

## Why Only 4 Entries

1. **Quality over quantity**: Each entry must be reusable, grounded, and actionable. Speculative entries degrade the knowledge base.
2. **Injection cap**: Only 5 entries are injected per run. Adding more than needed dilutes the most impactful entries.
3. **Token budget**: The knowledge block should stay under ~300 tokens to avoid competing with implementation context.
4. **Evidence level**: All new entries are `hypothesis`. They need validation through future runs before the knowledge base should grow further.
