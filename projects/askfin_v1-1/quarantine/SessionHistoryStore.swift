import Foundation
import Combine

final class SessionHistoryStore: ObservableObject {
    @Published private(set) var results: [SimulationResult] = []

    private let key = "driveai_session_history"
    private let defaults = UserDefaults.standard

    init() {
        load()
    }

    func addResult(_ result: SimulationResult) {
        results.insert(result, at: 0)
        save()
    }

    func addTrainingResult(correct: Int, total: Int, duration: TimeInterval) {
        let fehlerpunkte = total - correct
        let result = SimulationResult.build(
            simulationID: UUID(),
            completedAt: Date(),
            totalFehlerpunkte: fehlerpunkte,
            fehlerpunkteByTopic: [:],
            vorfahrtErrorCount: 0,
            timeTaken: duration,
            enforceInstantFail: false,
            readinessScoreAtTime: total > 0 ? Int(Double(correct) / Double(total) * 100) : 0,
            readinessDelta: nil,
            questionResults: []
        )
        results.insert(result, at: 0)
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SimulationResult].self, from: data)
        else { return }
        results = decoded
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(results) {
            defaults.set(encoded, forKey: key)
        }
    }
}
