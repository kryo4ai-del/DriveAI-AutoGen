import Foundation

// MARK: - ReadinessScoringEngine
//
// Pure, stateless scoring and recommendation logic.
// `enum` namespace prevents instantiation and signals no instance state
// exists (STRUCT-007).

enum ReadinessScoringEngine {

    // MARK: - Streak Constants

    static let maxStreakBonus: Double         = 0.05
    static let streakBonusDenominator: Double = 140.0

    /// Minimum consecutive days considered a healthy daily-practice habit.
    /// Users below this receive an `.increaseStreak` recommendation.
    /// Rationale: one full week as habit-formation baseline (DESIGN-007).
    static let streakRecommendationThreshold: Int = 7

    // MARK: - Urgency Penalty Constants
    //
    // ⚠️  DESIGN-004 — Product decision pending.
    // This penalty reduces the displayed score as the exam approaches,
    // even when the user's knowledge has genuinely improved. Until the
    // product decision is made, urgency should ideally be surfaced
    // separately in the view rather than embedded in the score value.

    static let urgencyPenaltyThresholdDays: Int = 7
    static let urgencyPenaltyMaxAmount: Double   = 0.05

    // MARK: - Trend Constants

    /// Minimum absolute score change to register as improving or declining.
    /// Boundary is inclusive: delta == trendThreshold → .improving or .declining.
    static let trendThreshold: Double = 0.05

    // MARK: - Score Computation

    /// Returns a raw score in [0, 1]. Returns only `Double` — trend is
    /// determined separately by the caller once historical data is available,
    /// preventing a placeholder `ReadinessScore(trend: .stable)` object
    /// from being accidentally used (DESIGN-001, STRUCT-006).
    static func computeScore(
        from categories: [CategoryReadiness],
        streak: Int,
        daysUntilExam: Int?
    ) -> Double {
        let categoryScore: Double = categories.isEmpty
            ? 0.0
            : categories.map(\.weightedScore).reduce(0, +) / Double(categories.count)

        let streakBonus = min(Double(streak) / streakBonusDenominator, maxStreakBonus)
        let penalty     = urgencyPenalty(daysUntilExam: daysUntilExam)
        return min(max(categoryScore + streakBonus - penalty, 0), 1)
    }

    // MARK: - Urgency Penalty
    //
    // See DESIGN-004 warning above before modifying.
    //
    // Linear interpolation from 0.0 (at threshold boundary) to
    // urgencyPenaltyMaxAmount (at 1 day remaining).
    //
    // Boundary table (threshold = 7, max = 0.05):
    //   nil  → 0.0
    //   0    → 0.0  (exam today/passed — excluded by days > 0 guard)
    //   8+   → 0.0  (outside window)
    //   7    → 0.0  (window edge; fraction = 0)
    //   4    → 0.025
    //   1    → 0.05 (maximum)

    static func urgencyPenalty(daysUntilExam: Int?) -> Double {
        guard
            let days = daysUntilExam,
            days > 0,
            days <= urgencyPenaltyThresholdDays
        else { return 0.0 }

        let windowSize = Double(urgencyPenaltyThresholdDays - 1) // 6.0
        let fraction   = 1.0 - (Double(days - 1) / windowSize)
        return fraction * urgencyPenaltyMaxAmount
    }

    // MARK: - Trend

    /// Returns `.stable` when `previous` is `nil` (first-run users have
    /// no history). Boundary inclusive: |delta| == trendThreshold qualifies.
    static func determineTrend(current: Double, previous: Double?) -> ReadinessScore.Trend {
        guard let previous else { return .stable }
        let delta = current - previous
        if delta >=  trendThreshold { return .improving }
        if delta <= -trendThreshold { return .declining }
        return .stable
    }

    // MARK: - Recommendations
    //
    // Rules in priority order:
    // 1. practiceWeakCategory — up to 2, sorted weakest-first (high)
    // 2. reviewMistakes       — any incorrect answers exist (high)
    // 3. runExamSimulation    — score ≥ 0.65 (medium)
    // 4. completeCategory     — incomplete, non-weak categories (medium)
    // 5. increaseStreak       — streak below threshold (low)
    //
    // targetCategoryID is nil for reviewMistakes, runExamSimulation,
    // and increaseStreak (test requirement §3.4).
    //
    // Policy: weak-category practice always takes top-3 priority over
    // simulation. A user with 2 weak categories and score ≥ 0.65 will
    // see practice + reviewMistakes before simulation (STRUCT-011).

    static func generateRecommendations(
        score: ReadinessScore,
        categories: [CategoryReadiness],
        streak: Int,
        daysUntilExam: Int?
    ) -> [ReadinessRecommendation] {
        var result: [ReadinessRecommendation] = []

        // 1. Weak categories — sorted ascending by accuracyRate (weakest first)
        let weakSorted = categories
            .filter(\.isWeak)
            .sorted { $0.accuracyRate < $1.accuracyRate }

        for category in weakSorted.prefix(2) {
            result.append(ReadinessRecommendation(
                id: UUID(),
                type: .practiceWeakCategory,
                title: "Übe \(category.categoryName)",
                subtitle: "\(category.accuracyPercentage) % Genauigkeit – Verbesserung möglich",
                priority: .high,
                targetCategoryID: category.categoryID,
                actionLabel: "Jetzt üben"
            ))
        }

        // 2. Review mistakes — uses accuracyRate for consistency with the
        //    clamped value the rest of the system observes (COR-003)
        let hasErrors = categories.contains {
            $0.questionsAttempted > 0 && $0.accuracyRate < 1.0
        }
        if hasErrors {
            result.append(ReadinessRecommendation(
                id: UUID(),
                type: .reviewMistakes,
                title: "Fehler wiederholen",
                subtitle: "Geh deine Fehlantworten noch einmal durch",
                priority: .high,
                targetCategoryID: nil,
                actionLabel: "Fehler ansehen"
            ))
        }

        // 3. Exam simulation
        if score.value >= 0.65 {
            result.append(ReadinessRecommendation(
                id: UUID(),
                type: .runExamSimulation,
                title: "Probeprüfung starten",
                subtitle: "Teste dein Wissen unter Prüfungsbedingungen",
                priority: .medium,
                targetCategoryID: nil,
                actionLabel: "Simulation starten"
            ))
        }

        // 4. Complete incomplete, non-weak categories (COR-004: mastered
        //    categories already have completionRate == 1.0 so the
        //    completionRate < 1.0 check makes !isMastered redundant, but
        //    the intent is stated explicitly for readability)
        let incomplete = categories.filter {
            $0.completionRate < 1.0 && !$0.isWeak
        }
        for category in incomplete.prefix(2) {
            result.append(ReadinessRecommendation(
                id: UUID(),
                type: .completeCategory,
                title: "\(category.categoryName) abschließen",
                subtitle: "\(category.completionPercentage) % abgeschlossen",
                priority: .medium,
                targetCategoryID: category.categoryID,
                actionLabel: "Weiter lernen"
            ))
        }

        // 5. Streak encouragement (DESIGN-009: streak=0 uses start copy;
        //    singular/plural handled via Int.germanDayLabel)
        if streak < streakRecommendationThreshold {
            let daysNeeded = streakRecommendationThreshold - streak
            let subtitle = streak == 0
                ? "Starte heute deinen \(streakRecommendationThreshold)-Tage-Streak"
                : "Noch \(daysNeeded.germanDayLabel) bis zu deinem \(streakRecommendationThreshold)-Tage-Streak"

            result.append(ReadinessRecommendation(
                id: UUID(),
                type: .increaseStreak,
                title: "Lernstreak aufbauen",
                subtitle: subtitle,
                priority: .low,
                targetCategoryID: nil,
                actionLabel: "Heute lernen"
            ))
        }

        return result
    }
}

// MARK: - Int + German Day Label

private extension Int {
    /// Grammatically correct German singular/plural day string (DESIGN-005, DESIGN-009).
    var germanDayLabel: String { self == 1 ? "1 Tag" : "\(self) Tage" }
}