import Foundation

protocol QuestionDatabaseServiceProtocol {
    func loadQuestions() async throws -> [QuizQuestion]
    func saveQuestions(_ questions: [QuizQuestion]) async throws
    func getQuestionCount() async throws -> Int
    func getQuestion(byId id: String) async throws -> QuizQuestion?
    func resetDatabase() async throws
}

final class QuestionDatabaseService: QuestionDatabaseServiceProtocol {
    private let dataService: LocalDataServiceProtocol
    private let filename: String

    init(dataService: LocalDataServiceProtocol = LocalDataService(),
         filename: String = "questions.json") {
        self.dataService = dataService
        self.filename = filename
    }

    func loadQuestions() async throws -> [QuizQuestion] {
        try await dataService.load(filename)
    }

    func saveQuestions(_ questions: [QuizQuestion]) async throws {
        try await dataService.save(questions, to: filename)
    }

    func getQuestionCount() async throws -> Int {
        let questions = try await loadQuestions()
        return questions.count
    }

    func getQuestion(byId id: String) async throws -> QuizQuestion? {
        let questions = try await loadQuestions()
        return questions.first { $0.id == id }
    }

    func resetDatabase() async throws {
        try await dataService.delete(filename)
    }

    func validateQuestions(_ questions: [QuizQuestion]) throws {
        let uniqueIds = Set(questions.map { $0.id })
        guard uniqueIds.count == questions.count else {
            throw DataServiceError.invalidData
        }
        for question in questions {
            try validateQuestion(question)
        }
    }

    private func validateQuestion(_ question: QuizQuestion) throws {
        guard !question.id.isEmpty else {
            throw DataServiceError.invalidData
        }
        guard !question.text.isEmpty else {
            throw DataServiceError.invalidData
        }
        guard !question.answers.isEmpty else {
            throw DataServiceError.invalidData
        }
        guard question.correctAnswerIndex < question.answers.count else {
            throw DataServiceError.invalidData
        }
    }
}