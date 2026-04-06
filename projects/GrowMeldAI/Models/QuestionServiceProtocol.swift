// Core/Services/QuestionService.swift
import Foundation

protocol QuestionServiceProtocol: Actor {
    func fetchQuestions(category: Category?, limit: Int?) async throws -> [Question]
    func checkAnswer(_ answerID: String, for question: Question) -> Bool
    func fetchCategories() async throws -> [Category]
}

actor QuestionService: QuestionServiceProtocol {
    private let dataService: LocalDataService
    
    init(dataService: LocalDataService) {
        self.dataService = dataService
    }
    
    func fetchQuestions(category: Category? = nil, limit: Int? = nil) async throws -> [Question] {
        var questions = try await dataService.fetchQuestions(category: category)
        
        if let limit = limit {
            questions = Array(questions.prefix(limit))
        }
        
        return questions.shuffled()
    }
    
    func checkAnswer(_ answerID: String, for question: Question) -> Bool {
        return answerID == question.correctAnswerID
    }
    
    func fetchCategories() async throws -> [Category] {
        return try await dataService.fetchCategories()
    }
}

// Core/Services/AnalyticsService.swift
import Foundation

struct AnswerRecord: Codable {
    let id: UUID
    let questionID: String
    let correct: Bool
    let categoryID: String
    let responseTime: TimeInterval
    let timestamp: Date
    
    init(
        questionID: String,
        correct: Bool,
        categoryID: String,
        responseTime: TimeInterval,
        timestamp: Date = Date()
    ) {
        self.id = UUID()
        self.questionID = questionID
        self.correct = correct
        self.categoryID = categoryID
        self.responseTime = responseTime
        self.timestamp = timestamp
    }
}

@MainActor
final class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    @Published private(set) var answerHistory: [AnswerRecord] = []
    
    private let storageKey = "driveai_answers"
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        loadAnswerHistory()
    }
    
    func recordAnswer(
        questionID: String,
        correct: Bool,
        categoryID: String,
        responseTime: TimeInterval
    ) async {
        let record = AnswerRecord(
            questionID: questionID,
            correct: correct,
            categoryID: categoryID,
            responseTime: responseTime
        )
        
        answerHistory.append(record)
        
        // Persist to disk
        do {
            try persistAnswerHistory()
        } catch {
            print("⚠️ Failed to persist answer history: \(error)")
        }
    }
    
    func getStats(for categoryID: String) -> (correct: Int, total: Int) {
        let filtered = answerHistory.filter { $0.categoryID == categoryID }
        let correct = filtered.filter { $0.correct }.count
        return (correct, filtered.count)
    }
    
    private func persistAnswerHistory() throws {
        let data = try encoder.encode(answerHistory)
        let documentsURL = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let fileURL = documentsURL.appendingPathComponent(storageKey)
        try data.write(to: fileURL)
    }
    
    private func loadAnswerHistory() {
        let documentsURL = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        
        guard let fileURL = documentsURL?.appendingPathComponent(storageKey),
              fileManager.fileExists(atPath: fileURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            answerHistory = try decoder.decode([AnswerRecord].self, from: data)
        } catch {
            print("⚠️ Failed to load answer history: \(error)")
        }
    }
}

// Core/Services/LocalDataService.swift
import Foundation

enum LocalDataError: LocalizedError {
    case fileNotFound
    case decodingFailed(String)
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Fragen-Datei nicht gefunden"
        case .decodingFailed(let detail):
            return "Fragen konnten nicht geladen werden: \(detail)"
        case .databaseError(let msg):
            return msg
        }
    }
}
