import Foundation

class TrafficSignHistoryService {

    private let storageKey = "driveai_traffic_sign_history"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Save

    func save(_ entry: TrafficSignHistoryEntry) {
        var history = fetch()
        history.insert(entry, at: 0)   // newest first
        if let data = try? encoder.encode(history) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func save(from result: TrafficSignRecognitionResult) {
        save(TrafficSignHistoryEntry(from: result))
    }

    // MARK: - Fetch

    func fetch() -> [TrafficSignHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let history = try? decoder.decode([TrafficSignHistoryEntry].self, from: data) else {
            return []
        }
        return history
    }

    // MARK: - Clear

    func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // MARK: - Weakness analysis

    func analyzeTrafficSignWeaknessPatterns() -> [TrafficSignWeaknessCategory] {
        TrafficSignWeaknessAnalysisService().analyzeWeaknessPatterns(from: fetch())
    }

    func topWeakSignCategories(limit: Int = 3) -> [TrafficSignWeaknessCategory] {
        TrafficSignWeaknessAnalysisService().topWeakCategories(from: fetch(), limit: limit)
    }

    // MARK: - Statistics

    func calculateTrafficSignStats() -> TrafficSignStats {
        let entries = fetch()
        guard !entries.isEmpty else { return .empty }

        let learningEntries = entries.filter { $0.wasLearningMode }
        let correct   = learningEntries.filter { $0.userAnswerCorrect == true }.count
        let incorrect = learningEntries.filter { $0.userAnswerCorrect == false }.count
        let avgConf   = entries.map { $0.confidence }.reduce(0, +) / Double(entries.count)

        return TrafficSignStats(
            totalSignsReviewed: entries.count,
            correctAnswers: correct,
            incorrectAnswers: incorrect,
            averageConfidence: avgConf
        )
    }
}
