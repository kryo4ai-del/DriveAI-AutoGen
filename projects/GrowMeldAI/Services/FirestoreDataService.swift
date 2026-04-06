import Foundation

// Local-only implementation — no Firebase dependency
// All data is stored on-device using LocalDataService

struct QuestionProgress: Codable {
    let id: String
    let questionID: String
    let userAnswer: String
    let isCorrect: Bool
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        questionID: String,
        userAnswer: String,
        isCorrect: Bool,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.questionID = questionID
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
        self.timestamp = timestamp
    }
}

protocol LocalDataService {
    func saveQuestionProgress(_ progress: QuestionProgress) async throws
    func loadQuestionProgress() async throws -> [QuestionProgress]
    func deleteAllQuestionProgress() async throws
}

final class FirestoreDataService: LocalDataService {

    // MARK: - Private Storage

    private let fileManager: FileManager = .default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let fileName = "question_progress.json"

    private var storageURL: URL {
        get throws {
            let docs = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            return docs.appendingPathComponent(fileName)
        }
    }

    // MARK: - Init

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - LocalDataService

    func saveQuestionProgress(_ progress: QuestionProgress) async throws {
        var existing = (try? await loadQuestionProgress()) ?? []

        if let index = existing.firstIndex(where: { $0.id == progress.id }) {
            existing[index] = progress
        } else {
            existing.append(progress)
        }

        let data = try encoder.encode(existing)
        let url = try storageURL
        try data.write(to: url, options: .atomic)
    }

    func loadQuestionProgress() async throws -> [QuestionProgress] {
        let url = try storageURL

        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode([QuestionProgress].self, from: data)
    }

    func deleteAllQuestionProgress() async throws {
        let url = try storageURL

        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
}