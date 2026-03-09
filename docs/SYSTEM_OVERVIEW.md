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

Planning agents:

- ProductStrategistAgent (idea classification, value estimation, priority)
- RoadmapAgent (feature prioritization, dependency mapping, phase planning)

Content agents:

- ContentScriptAgent (content drafts, marketing copy, video scripts, release notes)

Monitoring agents:

- ChangeWatchAgent (ecosystem changes, SDK updates, security, deprecations, impact analysis)

Quality agents:

- AccessibilityAgent (accessibility review, WCAG compliance, VoiceOver, touch targets)

Implementation agents:

- LeadAgent
- iOSArchitectAgent
- SwiftDeveloperAgent
- ReviewerAgent
- BugHunterAgent
- RefactorAgent
- AccessibilityAgent
- TestGeneratorAgent

Pipeline:

Task
→ Planning (optional: ProductStrategist + Roadmap)
→ Content (optional: ContentScriptAgent)
→ Watch (optional: ChangeWatchAgent)
→ Implementation
→ Bug Review
→ Refactor
→ Accessibility Review (optional: AccessibilityAgent)
→ Test Generation
→ Fix Execution
→ Code Extraction
→ Xcode Integration
→ Git Commit
→ Git Push

Total agents: 12 (2 planning + 1 content + 1 monitoring + 1 quality + 7 implementation)

Factory Idea Intake:

Idea → Inbox → Classified → Prioritized → Spec-Ready → Implementation → Done

Factory Spec Pipeline:

Prioritized Idea → Spec Draft → Review → Approved → Implementation → Done

Storage:
- factory/ideas/idea_store.json (ideas with metadata)
- factory/projects/project_registry.json (registered projects)
- factory/specs/spec_store.json (implementation specs)
- factory/idea_manager.py (Python API for ideas + projects)
- factory/spec_manager.py (Python API for specs)
- content/content_store.json (content records)
- content/content_manager.py (Python API for content)
- watch/watch_events.json (ecosystem change events)
- watch/watch_sources.json (monitored sources registry)
- watch/watch_manager.py (Python API for watch events + dashboard)
- accessibility/accessibility_reports.json (accessibility findings)
- accessibility/accessibility_manager.py (Python API for accessibility reports)

See docs/factory_intake.md for full documentation.

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
- factory_intake.md (includes spec pipeline documentation)
- factory_operating_guide.md (end-to-end operating manual)

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