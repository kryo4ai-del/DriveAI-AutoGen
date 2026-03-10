# DriveAI Agents

Last Updated: Current Session

---

# Overview

DriveAI is built with an AI Development System based on multiple specialized agents.

The agents simulate a software team.

Core idea:

User Task
→ Lead Agent
→ Specialized Agents
→ Review / Refactor / Tests
→ Code Extraction
→ Integration
→ Git Commit / Push

---

# Agent List

## Planning Agents (pre-implementation)

### 1. LeadAgent

Role:
Project lead and coordination agent.

Responsibilities:
- understand the requested feature
- break down tasks
- delegate work
- structure implementation goals
- keep output aligned with project goals

Typical focus:
- architecture direction
- task decomposition
- development planning

---

### 2. ProductStrategistAgent

Role:
Product strategy and idea classification agent.

Responsibilities:
- classify incoming ideas by scope (app-level, factory-level, future-product)
- estimate product value (user impact, revenue potential, effort)
- assign priority: now, next, later, blocked
- identify monetization relevance: free, premium, post-MVP
- generate concise product guidance for the team

Typical focus:
- idea evaluation
- scope classification
- value estimation
- go/no-go recommendations

Difference from LeadAgent:
LeadAgent breaks down approved tasks into engineering subtasks.
ProductStrategistAgent evaluates whether an idea should be built at all, and when.

When to use:
- new feature ideas arrive
- prioritization decisions are needed
- scope or monetization classification is unclear
- evaluating ideas across multiple products (not just AskFin)

---

### 3. RoadmapAgent

Role:
Feature prioritization and roadmap planning agent.

Responsibilities:
- prioritize features into execution order
- identify dependencies between features
- organize work into phases: now, next, later, blocked
- produce structured roadmap recommendations
- consider technical debt and prerequisites

Typical focus:
- phase planning
- dependency mapping
- execution order
- blocked item tracking

Difference from LeadAgent:
LeadAgent coordinates a single task run.
RoadmapAgent plans across multiple features and sessions.

When to use:
- planning a sprint or release
- multiple features need ordering
- dependency analysis is needed
- roadmap review or update

---

## Bootstrap Agents

### 4. ProjectBootstrapAgent

Role:
Project bootstrapping and structure generation agent.

Responsibilities:
- read validated idea records and create new project entries
- initialize standard project folder structure (PROJECT.md, roadmap.md, specs/, content/, compliance/)
- generate initial project metadata (ID, category, platform, status)
- link new projects back to their source ideas
- trigger initial spec creation for the project
- coordinate with RoadmapAgent for initial phase planning

Typical focus:
- new project creation from ideas
- folder structure scaffolding
- initial documentation generation
- project metadata management
- idea-to-project conversion

Difference from other agents:
ProductStrategistAgent evaluates whether an idea should become a project.
ProjectBootstrapAgent creates the actual project structure once the decision is made.
RoadmapAgent plans features within a project; BootstrapAgent creates the project itself.

When to use:
- an idea has been approved and needs to become a real project
- a new product needs initial structure
- the factory needs to scaffold a project workspace
- converting opportunities or specs into standalone projects

Idea-to-Project flow:
1. Idea reaches "spec-ready" or "prioritized" status
2. ProductStrategist approves project creation
3. ProjectBootstrapAgent creates PROJ-NNN record
4. Scaffold generates folders + PROJECT.md + roadmap.md
5. Project enters "planning" status
6. RoadmapAgent and SpecManager take over

---

## Orchestration Agents

### 5. AutonomousProjectOrchestrator

Role:
Central coordination and execution planning agent.

Responsibilities:
- inspect project status across all factory data stores
- evaluate execution readiness for projects and specs
- determine which agents are needed for the next execution step
- recommend the optimal execution phase
- produce structured execution plans (PLAN-NNN)
- identify blockers and risks that prevent execution
- coordinate the transition from planning to implementation
- suggest the appropriate pipeline run type and configuration

Typical focus:
- project readiness assessment
- agent selection for tasks
- execution phase recommendation
- blocker and risk identification
- delivery plan generation

Difference from LeadAgent:
LeadAgent coordinates a single pipeline run — it breaks down one task into subtasks for engineers.
AutonomousProjectOrchestrator coordinates across the entire factory — it decides WHICH pipeline run to execute next, with which agents, for which project.

Difference from RoadmapAgent:
RoadmapAgent prioritizes features within a phase.
Orchestrator decides which phase the project should be in and what needs to happen to advance.

When to use:
- deciding what to build next across the factory
- assessing whether a project is ready for implementation
- planning a multi-step delivery sequence
- identifying blockers before starting a pipeline run
- coordinating cross-project execution priorities

Execution plan lifecycle:
1. Orchestrator inspects all factory data stores
2. Creates PLAN-NNN with readiness assessment
3. Plan is approved (manually or auto)
4. Execution begins (pipeline run or manual action)
5. Plan marked as completed

---

## Content Agents

### 6. ContentScriptAgent

Role:
Content generation and copywriting agent.

Responsibilities:
- generate structured content drafts from project docs, specs, and product identity
- support content types: video_script, app_store_short, app_store_long, landingpage_copy, social_post, feature_announcement, release_notes
- adapt tone and style to target audience and platform
- base content on real features from specs and project docs
- produce human-readable, editable drafts

Typical focus:
- marketing copy
- app store descriptions
- video scripts
- release announcements
- social media posts

Difference from other agents:
ContentScriptAgent produces text content, not code or architecture.
It reads from specs and project docs but does not modify them.

When to use:
- app store listing needs writing or updating
- video script for a feature demo is needed
- release notes for a new version
- social media announcement for a launch or update
- landing page copy for a product

---

## Discovery Agents

### 7. OpportunityAgent

Role:
Opportunity discovery and new product ideation agent.

Responsibilities:
- analyze ecosystem changes and watch events for product potential
- detect opportunities from new APIs, AI capabilities, platform features, and developer trends
- assess market relevance and implementation complexity
- produce structured opportunity reports with actionable next steps
- feed promising opportunities into the factory idea intake system

Typical focus:
- new API and platform capability analysis
- AI model advancement opportunities
- market gap detection
- developer trend evaluation
- monetization opportunity identification

Difference from other agents:
OpportunityAgent proactively discovers what could be built.
ProductStrategistAgent evaluates whether a specific idea should be built.
ChangeWatchAgent monitors changes for risk; OpportunityAgent monitors for potential.

When to use:
- proactive product discovery is needed
- watch events reveal new capabilities worth building on
- market or technology trends suggest new products
- the factory needs fresh ideas for the backlog
- evaluating new APIs or platform features for product potential

Opportunity-to-Idea flow:
1. Detect opportunity (from watch events, trends, analysis)
2. Create opportunity record (OPP-NNN)
3. Evaluate relevance and complexity
4. If accepted: create an idea in idea_store.json referencing the opportunity
5. Mark opportunity as idea_created

---

## Compliance Agents

### 8. LegalRiskAgent

Role:
Legal and regulatory risk assessment agent.

Important:
This agent does NOT provide legal advice. It identifies potential risk areas and recommends when professional legal review is needed.

Responsibilities:
- analyze ideas, specs, and projects for potential legal and regulatory risks
- identify risk areas: copyright, licensing, trademarks, platform policies, GDPR, regulated domains, AI content risks
- assess risk severity and potential blockers
- recommend whether external legal review is needed
- produce structured risk assessment reports
- flag issues early in the planning phase before development effort is invested

Typical focus:
- GDPR/DSGVO compliance for user data
- App Store guideline compliance
- open source license compatibility
- trademark and naming conflicts
- regulated domain requirements (education, finance)
- AI-generated content liability

Difference from other agents:
LegalRiskAgent assesses legal risk areas — it does not provide legal opinions.
ProductStrategistAgent evaluates product value — LegalRiskAgent evaluates legal exposure.
ChangeWatchAgent monitors ecosystem changes — LegalRiskAgent evaluates regulatory implications.

When to use:
- before investing development effort in a new idea
- when entering regulated domains (finance, health, education)
- when using third-party APIs, SDKs, or content
- when handling user data or AI-generated output
- during spec review before implementation begins
- when expanding to new markets or platforms

Risk assessment lifecycle:
1. Idea or spec triggers risk review
2. Create compliance report (LEGAL-NNN)
3. Assess risk level and identify blockers
4. Flag for external review if needed
5. Mitigate, accept, or block based on findings

---

## Monitoring Agents

### 9. ChangeWatchAgent

Role:
Ecosystem change monitoring and impact analysis agent.

Responsibilities:
- track external changes affecting factory projects (SDK, tooling, models, security, pricing, deprecations)
- classify changes by category and severity
- assess impact on specific projects and platforms
- recommend concrete actions with deadlines
- produce watch summaries and dashboard updates

Typical focus:
- SDK version bumps and breaking changes
- AI model updates and deprecations
- security advisories and patches
- pricing changes for APIs and services
- new opportunities worth exploring

Difference from other agents:
ChangeWatchAgent monitors the external ecosystem, not internal code.
It produces impact assessments and recommendations, not code or content.

When to use:
- new SDK or platform version is released
- AI model is deprecated or updated
- security vulnerability affects a dependency
- API pricing changes
- evaluating whether to adopt a new tool or service

---

## Implementation Agents — iOS

### 10. iOSArchitectAgent

Role:
iOS architecture and system design expert.

Responsibilities:
- define app structure
- enforce SwiftUI + MVVM architecture
- recommend separation of Views / ViewModels / Services / Models
- design navigation and app flow
- improve maintainability

Typical focus:
- project structure
- modularity
- screen flow
- long-term scalability

---

### 11. SwiftDeveloperAgent

Role:
Main implementation agent.

Responsibilities:
- write SwiftUI code
- create Views, ViewModels, Models, Services
- implement features requested by the pipeline
- produce reusable Swift code
- follow existing design system and project structure

Typical focus:
- actual code generation
- UI implementation
- feature logic
- MVVM-compatible code

---

## Implementation Agents — Android

### 12. AndroidArchitectAgent

Role:
Android architecture and system design expert.

Responsibilities:
- design Android app architecture using Jetpack Compose
- define module boundaries and Gradle project structure
- recommend MVVM or MVI patterns
- design navigation using Navigation Compose
- ensure Material Design 3 compatibility

Typical focus:
- Gradle module structure
- dependency injection (Hilt/Dagger)
- Room + Retrofit/Ktor integration
- lifecycle-aware patterns

---

### 13. KotlinDeveloperAgent

Role:
Android implementation agent.

Responsibilities:
- write Kotlin code with Jetpack Compose UI
- build reusable Android UI components (Material Design 3)
- implement ViewModels with StateFlow/SharedFlow
- use Kotlin coroutines and Flow for async operations
- produce modular, testable, production-oriented code

Typical focus:
- Jetpack Compose UI
- Kotlin coroutines
- clean architecture
- lifecycle awareness

---

## Implementation Agents — Web

### 14. WebArchitectAgent

Role:
Web application architecture and system design expert.

Responsibilities:
- design web app architecture (React, Next.js, or other modern frameworks)
- define component hierarchy and state management patterns
- recommend folder structure and module boundaries
- design API integration and data flow
- plan deployment strategy (Vercel, Cloudflare, Docker)

Typical focus:
- React/Next.js architecture
- TypeScript type safety
- SSR vs CSR tradeoffs
- state management (Context, Zustand, Redux)
- SEO and performance

---

### 15. WebAppDeveloperAgent

Role:
Web implementation agent.

Responsibilities:
- write TypeScript code with React/Next.js
- build reusable web UI components
- implement responsive layouts with Tailwind CSS
- follow component-driven architecture patterns
- use React hooks and modern patterns

Typical focus:
- TypeScript strict mode
- React Server Components
- Tailwind CSS styling
- semantic HTML and ARIA
- web performance

---

## Review & Quality Agents

### 16. ReviewerAgent

Role:
Code review and quality agent.

Responsibilities:
- review generated Swift and Python code
- find structural issues
- suggest concrete improvements
- check readability and maintainability
- identify design inconsistencies

Typical focus:
- code quality
- maintainability
- clarity
- review feedback

---

### 17. BugHunterAgent

Role:
Bug and risk analysis agent.

Responsibilities:
- inspect generated code for likely bugs
- identify edge cases
- detect invalid states and runtime risks
- suggest practical bug fixes
- focus on real implementation weaknesses

Typical focus:
- crashes
- invalid input handling
- state bugs
- weak assumptions

---

### 18. RefactorAgent

Role:
Code cleanup and maintainability agent.

Responsibilities:
- improve structure
- reduce duplication
- improve naming
- improve modularity
- keep behavior unchanged

Typical focus:
- refactoring
- code cleanup
- extraction of reusable parts
- readability

---

### 19. AccessibilityAgent

Role:
Accessibility review and compliance agent.

Responsibilities:
- analyze UI code for accessibility issues
- detect missing accessibility labels, hints, and traits
- identify poor color contrast (WCAG 2.1 AA)
- detect small touch targets (below 44x44pt)
- recommend VoiceOver and screen reader improvements
- check Dynamic Type compatibility
- evaluate focus order and semantic structure
- flag animations lacking reduced-motion alternatives

Typical focus:
- accessibility labels and hints
- color contrast compliance
- touch target sizing
- VoiceOver navigation
- Dynamic Type scaling
- semantic grouping

Difference from ReviewerAgent:
ReviewerAgent focuses on code quality and structure.
AccessibilityAgent focuses specifically on accessibility compliance and inclusive design.

When to use:
- after UI code is generated or modified
- during review passes for accessibility compliance
- before release to ensure accessibility standards are met
- when adding new screens or interactive elements

---

### 20. TestGeneratorAgent

Role:
Test planning and quality assurance agent.

Responsibilities:
- generate test cases
- identify happy paths
- identify edge cases
- identify failure cases
- create implementation-oriented test suggestions

Typical focus:
- test coverage
- scenarios
- validation
- expected behavior

---

# Agent Pipeline

A normal feature run uses the following sequence:

1. AutonomousProjectOrchestrator (optional — for execution planning)
2. LeadAgent
3. ProductStrategistAgent (optional — for idea evaluation)
4. RoadmapAgent (optional — for multi-feature planning)
5. ProjectBootstrapAgent (optional — for project creation from ideas)
6. ContentScriptAgent (optional — for content generation)
7. OpportunityAgent (optional — for opportunity discovery)
8. LegalRiskAgent (optional — for legal risk assessment)
9. ChangeWatchAgent (optional — for ecosystem monitoring)
10. iOSArchitectAgent (iOS projects)
11. SwiftDeveloperAgent (iOS projects)
12. AndroidArchitectAgent (Android projects)
13. KotlinDeveloperAgent (Android projects)
14. WebArchitectAgent (Web projects)
15. WebAppDeveloperAgent (Web projects)
16. ReviewerAgent
17. BugHunterAgent
18. RefactorAgent
19. AccessibilityAgent (optional — for accessibility review)
20. TestGeneratorAgent

For pure implementation tasks, planning/content/watch agents may be skipped.
For idea intake or roadmap planning, implementation agents may be skipped.
For content generation, implementation and review agents may be skipped.
For opportunity discovery, only OpportunityAgent and ProductStrategistAgent are needed.
For legal risk assessment, only LegalRiskAgent and ProductStrategistAgent are needed.
For project bootstrapping, only ProjectBootstrapAgent, ProductStrategistAgent, and RoadmapAgent are needed.
For ecosystem monitoring, all other agents may be skipped.
For accessibility review, only AccessibilityAgent and ReviewerAgent are needed.
For Android implementation, AndroidArchitectAgent and KotlinDeveloperAgent replace iOS agents.
For Web implementation, WebArchitectAgent and WebAppDeveloperAgent replace iOS agents.
For execution planning, only AutonomousProjectOrchestrator and ProductStrategistAgent are needed.

Depending on run mode or agent toggles, some optional agents can be disabled.

---

# Required Core Agents

The system requires at least:

- LeadAgent
- SwiftDeveloperAgent

These are force-enabled.

All others are optional depending on configuration.

---

# Agent Execution Model

The project uses an AgentChat / Selector-based orchestration model.

Behavior:
- the team shares the same task context
- relevant agents are selected based on role
- multi-pass execution is used for implementation, review, refactor, tests, and fixes

---

# Multi-Pass Development Flow

## Pass 0 – Planning (optional)
Main agents:
- ProductStrategistAgent
- RoadmapAgent

Goal:
Evaluate idea scope, classify priority, identify dependencies, produce roadmap.
Runs before implementation when the task involves new ideas or multi-feature planning.

---

## Pass 1 – Implementation
Main agents (platform-dependent):
- LeadAgent
- iOSArchitectAgent + SwiftDeveloperAgent (iOS)
- AndroidArchitectAgent + KotlinDeveloperAgent (Android)
- WebArchitectAgent + WebAppDeveloperAgent (Web)

Goal:
Generate the requested feature for the target platform.

---

## Pass 2 – Bug Review
Main agents:
- ReviewerAgent
- BugHunterAgent

Goal:
Find bugs, weaknesses, and edge cases.

---

## Pass 3 – Refactor
Main agents:
- RefactorAgent
- ReviewerAgent

Goal:
Improve readability, modularity, and structure.

---

## Pass 4 – Test Generation
Main agents:
- TestGeneratorAgent

Goal:
Generate useful test cases and QA scenarios.

---

## Pass 5 – Fix Execution
Main agents:
- SwiftDeveloperAgent
- LeadAgent
- optional review agents

Goal:
Apply the most relevant fixes after the previous passes.

---

# Agent Outputs

The agents may produce:

Orchestration outputs:
- execution plans (PLAN-NNN)
- readiness assessments (not_ready/blocked/needs_spec/needs_review/ready)
- agent selection recommendations
- execution step sequences
- blocker and risk identification
- suggested pipeline run commands

Bootstrap outputs:
- project records (PROJ-NNN)
- project folder structures (PROJECT.md, roadmap.md, specs/, content/, compliance/)
- project metadata (category, platform, status, linked idea)
- initial roadmap templates

Compliance outputs:
- legal risk assessment reports (LEGAL-NNN)
- risk level classifications (low/medium/high/critical)
- potential blocker identification
- external review recommendations
- mitigation suggestions

Discovery outputs:
- structured opportunity reports (OPP-NNN)
- market relevance and complexity assessments
- potential product lists
- suggested next steps (research, prototype, spec, idea intake)
- watch event to opportunity linkages

Planning outputs:
- idea classifications
- priority assignments
- roadmap recommendations
- dependency maps
- product guidance
- implementation specs (goal, scope, acceptance criteria, suggested template/agents)

Accessibility outputs:
- accessibility findings (missing labels, contrast issues, touch targets)
- severity-ranked reports with specific fix recommendations
- WCAG compliance assessments
- VoiceOver navigation analysis

Monitoring outputs:
- ecosystem change events and impact assessments
- severity classifications and recommended actions
- watch dashboard (grouped by urgency)
- deadline tracking for breaking changes

Content outputs:
- video scripts
- app store descriptions (short + long)
- landing page copy
- social media posts
- feature announcements
- release notes

Implementation outputs (iOS):
- SwiftUI Views
- ViewModels
- Services
- Models
- Design system components
- navigation logic

Implementation outputs (Android):
- Jetpack Compose UI
- ViewModels (StateFlow/SharedFlow)
- Room database entities
- Retrofit/Ktor network layers
- Gradle module configurations

Implementation outputs (Web):
- React/Next.js components
- TypeScript types and interfaces
- Tailwind CSS layouts
- API route handlers
- State management stores

Shared implementation outputs:
- test cases
- refactor suggestions
- debug support
- explanation logic

---

# Agent Configuration

Agent role definitions are centralized in:

config/agent_roles.json

This file contains:
- descriptions
- system messages

This allows prompt changes without editing agent Python files.

---

# Agent Toggles

Agent enable/disable config is managed in:

config/agent_toggles.json

Possible:
- disable optional agents
- keep only core agents
- reduce cost / complexity for some runs

CLI overrides also exist:
- --disable-agent
- --enable-agent

---

# Session / Workflow Interaction

Agents are also influenced by:

- session presets
- workflow recipes
- run mode
- approval mode
- environment profiles

This means the active agent behavior may vary per run.

---

# Agent Memory

The system has persistent memory.

Memory stores:
- decisions
- architecture notes
- implementation notes
- review notes

This helps the agents keep continuity across runs.

---

# Agent Context

Agents receive task context built from:

1. project roadbook / project context
2. persistent memory summary
3. factory idea summary (from idea_store.json)
4. factory project summary (from project_registry.json)
5. factory spec summary (from spec_store.json)
6. content summary (from content_store.json)
7. watch summary (from watch_events.json)
8. accessibility summary (from accessibility_reports.json)
9. opportunity summary (from opportunity_store.json)
10. compliance summary (from compliance_reports.json)
11. bootstrap summary (from project_store.json)
12. orchestration summary (from orchestration_plan_store.json)
13. current user task

Planning agents additionally have awareness of:
- idea fields, scopes, types, statuses, priorities
- project registry IDs
- idea lifecycle (inbox → classified → prioritized → spec-ready → done)
- spec fields, statuses, and lifecycle (draft → review → approved → in-progress → done)
- spec-to-idea linking via linked_idea_id

See docs/factory_intake.md for the full idea intake and spec pipeline workflow.

This ensures that feature generation stays aligned with the project.

---

# Current Project Context

Implementation agents cover three platforms:

iOS:
- Swift / SwiftUI / MVVM
- iPhone / iPad / watchOS

Android:
- Kotlin / Jetpack Compose / MVVM-MVI
- Material Design 3

Web:
- TypeScript / React / Next.js
- Tailwind CSS / Server Components

Planning, review, and quality agents are platform-agnostic and reusable across all platforms.

Primary active project:
AskFin (DriveAI)

---

# Long-Term Vision

The current agent system is designed to evolve into a broader:

Universal AI App Factory

Current platform coverage:
- iOS (iOSArchitect + SwiftDeveloper)
- Android (AndroidArchitect + KotlinDeveloper)
- Web (WebArchitect + WebAppDeveloper)

Future expansions may include:
- Unity game agents
- SaaS feature agents
- marketing / analytics / support agents

DriveAI/AskFin is the first real product being built on top of this system.

---

# Practical Note

When a new assistant or coding model joins the project, this file helps answer:

- which agents exist
- what each agent does
- which agents are required
- how the pipeline works
- how feature generation is organized