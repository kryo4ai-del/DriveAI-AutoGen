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

## 1. LeadAgent

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

## 2. iOSArchitectAgent

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

## 3. SwiftDeveloperAgent

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

## 4. ReviewerAgent

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

## 5. BugHunterAgent

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

## 6. RefactorAgent

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

## 7. TestGeneratorAgent

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

1. LeadAgent
2. iOSArchitectAgent
3. SwiftDeveloperAgent
4. ReviewerAgent
5. BugHunterAgent
6. RefactorAgent
7. TestGeneratorAgent

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

## Pass 1 – Implementation
Main agents:
- LeadAgent
- iOSArchitectAgent
- SwiftDeveloperAgent

Goal:
Generate the requested feature.

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

- SwiftUI Views
- ViewModels
- Services
- Models
- Design system components
- navigation logic
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
3. current user task

This ensures that feature generation stays aligned with the project.

---

# Current Project Context

The agents are currently specialized for:

- Swift
- SwiftUI
- MVVM
- Apple ecosystem
- iPhone / iPad / future Apple Watch integration

Primary active project:
DriveAI

---

# Long-Term Vision

The current agent system is designed to evolve into a broader:

Universal AI App Factory

Future expansions may include:
- Android agents
- Unity game agents
- Web app agents
- SaaS feature agents
- marketing / analytics / support agents

DriveAI is the first real product being built on top of this system.

---

# Practical Note

When a new assistant or coding model joins the project, this file helps answer:

- which agents exist
- what each agent does
- which agents are required
- how the pipeline works
- how feature generation is organized