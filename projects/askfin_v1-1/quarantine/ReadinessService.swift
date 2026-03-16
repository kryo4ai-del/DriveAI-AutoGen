import Foundation

final class ReadinessService: ReadinessServiceProtocol {

    // MARK: - Dependencies

    private let progressRepository: ProgressRepositoryProtocol
    private let questionRepository: QuestionRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol

    init(
        progressRepository: ProgressRepositoryProtocol,
        questionRepository: QuestionRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol
    ) {
        self.progressRepository = progressRepository
        self.questionRepository = questionRepository
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Public API

    func fetchLatestSnapshot() async throws -> ExamReadinessSnapshot {
        async let categoriesTask  = buildCategoryReadiness()
        async let profileTask     = userProfileRepository.fetchProfile()
        async let streakTask      = progressRepository.fetchCurrentStreak()

        let (categories, profile, streak) = try await (
            categoriesTask, profileTask, streakTask
        )

        let daysUntilExam = profile.examDate.map {
            max(Calendar.current.dateComponents([.day], from: .now, to: $0).day ?? 0, 0)
        }

        let rawScore = computeScore(
            from: categories,
            streak: streak,
            daysUntilExam: daysUntilExam
        )

        let previousScore = try? await progressRepository.fetchPreviousReadinessScore()
        let trend = determineTrend(current: rawScore.value, previous: previousScore?.value)

        let finalScore = ReadinessScore(
            value: rawScore.value,
            computedAt: .now,
            trend: trend
        )

        // Build snapshot without recommendations first, then inject
        let partialSnapshot = ExamReadinessSnapshot(
            score: finalScore,
            categoryBreakdown: categories,
            recommendations: [],
            currentStreak: streak,
            examDate: profile.examDate,
            daysUntilExam: daysUntilExam
        )

        let recommendations = generateRecommendations(snapshot: partialSnapshot)

        return ExamReadinessSnapshot(
            score: finalScore,
            categoryBreakdown: categories,
            recommendations: recommendations,
            currentStreak: streak,
            examDate: profile.examDate,
            daysUntilExam: daysUntilExam
        )
    }

    // MARK: - Score Computation

    func computeScore(
        from categories: [CategoryReadiness],
        streak: Int,
        daysUntilExam: Int?
    ) -> ReadinessScore {
        guard !categories.isEmpty else {
            return ReadinessScore(value: 0, computedAt: .now, trend: .stable)
        }

        // Base: average weighted score across all categories
        let categoryScore = categories
            .map(\.weightedScore)
            .reduce(0, +) / Double(categories.count)

        // Streak bonus: +0.05 max at 7+ consecutive days
        let streakBonus = min(Double(streak) / 140.0, 0.05)

        // Urgency penalty: exam within 7 days and score below 70%
        let urgencyPenalty: Double
        if let days = daysUntilExam, days < 7, categoryScore < 0.70 {
            urgencyPenalty = 0.05
        } else {
            urgencyPenalty = 0.0
        }

        let finalValue = (categoryScore + streakBonus - urgencyPenalty)
            .clamped(to: 0...1)

        return ReadinessScore(value: finalValue, computedAt: .now, trend: .stable)
    }

    // MARK: - Recommendations

    func generateRecommendations(
        snapshot: ExamReadinessSnapshot
    ) -> [ReadinessRecommendation] {
        var recs: [ReadinessRecommendation] = []

        // Weak categories (up to 2)
        for weak in snapshot.weakCategories.prefix(2) {
            recs.append(ReadinessRecommendation(
                id: UUID(),
                type: .practiceWeakCategory,
                title: "Übe: \(weak.categoryName)",
                subtitle: "\(weak.accuracyPercentage)% Genauigkeit — Verbesserung nötig",
                priority: .high,
                targetCategoryID: weak.categoryID,
                actionLabel: "Jetzt üben"
            ))
        }

        // Exam simulation nudge
        if snapshot.score.value >= 0.60 {
            recs.append(ReadinessRecommendation(
                id: UUID(),
                type: .runExamSimulation,
                title: "Probiere eine Prüfungssimulation",
                subtitle: "Du bist bereit, dich zu testen",
                priority: .medium,
                targetCategoryID: nil,
                actionLabel: "Simulation starten"
            ))
        }

        // Streak nudge
        if snapshot.currentStreak < 3 {
            recs.append(ReadinessRecommendation(
                id: UUID(),
                type: .increaseStreak,
                title: "Baue eine Lern-Streak auf",
                subtitle: "Tägliches Üben verbessert die Merkfähigkeit",
                priority: .low,
                targetCategoryID: nil,
                actionLabel: "Heute üben"
            ))
        }

        // First incomplete (non-weak) category
        if let incomplete = snapshot.categoryBreakdown
            .first(where: { $0.completionRate < 0.30 && !$0.isWeak }) {
            recs.append(ReadinessRecommendation(
                id: UUID(),
                type: .completeCategory,
                title: "Vervollständige: \(incomplete.categoryName)",
                subtitle: "Nur \(incomplete.completionPercentage)% abgeschlossen",
                priority: .medium,
                targetCategoryID: incomplete.categoryID,
                actionLabel: "Weiter lernen"
            ))
        }

        return recs.sorted { $0.priority > $1.priority }
    }

    // MARK: - Private Helpers

    private func buildCategoryReadiness() async throws -> [CategoryReadiness] {
        let allCategories = try await questionRepository.fetchAllCategories()

        return try await withThrowingTaskGroup(of: CategoryReadiness.self) { group in
            for category in allCategories {
                group.addTask { [weak self] in
                    guard let self else { throw ServiceError.deallocated }
                    let stats = try await self.progressRepository.fetchStats(for: category.id)
                    return CategoryReadiness(
                        id: UUID(),
                        categoryID: category.id,
                        categoryName: category.name,
                        questionsTotal: category.questionCount,
                        questionsAttempted: stats.attempted,
                        correctAnswers: stats.correct,
                        lastAttempted: stats.lastAttempted
                    )
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }
    }

    private func determineTrend(current: Double, previous: Double?) -> ReadinessScore.Trend {
        guard let previous else { return .stable }
        let delta = current - previous
        if delta >= 0.05  { return .improving }
        if delta <= -0.05 { return .declining }
        return .stable
    }
}

// MARK: - Private Extensions

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}