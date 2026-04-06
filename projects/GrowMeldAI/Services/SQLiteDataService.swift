import Foundation

final class SQLiteDataService {
    private let dbURL: URL

    init(dbURL: URL) {
        self.dbURL = dbURL
    }

    func saveQuestionProgress(_ progress: QuestionProgress) {
        let fileURL = dbURL.appendingPathComponent("question_progress.json")
        var all = loadAllProgress()
        all[progress.questionId] = progress
        if let data = try? JSONEncoder().encode(all) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    func loadQuestionProgress(for questionId: String) -> QuestionProgress? {
        return loadAllProgress()[questionId]
    }

    func deleteAllUserData() {
        let fileURL = dbURL.appendingPathComponent("question_progress.json")
        try? FileManager.default.removeItem(at: fileURL)
    }

    private func loadAllProgress() -> [String: QuestionProgress] {
        let fileURL = dbURL.appendingPathComponent("question_progress.json")
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([String: QuestionProgress].self, from: data) else {
            return [:]
        }
        return decoded
    }
}

struct QuestionProgress: Codable, Identifiable {
    let id: String
    let questionId: String
    let isCorrect: Bool
    let answeredAt: Date

    init(id: String = UUID().uuidString,
         questionId: String,
         isCorrect: Bool,
         answeredAt: Date = Date()) {
        self.id = id
        self.questionId = questionId
        self.isCorrect = isCorrect
        self.answeredAt = answeredAt
    }
}