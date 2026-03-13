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
