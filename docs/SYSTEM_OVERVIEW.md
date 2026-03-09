# AskFin System Overview

Last Updated: 2026-03-09

---

# Product Identity

App Name:
AskFin

Slogan:
Nutze Fin und sage Ja

Design Direction:
Futuristic but clean learning interface

---

# Project Structure

The project consists of two layers:

1. DriveAI-AutoGen
   - the AI development system
   - agents, workflows, code generation, docs

2. AskFin (inside DriveAI folder)
   - the actual SwiftUI iOS application

---

# AI Development System

Core agents:

- LeadAgent
- iOSArchitectAgent
- SwiftDeveloperAgent
- ReviewerAgent
- BugHunterAgent
- RefactorAgent
- TestGeneratorAgent

Pipeline:

Task
→ Implementation
→ Bug Review
→ Refactor
→ Test Generation
→ Fix Execution
→ Code Extraction
→ Xcode Integration
→ Git Commit
→ Git Push

---

# AskFin App Modules

## Question Learning Domain

Image / Screenshot
→ OCRRecognitionService
→ QuestionParsingEngine
→ MultipleChoiceDetection
→ QuestionAnalysisService
→ LLMQuestionSolverService
→ AnswerExplanationView
→ Confidence
→ LearningMode
→ QuestionHistory
→ LearningStatistics
→ WeaknessDetection

## Traffic Sign Learning Domain

Image
→ TrafficSignRecognitionService
→ Sign explanation
→ TrafficSignLearningMode
→ TrafficSignHistory
→ TrafficSignStatistics
→ TrafficCategoryWeaknessDetection

---

# Main User Flow

DriveAIApp
→ LaunchScreenView
→ AppNavigationView
→ OnboardingView
→ HomeDashboardView

From Dashboard:

Questions
- Scan Question
- Import Screenshot
- History
- Statistics
- Weaknesses

Traffic Signs
- Recognize Sign
- Sign History
- Sign Statistics
- Sign Weaknesses

Developer-only:
- Debug Panel
- Sample Validation
- Reset Onboarding

---

# Current MVP Status

Implemented:
- branding
- dark futuristic UI theme
- onboarding
- dashboard
- question analysis flow
- traffic sign recognition flow
- learning mode
- explanation
- confidence
- history
- statistics
- weakness detection
- debug panel
- validation flow
- build readiness
- runtime safety

The MVP is structurally complete and ready for:
- real sample testing
- first Xcode build validation
- release preparation
- future feature expansion

---

# Documentation Files

docs/

- memory.md
- architecture.md
- roadmap.md
- agents.md
- commands.md
- PROJECT_STATE.md
- FEATURE_INDEX.md
- UX_FLOW.md
- SYSTEM_OVERVIEW.md

These files are the main persistence layer for continuing the project in future chats or with new coding agents.

---

# Recommended Next Steps

1. First real image test
2. Xcode / runtime validation on real device or Mac build environment
3. Release preparation
4. Optional future upgrades:
   - TrafficSceneAnalyzer
   - OfflineRuleEngine
   - QuestionCategoryDetection
   - broader AI App Factory expansion