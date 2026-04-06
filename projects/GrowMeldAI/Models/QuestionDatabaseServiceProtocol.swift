// QuestionDatabaseService.swift
import Foundation
import Combine

/// Protocol defining the question database service contract
protocol QuestionDatabaseServiceProtocol {
    func loadQuestions() async throws -> [Question]
    func saveQuestions(_ questions: [Question]) async throws
    func getQuestionCount() async throws -> Int
    func getQuestion(byId id: String) async throws -> Question?
    func resetDatabase() async throws
}

/// Concrete implementation of the question database service
final class QuestionDatabaseService: QuestionDatabaseServiceProtocol {
    private let dataService: LocalDataServiceProtocol
    private let filename: String
    private let queue = DispatchQueue(label: "com.driveai.questionService", qos: .utility)

    init(dataService: LocalDataServiceProtocol = LocalDataService(),
         filename: String = "questions.json") {
        self.dataService = dataService
        self.filename = filename
    }

    // MARK: - Public Methods

    func loadQuestions() async throws -> [Question] {
        try await dataService.load(filename)
    }

    func saveQuestions(_ questions: [Question]) async throws {
        try await dataService.save(questions, to: filename)
    }

    func getQuestionCount() async throws -> Int {
        let questions = try await loadQuestions()
        return questions.count
    }

    func getQuestion(byId id: String) async throws -> Question? {
        let questions = try await loadQuestions()
        return questions.first { $0.id == id }
    }

    func resetDatabase() async throws {
        try await dataService.delete(filename)
    }

    // MARK: - Question Validation

    func validateQuestions(_ questions: [Question]) throws {
        let uniqueIds = Set(questions.map { $0.id })
        guard uniqueIds.count == questions.count else {
            throw DataServiceError.invalidData
        }

        for question in questions {
            try validateQuestion(question)
        }
    }

    private func validateQuestion(_ question: Question) throws {
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

// MARK: - Question Model

// MARK: - Preview Provider
#if DEBUG
struct QuestionDatabaseService_Previews: PreviewProvider {
    static var previews: some View {
        Text("Question Database Service")
            .padding()
    }
}
#endif