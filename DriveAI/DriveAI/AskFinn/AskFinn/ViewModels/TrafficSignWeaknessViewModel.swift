import Foundation
import Combine

class TrafficSignWeaknessViewModel: ObservableObject {
    @Published var topWeakCategories: [TrafficSignWeaknessCategory] = []
    @Published var allCategories: [TrafficSignWeaknessCategory] = []

    private let service = TrafficSignHistoryService()

    func load() {
        let entries = service.fetch()
        let analyser = TrafficSignWeaknessAnalysisService()
        allCategories = analyser.analyzeWeaknessPatterns(from: entries)
        topWeakCategories = analyser.topWeakCategories(from: entries, limit: 3)
    }
}
