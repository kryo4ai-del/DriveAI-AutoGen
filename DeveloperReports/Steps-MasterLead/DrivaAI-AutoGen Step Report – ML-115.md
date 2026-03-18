# DrivaAI-AutoGen Step Report – ML-115

## Title
Adaptive Learning Visibility Layer on the Protected AskFin Baseline

## Why this step now
The latest runtime validation confirms a major product truth:

- the adaptive learning loop is technically complete
- topic prioritization follows:
  - dueTopics
  - weakestTopics
  - leastCoveredTopics
- persisted signals influence future sessions
- cold restart behavior is confirmed

That means AskFin is no longer only simulating adaptation.
It is already adapting.

The remaining gap is not algorithmic.
It is **product visibility**:

- adaptation is mostly implicit
- users are not clearly told *why* they are seeing a given question/topic
- the system is smart, but that intelligence is still mostly invisible

So the next correct move is not another expensive model run and not deeper adaptive logic.
The next correct move is to add the smallest coherent **adaptive-visibility layer** so the product can explain its own learning behavior.

## Goal
Design and implement the smallest bounded UI layer that makes AskFin’s adaptive learning behavior visible and understandable to the user without changing the underlying adaptive logic.

## Desired outcome
- users can see why a question/topic/session was prioritized
- the adaptive loop becomes product-visible, not only technically present
- the explanation remains lightweight and non-intrusive
- the protected baseline remains green
- the app moves from “adaptive internally” to “adaptive and understandable”

## In scope
- inspect where adaptive priority is already decided
- determine the smallest meaningful explanation surface, such as:
  - a badge
  - a short reason label
  - a compact info line
  - or a subtle section header
- prefer bounded explanations like:
  - “Wegen Schwächen priorisiert”
  - “Länger nicht geübt”
  - “Wenig abgedeckt”
- reuse existing adaptive signals
- avoid changing selection behavior itself
- run golden gates afterward if practical

## Out of scope
- another autonomy run
- new adaptive scoring logic
- recommender redesign
- large UI redesign
- analytics dashboard expansion
- commercialization work

## Success criteria
- adaptive prioritization becomes user-visible
- the explanation matches actual adaptive logic
- no regression is introduced
- the protected baseline remains green
- the product becomes meaningfully more understandable without increasing complexity too much
