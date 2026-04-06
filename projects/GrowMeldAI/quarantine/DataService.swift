// Services/Data/DataService.swift
import Foundation

protocol DataService: Sendable {
    nonisolated func fetchAllCategories() async throws -> [Category]
    nonisolated func fetchQuestions(for categoryID: String) async throws -> [Question]
    nonisolated func fetchQuestion(by id: String) async throws -> Question?
    nonisolated func fetchUserProgress() async throws -> UserProgress
    nonisolated func saveUserAnswer(_ answer: UserAnswer) async throws
    nonisolated func saveExamResult(_ result: ExamResult) async throws
}

// MARK: - JSON Implementation
@MainActor

// MARK: - Mock for Testing
final class MockDataService: DataService {
    var mockQuestions: [Question] = []
    var mockCategories: [Category] = []
    var shouldFail = false
    
    nonisolated func fetchAllCategories() async throws -> [Category] {
        if shouldFail { throw DataServiceError.mockError }
        return mockCategories
    }
    
    nonisolated func fetchQuestions(for categoryID: String) async throws -> [Question] {
        if shouldFail { throw DataServiceError.mockError }
        return mockQuestions.filter { $0.categoryID == categoryID }
    }
    
    nonisolated func fetchQuestion(by id: String) async throws -> Question? {
        if shouldFail { throw DataServiceError.mockError }
        return mockQuestions.first { $0.id == id }
    }
    
    nonisolated func fetchUserProgress() async throws -> UserProgress {
        if shouldFail { throw DataServiceError.mockError }
        return UserProgress.empty
    }
    
    nonisolated func saveUserAnswer(_ answer: UserAnswer) async throws {
        if shouldFail { throw DataServiceError.mockError }
    }
    
    nonisolated func saveExamResult(_ result: ExamResult) async throws {
        if shouldFail { throw DataServiceError.mockError }
    }
}

enum DataServiceError: LocalizedError {
    case categoryNotFound
    case questionNotFound
    case loadTimeout
    case mockError
    
    var errorDescription: String? {
        switch self {
        case .categoryNotFound:
            return "Category not found"
        case .questionNotFound:
            return "Question not found"
        case .loadTimeout:
            return "Data loading timed out"
        case .mockError:
            return "Mock error for testing"
        }
    }
}