# DrivaAI-AutoGen Step Report – ML-121

## Title
Factory Template Extraction: Generic TopicArea and Question Schema Protocol Layer

## Why this step now
The latest factory reflection reached the right conclusion:

- 11 system capabilities identified
- 9 are immediately reusable
- only 2 remain domain-specific:
  - Questions
  - Topics
- highest factory leverage:
  generic `TopicArea` / Question schema abstraction

That means the next correct move is not another product feature.
The next correct move is to extract the first real reusable factory seam from the working AskFin system.

## Goal
Design and implement the smallest safe generic protocol/type layer for TopicArea and Question schema so the learning system can begin moving from “driving-school app” toward “reusable learning-app factory template.”

## Desired outcome
- domain-specific assumptions around `TopicArea` and question shape are isolated
- a generic reusable abstraction layer exists
- AskFin still works unchanged on top of that abstraction
- the protected baseline remains green
- the first true factory-template seam is created

## In scope
- inspect current topic and question model assumptions
- identify the smallest generic protocol/type boundary
- abstract only what is necessary
- preserve AskFin behavior through concrete conformance/adapters
- run build and golden gates afterward if practical

## Out of scope
- full multi-domain platform buildout
- broad architecture rewrite
- new feature implementation
- replacing all domain names everywhere at once
- commercialization work

## Success criteria
- a minimal generic protocol/schema layer exists
- AskFin conforms without losing current behavior
- the baseline stays green
- the system becomes more reusable as a factory template
