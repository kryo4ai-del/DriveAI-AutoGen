# AskFin Premium

## Identity

| Field | Value |
|---|---|
| Project ID | askfin_premium |
| Product | AskFin — AI Exam Coach for German Driving Theory |
| Platform | iOS (SwiftUI, MVVM) |
| Status | Planning |
| Created | 2026-03-13 |
| Parent | askfin (MVP — untouched, reference only) |

## Vision

> AskFin ist dein persoenlicher Fuehrerschein-Coach, der weiss wo du stehst, dich gezielt trainiert und dich pruefungsreif macht.

## Emotional Core

Von Pruefungsangst zu Pruefungssicherheit.

## Differentiator

Nicht der Fragenkatalog macht den Unterschied, sondern das adaptive Lernsystem dahinter. AskFin trainiert dich — andere Apps testen dich nur.

## Positioning Statement

AskFin is the AI exam coach for German driving theory learners who want to stop guessing if they're ready — and actually know.

---

## Experience Pillars

| # | Pillar | Core Feeling | Priority |
|---|---|---|---|
| 1 | Training Mode | "Die App weiss was ich brauche" | P0 — first to build |
| 2 | Skill Map | "Ich sehe genau wo ich stehe" | P0 — enables adaptive logic |
| 3 | Exam Simulation | "Jetzt weiss ich ob ich bereit bin" | P1 — after training mode |
| 4 | Progress Visualization | "Ich werde besser" | P1 — readiness score is key |
| 5 | Motivational Feedback | "Die App versteht mich" | P2 — polish layer |

### Pillar Priority Rationale

**P0 — Training Mode + Skill Map** together form the minimum viable premium product. Training Mode is the daily engagement hook. Skill Map is the competence dashboard that makes adaptive training visible. Without Skill Map, Training Mode has no feedback loop. Without Training Mode, Skill Map has no data.

**P1 — Exam Simulation + Progress** are the conversion triggers. The Readiness Score (from Progress) is the paywall moment. Exam Simulation validates readiness. These come second because they need training data to be meaningful.

**P2 — Motivational Feedback** is the polish layer that differentiates a good product from a premium one. It depends on all other pillars being functional.

---

## Relationship to MVP

The existing AskFin MVP (in `DriveAI/`) remains **untouched**:

- MVP = scan-based question solver + basic learning modes
- Premium = adaptive coaching system built on the 5 Experience Pillars
- MVP code serves as reference for working OCR/parsing/LLM pipeline
- Premium is a rebuild using the factory pipeline with full review layers (CD + UX Psych)

### What carries over from MVP
- OCR + Question Parsing pipeline (proven, working)
- LLM Solver + Explanation engine
- Design System foundation (AppTheme, components)
- Data models (Question, Answer, AnswerResult)

### What is new in Premium
- Adaptive question selection (spacing, interleaving, weakness targeting)
- Skill Map with topic-level competence tracking
- Exam Simulation with readiness scoring
- Progress dashboard with readiness forecast
- Motivational micro-copy system
- Premium design identity (swipe-based, haptic, progressive disclosure)

---

## Design Signature

### Visual
- Primary: Dark theme (trust, focus)
- Accent: Progress color (green grows, red shrinks)
- Typography: Clear, large, confident — no small gray labels
- Animations: Subtle but noticeable — score changes animate, weaknesses disappear visually

### Interaction
- Swipe-based question answering (not small buttons)
- Haptic feedback (correct = light tap, incorrect = short vibration)
- Progressive disclosure (explanations expand, not all at once)

### Tone
- Sachlich aber warm
- Ermutigend ohne kindisch
- Direkt ohne harsch
- Example: "Vorfahrt ist noch wackelig. 3 von 5 richtig — aber letzte Woche waren es 1 von 5. Du bist dran."

---

## Constraints

### Legal
- No bundled official questions (arge tp 21 licensing)
- Camera/scan input only — user supplies their own material
- Disclaimer: "Lernhilfe, keine offizielle Pruefungsvorbereitung"

### Technical
- 100% Anthropic Claude (no OpenAI)
- Offline capability for core features (MVP proven)
- LLM cost cap per free-tier user

### Commercial
- Freemium: Free tier (limited scans + basic training) / Premium (full adaptive + readiness score)
- Lifetime purchase recommended over subscription (4-16 week user lifecycle)
- See: `strategy_books/askfin_strategy.md` for full commercial strategy

---

## Factory Knowledge Applied

The premium rebuild incorporates these factory learnings:

| ID | Lesson | Applied to |
|---|---|---|
| FK-001 | Define emotional core before features | Vision + Pillars |
| FK-002 | Emotional micro-copy > data display | Pillar 5 (Motivational Feedback) |
| FK-003 | Domain-specific progress > generic gamification | Pillar 4 (Readiness Score) |
| FK-007 | Explain WHY, not just correct/incorrect | Pillar 1 (Training Mode feedback) |
| FK-008 | Mid-session competence signals | Pillar 1 (between-question feedback) |
| FK-009 | Differentiate task types visually | Pillar 1 (question type labels) |
| FK-010 | Interleave weak topics with spacing | Pillar 1 (adaptive question selection) |

---

## Directory Structure

```
projects/askfin_premium/
├── PROJECT.md          ← This file (project definition + pillars)
├── specs/              ← Feature specifications (one per pillar/feature)
├── design/             ← Design tokens, component specs, mockup references
└── generated/          ← Factory-generated code (output of pipeline runs)
```

---

## Next Steps

1. Spec Training Mode (Pillar 1) — feature specification for factory pipeline
2. Spec Skill Map (Pillar 2) — data model + visualization spec
3. Generate Training Mode via factory pipeline
4. Review with CD + UX Psychology passes
5. Iterate based on review findings
