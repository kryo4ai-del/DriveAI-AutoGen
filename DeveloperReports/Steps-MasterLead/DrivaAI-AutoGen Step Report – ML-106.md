# DrivaAI-AutoGen Step Report – ML-106

## Title
Weakness Drilldown → Action Bridge (Start Training from Detail)

## Why this step now
The drilldown layer is now working:

- weakness entries tappable
- topic detail sheet shows name, FP, recommendation
- no new model introduced
- build succeeded

This completes:
Result → Insight → Drilldown

The next step is to complete the loop:

Drilldown → Action

## Goal
Allow the user to start a focused training session directly from the weakness drilldown.

## Desired outcome
- user can trigger training from detail view
- existing training flow is reused
- no new architecture
- baseline remains green

## Scope
- add CTA in drilldown
- connect to existing training flow
- reuse existing data

## Success criteria
- CTA works
- training starts correctly
- no regression
