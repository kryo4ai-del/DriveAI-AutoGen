import Foundation

protocol GenerateRecommendationsUseCase {
    func execute(for result: DiagnosticResult) async throws -> [AppRecommendation]
}

final class GenerateRecommendationsUseCaseImpl: GenerateRecommendationsUseCase {
    func execute(for result: DiagnosticResult) async throws -> [AppRecommendation] {
        var recommendations: [AppRecommendation] = []

        if let criticalGap = result.learningGaps.first(where: { $0.gapSeverity == .critical }) {
            recommendations.append(
                AppRecommendation(
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

        if !recommendations.isEmpty && result.learningGaps.count > 1 {
            let secondaryGaps = result.learningGaps
                .filter { $0.gapSeverity != .critical && $0.gapSeverity == .moderate }
                .prefix(2)

            for gap in secondaryGaps {
                recommendations.append(
                    AppRecommendation(
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

        if result.isReadyForExam {
            recommendations.append(
                AppRecommendation(
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