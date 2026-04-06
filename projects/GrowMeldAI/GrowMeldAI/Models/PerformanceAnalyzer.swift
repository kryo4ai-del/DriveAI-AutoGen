// Services/Analytics/PerformanceAnalyzer.swift

final class PerformanceAnalyzer: Sendable {
    private let masteryThreshold: Double = 0.85
    
    // MARK: - Core Analytics
    
    func calculateMasteryPercentage(
        from attempts: [QuestionAttempt]
    ) -> Double {
        guard !attempts.isEmpty else { return 0 }
        let correct = Double(attempts.filter(\.isCorrect).count)
        return correct / Double(attempts.count)
    }
    
    func identifyWeakAreas(
        from allAttempts: [QuestionAttempt],
        categoryNames: [String: String] // categoryID -> name
    ) -> [WeakArea] {
        let grouped = Dictionary(grouping: allAttempts) { $0.categoryID }
        
        return grouped
            .map { categoryID, attempts in
                let mastery = calculateMasteryPercentage(from: attempts)
                return (categoryID, mastery, attempts.count)
            }
            .filter { $0.1 < masteryThreshold }
            .sorted { $0.1 < $1.1 }
            .map { categoryID, mastery, count in
                WeakArea(
                    categoryID: categoryID,
                    categoryName: categoryNames[categoryID] ?? categoryID,
                    masteryPercentage: mastery,
                    attemptCount: count
                )
            }
    }
    
    func estimateExamReadiness(
        overallScore: Double,
        weakAreas: [WeakArea],
        timeEfficiency: Double
    ) -> ExamReadinessScore {
        let scoreWeight: Double = 0.50
        let weakAreasWeight: Double = 0.30
        let timeWeight: Double = 0.20
        
        // Weak areas penalty: -5% per weak area, max -50%
        let weakAreasPenalty = min(Double(weakAreas.count) * 0.05, 0.50)
        let weakAreasScore = max(0, 1.0 - weakAreasPenalty)
        
        let readiness =
            (overallScore * scoreWeight) +
            (weakAreasScore * weakAreasWeight) +
            (timeEfficiency * timeWeight)
        
        return ExamReadinessScore(
            value: readiness,
            breakdown: ExamReadinessScore.Breakdown(
                overallScoreContribution: overallScore * scoreWeight,
                weakAreasContribution: weakAreasScore * weakAreasWeight,
                timeEfficiencyContribution: timeEfficiency * timeWeight
            )
        )
    }
    
    func generateRecommendations(
        snapshot: PerformanceSnapshot
    ) -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Weak areas need review
        for weakArea in snapshot.weakAreas.prefix(3) {
            recommendations.append(
                Recommendation(
                    type: .reviewCategory,
                    title: "Thema wiederholen: \(weakArea.categoryName)",
                    description: "Sie beherrschten \(weakArea.masteryPercentageFormatted) dieses Themas.",
                    actionCategoryID: weakArea.categoryID,
                    priority: 5
                )
            )
        }
        
        // Time efficiency
        let avgTime = snapshot.examSessions
            .map(\.averageTimePerQuestion)
            .reduce(0, +) / Double(max(1, snapshot.examSessions.count))
        
        if avgTime > 120 { // > 2 minutes per question
            recommendations.append(
                Recommendation(
                    type: .improveSpeed,
                    title: "Tempo erhöhen",
                    description: "Üben Sie unter Zeitdruck (durchschn. \(Int(avgTime))s pro Frage)",
                    priority: 4
                )
            )
        }
        
        // Streak maintenance
        if snapshot.currentStreak.isActive && snapshot.currentStreak.currentCount > 5 {
            recommendations.append(
                Recommendation(
                    type: .maintainStreak,
                    title: "Streak aufrechterhalten",
                    description: "\(snapshot.currentStreak.currentCount) Tage in Folge! Weiter so!",
                    priority: 3
                )
            )
        }
        
        return recommendations.sorted { $0.priority > $1.priority }
    }
}