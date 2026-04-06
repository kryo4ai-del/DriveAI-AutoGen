// MARK: - UseCases/DiagnoseUserStrengthsUseCase.swift

import Foundation

protocol DiagnoseUserStrengthsUseCase {
    func execute() async throws -> DiagnosticResult
}

final class DiagnoseUserStrengthsUseCaseImpl: DiagnoseUserStrengthsUseCase {
    private let progressRepository: ProgressRepository
    private let questionRepository: QuestionRepository
    
    init(
        progressRepository: ProgressRepository,
        questionRepository: QuestionRepository
    ) {
        self.progressRepository = progressRepository
        self.questionRepository = questionRepository
    }
    
    func execute() async throws -> DiagnosticResult {
        let progress = try await progressRepository.fetchUserProgress()
        let allCategories = try await questionRepository.fetchAllCategories()
        
        let strengths = allCategories.map { category -> CategoryStrength in
            let categoryProgress = progress.categoryProgress[category.id] ?? CategoryProgress()
            let accuracy = categoryProgress.accuracy
            let level = MasteryLevel.fromAccuracy(accuracy)
            
            return CategoryStrength(
                category: category,
                accuracy: accuracy,
                questionCount: categoryProgress.attemptedCount,
                masteryLevel: level,
                lastReviewedDate: categoryProgress.lastReviewedDate
            )
        }
        
        let masteryCoverage = computeMasteryCoverage(from: strengths)
        let gaps = identifyLearningGaps(from: strengths)
        let overallAccuracy = progress.overallAccuracy
        
        return DiagnosticResult(
            timestamp: .now,
            categoryStrengths: strengths,
            masteryCoverage: masteryCoverage,
            overallAccuracy: overallAccuracy,
            learningGaps: gaps,
            recommendations: [],
            interactiveActions: []
        )
    }
    
    private func computeMasteryCoverage(from strengths: [CategoryStrength]) -> Double {
        guard !strengths.isEmpty else { return 0.0 }
        let proficientCount = strengths.filter { $0.masteryLevel >= .proficient }.count
        return Double(proficientCount) / Double(strengths.count)
    }
    
    private func identifyLearningGaps(from strengths: [CategoryStrength]) -> [LearningGap] {
        return strengths
            .filter { $0.accuracy < 0.9 }  // All non-expert categories are potential gaps
            .map { strength in
                let severity: GapSeverity = {
                    switch strength.accuracy {
                    case 0..<0.4: return .critical
                    case 0.4..<0.7: return .moderate
                    default: return .minor
                    }
                }()
                
                let recommendedCount = severity == .critical ? 5 : (severity == .moderate ? 3 : 1)
                let estimatedMinutes = recommendedCount * 3
                
                return LearningGap(
                    category: strength.category,
                    gapSeverity: severity,
                    affectedTopics: [],
                    recommendedPracticeCount: recommendedCount,
                    lastReviewedDate: strength.lastReviewedDate,
                    estimatedMinutesToClose: estimatedMinutes
                )
            }
            .sorted { $0.gapSeverity > $1.gapSeverity }
    }
}

// MARK: - UseCases/GenerateRecommendationsUseCase.swift

final class GenerateRecommendationsUseCaseImpl: GenerateRecommendationsUseCase {
    func execute(for result: DiagnosticResult) async throws -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Priority 1: Critical gaps
        let criticalGaps = result.learningGaps.filter { $0.gapSeverity == .critical }
        for (index, gap) in criticalGaps.prefix(2).enumerated() {
            recommendations.append(
                Recommendation(
                    type: .reviewCriticalGap(gap),
                    priority: 1 + index,
                    title: "⚠️ Kritische Lücke: \(gap.category.name)",
                    description: "Diese Kategorie braucht dringende Aufmerksamkeit. Empfohlene Wiederholungen: \(gap.recommendedPracticeCount)",
                    targetCategory: gap.category,
                    estimatedMinutes: gap.estimatedMinutesToClose,
                    actionLabel: "Jetzt trainieren"
                )
            )
        }
        
        // Priority 2: Moderate gaps
        let moderateGaps = result.learningGaps.filter { $0.gapSeverity == .moderate }
        for gap in moderateGaps.prefix(1) {
            recommendations.append(
                Recommendation(
                    type: .focusCategory(gap.category),
                    priority: 3,
                    title: "📚 Vertiefung: \(gap.category.name)",
                    description: "Du machst gute Fortschritte. Noch ein wenig Übung und du erreichst Mastery.",
                    targetCategory: gap.category,
                    estimatedMinutes: gap.estimatedMinutesToClose,
                    actionLabel: "Trainieren"
                )
            )
        }
        
        // Priority 3: Exam simulation readiness
        if result.masteryCoverage >= 0.7 && result.overallAccuracy >= 0.75 {
            recommendations.append(
                Recommendation(
                    type: .simulateExam,
                    priority: 3,
                    title: "📝 Prüfungssimulation",
                    description: "Du bist gut vorbereitet! Teste dein Wissen mit einer vollständigen 30er Simulation.",
                    targetCategory: nil,
                    estimatedMinutes: 45,
                    actionLabel: "Simulation starten"
                )
            )
        }
        
        return recommendations
    }
}