import Foundation
import Combine

class QuestionHistoryViewModel: ObservableObject {

    @Published var entries: [QuestionHistoryEntry] = []
    @Published var filter: HistoryFilter = .all

    private let service = QuestionHistoryService()

    enum HistoryFilter {
        case all, correct, incorrect
    }

    var filteredEntries: [QuestionHistoryEntry] {
        switch filter {
        case .all:       return entries
        case .correct:   return entries.filter { $0.isCorrect }
        case .incorrect: return entries.filter { !$0.isCorrect }
        }
    }

    func load() {
        entries = service.fetch()
    }

    func clearHistory() {
        service.clear()
        entries = []
    }
}
