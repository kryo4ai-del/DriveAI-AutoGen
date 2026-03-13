# Exam Simulation + Progress / Readiness Layer — Feature Specification

Project: AskFin Premium
Pillars: 3 (Exam Simulation) + 4 (Progress Visualization)
Priority: P1
Date: 2026-03-13
Depends on: Training Mode + Skill Map (P0, implemented)

---

## 1. Product Purpose

### Why AskFin Needs an Exam Simulation Layer

Training Mode teaches. Exam Simulation proves.

Without simulation, the user trains in an open-ended loop — they get better, but never know *how ready* they actually are. The result: exam anxiety persists even in well-prepared learners. "Ich lerne seit Wochen, aber weiss nicht ob es reicht."

The Exam Simulation closes this gap. It puts the user into a realistic exam scenario — same question count, same time pressure, same pass/fail threshold — and delivers an honest verdict: bereit oder noch nicht.

This is not a generic quiz mode. It is a calibrated rehearsal that mirrors the conditions of the official Theorieprüfung.

### Why a Readiness / Progress System Is Essential

Progress without context is noise. "Du hast 120 Fragen beantwortet" says nothing. "Du bist zu 78% prüfungsbereit — Vorfahrt und Abstand brauchen noch Arbeit" says everything.

The Readiness Score is the single number that converts training data into a decision signal. It answers the question every learner asks every day: "Bin ich bereit?"

Combined with a Progress Dashboard, it makes improvement visible over time. The user sees their trajectory — not just where they are, but where they came from and how fast they're moving. This builds confidence through evidence, not encouragement.

### How This Builds Confidence Rather Than Anxiety

| Design Decision | Effect |
|---|---|
| No surprise pass/fail — user sees readiness estimate *before* starting | Sets expectations, reduces shock |
| Practice simulations are framed as "Generalprobe", not "Test" | Reframes failure as rehearsal data |
| After a failed simulation, the app shows exactly what to work on | Channels disappointment into action |
| Confidence trajectory shows improvement over time | Even after a bad simulation, the user sees they're trending up |
| Readiness Score updates gradually, never drops catastrophically | One bad day doesn't erase weeks of progress |

---

## 2. User Experience Goals

### What the User Should Feel

| Phase | Feeling | Mechanism |
|---|---|---|
| Before simulation | "Ich trau mich — die App sagt ich bin bei 82%" | Readiness Score as permission signal |
| During simulation | "Das fühlt sich echt an" | Realistic conditions — timer, question count, no hints |
| After passing | "Jetzt weiss ich es — ich kann das" | Evidence-based confidence, not hope |
| After failing | "Ok, ich weiss was fehlt — das krieg ich hin" | Concrete gap analysis, no vague "try again" |
| Over days/weeks | "Ich sehe wie ich besser werde" | Progress Dashboard with trajectory |

### Anti-Goals

- NOT: "Ich hab Angst vor dem nächsten Simulationsergebnis"
- NOT: "Die App zeigt mir nur was ich falsch mache"
- NOT: "Ich mache Simulationen als Selbstbestrafung"
- NOT: "Die Prozentzahl macht mich nervös"

---

## 3. Core Experience Components

### Overview

| Component | What It Is | Where It Lives |
|---|---|---|
| Exam Simulation Mode | Realistic Theorieprüfung rehearsal | Full-screen experience, accessed from Dashboard |
| Readiness Score | Single 0-100% number with topic breakdown | Dashboard header, Skill Map footer, Simulation entry |
| Progress Dashboard | Visual history of readiness over time | Dedicated tab or Dashboard section |
| Weakness Tracking | Persistent record of recurring problem areas | Embedded in Simulation Results + Progress Dashboard |
| Exam History | List of past simulation attempts with results | Accessible from Progress Dashboard |
| Confidence Trajectory | Trend line showing readiness direction | Progress Dashboard chart |

### Component Relationships

```
Dashboard
├── Readiness Score (always visible)
├── [Simulation starten] → ExamSimulationView
│       └── SimulationResultView
│               ├── Topic Breakdown (gap analysis)
│               ├── [Schwächen trainieren] → Training Mode (weakness queue)
│               └── [Nochmal] → new simulation
├── [Fortschritt] → ProgressDashboardView
│       ├── Confidence Trajectory (chart)
│       ├── Exam History (list)
│       └── Weakness Tracking (recurring gaps)
└── Skill Map (existing, enhanced with readiness bar)
```

---

## 4. Simulation Design

### Exam Format (Mirrors Official Theorieprüfung)

| Parameter | Official Exam | AskFin Simulation |
|---|---|---|
| Question count | 30 (Klasse B) | 30 |
| Time limit | 45 min | 45 min (configurable: 30/45/60) |
| Pass threshold | Max 10 Fehlerpunkte | Max 10 Fehlerpunkte |
| Question types | Mixed (Vorfahrt, Zeichen, Technik, ...) | Weighted by official topic distribution |
| Feedback during exam | None | None (realistic mode) |
| Result | Pass/Fail + Fehlerpunkte | Pass/Fail + Fehlerpunkte + topic breakdown |

### Fehlerpunkte-System

The official exam uses a point-based system, not simple right/wrong counting:

| Question Type | Fehlerpunkte if Wrong |
|---|---|
| Vorfahrt-Fragen (priority questions) | 5 Punkte |
| Standard-Fragen | 2 Punkte |
| Grundstoff-Fragen (basic theory) | 3 Punkte |

Instant fail: 2 Vorfahrt-Fragen falsch = durchgefallen (regardless of total points).

AskFin simulations implement this exact scoring system. The user learns not just "how many wrong" but "how expensive each mistake is."

### Pre-Simulation Screen

```
┌─────────────────────────────────────────┐
│                                         │
│   Generalprobe                          │
│                                         │
│   30 Fragen · 45 Minuten               │
│   Bestanden ab max. 10 Fehlerpunkte    │
│                                         │
│   ─────────────────────────────         │
│   Deine aktuelle Bereitschaft: 82%     │
│   Letzte Simulation: 8 FP (bestanden)  │
│   ─────────────────────────────         │
│                                         │
│   [ Simulation starten ]                │
│                                         │
│   Einstellungen:                        │
│   Zeitlimit: [30] [45] [60] min        │
│                                         │
└─────────────────────────────────────────┘
```

Key design decisions:
- "Generalprobe" not "Prüfung" — it's a rehearsal, not judgment
- Readiness Score shown before start — sets expectations
- Last simulation result shown — context for improvement
- Time limit configurable — 30 min for quick check, 60 min for low-stress practice

### During Simulation

```
┌─────────────────────────────────────────┐
│  Frage 12 / 30            ⏱ 34:21     │
│  ════════════════════                   │
│                                         │
│  [Question card — same QuestionCardView │
│   as Training Mode, but without         │
│   immediate feedback]                   │
│                                         │
│  A: [option]     B: [option]            │
│  C: [option]     D: [option]            │
│                                         │
│  Fehlerpunkte bisher: 4                 │
│                                         │
└─────────────────────────────────────────┘
```

Differences from Training Mode:
- **No immediate feedback** — answer is recorded, next question loads immediately
- **Timer running** — visible countdown in header
- **Progress bar** — shows question N of 30
- **Fehlerpunkte counter** — running total (user can choose to hide this)
- **No WHY explanations** — just like the real exam
- **No competence signals** — pure exam conditions
- Same swipe gestures as Training Mode (muscle memory transfer)

### Simulation Pacing

- No auto-advance (user controls pace via tap/swipe)
- Skip allowed — unanswered questions count as wrong (flagged in results)
- "Frage markieren" button — flags question for review at the end
- After question 30: "Markierte Fragen prüfen?" prompt before submission

### Immediate vs Delayed Feedback

**Default: Delayed** (after submission of all 30 questions). This is the realistic mode.

**Optional: Sofort-Modus** — shows correct/incorrect after each answer. For early learners who aren't ready for full exam pressure yet. Clearly labeled as "Übungsmodus" not "Simulation."

| Mode | When to Use | Label |
|---|---|---|
| Realistic (delayed) | Readiness >= 60% | "Generalprobe" |
| Practice (immediate) | Readiness < 60% or user preference | "Übungssimulation" |

### Result Summary (SimulationResultView)

#### Passed

```
┌─────────────────────────────────────────┐
│                                         │
│   Bestanden!                            │
│                                         │
│   6 Fehlerpunkte (max. 10)             │
│   25 von 30 richtig                     │
│   Zeit: 28:45 von 45:00                │
│                                         │
│   ─────────────────────────────         │
│   Themen-Übersicht:                     │
│   ● Vorfahrt      5/5  ✓               │
│   ● Zeichen       4/5  ✓               │
│   ● Geschwindigkeit 3/4  1 FP          │
│   ● Abstand       2/3  2 FP            │
│   ● Technik       2/3  3 FP            │
│   ─────────────────────────────         │
│                                         │
│   Bereitschaft: 82% → 86% (+4%)        │
│                                         │
│   [ Ergebnisse im Detail ]              │
│   [ Fertig ]                            │
│                                         │
└─────────────────────────────────────────┘
```

#### Failed

```
┌─────────────────────────────────────────┐
│                                         │
│   Noch nicht bestanden.                 │
│   14 Fehlerpunkte (max. 10)            │
│                                         │
│   Das ist okay — genau dafür ist die   │
│   Generalprobe da.                      │
│                                         │
│   ─────────────────────────────         │
│   Was zu tun ist:                       │
│                                         │
│   1. Abstand (6 FP)                    │
│      → 1 von 4 richtig                 │
│      → Empfehlung: Thema gezielt üben  │
│                                         │
│   2. Vorfahrt (5 FP)                   │
│      → 2 von 5 richtig                 │
│      → Achtung: 2 Vorfahrt-Fehler =   │
│        automatisch durchgefallen        │
│                                         │
│   ─────────────────────────────         │
│                                         │
│   [ Schwächen trainieren ]              │
│   [ Alle Antworten ansehen ]            │
│   [ Nochmal simulieren ]                │
│                                         │
└─────────────────────────────────────────┘
```

Key design decisions:
- **"Noch nicht bestanden"** not "Durchgefallen" — language matters
- **"Genau dafür ist die Generalprobe da"** — reframes failure as expected learning
- **Actionable gap analysis** — ranked by Fehlerpunkte, not alphabetical
- **Specific recommendations** — "Thema gezielt üben" links to Training Mode
- **Vorfahrt warning** — explains the instant-fail rule (many learners don't know it)
- **Readiness Score update** — shows delta, never dramatic drops (see section 5)

### Retry Flow

After any simulation result:
- "Nochmal simulieren" → starts new simulation immediately (fresh 30 questions)
- "Schwächen trainieren" → opens Training Mode with weakness queue pre-loaded
- "Alle Antworten ansehen" → scrollable list showing each question + correct answer + user answer
- Questions are regenerated each simulation (not same 30 every time)

### Answer Review (Post-Simulation)

```
┌─────────────────────────────────────────┐
│  Frage 7 / 30 — Abstand          ✗    │
│                                         │
│  [Question text]                        │
│                                         │
│  Deine Antwort: A                       │
│  Richtig: C                             │
│                                         │
│  Weil: Bei Regen verdoppelt sich der   │
│  Sicherheitsabstand — von "halber      │
│  Tacho" auf "ganzer Tacho".            │
│                                         │
│  Fehlerpunkte: 2                        │
│  ─────────────────────────────         │
└─────────────────────────────────────────┘
```

WHY explanations are shown here — after the simulation is over. This is the learning moment. During the simulation, no hints. After, full transparency.

---

## 5. Progress / Readiness Logic

### Readiness Score Calculation

The Readiness Score (0-100%) combines multiple signals into a single number. It uses the existing `TopicCompetenceService` data as foundation.

```
readinessScore = (
    topicCompetenceScore * 0.50
  + simulationPerformanceScore * 0.30
  + consistencyScore * 0.20
)
```

#### Component 1: Topic Competence Score (50%)

Uses existing weighted average from Training Mode spec:

```
topicCompetenceScore = weightedAverage(
    topic_scores,
    weights = topic_exam_weights  // from training_mode.md
)

where topic_score = {
    notStarted: 0,
    weak: 25,
    shaky: 55,
    solid: 80,
    mastered: 100
}
```

This is already computed by `TopicCompetenceService.overallReadiness`.

#### Component 2: Simulation Performance Score (30%)

Based on recent simulation results:

```
if no_simulations_completed:
    simulationPerformanceScore = topicCompetenceScore * 0.6
    // Estimate from training data until first simulation

else:
    // Use last 3 simulations, exponentially weighted
    weights = [0.6, 0.3, 0.1]  // most recent = highest weight

    for each simulation:
        simScore = max(0, (1 - fehlerpunkte / 30) * 100)

    simulationPerformanceScore = weightedAverage(simScores, weights)
```

Important: Before any simulation is completed, the simulation component is estimated from training data (at 60% value) rather than showing 0%. This prevents the Readiness Score from dropping when the user first discovers the simulation feature.

#### Component 3: Consistency Score (20%)

Rewards regular practice:

```
streakDays = current learning streak length
recentActivity = sessions in last 7 days

consistencyScore = min(100,
    (min(streakDays, 14) / 14) * 50     // streak component (caps at 14 days)
  + (min(recentActivity, 7) / 7) * 50   // activity component (caps at 7 sessions)
)
```

This ensures that a user who trains 3x per week with consistent results scores higher than one who crams 20 sessions in one day.

### Readiness Score Stability Rules

To avoid anxiety-inducing score swings:

| Rule | Reason |
|---|---|
| Maximum daily drop: 5 points | One bad simulation doesn't erase a week of progress |
| Minimum score: never below lowest of last 7 days minus 10 | Prevents crash-to-zero scenarios |
| Score rises faster than it falls | Positive reinforcement: improvement is more visible than regression |
| New topics don't lower score | Starting a new topic area adds potential, doesn't dilute existing competence |

### Readiness Milestones

| Score | Label | Color | Meaning |
|---|---|---|---|
| 0-29 | "Am Anfang" | Grau | Just started, needs all topic areas |
| 30-49 | "Grundlagen gelegt" | Rot | Basics covered, many gaps remain |
| 50-69 | "Auf dem Weg" | Gelb | Solid foundation, specific weaknesses to address |
| 70-84 | "Fast bereit" | Hellgrün | Good chance of passing, polish needed |
| 85-100 | "Prüfungsbereit" | Grün | Confident prediction: ready for real exam |

### Confidence Trajectory

The Progress Dashboard shows a line chart of Readiness Score over time:

```
100% ┤
 90% ┤                                    ●
 80% ┤                          ●  ●  ●
 70% ┤               ●  ●  ●
 60% ┤         ●  ●
 50% ┤    ●  ●
 40% ┤ ●
 30% ┤
     └──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──
       Mo Di Mi Do Fr Sa So Mo Di Mi Do
```

- One data point per day (highest readiness score of the day)
- X-axis: last 14 days (scrollable to full history)
- Milestone labels shown as horizontal reference lines
- Current score highlighted with label

### Weakness Tracking

Tracks which topics repeatedly cause Fehlerpunkte across simulations:

```
Recurring weaknesses (last 5 simulations):

  Abstand:       4 of 5 simulations with errors (avg 3.2 FP)
  Vorfahrt:      3 of 5 simulations with errors (avg 2.0 FP)
  Fahrzeugtechnik: 2 of 5 simulations with errors (avg 1.5 FP)
```

This is distinct from topic competence level. A user might be `shaky` in Abstand (50-79% accuracy in training) but consistently lose Fehlerpunkte in simulations specifically. Weakness tracking captures simulation-specific failure patterns.

### Exam History

Persistent record of all simulation attempts:

```
Deine Simulationen:

  13.03.2026  14 FP  ✗  28:45 min
  11.03.2026   8 FP  ✓  32:10 min
  09.03.2026  12 FP  ✗  41:30 min
  07.03.2026  16 FP  ✗  38:15 min
```

Each entry is tappable → opens full SimulationResultView for that attempt.

---

## 6. UX Psychology Integration

### Competence Signaling

The Readiness Score is the primary competence signal. Unlike Training Mode's per-topic feedback, the Readiness Score addresses the meta-question: "Bin ich insgesamt bereit?"

**Applied principles:**
- Single number with clear label → reduces cognitive load vs. 16 topic percentages
- Milestone labels ("Fast bereit", "Prüfungsbereit") → calibrated language that matches internal self-assessment
- Score shown *before* simulation → user makes informed decision, not blind leap

### Anxiety Reduction

The exam itself triggers anxiety. The simulation must reduce it, not amplify it.

**Applied principles:**
- "Generalprobe" framing → theater metaphor: rehearsal is expected to have rough spots
- Stability rules → score never crashes, user never feels "back to zero"
- Practice mode available → user isn't forced into realistic mode before they're ready
- Failed simulation → immediate actionable plan, not just a number
- "Noch nicht bestanden" → temporal language: "yet" implies future success

### Feedback Timing

**During simulation:** No feedback (realistic). This builds exam tolerance — the ability to continue without knowing if the last answer was right.

**After simulation:** Full transparency. Every answer reviewed with WHY explanations. This is the high-impact learning moment — the user is maximally engaged after seeing their result.

**In Progress Dashboard:** Delayed feedback over days/weeks. The trajectory chart shows patterns the user can't see in individual sessions.

### Motivation Through Progress

The Confidence Trajectory is the key motivational mechanism. It works because:

1. **Visual proof** — "I was at 45% two weeks ago, now I'm at 72%"
2. **Normalizes dips** — bad days are visible but don't dominate the trend
3. **Goal proximity** — the closer to "Prüfungsbereit", the stronger the pull
4. **History anchoring** — even after a bad simulation, the chart shows overall upward movement

### Confidence Calibration

The Readiness Score must be calibrated to reality. A user at 85% should actually pass the exam most of the time.

**Calibration approach:**
- Topic competence (50%) is validated against the official topic distribution
- Simulation performance (30%) directly mirrors exam conditions
- The milestone labels are conservative: "Prüfungsbereit" at 85%, not 70%
- Better to under-promise and over-deliver than send a user to the exam too early

---

## 7. Premium Differentiation

### What Generic Apps Do

| Feature | Generic App | AskFin Premium |
|---|---|---|
| Practice quiz | 30 random questions, score at end | 30 questions weighted by official topic distribution with Fehlerpunkte scoring |
| Progress | "Du hast 340 Fragen beantwortet" | Readiness Score with trajectory, topic breakdown, weakness tracking |
| Exam prep | "Übe mehr" after failing | Specific gap analysis + direct link to targeted training |
| Feedback | Correct/incorrect count | Per-question WHY explanations (post-simulation) |
| Scoring | Percentage | Fehlerpunkte system mirroring official exam (5/3/2 point weighting) |
| Confidence | Badge: "Quiz Champion" | "Deine Bereitschaft: 82% — Vorfahrt und Abstand noch trainieren" |
| History | None or basic list | Trajectory chart with milestone markers |
| Recovery | "Nochmal versuchen" | "Abstand ist dein Hauptproblem — hier sind 5 Fragen dazu" |

### The Premium Moment

The paywall moment for AskFin is the Readiness Score. Free users get Training Mode (limited sessions) but never see their Readiness Score or Confidence Trajectory.

The pitch: "Du trainierst seit 2 Wochen. Willst du wissen ob du bereit bist?"

This is the moment of highest willingness to pay — the user has invested time, has data, and wants the answer to the one question that matters.

---

## 8. First Implementation Targets

### First Factory Run Scope

Keep the first implementation realistic: core simulation flow + readiness foundation. No full Progress Dashboard yet.

#### Models (4 files)

| File | Purpose |
|---|---|
| `ExamSimulation.swift` | Simulation session model: questions, answers, timestamps, fehlerpunkte, pass/fail |
| `SimulationConfig.swift` | Configuration: question count, time limit, mode (realistic/practice), topic weights |
| `SimulationResult.swift` | Result model: fehlerpunkte breakdown by topic, pass/fail, comparison to last attempt |
| `ReadinessScore.swift` | Readiness model: score value, components (topic/simulation/consistency), milestone label |

#### Services (2 files)

| File | Purpose |
|---|---|
| `ExamSimulationService.swift` | Simulation lifecycle: generate question set (weighted), track answers, calculate fehlerpunkte |
| `ReadinessScoreService.swift` | Compute readiness from TopicCompetenceService data + simulation history + consistency |

#### ViewModels (2 files)

| File | Purpose |
|---|---|
| `ExamSimulationViewModel.swift` | Drives simulation flow: timer, question progression, answer recording, submission |
| `SimulationResultViewModel.swift` | Processes result: topic breakdown, gap analysis, readiness delta, recommendations |

#### Views (4 files)

| File | Purpose |
|---|---|
| `ExamSimulationView.swift` | Full-screen simulation: pre-start screen, question flow, timer, fehlerpunkte counter |
| `SimulationResultView.swift` | Result screen: pass/fail, topic breakdown, actionable recommendations, retry CTA |
| `ReadinessScoreView.swift` | Reusable component: readiness circle/bar with score, milestone label, delta indicator |
| `ExamHistoryView.swift` | List of past simulation attempts with results, tappable for detail |

#### Tests (1 file)

| File | Purpose |
|---|---|
| `ReadinessScoreServiceTests.swift` | Unit tests: score calculation, stability rules, milestone classification, edge cases |

**Total: 4 Models + 2 Services + 2 ViewModels + 4 Views + 1 Test = 13 files.**

### Architecture Reuse

| Existing Component | Reused For |
|---|---|
| `TopicCompetenceService` | Readiness Score component 1 (topic competence) |
| `TopicArea` enum | Topic distribution weights in simulation question generation |
| `CompetenceLevel` enum | Milestone label mapping |
| `SessionQuestion` struct | Simulation questions (extended with fehlerpunkte weight) |
| `QuestionCardView` | Same card UI in simulation (without feedback overlay) |
| `CompletedQuestion` struct | Answer recording during simulation |
| `TrainingResult` struct | Pattern for SimulationResult |
| `LearningStreak` struct | Consistency Score component |

### What Is NOT in First Run

| Deferred | Why |
|---|---|
| ProgressDashboardView | Needs simulation history data first — build after 2-3 simulation runs exist |
| Confidence Trajectory chart | Requires charting library decision + multi-day data |
| Weakness Tracking view | Needs 3+ simulations to show meaningful patterns |
| Practice mode (immediate feedback) | Start with realistic mode, add practice mode in iteration 2 |
| Question flagging + review loop | Nice-to-have, not core flow |
| Configurable Fehlerpunkte display (hide/show) | Default: show. Setting comes later |

---

## Screens to Generate

The factory pipeline should generate these SwiftUI files:

| Screen | Purpose | Complexity |
|---|---|---|
| `ExamSimulationView` | Pre-start screen + simulation flow + timer + question progression | High |
| `SimulationResultView` | Pass/fail + Fehlerpunkte breakdown + topic analysis + recommendations | High |
| `ReadinessScoreView` | Reusable readiness indicator (circular/bar) with score + milestone + delta | Medium |
| `ExamHistoryView` | List of past simulation attempts | Low |
| `ExamSimulationViewModel` | Timer, question flow, answer recording, Fehlerpunkte calculation | High |
| `SimulationResultViewModel` | Result processing, gap ranking, readiness delta, recommendations | Medium |
| `ExamSimulationService` | Question generation (weighted), Fehlerpunkte scoring, simulation persistence | High |
| `ReadinessScoreService` | Readiness computation (3-component), stability rules, milestone classification | High |
| `ExamSimulation` | Simulation session model | Low |
| `SimulationConfig` | Configuration model | Low |
| `SimulationResult` | Result model with Fehlerpunkte breakdown | Medium |
| `ReadinessScore` | Score model with components + milestone | Low |
| `ReadinessScoreServiceTests` | Unit tests for readiness calculation | Medium |

Total: 4 Views + 2 ViewModels + 2 Services + 4 Models + 1 Test = 13 files.

---

## Factory Pipeline Configuration

### Recommended Template

Use `feature` template — this generates Views + ViewModels + Services + Models as a coherent unit.

### Task Prompt (for factory run)

```
Design and implement the Exam Simulation + Readiness Layer for AskFin Premium.

This is the second premium pillar, building on the existing Training Mode + Skill Map implementation.

Core components:
1. ExamSimulationView — full-screen exam rehearsal: pre-start screen with readiness estimate, 30-question timed simulation, Fehlerpunkte counter, no feedback during exam
2. SimulationResultView — pass/fail result with Fehlerpunkte breakdown by topic, actionable gap analysis sorted by impact, readiness delta, retry/train CTAs
3. ReadinessScoreView — reusable component showing readiness percentage (0-100%), milestone label, delta indicator. Used in Dashboard, Simulation entry, and Result screens
4. ExamHistoryView — chronological list of past simulation attempts with Fehlerpunkte + pass/fail + time
5. ExamSimulationViewModel — manages timer (countdown), question progression (30 questions), answer recording, Fehlerpunkte calculation (5/3/2 point system), submission
6. SimulationResultViewModel — processes simulation into ranked gap analysis, computes readiness delta, generates per-topic recommendations
7. ExamSimulationService — generates weighted question sets (30 questions distributed by official exam topic weights), calculates Fehlerpunkte with Vorfahrt instant-fail rule, persists simulation history
8. ReadinessScoreService — computes readiness from 3 components: topic competence (50%, from TopicCompetenceService), simulation performance (30%, last 3 simulations weighted), consistency (20%, streak + recent activity). Enforces stability rules (max 5-point daily drop)

Data models:
- ExamSimulation: session with questions, answers, timestamps, config reference
- SimulationConfig: questionCount (30), timeLimit (45 min), mode (realistic/practice), topic weights matching official exam
- SimulationResult: fehlerpunkte total + per topic, pass/fail, time taken, topic breakdown, comparison to previous attempt
- ReadinessScore: score (0-100), components (topic/simulation/consistency), milestone (amAnfang/grundlagenGelegt/aufDemWeg/fastBereit/pruefungsbereit)

Design requirements:
- Dark theme, green accent for progress (matches existing Training Mode)
- Same swipe gestures as Training Mode for question answering (muscle memory)
- No feedback during realistic simulation (exam conditions)
- German UI text — "Generalprobe" not "Test", "Noch nicht bestanden" not "Durchgefallen"
- Haptic feedback: simulation start (heavy), answer recorded (light), time warning at 5 min (warning), simulation end (heavy)
- Fehlerpunkte scoring mirrors official exam: Vorfahrt = 5 FP, Grundstoff = 3 FP, Standard = 2 FP
- Vorfahrt instant-fail rule: 2 wrong Vorfahrt questions = automatic fail regardless of total FP

Behavioral requirements:
- Pre-start screen shows current readiness + last simulation result
- Timer counts down, visible in header
- After submission: full WHY explanations available for every question (learning moment)
- Failed simulation: actionable gap analysis ranked by FP impact, direct link to Training Mode weakness queue
- Readiness Score stability: max 5-point daily drop, score rises faster than it falls
- Reuse TopicCompetenceService, TopicArea, CompetenceLevel, SessionQuestion from existing Training Mode

Existing architecture to integrate with:
- TopicCompetenceService (Services/) — provides topic competence data for readiness calculation
- TopicArea enum (Models/) — 16 topics with exam weights
- CompetenceLevel enum (Models/) — competence thresholds
- SessionQuestion (Models/) — question data structure
- QuestionCardView (Views/Training/) — reuse for simulation questions (without feedback overlay)
- TrainingSession / CompletedQuestion (Models/) — pattern for simulation session tracking

No generic gamification. No badges. No leaderboards. The Readiness Score IS the game.
```

---

## Out of Scope (for this spec)

- ProgressDashboardView (iteration 2 — needs simulation data first)
- Confidence Trajectory chart (iteration 2 — needs charting + multi-day data)
- Weakness Tracking dedicated view (iteration 2 — needs 3+ simulations)
- Practice simulation mode (iteration 2 — start with realistic only)
- Question flagging during simulation (nice-to-have, not core)
- Push notifications for readiness milestones (Pillar 5 territory)
- Social comparison / leaderboards (never — anti-pattern for exam anxiety)
- Adaptive question count in simulation (always 30 — mirrors real exam)

---

## Factory Knowledge Applied

| ID | Principle | Where Applied |
|---|---|---|
| FK-001 | Emotional core before features | "Von Prüfungsangst zu Prüfungssicherheit" drives every design decision |
| FK-002 | Emotional micro-copy > data | "Noch nicht bestanden" + "Genau dafür ist die Generalprobe da" |
| FK-003 | Domain-specific progress | Fehlerpunkte system (not generic percentage), Readiness milestones |
| FK-007 | Explain WHY | Post-simulation answer review with rule explanations |
| FK-008 | Mid-session competence signals | Fehlerpunkte counter during simulation (optional) |
| FK-009 | Task type differentiation | Fehlerpunkte weighting by question type (5/3/2) |
| FK-010 | Spacing + interleaving | Weakness queue after failed simulation feeds back into Training Mode |

---

## Acceptance Criteria

1. User can start a 30-question timed simulation from Dashboard
2. Simulation uses weighted question distribution matching official exam topics
3. Fehlerpunkte calculated correctly (5/3/2 system + Vorfahrt instant-fail)
4. No feedback shown during realistic simulation
5. Result shows pass/fail + Fehlerpunkte breakdown by topic
6. Failed simulation shows actionable gap analysis ranked by FP impact
7. WHY explanations available in post-simulation answer review
8. Readiness Score computed from topic competence + simulation performance + consistency
9. Readiness Score stability: max 5-point daily drop enforced
10. Exam History persists across sessions
11. "Schwächen trainieren" links to Training Mode weakness queue
12. All UI text in German, "Generalprobe" framing throughout
13. Same swipe gestures as Training Mode
14. Data persists locally, no server dependency
