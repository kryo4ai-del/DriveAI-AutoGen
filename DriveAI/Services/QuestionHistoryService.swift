import Foundation

class QuestionHistoryService {

    private let storageKey = "driveai_question_history"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Save
    func save(_ entry: QuestionHistoryEntry) {
        var history = fetch()
        history.insert(entry, at: 0) // newest first
        if let data = try? encoder.encode(history) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // MARK: - Fetch
    func fetch() -> [QuestionHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let history = try? decoder.decode([QuestionHistoryEntry].self, from: data) else {
            return []
        }
        return history
    }

    // MARK: - Clear
    func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
