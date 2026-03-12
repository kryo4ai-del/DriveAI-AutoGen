import Foundation
import Combine

class LearningInsightsViewModel: ObservableObject {
    @Published var topWeakCategories: [WeaknessCategory] = []
    @Published var allCategories: [WeaknessCategory] = []

    private let historyService = QuestionHistoryService()

    func load() {
        let entries = historyService.fetch()
        let service = WeaknessAnalysisService()
        allCategories = service.analyzeWeaknessPatterns(from: entries)
        topWeakCategories = service.topWeakCategories(from: entries, limit: 3)
    }
}
