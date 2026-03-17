# Quarantine Status — Deferred Structural Debt

**Last Updated**: 2026-03-17
**Stop Condition**: No safe rehabilitation candidate remaining without new type creation.

## Classification: INTENTIONALLY DEFERRED

These 9 files are **not broken code waiting to be fixed** — they are structurally incompatible with the current active codebase and require real new-type work to rehabilitate. Future rehabilitation should only happen as part of deliberate feature work that naturally creates the missing types.

## Remaining Files (9)

| File | Lines | Refs | Missing Types/Interfaces |
|---|---|---|---|
| ReadinessService.swift | 208 | 6 | 6 incompatible interfaces (ReadinessScore init, ExamReadinessSnapshot shape, CategoryReadiness properties, ReadinessRecommendation init, ServiceError, fetchAllCategories) |
| ReadinessScoringEngine.swift | 214 | 1 | Multiple missing types + incompatible scoring interfaces |
| ReadinessCalculator.swift | 173 | 2 | ExamDateManager, UrgencyLevel, incompatible ReadinessScore init |
| ExamReadinessDashboard.swift | 257 | 1 | ReadinessPrediction, PrepRecommendation, multiple ViewModel properties |
| PredictionEngine.swift | 106 | 0 | ReadinessPrediction, PredictionFactor, ReadinessCalculationResult |
| OverallReadinessCardView.swift | 56 | 0 | CircularProgressAccessibleView, readinessColor |
| FocusRecommendationRow.swift | 48 | 0 | FocusRecommendation, Badge |
| ReadinessDataService.swift | 44 | 0 | ReadinessDataServiceProtocol |
| PreviewDataFactory.swift | 30 | 0 | Factory methods (categoryMetrics, recommendations, weakCategories, metrics) |

## Why This Boundary Matters

Each file would require creating 1-6 new types/protocols that don't exist yet. Creating stub types just to compile quarantined code adds dead code without user value. The right time to rehabilitate is when a feature naturally needs these types.

## Rehabilitation History

| Date | File | Action |
|---|---|---|
| 2026-03-17 | PriorityBadgeView.swift | REHABILITATED (4 case-name fixes) |
| 2026-03-17 | ExamReadinessView.swift | DELETED (fragment) |
| 2026-03-17 | 10 files | DELETED (pseudo-code, fragments, stale artifacts) |
| 2026-03-17 | ReadinessService.swift | KEPT (6 incompatible interfaces) |
