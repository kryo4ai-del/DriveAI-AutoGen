# DrivaAI-AutoGen Step Report – ML-117

## Title
Confidence Signal Integration into Adaptive Scoring

## Why this step now
User feedback loop is now implemented:

- confidence feedback UI exists (unsure / okay / confident)
- captured after each answer
- stored in SessionResult
- build succeeded

However:
The signal is not yet influencing the adaptive system.

## Goal
Integrate confidence feedback into weightedAccuracy so adaptive prioritization becomes more precise.

## Desired outcome
- confidence affects learning signal
- weak + low-confidence answers weighted higher
- system becomes more nuanced
- baseline remains green

## Scope
- adjust weightedAccuracy calculation
- incorporate confidence weight
- keep logic simple

## Success criteria
- confidence affects prioritization
- no regression
- build remains green
