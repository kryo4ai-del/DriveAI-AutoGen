protocol GenerateRecommendationsUseCase {
    func execute(for result: DiagnosticResult) async throws -> [Recommendation]
}

final class GenerateRecommendationsUseCaseImpl: GenerateRecommendationsUseCase {
    func execute(for result: DiagnosticResult) async throws -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // RULE 1: Always show exactly ONE primary recommendation
        // (Reduces cognitive load, creates decision focus)
        if let criticalGap = result.learningGaps.first(where: { $0.gapSeverity == .critical }) {
            recommendations.append(
                Recommendation(
                    type: .reviewCriticalGap(criticalGap),
                    priority: 1,
                    title: "🎯 Fokus: \(criticalGap.category.name)",
                    description: "Deine größte Lücke. \(criticalGap.recommendedPracticeCount) Wiederholungen = 30 Min. Danach: +15% Genauigkeit erwartet.",
                    targetCategory: criticalGap.category,
                    estimatedMinutes: criticalGap.estimatedMinutesToClose,
                    actionLabel: "Jetzt trainieren"
                )
            )
        }
        
        // RULE 2: Show secondary recommendations only if primary is "in progress" (not if new user)
        // (Progressive disclosure: reveal next steps after user starts)
        if !recommendations.isEmpty && result.learningGaps.count > 1 {
            let secondaryGaps = result.learningGaps
                .filter { $0.gapSeverity != .critical && $0.gapSeverity == .moderate }
                .prefix(2)
            
            for gap in secondaryGaps {
                recommendations.append(
                    Recommendation(
                        type: .focusCategory(gap.category),
                        priority: 2,
                        title: "📚 Nächster Fokus: \(gap.category.name)",
                        description: "Nach der aktuellen Lücke. Moderater Schwerpunkt.",
                        targetCategory: gap.category,
                        estimatedMinutes: gap.estimatedMinutesToClose,
                        actionLabel: "Später trainieren"
                    )
                )
            }
        }
        
        // RULE 3: Exam simulation only if 70%+ coverage (not overwhelming)
        if result.isReadyForExam {
            recommendations.append(
                Recommendation(
                    type: .simulateExam,
                    priority: 2,
                    title: "🧪 Bereit zum Test: Prüfungssimulation",
                    description: "Du bist nah dran! Eine 30er Simulation zeigt dir, ob du wirklich bereit bist.",
                    targetCategory: nil,
                    estimatedMinutes: 45,
                    actionLabel: "Simulation starten"
                )
            )
        }
        
        return recommendations.sorted { $0.priority < $1.priority }
    }
}