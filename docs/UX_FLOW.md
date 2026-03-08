# DriveAI UX Flow

Last Updated: Current Session

This document describes the user experience flow of the DriveAI application.

Purpose:

- visualize the user journey
- ensure consistent navigation
- help AI agents understand screen relationships
- track UX changes when new features are added

---

# App Entry Flow

DriveAIApp
↓
OnboardingView (set exam date → Continue)
↓
HomeDashboardView

The Home Dashboard is the main navigation hub. All features are accessible from the Dashboard.

---

# Home Dashboard

HomeDashboardView provides access to all core functions, grouped into two parallel domains.

Navigation title: "DriveAI"

---

## Questions section

Primary action:
  Scan Question → ScannerView

Secondary grid (2 columns):
  Import Screenshot → ImageImportView
  History → QuestionHistoryView
  Insights → LearningInsightsView
  Statistics → LearningStatisticsView

---

## Traffic Signs section

Primary action:
  Recognize Sign → TrafficSignRecognitionView

Secondary grid (2 columns):
  Sign History → TrafficSignHistoryView
  Sign Statistics → TrafficSignStatisticsView

Full-width secondary:
  Sign Weaknesses → TrafficSignWeaknessView

---

Navigation:

HomeDashboardView
→ ScannerView (primary: Scan Question)
→ ImageImportView (secondary: Import Screenshot)
→ QuestionHistoryView (secondary: History)
→ LearningInsightsView (secondary: Insights)
→ LearningStatisticsView (secondary: Statistics)
→ TrafficSignRecognitionView (primary: Recognize Sign)
→ TrafficSignHistoryView (secondary: Sign History)
→ TrafficSignStatisticsView (secondary: Sign Statistics)
→ TrafficSignWeaknessView (secondary: Sign Weaknesses)

---

# Question Analysis Flow

User analyzes a question using either the camera or image import.

Flow:

ScannerView / ImageImportView
↓
ImageAnalysisView
↓
OCRRecognitionService
↓
QuestionParsingEngine
↓
MultipleChoiceDetection
↓
QuestionAnalysisService
↓
LLMQuestionSolverService
↓
QuestionView

---

# Question Interaction Flow

Two modes exist:

Assist Mode

QuestionView
↓
Tap answer
↓
Immediate result sheet
↓
AnswerExplanationView

Learning Mode

QuestionView
↓
User selects answer
↓
Submit button
↓
Result evaluation
↓
AnswerExplanationView

---

# Explanation Flow

AnswerExplanationView displays:

Correct answer  
User answer  
Explanation text  
Confidence score  

Optional elements:

Confidence bar  
Visual indicators

---

# Question History Flow

QuestionHistoryView
↓
List of previous analyzed questions

Each entry shows:

Image thumbnail  
Question text  
Correct / Incorrect icon  
Confidence score  
Timestamp

User actions:

Tap entry
↓
QuestionHistoryDetailView
↓
Full image preview + result

---

# Learning Insights Flow

HomeDashboardView
↓
Tap "Learning Insights"
↓
LearningInsightsView

Displays:

Top 3 weakest categories
↓ Each card shows:
  Category name
  Accuracy percentage
  Progress bar (red / orange / green)
  Incorrect count / total attempts

All categories list below (sorted by accuracy ascending)

Empty state:

If no history exists or all answers are correct:
  Checkmark icon + "No weak areas detected yet."

Data source:

QuestionHistoryService → WeaknessAnalysisService
Keyword-based category detection (10 categories + General fallback)

---

# Learning Statistics Flow

HomeDashboardView
↓
Tap "Learning Statistics"
↓
LearningStatisticsView

Displays:

4 summary cards:
  Total Questions
  Accuracy %
  Correct (count)
  Incorrect (count)

Overall Accuracy progress bar (red / orange / green)
Average confidence label

Correct vs Incorrect bar chart (proportional height bars)

Empty state:

If no history: chart icon + "No data yet."

Data source:

QuestionHistoryService → calculateLearningStats()

---

# Traffic Sign Recognition Flow

HomeDashboardView
↓
Tap "Traffic Signs"
↓
TrafficSignRecognitionView

Mode picker (segmented):
  Assist | Learning

---

Assist Mode:

Import image → auto-analysis → result card:
  Category badge (color-coded)
  Confidence badge (%)
  Sign name (bold title)
  Explanation text
  Confidence progress bar
  → history auto-saved (mode: Assist)

---

Learning Mode:

Import image → auto-analysis → options card:
  "What does this sign mean?"
  4 shuffled meaning options (1 correct + 3 distractors)
  User selects option → Submit button activates
  Submit →
  Result card:
    Correct / Incorrect header
    User's selected answer
    Correct sign name + category badge
    Explanation
    Confidence bar
  → history auto-saved (mode: Learning, userSelectedMeaning, userAnswerCorrect)

---

Clear button (×) removes image and resets all state.

Empty state:

Sign yield icon + import prompt

Architecture note:

TrafficSignRecognitionService.generateMeaningOptions(for:) is reusable by TrafficSceneAnalyzer.
TrafficSignRecognitionService is designed for future CoreML / Vision swap.
Categories: Prohibitory, Mandatory, Warning, Priority, Informational, Unknown

---

# Traffic Sign Statistics Flow

HomeDashboardView
↓
Tap "Sign Statistics"
↓
TrafficSignStatisticsView

Displays:

4 summary cards:
  Signs Reviewed (total)
  Avg Confidence %
  Correct (learning mode answers)
  Incorrect (learning mode answers)

If learning mode answers exist:
  Learning Mode Accuracy progress bar (red / orange / green)
  Correct vs Incorrect bar chart

If only Assist mode entries:
  Info note: "All signs were analyzed in Assist Mode"

Empty state:
  Triangle icon + "No sign data yet."

Data source:
  TrafficSignHistoryService → calculateTrafficSignStats()
  Accuracy computed from learning-mode entries only

Debug Panel:
  Sign Statistics section (reviewed, avg confidence, accuracy, correct, incorrect)

---

# Traffic Sign History Flow

HomeDashboardView
↓
Tap "Traffic Sign History"
↓
TrafficSignHistoryView

Displays list of recognized signs:
  Image thumbnail (52×52) or placeholder icon
  Sign name
  Category badge (color-coded)
  Confidence label + %
  Timestamp

Tap entry:
↓
TrafficSignHistoryDetailView
  Larger image preview
  Category badge + date
  Sign name (title)
  Explanation text
  Confidence progress bar

Clear button: confirmation alert → clears all entries

Auto-save:

Recognition completes → TrafficSignHistoryService.save(from:) called automatically

Storage:

JSON + UserDefaults (key: driveai_traffic_sign_history)

---

# Traffic Sign Weaknesses Flow

HomeDashboardView
↓
Tap "Traffic Sign Weaknesses"
↓
TrafficSignWeaknessView

Displays:

Top weak sign categories (learning mode entries only):
  Category name (TrafficSignCategory.rawValue)
  Accuracy percentage
  Progress bar (red / orange / green)
  Incorrect count / total attempts

All categories list below (sorted by accuracy ascending)

Empty state:

If no learning-mode history exists:
  Checkmark seal icon + "No weak sign categories detected yet."

Data source:

TrafficSignHistoryService → TrafficSignWeaknessAnalysisService
Groups by TrafficSignCategory enum (Prohibitory, Mandatory, Warning, Priority, Informational, Unknown)
Only learning-mode entries (wasLearningMode == true) are included

Debug Panel:

Sign Weakness Summary section (top weak sign categories)

---

# Debug Flow

AnalysisDebugPanel

Displays internal pipeline data.

Shows:

Answer Confidence (when available)
Evaluation result (user answer / correct answer)
Latest history entry (with image thumbnail)
Traffic Sign Statistics (reviewed, avg confidence, accuracy if learning mode)
Last saved traffic sign from history (auto-loaded)
Last Traffic Sign recognition result (injected when available)
Learning Statistics (total, accuracy %, correct, incorrect, avg confidence)
Weakness Summary (top 3 weakest question categories)
Sign Weakness Summary (top weak sign categories)
OCR text
Parsed question
Detected answers
Solver decision

Purpose:

- debugging
- testing pipeline reliability
- development diagnostics

---

# Full User Journey

Typical usage scenario:

User opens app
↓
Dashboard
↓
Scan or import screenshot
↓
App analyzes question
↓
User selects answer (learning mode)
↓
App evaluates result
↓
Explanation + confidence
↓
Entry saved to history (with image thumbnail)
↓
User reviews history later
↓
User taps "Learning Insights"
↓
Sees weakest categories + accuracy trends

---

# UX Design Principles

DriveAI UX is designed around:

Minimal steps  
Clear feedback  
Learning reinforcement  
Transparency of AI decisions

Key UX goals:

Fast question analysis  
Clear explanations  
Track learning progress  
Encourage self-learning

---

# UX Flow Maintenance Rules

When new screens are added:

1. Update the relevant section.
2. Add the new screen to the navigation flow.
3. Update the Full User Journey if the main flow changes.

Do not remove existing flows unless the feature is removed.