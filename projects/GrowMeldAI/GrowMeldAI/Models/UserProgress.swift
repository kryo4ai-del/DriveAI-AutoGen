import Foundation

struct UserProgress: Codable, Equatable {
    let categoryId: String
    private(set) var totalAnswered: Int = 0
    private(set) var correctAnswers: Int = 0
    var lastAnsweredDate: Date = Date()
    var reviewSchedules: [String: ReviewSchedule] = [:]
    
    // Immutable update pattern
    mutating func recordAnswer(questionId: String, isCorrect: Bool) {
        totalAnswered += 1
        if isCorrect {
            correctAnswers += 1
        }
        let schedule = ReviewSchedule.schedule(for: isCorrect)
        reviewSchedules[questionId] = schedule
    }
}

// Service layer handles concurrency
@MainActor // Serialize all progress updates on main thread
final class ProgressTrackingServiceImpl: ProgressTrackingServiceProtocol {
    private let dataService: LocalDataServiceProtocol
    private let persistenceManager: UserDefaultsManager
    
    init(dataService: LocalDataServiceProtocol, persistenceManager: UserDefaultsManager) {
        self.dataService = dataService
        self.persistenceManager = persistenceManager
    }
    
    func recordAnswer(questionId: String, categoryId: String, isCorrect: Bool) async throws {
        var progress = try await dataService.fetchProgress(categoryId: categoryId)
        progress.recordAnswer(questionId: questionId, isCorrect: isCorrect)
        try await dataService.saveProgress(progress)
        
        persistenceManager.updateLastActiveDate()
    }
}