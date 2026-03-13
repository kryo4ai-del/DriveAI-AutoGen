# UX Psychology Review Layer

Date: 2026-03-13

---

## Purpose

The UX Psychology review pass analyzes generated product features from a behavioral science and learning psychology perspective. It evaluates whether implementations create meaningful user motivation, effective progress feedback, manageable cognitive load, and sustainable retention mechanics.

---

## How It Differs from Creative Director

| Aspect | Creative Director | UX Psychology |
|---|---|---|
| Core question | Does this LOOK premium? | Does this WORK psychologically? |
| Focus | Visual design, branding, micro-copy, differentiation | Motivation, habit formation, learning science, retention |
| Lens | Product quality & design identity | Behavioral science & cognitive psychology |
| Output | Pass/conditional_pass/fail rating + design suggestions | Findings with psychological principles + behavioral fixes |
| Gate | Soft gate (can stop pipeline on FAIL) | Advisory only (never blocks) |

The two passes are complementary:
- CD catches: generic design, missing personality, weak interaction patterns
- UX Psych catches: missing motivation loops, poor progress feedback, cognitive overload, violated learning principles

---

## When It Runs

| Template | UX Psychology runs? |
|---|---|
| `screen` | Yes |
| `feature` | Yes |
| `service` | No (skipped) |
| `viewmodel` | No (skipped) |
| Other | No (skipped) |

The pass also skips when the CD gate has stopped the pipeline (FAIL rating).

### Pipeline position

```
Implementation → Bug Hunter → Creative Director → [CD Gate] → UX Psychology → Refactor → Test Gen
```

---

## Evaluation Dimensions

1. **Motivation architecture**: Intrinsic motivation, agency, competence
2. **Progress feedback**: Immediate, specific, actionable feedback
3. **Cognitive load**: Information chunking, clear decision points
4. **Learning psychology**: Retrieval practice, spaced repetition, interleaving, desirable difficulty
5. **Retention mechanics**: Re-engagement triggers, domain-relevant return reasons
6. **Emotional reinforcement**: Earned success, constructive failure
7. **Habit formation**: Trigger-action-reward loops, variable rewards

---

## Forbidden Suggestions

The UX Psychology agent is explicitly prohibited from suggesting:
- Generic gamification (badges, points, XP, leaderboards, streaks)
- Social pressure mechanics
- Dark patterns (artificial urgency, guilt-based notifications)
- Vague advice ("add motivation", "improve engagement")

All suggestions must be grounded in specific psychological principles with expected behavioral effects.

---

## How to Disable

```bash
# Disable UX Psychology for a single run
python main.py --template screen --name Dashboard --profile dev --approval auto --disable-agent ux_psychology

# Disable both review layers
python main.py --template screen --name Dashboard --profile dev --approval auto --disable-agent creative_director --disable-agent ux_psychology
```

---

## Implementation Location

### Agent
`agents/ux_psychology.py` — mirrors creative_director.py pattern

### System message
`config/agent_roles.json` → `ux_psychology` entry

### Pipeline integration
`main.py` — inserted after CD gate, before refactor pass

### Configuration
- `config/agent_toggles.json` → `ux_psychology: true`
- `config/agent_toggle_config.py` → added to `ALL_AGENTS`
- `config/model_router.py` → `ux_psychology_review` route (Sonnet, Tier 2)

---

## Limitations

1. **No gate**: UX Psychology is advisory only. Even poor behavioral design does not stop the pipeline.
2. **SelectorGroupChat speaker selection**: Like CD, the selector may choose a different agent. The task prefix `ux_psychology:` mitigates this.
3. **Token cost**: Adds one additional 10-message pass per product-facing run (~3-5k tokens).
4. **No knowledge injection**: Unlike CD, UX Psychology does not yet receive factory knowledge entries. This can be added later if UX-specific knowledge entries are seeded.
5. **Overlap risk**: Some findings may echo CD findings if both agents identify motivation-related issues. This is acceptable — different lenses may produce complementary insights.
