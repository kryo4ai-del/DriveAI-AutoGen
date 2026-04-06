import Foundation

class MockQuestionService: LocalDataService {
    var mockQuestions: [Question] = []
    var mockCategories: [String] = []
    var shouldThrowError = false
    var errorToThrow: LocalDataError = .decodingError
    
    var fetchQuestionsByCategoryCalled = false
    var lastRequestedCategory: String?
    var expectedCategory: String?
    
    func fetchAllQuestions() async throws -> [Question] {
        if shouldThrowError {
            throw errorToThrow
        }
        return mockQuestions.isEmpty ? [Question.mock] : mockQuestions
    }
    
    func fetchQuestionsByCategory(_ category: String) async throws -> [Question] {
        fetchQuestionsByCategoryCalled = true
        lastRequestedCategory = category
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        let filtered = mockQuestions.filter { $0.category == category }
        guard !filtered.isEmpty else {
            throw LocalDataError.categoryNotFound
        }
        return filtered
    }
    
    func fetchCategories() async throws -> [String] {
        if shouldThrowError {
            throw errorToThrow
        }
        return mockCategories.isEmpty
            ? Set(mockQuestions.map { $0.category }).sorted()
            : mockCategories
    }
    
    func saveProgress(_ result: QuizResult) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        // Mock implementation
    }
}