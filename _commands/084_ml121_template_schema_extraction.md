# 084 Ml121 Template Schema Extraction

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml121-template-schema-extraction.md

Goal:
Design and implement the smallest safe generic protocol/type layer for TopicArea and Question schema so the learning system can begin moving from “driving-school app” toward “reusable learning-app factory template.”

Prompt ist für Mac

Task:
Inspect the current AskFin topic and question model assumptions, identify the smallest reusable abstraction seam, and implement a minimal generic protocol/type layer for TopicArea and Question schema while preserving current AskFin behavior.

Current confirmed state:
- 11 capabilities identified
- 9 are immediately reusable
- 2 remain domain-specific: Questions and Topics
- highest factory leverage identified: generic `TopicArea` / Question schema abstraction
- AskFin baseline is green and protected

Important:
Do not start another generation/autonomy run.
Do not broaden into a full multi-domain platform rewrite.
Do not redesign the whole app architecture.
The goal is one bounded factory-template extraction step with minimal disruption.

Focus especially on:
- where `TopicArea` assumptions are currently hard-coded
- where question schema assumptions are currently hard-coded
- the smallest protocol/type boundary that increases reuse
- preserving current AskFin naming/behavior through conformances or adapters
- keeping the extraction minimal, explicit, and testable
- verifying the result against build and golden gates afterward

Required checks:
1. Inspect current topic/question model assumptions.
2. Define the smallest coherent generic abstraction seam.
3. Implement the bounded protocol/type extraction.
4. Preserve current AskFin behavior through concrete conformance/adapters.
5. Run build and golden gates afterward if practical.
6. Record whether:
   - the abstraction layer works,
   - AskFin behavior is preserved,
   - the baseline remains green,
   - or a concrete blocker appears.
7. If a blocker appears, isolate the first concrete blocker exactly.
8. End with one single next recommended step.

Expected report:
1. Current domain-specific assumptions inspected
2. Abstraction seam chosen and why
3. Exact protocol/type layer implemented
4. Preservation strategy for AskFin
5. Build/gate outcome
6. Any blockers found
7. Single next recommended step

## Nach Abschluss

1. Ergebnis in `_commands/084_ml121_template_schema_extraction_result.md`
2. `git add -A && git commit -m "ml121_template_schema_extraction: execute command 084" && git push`
