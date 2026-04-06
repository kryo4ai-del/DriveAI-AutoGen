import Foundation

protocol ProgressRepository {
    func loadProgress() -> UserProgress
    func saveProgress(_ progress: UserProgress)
    func recordAnswer(categoryId: String, isCorrect: Bool)
    func saveExamResult(_ result: ExamResult)
}

struct UserProgress: Codable {
    let totalAnswered: Int
    let totalCorrect: Int
    let lastUpdated: Date

    init(totalAnswered: Int = 0, totalCorrect: Int = 0, lastUpdated: Date = Date()) {
        self.totalAnswered = totalAnswered
        self.totalCorrect = totalCorrect
        self.lastUpdated = lastUpdated
    }
}

struct ExamResult: Codable {
    let id: String
    let score: Int
    let totalQuestions: Int
    let date: Date

    init(id: String = UUID().uuidString, score: Int, totalQuestions: Int, date: Date = Date()) {
        self.id = id
        self.score = score
        self.totalQuestions = totalQuestions
        self.date = date
    }
}

final class LocalProgressRepository: ProgressRepository {
    private let progressKey = "com.growmeldai.progress"
    private let examResultsKey = "com.growmeldai.examResults"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadProgress() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let progress = try? decoder.decode(UserProgress.self, from: data) else {
            return UserProgress()
        }
        return progress
    }

    func saveProgress(_ progress: UserProgress) {
        guard let data = try? encoder.encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: progressKey)
    }

    func recordAnswer(categoryId: String, isCorrect: Bool) {
        let current = loadProgress()
        let updated = UserProgress(
            totalAnswered: current.totalAnswered + 1,
            totalCorrect: current.totalCorrect + (isCorrect ? 1 : 0),
            lastUpdated: Date()
        )
        saveProgress(updated)
    }

    func saveExamResult(_ result: ExamResult) {
        var results = loadExamResults()
        results.append(result)
        guard let data = try? encoder.encode(results) else { return }
        UserDefaults.standard.set(data, forKey: examResultsKey)
    }

    private func loadExamResults() -> [ExamResult] {
        guard let data = UserDefaults.standard.data(forKey: examResultsKey),
              let results = try? decoder.decode([ExamResult].self, from: data) else {
            return []
        }
        return results
    }
}