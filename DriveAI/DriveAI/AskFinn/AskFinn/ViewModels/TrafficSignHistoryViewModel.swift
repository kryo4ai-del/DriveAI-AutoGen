import Foundation
import Combine

class TrafficSignHistoryViewModel: ObservableObject {
    @Published var entries: [TrafficSignHistoryEntry] = []

    private let service = TrafficSignHistoryService()

    func load() {
        entries = service.fetch()
    }

    func clearHistory() {
        service.clear()
        entries = []
    }
}
