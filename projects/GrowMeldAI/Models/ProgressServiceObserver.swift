// Services/Progress/ProgressService.swift
actor ProgressService: Sendable {
    private var userProgress: UserProgress
    private let persistence: ProgressPersistence
    private let logger = LoggingService.shared
    
    // MARK: - Initialization
    init(persistence: ProgressPersistence) {
        self.persistence = persistence
        // Load async in separate task (don't block init)
        self.userProgress = try? UserProgress(userID: UUID().uuidString) ?? 
            UserProgress(userID: UUID().uuidString)
    }
    
    // MARK: - Public interface (nonisolated, async-safe)
    nonisolated func recordAnswer(_ answer: SessionAnswer) async throws {
        try await _recordIsolated(answer)
    }
    
    nonisolated func saveProgress() async throws {
        try await persistence.save(userProgress)
        logger.log(level: .debug, message: "Progress persisted")
    }
    
    nonisolated func getOverallStats() async -> UserStatistics {
        let snapshot = userProgress
        return UserStatistics(
            totalQuestionsAnswered: snapshot.sessionAnswers.count,
            overallScore: snapshot.getOverallScore(),
            categoryScores: snapshot.categoryProgresses,
            daysUntilExam: snapshot.daysUntilExam
        )
    }
    
    nonisolated func getProgress(forCategory categoryID: CategoryID) async -> CategoryProgress? {
        userProgress.getProgressForCategory(categoryID)
    }
    
    nonisolated func resetProgress() async throws {
        try await _resetIsolated()
        try await saveProgress()
    }
    
    // MARK: - Private isolated mutations
    private func _recordIsolated(_ answer: SessionAnswer) throws {
        var progress = userProgress
        progress.recordAnswer(answer)
        userProgress = progress
        logger.log(level: .debug, message: "Answer recorded for Q\(answer.questionID)")
    }
    
    private func _resetIsolated() {
        userProgress.sessionAnswers.removeAll()
        userProgress.categoryProgresses.removeAll()
    }
}

// MARK: - Observable wrapper for SwiftUI
@MainActor
final class ProgressServiceObserver: ObservableObject {
    @Published private(set) var stats: UserStatistics = .empty
    @Published var errorMessage: String?
    
    private let service: ProgressService
    private let refreshInterval: TimeInterval = 2.0
    
    init(service: ProgressService) {
        self.service = service
        Task {
            await loadInitialStats()
        }
    }
    
    // MARK: - Public actions
    func recordAnswerAndUpdate(_ answer: SessionAnswer) async {
        do {
            try await service.recordAnswer(answer)
            try await service.saveProgress()
            await loadInitialStats()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Fehler beim Speichern"
            logger.log(level: .error, message: "Record answer failed", error: error)
        }
    }
    
    // MARK: - Private
    private func loadInitialStats() async {
        stats = await service.getOverallStats()
    }
}