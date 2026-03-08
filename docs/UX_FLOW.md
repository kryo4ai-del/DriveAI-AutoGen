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
OnboardingView
↓
HomeDashboardView

The Home Dashboard is the main navigation hub.

---

# Home Dashboard

HomeDashboardView provides access to core app functions.

Main actions:

Scan Question
Import Screenshot
Question History
Learning Insights
Learning Statistics
Traffic Signs
Traffic Sign History

Navigation:

HomeDashboardView
→ ScannerView
→ ImageImportView
→ QuestionHistoryView (toolbar button)
→ LearningInsightsView (dashboard button)
→ LearningStatisticsView (dashboard button)
→ TrafficSignRecognitionView (dashboard button)
→ TrafficSignHistoryView (dashboard button)

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

User actions:

Tap import area or toolbar "+" button
↓
Photo library picker (TrafficSignImagePicker)
↓
Image selected → auto-analysis starts
↓
ProgressView ("Analyzing sign…")
↓
Result card shows:
  Category badge (color-coded)
  Confidence badge (%)
  Sign name (bold title)
  Explanation text
  Confidence progress bar

Clear button (×) removes image and result.

Empty state:

Sign yield icon + import prompt

Architecture note:

TrafficSignRecognitionService is designed for future CoreML / Vision swap.
Color heuristic is used for prototype classification.
Categories: Prohibitory, Mandatory, Warning, Priority, Informational, Unknown

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

# Debug Flow

AnalysisDebugPanel

Displays internal pipeline data.

Shows:

Answer Confidence (when available)
Evaluation result (user answer / correct answer)
Latest history entry (with image thumbnail)
Last saved traffic sign from history (auto-loaded)
Last Traffic Sign recognition result (injected when available)
Learning Statistics (total, accuracy %, correct, incorrect, avg confidence)
Weakness Summary (top 3 weakest categories)
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