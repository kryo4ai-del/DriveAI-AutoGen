import Foundation
import Combine

class LearningStatsViewModel: ObservableObject {
    @Published var stats: LearningStats = .empty
    @Published var allCategories: [WeaknessCategory] = []
    @Published var weakestCategory: WeaknessCategory?
    @Published var strongestCategory: WeaknessCategory?

    private let historyService = QuestionHistoryService()
    private let weaknessService = WeaknessAnalysisService()

    func load() {
        stats = historyService.calculateLearningStats()

        let entries = historyService.fetch()
        let categories = weaknessService.analyzeWeaknessPatterns(from: entries)
        allCategories = categories

        // Weakest: lowest accuracy with at least 1 incorrect (already sorted weakest-first)
        weakestCategory = categories.first(where: { $0.incorrectCount > 0 })

        // Strongest: highest accuracy with at least 2 attempts (sorted weakest-first, so last)
        strongestCategory = categories
            .filter { $0.totalAttempts >= 2 }
            .last
    }
}
