# Training Mode — Feature Specification

Project: AskFin Premium
Pillar: 1 (Training Mode) + 2 (Skill Map)
Priority: P0
Date: 2026-03-13

---

## Purpose

Training Mode is the daily engagement core of AskFin Premium. It replaces passive question browsing with adaptive coaching sessions that target the user's weakest topics, apply spacing principles, and provide immediate competence feedback.

Combined with the Skill Map, it forms the minimum viable premium product.

Core feeling: "Die App weiss was ich brauche."

---

## User Flow

### Entry Points

```
HomeDashboard
├── [Daily Challenge]  → TrainingSessionView (adaptive, 5-10 questions)
├── [Topic Focus]      → TopicPickerView → TrainingSessionView (topic-locked)
├── [Weak Spots]       → TrainingSessionView (weakness-only queue)
└── [Skill Map]        → SkillMapView → tap topic → TrainingSessionView (topic-locked)
```

### Daily Challenge Flow (Primary)

```
HomeDashboard
  ↓ tap "Tägliches Training"
TrainingSessionView
  ↓ shows question 1 of N
QuestionCardView
  ↓ user swipes answer (left = A, right = B, up = C, down = D)
AnswerRevealView
  ↓ shows correct/incorrect + WHY explanation + topic tag
  ↓ shows competence signal ("3 von 5 richtig · Vorfahrt")
  ↓ tap or auto-advance (2s delay)
QuestionCardView (next question)
  ↓ ... repeat for N questions
SessionSummaryView
  ↓ shows: accuracy, topics covered, strengths, gaps, streak
  ↓ shows: Skill Map mini-update (which topics changed color)
  ↓ tap "Fertig" → HomeDashboard (updated)
```

### Topic Focus Flow

```
HomeDashboard
  ↓ tap "Thema üben"
TopicPickerView
  ↓ shows topic grid with competence colors (from Skill Map)
  ↓ user taps a topic (e.g. "Vorfahrt")
TrainingSessionView (locked to topic)
  ↓ same question → reveal → summary flow
  ↓ session summary shows topic-specific progress
```

### Weak Spots Flow

```
HomeDashboard
  ↓ tap "Schwächen trainieren"
TrainingSessionView (weakness queue only)
  ↓ questions drawn exclusively from red/yellow topics
  ↓ interleaved across weak topics (not massed on one)
```

---

## Session Configuration

| Parameter | Daily Challenge | Topic Focus | Weak Spots |
|---|---|---|---|
| Question count | 5-10 (adaptive) | 5-10 | 5-10 |
| Question source | Adaptive mix | Single topic | Red/yellow topics only |
| Interleaving | Yes (FK-010) | No (single topic) | Yes across weak topics |
| Spacing | Yes (prioritize due items) | No | Yes |
| Time estimate | ~3-5 min | ~3-5 min | ~3-5 min |

### Adaptive Question Count

The Daily Challenge starts at 5 questions. If the user answers all 5 correctly, 2 bonus questions are added (up to 10 max). This rewards engagement without forcing commitment.

---

## Skill Map Structure

### Topics

The German driving theory exam covers these official topic areas. Each is a node in the Skill Map.

```swift
enum TopicArea: String, Codable, CaseIterable {
    // Maps to existing QuestionCategory where possible
    case rightOfWay       // Vorfahrt / Vorrang
    case trafficSigns     // Verkehrszeichen
    case speed            // Geschwindigkeit
    case distance         // Abstand
    case overtaking       // Überholen
    case parking          // Halten und Parken
    case turning          // Abbiegen, Wenden, Rückwärtsfahren
    case highway          // Autobahn und Kraftfahrstraße
    case railwayCrossing  // Bahnübergang
    case visibility       // Beleuchtung, Sicht, Wetter
    case alcoholDrugs     // Alkohol, Drogen, Medikamente
    case vehicleTech      // Fahrzeugtechnik
    case environment      // Umwelt
    case passengers       // Ladung und Personen
    case emergency        // Verhalten bei Unfällen / Pannen
    case general          // Allgemeine Regeln
}
```

16 topics. This maps closely to the existing `QuestionCategory` enum from the MVP (12 categories) extended with 4 additional exam-relevant areas.

### Competence Levels

Each topic has a competence level calculated from answer history:

```swift
enum CompetenceLevel: Int, Comparable {
    case notStarted = 0   // Grau  — no questions answered in this topic
    case weak = 1         // Rot   — accuracy < 50% or < 3 answers
    case shaky = 2        // Gelb  — accuracy 50-79%
    case solid = 3        // Grün  — accuracy 80-94%
    case mastered = 4     // Gold  — accuracy >= 95% AND >= 5 answers AND last wrong > 7 days ago
}
```

### Skill Map View

The Skill Map renders as a 4x4 grid of topic cards:

```
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ Vorfahrt │ │ Zeichen  │ │ Tempo    │ │ Abstand  │
│   ●●●○   │ │   ●●○○   │ │   ●○○○   │ │   ○○○○   │
│   GELB   │ │   GELB   │ │   ROT    │ │   GRAU   │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ Überhol. │ │ Parken   │ │ Abbiegen │ │ Autobahn │
│   ●●●●   │ │   ●●●○   │ │   ●●○○   │ │   ○○○○   │
│   GRÜN   │ │   GRÜN   │ │   GELB   │ │   GRAU   │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
       ...           ...           ...           ...
```

Each card shows:
- Topic name (German, abbreviated)
- Competence dots (filled = level)
- Background color tint matching competence
- Tap → opens Topic Focus session for that topic

Below the grid: **Readiness Bar** showing overall exam readiness (0-100%).

---

## Confidence Score Logic

### Per-Topic Competence

```
accuracy = correct_answers / total_answers  (for this topic)

if total_answers == 0:
    level = notStarted
elif total_answers < 3 or accuracy < 0.50:
    level = weak
elif accuracy < 0.80:
    level = shaky
elif accuracy < 0.95:
    level = solid
elif accuracy >= 0.95 and total_answers >= 5 and days_since_last_wrong > 7:
    level = mastered
else:
    level = solid
```

### Recency Weighting

Recent answers count more than old ones. Use exponential decay:

```
weight = 0.9 ^ days_since_answer

weighted_accuracy = sum(weight * is_correct) / sum(weight)
```

This means an answer from today has weight 1.0, from 7 days ago has weight 0.48, from 14 days ago has weight 0.23. Old correct answers fade, ensuring the user must re-prove knowledge.

### Overall Readiness Score

```
readiness = weighted_average(topic_scores, weights=topic_exam_weights)
```

Where `topic_exam_weights` reflect how many questions each topic typically contributes to the real exam. Vorfahrt and Verkehrszeichen are weighted higher because they appear more frequently.

| Topic | Exam Weight |
|---|---|
| rightOfWay | 0.12 |
| trafficSigns | 0.12 |
| speed | 0.08 |
| distance | 0.06 |
| overtaking | 0.06 |
| parking | 0.06 |
| turning | 0.06 |
| highway | 0.06 |
| railwayCrossing | 0.04 |
| visibility | 0.06 |
| alcoholDrugs | 0.06 |
| vehicleTech | 0.06 |
| environment | 0.04 |
| passengers | 0.04 |
| emergency | 0.04 |
| general | 0.04 |

Sum = 1.00. Per-topic score is mapped to 0-100:

```
notStarted = 0
weak = 25
shaky = 55
solid = 80
mastered = 100
```

---

## Adaptive Question Selection

### Daily Challenge Algorithm

The Daily Challenge selects questions using a priority system:

```
Priority 1: Due for spacing review
  Questions answered incorrectly, where days_since_answer matches
  the spacing interval (1, 3, 7, 14, 30 days).
  → FK-010: Interleave weak topics using spacing principles.

Priority 2: Weakest topics first
  Questions from topics with lowest competence level.
  No more than 2 consecutive questions from the same topic.
  → FK-010: Avoid massed practice.

Priority 3: Coverage gaps
  Topics with 0 or very few answers get exploration questions.
  Ensures the user eventually touches all 16 topics.

Priority 4: Reinforcement
  Questions from solid/mastered topics to maintain confidence.
  Max 1 per session (keep focus on growth areas).
```

### Spacing Intervals

When a user answers incorrectly, the question enters the spacing queue:

| Attempt | Interval |
|---|---|
| 1st wrong | Review in 1 day |
| 2nd wrong | Review in 1 day (reset) |
| 1st correct after wrong | Review in 3 days |
| 2nd correct | Review in 7 days |
| 3rd correct | Review in 14 days |
| 4th correct | Review in 30 days (then exit queue) |

This is a simplified Leitner-style system tuned for the 4-16 week exam prep window.

---

## Feedback System

### Per-Question Feedback (AnswerRevealView)

Shown immediately after the user answers:

```
┌─────────────────────────────────────────┐
│                                         │
│   ✓ Richtig!                           │
│                                         │
│   Weil: Bei diesem Zeichen gilt         │
│   "rechts vor links" nicht — das        │
│   Vorfahrt-gewähren-Zeichen hebt        │
│   die Grundregel auf.                   │
│                                         │
│   ─────────────────────────────         │
│   Vorfahrt · 4 von 5 richtig           │
│                                         │
└─────────────────────────────────────────┘
```

Elements:
1. **Result indicator**: Checkmark (green) or X (red) with haptic feedback
2. **WHY explanation**: 1-2 sentences connecting answer to rule (FK-007)
3. **Topic tag**: Which topic this question belongs to (FK-009)
4. **Competence signal**: Running accuracy for this topic in this session (FK-008)

### After Wrong Answer

```
┌─────────────────────────────────────────┐
│                                         │
│   ✗ Nicht ganz.                        │
│                                         │
│   Die richtige Antwort ist B.           │
│   Weil: Bei Dunkelheit und Regen        │
│   muss der Sicherheitsabstand           │
│   verdoppelt werden — von "halber       │
│   Tacho" auf "ganzer Tacho".            │
│                                         │
│   ─────────────────────────────         │
│   Abstand · 1 von 3 richtig            │
│   Kommt in 1 Tag wieder dran.           │
│                                         │
└─────────────────────────────────────────┘
```

Additional elements for wrong answers:
- Correct answer shown explicitly
- Spacing hint: "Kommt in X Tag(en) wieder dran" — makes the learning system visible
- No blame language — "Nicht ganz" instead of "Falsch"

### Session Summary (SessionSummaryView)

Shown after the last question:

```
┌─────────────────────────────────────────┐
│                                         │
│   Tägliches Training — fertig!          │
│                                         │
│   7 von 10 richtig                      │
│                                         │
│   Themen heute:                         │
│   ● Vorfahrt      4/5  ↑ GELB → GRÜN  │
│   ● Abstand       2/3  → GELB          │
│   ● Überholen     1/2  ↓ GRÜN → GELB  │
│                                         │
│   ─────────────────────────────         │
│   Prüfungsbereitschaft: 67%  (+2%)     │
│   Lern-Streak: 4 Tage 🔥              │
│                                         │
│   [ Schwächen trainieren ]              │
│   [ Fertig ]                            │
│                                         │
└─────────────────────────────────────────┘
```

Elements:
- Total accuracy
- Per-topic breakdown with competence change indicators (↑ ↓ →)
- Overall readiness delta
- Streak counter (days in a row with at least 1 session)
- CTA: "Schwächen trainieren" (if weak topics exist) or "Fertig"

---

## Interaction Model

### Swipe-Based Answering

Questions with 2-4 answer options use directional swipes:

| Options | Gesture |
|---|---|
| 2 options (A/B) | Swipe left = A, swipe right = B |
| 3 options (A/B/C) | Left = A, right = B, up = C |
| 4 options (A/B/C/D) | Left = A, right = B, up = C, down = D |

The answer options are displayed at the card edges corresponding to their swipe direction. The question text is centered.

Fallback: Tap on answer option directly (accessibility, preference).

### Haptic Feedback

| Event | Haptic |
|---|---|
| Swipe registered | Light impact |
| Correct answer | Success notification |
| Wrong answer | Error notification (short double-tap) |
| Session complete | Heavy impact |
| Competence level up | Success notification |

### Progressive Disclosure

- Question shows only question text + answer options initially
- After answering: explanation expands from bottom
- Tap explanation to see full detail (if long)
- Competence signal appears as a subtle bar below the explanation

### Transitions

- Question → Answer Reveal: Card flip animation (0.3s)
- Answer Reveal → Next Question: Slide left (0.2s) or auto-advance after 2s (configurable)
- Last Question → Session Summary: Expand from center (0.4s)

---

## Data Model

### New Models (Premium)

```swift
// Persistent topic competence state
struct TopicCompetence: Codable, Identifiable {
    let id: UUID
    let topic: TopicArea
    var totalAnswers: Int
    var correctAnswers: Int
    var lastAnswered: Date?
    var lastWrongDate: Date?
    var competenceLevel: CompetenceLevel  // computed, cached
    var weightedAccuracy: Double          // computed with recency decay
}

// A single training session
struct TrainingSession: Codable, Identifiable {
    let id: UUID
    let type: SessionType  // daily, topicFocus, weakSpots
    let startedAt: Date
    var completedAt: Date?
    var questions: [SessionQuestion]
    var focusTopic: TopicArea?  // nil for daily/weakSpots
}

enum SessionType: String, Codable {
    case daily
    case topicFocus
    case weakSpots
}

// A question within a session
struct SessionQuestion: Codable, Identifiable {
    let id: UUID
    let questionText: String
    let options: [String]
    let correctOptionIndex: Int
    let topic: TopicArea
    let questionType: QuestionType  // recall, application, hazard
    var userAnswerIndex: Int?
    var isCorrect: Bool?
    var answeredAt: Date?
    var explanation: String?  // WHY — filled by LLM or pre-stored
}

enum QuestionType: String, Codable {
    case recall       // "Was bedeutet dieses Zeichen?"
    case application  // "Was tun Sie in dieser Situation?"
    case hazard       // "Womit müssen Sie rechnen?"
}

// Spacing queue entry
struct SpacingItem: Codable, Identifiable {
    let id: UUID
    let topic: TopicArea
    let questionRef: String  // reference to question content
    var consecutiveCorrect: Int
    var nextReviewDate: Date
    var lastReviewDate: Date
}

// Daily streak tracking
struct LearningStreak: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastSessionDate: Date?
}
```

### Relationship to MVP Models

| MVP Model | Premium Model | Relationship |
|---|---|---|
| `QuestionCategory` | `TopicArea` | Extended (12 → 16 topics) |
| `QuestionHistoryEntry` | `SessionQuestion` + `TopicCompetence` | Split: raw answer vs. aggregated competence |
| `AnswerResult` | `SessionQuestion.explanation` | WHY explanation now per-question |
| `LearningMode` | `SessionType` | Replaced: assist/learning → daily/topicFocus/weakSpots |
| `QuizResult` | `TrainingSession` | Enhanced: per-topic breakdown, not just total |

---

## Persistence

### Local Storage (UserDefaults / SwiftData)

| Data | Storage | Reason |
|---|---|---|
| TopicCompetence (16 entries) | SwiftData | Core state, must survive app updates |
| TrainingSession history | SwiftData | Progress tracking, streak calculation |
| SpacingItem queue | SwiftData | Must persist across sessions for spacing to work |
| LearningStreak | UserDefaults | Simple counter, fast read |

### No Server Required

All data is local. No sync, no accounts, no server. This matches the MVP constraint of full offline capability.

---

## Screens to Generate

The factory pipeline should generate these SwiftUI views:

| Screen | Purpose | Complexity |
|---|---|---|
| `TrainingSessionView` | Session container, manages question flow | High |
| `QuestionCardView` | Single question with swipe gesture | High |
| `AnswerRevealView` | Correct/incorrect + explanation + competence signal | Medium |
| `SessionSummaryView` | Post-session results with topic breakdown | Medium |
| `SkillMapView` | 4x4 topic grid with competence colors | Medium |
| `TopicPickerView` | Topic selection for focused sessions | Low |
| `TopicDetailView` | Single topic stats + history | Low |
| `TrainingSessionViewModel` | Session state, question selection, scoring | High |
| `SkillMapViewModel` | Topic competence aggregation, readiness score | Medium |
| `TopicCompetenceService` | Persistence, competence calculation, spacing | High |

Total: 7 Views + 2 ViewModels + 1 Service = 10 files.

---

## Factory Pipeline Configuration

### Recommended Template

Use `feature` template — this generates Views + ViewModels + Services as a coherent unit.

### Task Prompt (for factory run)

```
Design and implement the Training Mode for AskFin Premium.

Training Mode provides adaptive daily learning sessions with swipe-based question answering.

Core components:
1. TrainingSessionView — manages a session of 5-10 questions with swipe gestures
2. QuestionCardView — displays question text + 4 answer options, supports directional swipe
3. AnswerRevealView — shows correct/incorrect, WHY explanation, topic tag, competence signal
4. SessionSummaryView — post-session results with per-topic accuracy and competence changes
5. SkillMapView — 4x4 grid of 16 driving theory topics, color-coded by competence level
6. TrainingSessionViewModel — question selection (adaptive: spacing + weakness-first + coverage)
7. SkillMapViewModel — aggregates topic competence, calculates overall readiness score (0-100%)
8. TopicCompetenceService — persists per-topic accuracy with recency weighting, manages spacing queue

Design requirements:
- Dark theme, green accent for progress
- Swipe-based answering (left/right/up/down for A/B/C/D)
- Haptic feedback on answer (success/error notification)
- Progressive disclosure for explanations
- German UI text (AskFin targets German driving theory learners)

Data model:
- TopicArea enum (16 topics: rightOfWay, trafficSigns, speed, distance, overtaking, parking, turning, highway, railwayCrossing, visibility, alcoholDrugs, vehicleTech, environment, passengers, emergency, general)
- CompetenceLevel enum (notStarted/weak/shaky/solid/mastered with color mapping)
- TopicCompetence struct (topic, totalAnswers, correctAnswers, weightedAccuracy, competenceLevel)
- TrainingSession struct (type, questions, timestamps)
- SessionQuestion struct (text, options, correctIndex, topic, questionType, explanation)
- SpacingItem struct (topic, consecutiveCorrect, nextReviewDate)

Behavioral requirements:
- After each answer, show WHY explanation (1-2 sentences connecting answer to driving rule)
- Show running competence signal between questions ("3 von 5 richtig · Vorfahrt")
- Spacing: wrong answers re-appear after 1/3/7/14/30 day intervals
- Daily Challenge: prioritize spacing-due items, then weakest topics, then coverage gaps
- No generic gamification (no badges, XP, leaderboards)
- Micro-labels on questions showing type ("Recall: Verkehrszeichen" / "Anwendung: Gefahrensituation")
```

---

## Out of Scope (for this spec)

- Exam Simulation (Pillar 3) — separate spec
- Progress Visualization dashboard (Pillar 4) — separate spec, depends on training data
- Motivational micro-copy system (Pillar 5) — separate spec, polish layer
- Question content creation — Training Mode uses scanned/imported questions
- Server sync / user accounts
- Push notifications
- Onboarding tutorial

---

## Factory Knowledge Applied

| ID | Principle | Where applied |
|---|---|---|
| FK-001 | Emotional core before features | Session design centers on "Die App weiss was ich brauche" |
| FK-002 | Emotional micro-copy > data | "Nicht ganz" instead of "Falsch", contextual encouragement |
| FK-003 | Domain-specific progress | Readiness score (0-100%) tied to exam, not generic XP |
| FK-007 | Explain WHY | AnswerRevealView always shows rule/principle explanation |
| FK-008 | Mid-session competence | Running accuracy + topic shown after each question |
| FK-009 | Task type differentiation | QuestionType micro-labels on each question card |
| FK-010 | Spacing + interleaving | Adaptive question selection with Leitner-style intervals |

---

## Acceptance Criteria

1. User can complete a Daily Challenge of 5-10 adaptive questions
2. Each answer shows WHY explanation + topic tag + competence signal
3. Skill Map displays 16 topics with correct competence colors
4. Wrong answers enter spacing queue and reappear at correct intervals
5. Session summary shows per-topic accuracy with competence change indicators
6. Readiness score updates after each session
7. Swipe gestures work for 2/3/4-option questions
8. All UI text is in German
9. Data persists locally across app launches
10. No server dependency — fully offline capable
