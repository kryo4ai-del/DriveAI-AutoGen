# DrivaAI-AutoGen Step Report – ML-113

## Title
Learning Signal Persistence (Close the Adaptive Loop)

## Why this step now
Adaptive selection is already implemented in the ViewModel (Due → Weak → LeastCovered → All), including weakness-focus mode and dedup queue.

What’s missing:
Persistence of learning signals across sessions to make adaptation cumulative and durable.

## Goal
Persist and update learning signals (e.g., weakness strength, recency, coverage) so adaptive selection improves over time.

## Desired outcome
- signals saved after sessions
- next sessions reflect updated weaknesses
- no architecture break
- baseline remains green

## Scope
- persist minimal signals (topic stats)
- update on session end
- load on app start

## Success criteria
- signals persist across app restarts
- adaptive behavior changes after training
- build + gates remain green
