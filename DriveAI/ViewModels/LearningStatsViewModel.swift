import Foundation

class LearningStatsViewModel: ObservableObject {
    @Published var stats: LearningStats = .empty

    private let historyService = QuestionHistoryService()

    func load() {
        stats = historyService.calculateLearningStats()
    }
}
