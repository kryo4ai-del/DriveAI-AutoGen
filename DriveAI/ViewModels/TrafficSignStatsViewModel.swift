import Foundation

class TrafficSignStatsViewModel: ObservableObject {
    @Published var stats: TrafficSignStats = .empty

    private let service = TrafficSignHistoryService()

    func load() {
        stats = service.calculateTrafficSignStats()
    }
}
