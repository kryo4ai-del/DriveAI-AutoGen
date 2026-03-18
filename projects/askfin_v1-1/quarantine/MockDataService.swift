import Foundation
@testable import DriveAI

class MockDataService: DataServiceProtocol {
    var mockQuestions: [Question] = []
    var mockAnswerHistory: [UserAnswer] = []
    var shouldThrowError = false
    
    func fetchAllQuestions() async throws -> [Question] {
        if shouldThrowError {
            throw ReadinessError.dataUnavailable
        }
        return mockQuestions
    }
    
    func fetchUserAnswerHistory() async throws -> [UserAnswer] {
        if shouldThrowError {
            throw ReadinessError.dataUnavailable
        }
        return mockAnswerHistory
    }
    
    func fetchCategoryQuestions(for categoryId: String) async throws -> [Question] {
        if shouldThrowError {
            throw ReadinessError.dataUnavailable
        }
        return mockQuestions.filter { $0.category == categoryId }
    }
}

class MockExamDateManager: ExamDateManageable {
    var mockDaysToExam: Int?
    var mockExamDate: Date?
    
    func daysUntilExam() -> Int? {
        mockDaysToExam
    }
    
    func examDate() -> Date? {
        mockExamDate
    }
    
    func setExamDate(_ date: Date) {
        mockExamDate = date
    }
}