// QuestionLinkerService.swift
import Foundation

final class QuestionLinkerService: QuestionLinkerServiceProtocol {
    private let localDataService: LocalDataServiceProtocol

    init(localDataService: LocalDataServiceProtocol = LocalDataService()) {
        self.localDataService = localDataService
    }

    func getRelatedQuestions(for signID: String, limit: Int = 5) async throws -> [Question] {
        // Load all questions
        let allQuestions = try await localDataService.loadQuestions()

        // Filter by signID
        let relatedQuestions = allQuestions.filter { $0.signID == signID }

        // Limit results
        return Array(relatedQuestions.prefix(limit))
    }

    func getSignMetadata(signID: String) async throws -> TrafficSign? {
        let signs = try await localDataService.loadTrafficSigns()
        return signs.first { $0.id == signID }
    }
}

// MARK: - LocalDataService Protocol

// MARK: - LocalDataService Implementation
