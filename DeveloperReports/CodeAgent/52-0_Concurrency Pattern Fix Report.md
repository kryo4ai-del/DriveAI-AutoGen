# 52-0 Concurrency Pattern Fix Report

**Datum**: 2026-03-15
**Agent**: Claude Code (Mac, Xcode 26.3)

## Policy

`inout_async_isolation`: Actor-isolated Properties koennen nicht inout an async Functions uebergeben werden. Fix: local-copy-then-assign.

## Fix

ExamSessionViewModel.swift: `&session` → lokale Kopie, async Call, zurueckschreiben.

## Ergebnis

- ExamSessionViewModel: **0 Errors** (vorher 2)
- Neuer Blocker aufgedeckt: `NetworkMonitor` nicht im Scope (OfflineStatusViewModel.swift)
