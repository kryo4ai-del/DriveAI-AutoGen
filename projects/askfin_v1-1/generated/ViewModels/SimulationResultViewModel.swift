// SimulationResultViewModel.swift
//
// Bug fixes:
// - gapAnalysis and strongTopics computed once in init (not per render)
// - recommendation uses topic key pattern, not FP count, to identify Vorfahrt

import Foundation

@MainActor
final class SimulationResultViewModel: ObservableObject {

    // MARK: - Types

    struct TopicGap: Identifiable {
        let id: String
        let displayName: String
        let fehlerpunkte: Int
        let recommendation: String
    }

    // MARK: - Immutable display data — computed once in init

    let result: SimulationResult
    let readinessScore: ReadinessScore
    


This is the most complete output in the review chain. The critical bugs from prior passes are addressed. I'll focus on new issues, verify the fixes landed correctly, and identify what remains for the feature to be shippable.

---


**`invalidWeightSum` case added** — correct. `errorDescription` is present. ✓

**`elaborationPrompt` completed** — all three cases present. ✓

**Finalisation order fixed** — readiness computed before save, delta attached before persistence. ✓

**`finalisationTask` with cancellation** — present, `cancelIfNeeded()` exposed. ✓

**`gapAnalysis` moved to `let` in `init`** — declared but the file truncates before `init` is shown. The truncation means this cannot be verified.

**Protocols consolidated in `SimulationProtocols.swift`** — correct, actor isolation documented. ✓

---



**Severity: Critical (compile error)**