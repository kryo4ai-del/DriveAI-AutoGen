import Foundation
import Combine

@MainActor
final class UserSession: ObservableObject {
    @Published var userProgress: [UUID: QuizProgress] = [:]
    @Published var recentQuizzes: [UUID] = []
    
    private let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService = .shared) {
        self.persistenceService = persistenceService
        loadProgress()
    }
    
    func loadProgress() {
        userProgress = persistenceService.loadAllProgress()
        recentQuizzes = persistenceService.loadRecentQuizzes()
    }
    
    func saveQuizAttempt(_ attempt: QuizAttempt, for quizId: UUID) throws {
        try attempt.validate()
        
        var progress = userProgress[quizId] ?? QuizProgress(
            id: UUID(),
            quizId: quizId,
            attempts: []
        )
        
        try progress.addAttempt(attempt)
        userProgress[quizId] = progress
        
        persistenceService.save(progress)
        updateRecentQuizzes(quizId)
    }
    
    private func updateRecentQuizzes(_ quizId: UUID) {
        recentQuizzes.removeAll { $0 == quizId }
        recentQuizzes.insert(quizId, at: 0)
        
        if recentQuizzes.count > 10 {
            recentQuizzes.removeLast()
        }
        
        persistenceService.saveRecentQuizzes(recentQuizzes)
    }
}