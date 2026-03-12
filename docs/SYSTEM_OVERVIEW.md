# AskFin System Overview

Last Updated: 2026-03-10

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

Bootstrap agents:

- ProjectBootstrapAgent (project creation from ideas, folder scaffolding, metadata)

Orchestration agents:

- AutonomousProjectOrchestrator (execution planning, readiness assessment, agent selection, delivery plans)

Content agents:

- ContentScriptAgent (content drafts, marketing copy, video scripts, release notes)

Discovery agents:

- OpportunityAgent (opportunity discovery, trend analysis, new product ideation)
- OpportunityRadar (external signal intake, evaluation, opportunity promotion)

Compliance agents:

- LegalRiskAgent (legal/regulatory risk assessment, GDPR, licensing, platform policies)

Strategy agents:

- StrategyReportAgent (weekly strategic analysis, cross-signal aggregation, risk/opportunity assessment)

Knowledge agents:

- ResearchMemoryGraph (entity relationship tracking, cross-signal context, connected knowledge)

Research agents:

- AutoResearchAgent (automated research report generation from signals, technology/tool/architecture analysis)

Cost & Routing agents:

- ModelRouter (intelligent model selection, local vs API routing, cost optimization)
- AICostMonitor (usage tracking, budget alerts, cost-per-agent/project reporting)

Monitoring agents:

- ChangeWatchAgent (ecosystem changes, SDK updates, security, deprecations, impact analysis)

Quality agents:

- AccessibilityAgent (accessibility review, WCAG compliance, VoiceOver, touch targets)

Implementation agents (iOS):

- iOSArchitectAgent
- SwiftDeveloperAgent

Implementation agents (Android):

- AndroidArchitectAgent
- KotlinDeveloperAgent

Implementation agents (Web):

- WebArchitectAgent
- WebAppDeveloperAgent

Core implementation agents:

- LeadAgent
- ReviewerAgent
- BugHunterAgent
- RefactorAgent
- AccessibilityAgent
- TestGeneratorAgent

Pipeline:

Task
→ Planning (optional: ProductStrategist + Roadmap)
→ Bootstrap (optional: ProjectBootstrapAgent)
→ Content (optional: ContentScriptAgent)
→ Discovery (optional: OpportunityAgent)
→ Compliance (optional: LegalRiskAgent)
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

Total agents: 23 (2 planning + 1 bootstrap + 1 orchestration + 1 content + 1 discovery + 1 compliance + 1 monitoring + 1 quality + 1 strategy + 1 knowledge + 1 research + 1 cost/routing + 11 implementation)

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
- opportunities/opportunity_store.json (opportunity records)
- opportunities/opportunity_manager.py (Python API for opportunities)
- radar/radar_sources.json (radar source definitions)
- radar/radar_hits.json (radar hit records)
- radar/radar_manager.py (Python API for radar sources + hits)
- compliance/compliance_reports.json (legal risk reports)
- compliance/compliance_manager.py (Python API for compliance reports)
- bootstrap/project_store.json (bootstrapped project records)
- bootstrap/bootstrap_manager.py (Python API for project bootstrapping)
- orchestration/orchestration_plan_store.json (execution plans)
- orchestration/orchestration_manager.py (Python API for orchestration plans)
- costs/cost_usage.json (AI usage log)
- costs/cost_summary.json (daily cost summaries)
- costs/cost_manager.py (Python API for cost tracking)
- config/model_router.py (intelligent model routing)
- config/model_routing.json (custom routing rules)
- config/cost_budgets.json (daily/monthly budget limits)
- strategy/weekly_reports.json (weekly strategy reports)
- strategy/strategy_manager.py (Python API for strategy reports)
- strategy/html_report.py (HTML strategy report renderer)
- research_graph/graph_nodes.json (knowledge graph nodes)
- research_graph/graph_edges.json (knowledge graph edges)
- research_graph/graph_manager.py (Python API for knowledge graph)
- research_graph/ingest.py (graph population from factory stores)
- research_reports/research_reports.json (research report records)
- research_reports/research_manager.py (Python API for research reports)
- research/auto_research.py (automated research report generation)

See docs/factory_intake.md for full documentation.

Factory Control Center:
- control_center/app.py (Streamlit dashboard — overview + 9 pages)
- control_center/store_reader.py (read-only access to all JSON stores)
- control_center/pages/ (Ideas, Projects, Specs, Opportunities, Watch, Compliance, A11Y, Orchestration, Content, Activity Feed, Agent Memory, Improvements, Trends, Briefings, Radar, AI Costs, Strategy, Research Graph, Research)
- control_center/Dockerfile + docker-compose.yml (Docker deployment)
- See docs/factory_control_center.md for full documentation.

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
- factory_control_center.md (web dashboard documentation)

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